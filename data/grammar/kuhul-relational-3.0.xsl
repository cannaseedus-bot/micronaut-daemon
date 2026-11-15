<?xml version="1.0" encoding="UTF-8"?>
<!--
  Optional XSLT 3.0 eligibility evaluator for MicronautPatterns.
  Evaluation results are diagnostic evidence, never admission or authorization.
  No utility score, legal verdict, persistence, or Xul commit is produced.
-->
<xsl:stylesheet version="3.0"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:xs="http://www.w3.org/2001/XMLSchema"
                xmlns:k="https://kuhul.dev/"
                exclude-result-prefixes="xs k"
                expand-text="yes">
  <xsl:output method="xml" version="1.0" encoding="UTF-8" indent="yes"/>
  <xsl:variable name="k:phases" as="xs:string*" select="('Pop','Wo','Yax','Sek',&quot;Ch'en&quot;,'Xul')"/>

  <xsl:function name="k:cap" as="element(capability)*">
    <xsl:param name="caps" as="element(capability)*"/><xsl:param name="mu" as="xs:string"/>
    <xsl:sequence select="$caps[@micronaut = $mu]"/>
  </xsl:function>
  <xsl:function name="k:req" as="element(requirement)*">
    <xsl:param name="reqs" as="element(requirement)*"/><xsl:param name="op" as="xs:string"/>
    <xsl:sequence select="$reqs[@op = $op]"/>
  </xsl:function>
  <xsl:function name="k:subset" as="xs:boolean">
    <xsl:param name="a" as="xs:string*"/><xsl:param name="b" as="xs:string*"/>
    <xsl:sequence select="empty($a[not(. = $b)])"/>
  </xsl:function>
  <xsl:function name="k:phase-rank" as="xs:integer?">
    <xsl:param name="phase" as="xs:string?"/>
    <xsl:sequence select="if (exists($phase) and $phase = $k:phases) then index-of($k:phases, $phase)[1] else ()"/>
  </xsl:function>
  <!-- A capability may begin later than minPhase; its upper bound must reach it. -->
  <xsl:function name="k:phase-satisfies" as="xs:boolean">
    <xsl:param name="min-phase" as="xs:string?"/><xsl:param name="phase-scope" as="xs:string?"/>
    <xsl:variable name="required" select="k:phase-rank($min-phase)" as="xs:integer?"/>
    <xsl:variable name="scope" select="normalize-space($phase-scope)"/>
    <xsl:variable name="lower" select="if (contains($scope,'..')) then substring-before($scope,'..') else $scope"/>
    <xsl:variable name="upper" select="if (contains($scope,'..')) then substring-after($scope,'..') else $scope"/>
    <xsl:variable name="lower-rank" select="k:phase-rank($lower)" as="xs:integer?"/>
    <xsl:variable name="available-through" select="k:phase-rank($upper)" as="xs:integer?"/>
    <xsl:sequence select="if (empty($min-phase) or empty($scope)) then true() else exists($required) and exists($lower-rank) and exists($available-through) and $available-through ge $lower-rank and $available-through ge $required"/>
  </xsl:function>
  <xsl:function name="k:req-subset-cap" as="xs:boolean">
    <xsl:param name="requirements" as="element(requirement)*"/><xsl:param name="capability" as="element(capability)?"/>
    <xsl:variable name="cap-domains" as="xs:string*" select="$capability/domain/normalize-space(string())"/>
    <xsl:variable name="cap-ops" as="xs:string*" select="$capability/op/normalize-space(string())"/>
    <xsl:sequence select="exists($capability) and exists($requirements) and k:subset($requirements/@domain/string(), $cap-domains) and (every $r in $requirements satisfies (normalize-space($r/@op) = $cap-ops and k:phase-satisfies(string($r/@minPhase), string($capability/@phaseScope))))"/>
  </xsl:function>
  <xsl:function name="k:eligible-set" as="xs:string*">
    <xsl:param name="caps" as="element(capability)*"/><xsl:param name="reqs" as="element(requirement)*"/><xsl:param name="op" as="xs:string"/>
    <xsl:variable name="requirements" select="k:req($reqs,$op)" as="element(requirement)*"/>
    <xsl:sequence select="distinct-values(for $c in $caps return if (k:req-subset-cap($requirements,$c)) then string($c/@micronaut) else ())"/>
  </xsl:function>
  <xsl:function name="k:is-eligible" as="xs:boolean">
    <xsl:param name="caps" as="element(capability)*"/><xsl:param name="reqs" as="element(requirement)*"/><xsl:param name="mu" as="xs:string"/><xsl:param name="op" as="xs:string"/>
    <xsl:sequence select="$mu = k:eligible-set($caps,$reqs,$op)"/>
  </xsl:function>
  <xsl:function name="k:bridge-missing" as="xs:boolean">
    <xsl:param name="caps" as="element(capability)*"/><xsl:param name="reqs" as="element(requirement)*"/><xsl:param name="bridges" as="element(bridge)*"/><xsl:param name="mu" as="xs:string"/><xsl:param name="op" as="xs:string"/>
    <xsl:variable name="reqs-for-op" select="k:req($reqs,$op)"/>
    <xsl:variable name="primary" select="k:cap($caps,$mu)[1]/domain[1]/normalize-space(string())"/>
    <xsl:sequence select="exists($primary) and exists($reqs-for-op[@domain ne $primary][not(@domain = $bridges[@targetDomain = $primary]/@sourceDomain)])"/>
  </xsl:function>

  <xsl:template match="/">
    <xsl:variable name="caps" as="element(capability)*" select="//capability"/>
    <xsl:variable name="reqs" as="element(requirement)*" select="//requirement"/>
    <xsl:variable name="bridges" as="element(bridge)*" select="//bridge"/>
    <sdm xmlns:k="https://kuhul.dev/">
      <evaluation-contract admission="not-evaluated" source="MicronautPatterns.mml#EligibilityGate" capability-count="{count($caps)}" requirement-count="{count($reqs)}" bridge-count="{count($bridges)}"/>
      <xsl:apply-templates select="graph|node|edge|pattern|capability|corpus|bridge|requirement" mode="emit">
        <xsl:with-param name="caps" select="$caps" tunnel="yes"/><xsl:with-param name="reqs" select="$reqs" tunnel="yes"/><xsl:with-param name="bridges" select="$bridges" tunnel="yes"/>
      </xsl:apply-templates>
    </sdm>
  </xsl:template>
  <xsl:template match="text()"/>
  <xsl:template match="text()" mode="emit"/>
  <xsl:template match="*" mode="emit" priority="-1"/>

  <xsl:template match="graph" mode="emit">
    <graph><xsl:copy-of select="@id|@name|@role|@phase|@version|@provenance"/><xsl:apply-templates select="graph|node|edge|pattern|capability|corpus|bridge|requirement" mode="emit"/></graph>
  </xsl:template>
  <xsl:template match="node" mode="emit">
    <node><xsl:if test="@id"><xsl:attribute name="id" select="@id"/></xsl:if><xsl:attribute name="type" select="if (@type) then @type else 'micronaut'"/><xsl:copy-of select="@category|@phase|@provenance|@version|@scope|@role"/><xsl:apply-templates select="graph|pattern|capability|corpus|bridge|requirement" mode="emit"/></node>
  </xsl:template>
  <xsl:template match="edge" mode="emit">
    <edge isLink="true"><xsl:copy-of select="@id"/><xsl:attribute name="from" select="@source"/><xsl:attribute name="to" select="@target"/><xsl:attribute name="verb" select="if (@verb) then @verb else if (@directed=('false','0')) then '@relate' else '@call'"/><xsl:copy-of select="@directed|@phase|@provenance|@version|@scope|@role"/></edge>
  </xsl:template>
  <xsl:template match="pattern" mode="emit">
    <record kind="Pattern"><xsl:copy-of select="@id|@version|@matcher|@captures|@scope|@provenance|@phase"/><xsl:apply-templates select="capture" mode="capture"/></record>
  </xsl:template>
  <xsl:template match="capture" mode="capture"><capture><xsl:copy-of select="@name|@type|@scope|@sourceRef|@phase"/></capture></xsl:template>
  <xsl:template match="capability" mode="emit">
    <xsl:param name="caps" tunnel="yes" as="element(capability)*"/><xsl:param name="reqs" tunnel="yes" as="element(requirement)*"/>
    <xsl:variable name="mu" select="string(@micronaut)"/><record kind="Capability" admission="not-evaluated"><xsl:copy-of select="@micronaut|@phaseScope|@provenance|@phase"/><xsl:apply-templates select="domain|op" mode="capability-item"/><xsl:variable name="eligible-ops" as="xs:string*" select="distinct-values($reqs/@op/string())[k:is-eligible($caps,$reqs,$mu,.)]"/><xsl:if test="exists($eligible-ops)"><eligible-ops-evaluated><xsl:for-each select="$eligible-ops"><op>{.}</op></xsl:for-each></eligible-ops-evaluated></xsl:if></record>
  </xsl:template>
  <xsl:template match="domain|op" mode="capability-item"><xsl:element name="{name()}">{normalize-space(.)}</xsl:element></xsl:template>
  <xsl:template match="corpus" mode="emit"><record kind="CorpusBinding"><xsl:copy-of select="@domain|@keyPrefix|@corpusPath|@micronaut|@entryCount|@phase|@provenance"/></record></xsl:template>
  <xsl:template match="bridge" mode="emit"><record kind="Bridge"><xsl:copy-of select="@sourceDomain|@targetDomain|@admissionRef|@provenance"/></record></xsl:template>
  <xsl:template match="requirement" mode="emit">
    <xsl:param name="caps" tunnel="yes" as="element(capability)*"/><xsl:param name="reqs" tunnel="yes" as="element(requirement)*"/><xsl:param name="bridges" tunnel="yes" as="element(bridge)*"/>
    <xsl:variable name="op" select="string(@op)"/><xsl:variable name="set" as="xs:string*" select="k:eligible-set($caps,$reqs,$op)"/>
    <record kind="Requirement" admission="not-evaluated"><xsl:copy-of select="@op|@domain|@minPhase|@provenance"/><xsl:choose><xsl:when test="exists($set)"><xsl:attribute name="eligible-evaluated">true</xsl:attribute><xsl:attribute name="eligible-set-evaluated" select="string-join($set,' ')"/></xsl:when><xsl:otherwise><xsl:attribute name="eligible-evaluated">false</xsl:attribute><xsl:attribute name="dispatch_block_reason">MISS_capability</xsl:attribute></xsl:otherwise></xsl:choose><xsl:for-each select="$set"><xsl:variable name="mu" select="."/><xsl:if test="k:bridge-missing($caps,$reqs,$bridges,$mu,$op)"><bridge-missing-evaluated micronaut="{$mu}" reason="MISS_bridge" op="{$op}"/></xsl:if></xsl:for-each></record>
  </xsl:template>
</xsl:stylesheet>
