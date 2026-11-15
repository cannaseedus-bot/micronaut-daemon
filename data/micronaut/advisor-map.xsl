<?xml version="1.0" encoding="UTF-8"?>
<!--
  Advisor route map projection — XSLT 3.0 / XPath 3.1.

  Reads kuhul.advisor-map.v1 JSON (compiled by tools/advisor_map.py) and projects
  route families to typed XML route declarations. The source hash travels into each
  output element for traceability; a matching hash alone establishes neither
  authenticity nor authorization.

  Dispatch, XCFE admission, and expert invocation are not performed by this
  transformation. All routes carry dispatch="not_invoked"; cue-only routes also
  carry xcfe-required="true" to signal the host must gate them before use.
-->
<xsl:stylesheet version="3.0"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:xs="http://www.w3.org/2001/XMLSchema"
                xmlns:map="http://www.w3.org/2005/xpath-functions/map"
                xmlns:array="http://www.w3.org/2005/xpath-functions/array"
                xmlns:k="https://kuhul.dev/advisor-map"
                exclude-result-prefixes="xs map array k">

  <xsl:output method="xml" encoding="UTF-8" indent="yes"/>

  <xsl:param name="map-uri" as="xs:string"
             select="'advisor-map.json'"/>

  <xsl:function name="k:bool" as="xs:string">
    <xsl:param name="value" as="item()?"/>
    <xsl:sequence
      select="if ($value instance of xs:boolean and $value) then 'true' else 'false'"/>
  </xsl:function>

  <!-- Sort key: xcfe_gated families before cue_only; then by key string. -->
  <xsl:function name="k:family-sort-key" as="xs:string">
    <xsl:param name="policy"  as="xs:string"/>
    <xsl:param name="key"     as="xs:string"/>
    <xsl:sequence select="concat(if ($policy eq 'cue_only') then '1' else '0', ':', $key)"/>
  </xsl:function>

  <xsl:template match="/">
    <xsl:variable name="m" as="map(*)"
      select="json-doc(resolve-uri($map-uri, static-base-uri()))"/>

    <advisor-map-projection format="kuhul.advisor-map-projection/1"
        source="{$map-uri}"
        source-schema="{$m?source_schema}"
        source-hash="{$m?source_hash}"
        micronaut="{$m?micronaut}"
        authority="projection_only"
        admission="not_evaluated"
        execution="not_invoked">

      <xcfe admission="{$m?xcfe?admission}"
            dispatch="{$m?xcfe?dispatch}"
            route-authority="{$m?xcfe?route_authority}"/>

      <route-families>
        <!-- Iterate in deterministic order: xcfe_gated before cue_only, then alpha. -->
        <xsl:variable name="route-keys" as="xs:string*"
          select="map:keys($m?routes)"/>
        <xsl:for-each select="$route-keys">
          <xsl:sort select="k:family-sort-key(
              $m?routes(current())?dispatch_policy, current())"
            order="ascending" data-type="text"/>
          <xsl:variable name="key"    as="xs:string"  select="."/>
          <xsl:variable name="family" as="map(*)" select="$m?routes($key)"/>
          <xsl:variable name="is-cue" as="xs:boolean"
            select="$family?dispatch_policy eq 'cue_only'"/>

          <route-family key="{$key}"
                        expert="{$family?expert}"
                        phase="{$family?phase}"
                        next="{$family?next}"
                        dispatch-policy="{$family?dispatch_policy}"
                        xcfe-required="true"
                        dispatch="not_invoked"
                        source-hash="{$m?source_hash}">
            <xsl:if test="$is-cue">
              <xsl:attribute name="cue-event"
                select="($family?cue_event, '')[1]"/>
              <xsl:attribute name="cue-type"
                select="($family?cue_type, '')[1]"/>
            </xsl:if>
            <patterns>
              <xsl:for-each select="$family?patterns?*">
                <pattern specificity="{?specificity}"
                         wildcards="{k:bool(?wildcards)}"
                         dispatch-policy="{?dispatch_policy}">{?pattern}</pattern>
              </xsl:for-each>
            </patterns>
          </route-family>
        </xsl:for-each>
      </route-families>

    </advisor-map-projection>
  </xsl:template>

</xsl:stylesheet>
