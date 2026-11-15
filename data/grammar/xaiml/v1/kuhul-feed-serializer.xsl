<?xml version="1.0" encoding="UTF-8"?>
<!--
  K'UHUL feed v1 serializer.

  Input: one XML document containing exactly one <track id="..."
  grammar_ref="..." vector_field_ref="..."/> and zero or more sibling
  <trigram track="..." pattern="a b c" phase="..." fold_ref="..."/>.
  Trigrams may instead carry exactly three <atom> children, which permits
  literal spaces inside an atom without confusing them with separators.

  Output: canonical JSON with a digest-input helper and placeholder digest.
  The thin Python wrapper hashes the exact helper bytes, inserts the digest,
  removes the helper, and writes final canonical JSON/BSON/CBOR.
  Serialization contributes data only; it never admits or authorizes items.
-->
<xsl:stylesheet version="3.0"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:xs="http://www.w3.org/2001/XMLSchema"
                xmlns:map="http://www.w3.org/2005/xpath-functions/map"
                xmlns:array="http://www.w3.org/2005/xpath-functions/array"
                xmlns:k="https://kuhul.dev/feed"
                exclude-result-prefixes="xs map array k"
                expand-text="yes">
  <xsl:output method="text" encoding="UTF-8"/>
  <xsl:param name="generated-at" as="xs:dateTime?" select="()"/>

  <!-- The phase table is supplied by the caller from the one shared source
       (micronaut/phase_registry.py, backed by the semantic registry). This
       stylesheet deliberately carries no copy, so a phase code or role cannot
       go stale here. Run it through tools/kuhul_feed_serializer.py, which sets
       the parameter; a bare transform fails instead of guessing a table.

       Descriptive data only. This inventory is never consulted to authorize an
       operator; XCFE admission remains a separate runtime step. -->
  <xsl:param name="phase-table" as="xs:string" required="yes"/>
  <xsl:variable name="k:phase-descriptors" as="map(*)"
    select="parse-json($phase-table)"/>
  <xsl:variable name="k:hex" as="xs:string" select="'0123456789ABCDEF'"/>

  <xsl:function name="k:percent-byte" as="xs:string">
    <xsl:param name="n" as="xs:integer"/>
    <xsl:sequence select="'%' || substring($k:hex, ($n idiv 16) + 1, 1)
                                || substring($k:hex, ($n mod 16) + 1, 1)"/>
  </xsl:function>

  <xsl:function name="k:escape-component" as="xs:string">
    <xsl:param name="value" as="xs:string"/>
    <xsl:sequence select="string-join(
      for $cp in string-to-codepoints($value)
      return
        if ($cp = (32, 35, 37, 64)) then k:percent-byte($cp)
        else if (($cp ge 65 and $cp le 90) or ($cp ge 97 and $cp le 122)
                 or ($cp ge 48 and $cp le 57) or $cp = (95, 45, 46, 39, 42, 181))
             then codepoints-to-string($cp)
        else error(QName('https://kuhul.dev/feed', 'INVALID_ADDRESS_COMPONENT'),
                   'Disallowed code point in address component: ' || $cp),
      '')"/>
  </xsl:function>

  <xsl:function name="k:atoms" as="xs:string*">
    <xsl:param name="trigram" as="element()"/>
    <xsl:variable name="atoms" as="xs:string*"
      select="if ($trigram/atom) then $trigram/atom ! string(.)
              else tokenize(normalize-space(string($trigram/@pattern)), '\s+')"/>
    <xsl:if test="count($atoms) ne 3">
      <xsl:message terminate="yes">Trigram must have exactly three atoms; got {count($atoms)}</xsl:message>
    </xsl:if>
    <xsl:if test="some $atom in $atoms satisfies $atom = ''">
      <xsl:message terminate="yes">Trigram atoms must be non-empty</xsl:message>
    </xsl:if>
    <xsl:sequence select="$atoms"/>
  </xsl:function>

  <xsl:function name="k:guid" as="xs:string">
    <xsl:param name="track" as="xs:string"/>
    <xsl:param name="atoms" as="xs:string*"/>
    <xsl:param name="phase" as="xs:string"/>
    <xsl:sequence select="k:escape-component($track) || '#' ||
      string-join($atoms ! k:escape-component(.), ' ') || '@' || $phase"/>
  </xsl:function>

  <xsl:function name="k:json-string" as="xs:string">
    <xsl:param name="value" as="xs:string"/>
    <xsl:variable name="escaped" as="xs:string*" select="
      for $cp in string-to-codepoints($value)
      return
        if ($cp = 34) then '\&quot;'
        else if ($cp = 92) then '\\'
        else if ($cp = 8) then '\b'
        else if ($cp = 9) then '\t'
        else if ($cp = 10) then '\n'
        else if ($cp = 12) then '\f'
        else if ($cp = 13) then '\r'
        else if ($cp lt 32) then '\u00' || lower-case(substring($k:hex, ($cp idiv 16) + 1, 1))
                                  || lower-case(substring($k:hex, ($cp mod 16) + 1, 1))
        else codepoints-to-string($cp)"/>
    <xsl:sequence select="'&quot;' || string-join($escaped, '') || '&quot;'"/>
  </xsl:function>

  <xsl:function name="k:binding" as="map(*)">
    <xsl:param name="binding" as="element(bind)"/>
    <xsl:variable name="source" select="string($binding/@source)"/>
    <xsl:if test="not($binding/@name) or not($source = ('capture','lm_chain','char_overlap','explicit'))">
      <xsl:message terminate="yes">Invalid trigram binding name/source</xsl:message>
    </xsl:if>
    <xsl:if test="$binding/@index and not(matches(string($binding/@index), '^[1-9][0-9]*$'))">
      <xsl:message terminate="yes">Binding index must be a positive integer</xsl:message>
    </xsl:if>
    <xsl:sequence select="map:merge((
      map{'name':string($binding/@name), 'source':$source},
      if ($binding/@index) then map{'index':xs:integer($binding/@index)} else map{}
    ))"/>
  </xsl:function>

  <xsl:function name="k:item" as="map(*)">
    <xsl:param name="trigram" as="element()"/>
    <xsl:param name="feed-track" as="xs:string"/>
    <xsl:variable name="track" select="string($trigram/@track)"/>
    <xsl:variable name="phase" select="string($trigram/@phase)"/>
    <xsl:variable name="atoms" as="xs:string*" select="k:atoms($trigram)"/>
    <xsl:if test="$track ne $feed-track">
      <xsl:message terminate="yes">Trigram track does not match its feed track</xsl:message>
    </xsl:if>
    <xsl:if test="not(map:contains($k:phase-descriptors, $phase))">
      <xsl:message terminate="yes">Invalid K'UHUL phase: {$phase}</xsl:message>
    </xsl:if>
    <xsl:if test="not(normalize-space(string($trigram/@fold_ref)))">
      <xsl:message terminate="yes">Trigram requires a non-empty fold_ref</xsl:message>
    </xsl:if>
    <xsl:variable name="descriptor" select="$k:phase-descriptors($phase)"/>
    <xsl:variable name="guid" select="k:guid($track, $atoms, $phase)"/>
    <xsl:if test="$trigram/@guid and string($trigram/@guid) ne $guid">
      <xsl:message terminate="yes">Trigram GUID does not match its canonical address</xsl:message>
    </xsl:if>
    <xsl:sequence select="map:merge((
      map{
        'guid':$guid,
        'track':$track,
        'pattern':array{$atoms},
        'phase':$phase,
        'phase_code':$descriptor?code,
        'phase_role':$descriptor?role_title,
        'fold_ref':string($trigram/@fold_ref)
      },
      if ($trigram/@binding_ref) then map{'binding_ref':string($trigram/@binding_ref)} else map{},
      if ($trigram/@template_ref) then map{'template_ref':string($trigram/@template_ref)} else map{},
      if ($trigram/bind) then map{'bindings':array{$trigram/bind ! k:binding(.)}} else map{}
    ))"/>
  </xsl:function>

  <xsl:function name="k:json" as="xs:string">
    <xsl:param name="value" as="item()*"/>
    <xsl:choose>
      <xsl:when test="empty($value)">null</xsl:when>
      <xsl:when test="count($value) gt 1">
        <xsl:sequence select="'[' || string-join($value ! k:json(.), ',') || ']'"/>
      </xsl:when>
      <xsl:when test="$value instance of map(*)">
        <xsl:variable name="keys" select="sort(map:keys($value),
          'http://www.w3.org/2005/xpath-functions/collation/codepoint')"/>
        <xsl:sequence select="'{' || string-join(
          for $key in $keys return k:json-string(string($key)) || ':' || k:json($value($key)),
          ',') || '}'"/>
      </xsl:when>
      <xsl:when test="$value instance of array(*)">
        <xsl:sequence select="'[' || string-join(
          for $i in 1 to array:size($value) return k:json($value($i)), ',') || ']'"/>
      </xsl:when>
      <xsl:when test="$value instance of xs:string">
        <xsl:sequence select="k:json-string(string($value))"/>
      </xsl:when>
      <xsl:when test="$value instance of xs:anyAtomicType">
        <xsl:sequence select="serialize($value, map{'method':'json'})"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:sequence select="error(QName('https://kuhul.dev/feed','UNSUPPORTED_JSON_VALUE'),
          'Feed contains a value that is not JSON serializable')"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:function>

  <xsl:template match="/">
    <xsl:variable name="tracks" select="/*/track"/>
    <xsl:if test="count(map:keys($k:phase-descriptors)) ne 6">
      <xsl:message terminate="yes">phase-table must declare exactly six phases</xsl:message>
    </xsl:if>
    <xsl:if test="count($tracks) ne 1">
      <xsl:message terminate="yes">Feed serializer requires exactly one track per input document</xsl:message>
    </xsl:if>
    <xsl:variable name="track" select="$tracks[1]"/>
    <xsl:variable name="track-id" select="string($track/@id)"/>
    <xsl:variable name="grammar" select="string($track/@grammar_ref)"/>
    <xsl:if test="$track-id = '' or $grammar = ''">
      <xsl:message terminate="yes">Track requires non-empty id and grammar_ref</xsl:message>
    </xsl:if>
    <xsl:variable name="items" as="map(*)*"
      select="root($track)/*/trigram[@track = $track-id] ! k:item(., $track-id)"/>
    <xsl:if test="count(distinct-values($items?guid)) ne count($items)">
      <xsl:message terminate="yes">Duplicate canonical trigram guid in one feed</xsl:message>
    </xsl:if>
    <xsl:variable name="instant" as="xs:dateTime"
      select="adjust-dateTime-to-timezone(($generated-at, current-dateTime())[1], xs:dayTimeDuration('PT0H'))"/>
    <xsl:variable name="base" as="map(*)" select="map:merge((
      map{
        'feed':'kuhul.feed/1',
        'track':$track-id,
        'grammar':$grammar,
        'items':array{$items}
      },
      if ($track/@vector_field_ref) then map{'vector_field':string($track/@vector_field_ref)} else map{}
    ))"/>
    <!-- Exact canonical bytes to hash, excluding both generated_at and
         content_digest. This is a helper field removed by the Python wrapper. -->
    <xsl:variable name="digest-input" as="xs:string" select="k:json($base)"/>
    <xsl:variable name="feed" as="map(*)" select="map:merge((
      $base,
      map{
        'generated_at':format-dateTime($instant, '[Y0001]-[M01]-[D01]T[H01]:[m01]:[s01]Z'),
        'content_digest':'sha256:PENDING',
        'content_digest_input':$digest-input
      }
    ))"/>
    <xsl:value-of select="k:json($feed)"/>
  </xsl:template>
</xsl:stylesheet>
