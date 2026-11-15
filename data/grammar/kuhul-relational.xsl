<?xml version="1.0" encoding="UTF-8"?>
<!--
  Structural + typed-record preserving SDM projection. It preserves Pattern,
  Capability, CorpusBinding, Bridge, and Requirement fields, but does not enforce
  XCFE legality, score utility, evaluate eligibility, verify evidence, or admit
  records. Output is a projection, never an execution grant.
  Top-level graphs remain wrapped in <sdm><graph>...</graph></sdm>.
-->
<xsl:stylesheet version="1.0"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:k="https://kuhul.dev/">
  <xsl:output method="xml" version="1.0" encoding="UTF-8" indent="yes"/>

  <xsl:template match="/">
    <sdm xmlns:k="https://kuhul.dev/">
      <xsl:apply-templates select="graph|node|edge|pattern|capability|corpus|bridge|requirement"/>
    </sdm>
  </xsl:template>

  <!-- Unknown element subtrees are intentionally omitted (safe closed set). -->
  <xsl:template match="*" priority="-1"/>
  <xsl:template match="text()"/>

  <xsl:template match="graph" priority="1">
    <graph>
      <xsl:copy-of select="@id|@name|@role|@phase|@version|@provenance"/>
      <xsl:apply-templates select="node|edge|graph|pattern|capability|corpus|bridge|requirement"/>
    </graph>
  </xsl:template>

  <xsl:template match="node" priority="1">
    <node>
      <xsl:if test="@id"><xsl:attribute name="id"><xsl:value-of select="@id"/></xsl:attribute></xsl:if>
      <xsl:attribute name="type"><xsl:choose><xsl:when test="@type"><xsl:value-of select="@type"/></xsl:when><xsl:otherwise>micronaut</xsl:otherwise></xsl:choose></xsl:attribute>
      <xsl:copy-of select="@category|@phase|@provenance|@version|@scope|@role"/>
      <xsl:apply-templates select="graph|pattern|capability|corpus|bridge|requirement"/>
    </node>
  </xsl:template>

  <xsl:template match="edge" priority="1">
    <edge isLink="true">
      <xsl:copy-of select="@id"/>
      <xsl:attribute name="from"><xsl:value-of select="@source"/></xsl:attribute>
      <xsl:attribute name="to"><xsl:value-of select="@target"/></xsl:attribute>
      <xsl:attribute name="verb"><xsl:choose>
        <xsl:when test="@verb"><xsl:value-of select="@verb"/></xsl:when>
        <xsl:when test="@directed='false' or @directed='0'">@relate</xsl:when>
        <xsl:otherwise>@call</xsl:otherwise>
      </xsl:choose></xsl:attribute>
      <xsl:copy-of select="@directed|@phase|@provenance|@version|@scope|@role"/>
    </edge>
  </xsl:template>

  <!-- Pattern = <id, version, matcher, captures, scope, provenance>. -->
  <xsl:template match="pattern" priority="1">
    <record kind="Pattern">
      <xsl:copy-of select="@id|@version|@matcher|@scope|@provenance|@phase"/>
      <xsl:apply-templates select="capture" mode="capture"/>
    </record>
  </xsl:template>
  <xsl:template match="capture" mode="capture">
    <capture><xsl:copy-of select="@name|@type|@scope|@sourceRef|@phase"/></capture>
  </xsl:template>

  <!-- Capability = <micronaut, domains, ops, phaseScope>. -->
  <xsl:template match="capability" priority="1">
    <record kind="Capability">
      <xsl:copy-of select="@micronaut|@phaseScope|@provenance|@phase"/>
      <xsl:apply-templates select="domain|op" mode="capability-item"/>
    </record>
  </xsl:template>
  <xsl:template match="domain|op" mode="capability-item">
    <xsl:element name="{name()}"><xsl:value-of select="."/></xsl:element>
  </xsl:template>

  <!-- CorpusBinding = <domain, keyPrefix, corpusPath, micronaut, entryCount>. -->
  <xsl:template match="corpus" priority="1">
    <record kind="CorpusBinding">
      <xsl:copy-of select="@domain|@keyPrefix|@corpusPath|@micronaut|@entryCount|@phase|@provenance"/>
    </record>
  </xsl:template>

  <!-- Bridge = <sourceDomain, targetDomain, admissionRef>. -->
  <xsl:template match="bridge" priority="1">
    <record kind="Bridge"><xsl:copy-of select="@sourceDomain|@targetDomain|@admissionRef|@provenance"/></record>
  </xsl:template>

  <!-- Requirement = <op, domain, minPhase>. -->
  <xsl:template match="requirement" priority="1">
    <record kind="Requirement"><xsl:copy-of select="@op|@domain|@minPhase|@provenance"/></record>
  </xsl:template>
</xsl:stylesheet>
