<?xml version="1.0" encoding="UTF-8"?>
<!--
  Micronaut program registry projection — XSLT 3.0 / XPath 3.1.

  Reads micronaut.program.v0.1.json (or the URI supplied in $program-uri)
  as an XPath map and projects its declarations to typed XML nodes.
  The output is descriptive only: no continuation is called, no callable edge
  is dispatched, no registration is inferred, and no XCFE admission occurs.
-->
<xsl:stylesheet version="3.0"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:xs="http://www.w3.org/2001/XMLSchema"
                xmlns:map="http://www.w3.org/2005/xpath-functions/map"
                xmlns:k="https://kuhul.dev/micronaut/programs"
                exclude-result-prefixes="xs map k">

  <xsl:output method="xml" encoding="UTF-8" indent="yes"/>
  <xsl:param name="program-uri" as="xs:string"
             select="'micronaut.program.v0.1.json'"/>

  <xsl:function name="k:bool" as="xs:string">
    <xsl:param name="value" as="item()?"/>
    <xsl:sequence select="if ($value instance of xs:boolean and $value) then 'true' else 'false'"/>
  </xsl:function>

  <xsl:template match="/">
    <xsl:variable name="program" as="map(*)"
      select="json-doc(resolve-uri($program-uri, static-base-uri()))"/>

    <micronaut-program-projection format="kuhul.micronaut.program-projection/1"
        source="{$program-uri}"
        authority="projection_only"
        admission="not_evaluated"
        execution="not_invoked">
      <program id="{$program?('@type')}"
               schema="{$program?('$schema')}"
               version="{$program?version}"
               no-eval="{k:bool($program?('@no-eval'))}">
        <topology type="{$program?topology?type}"
                  space="{$program?topology?space}"
                  semantic-coordinates="{$program?topology?semantic_coordinates}">
          <phase-wheel>
            <xsl:for-each select="$program?topology?phase_wheel?*">
              <phase name="{.}"/>
            </xsl:for-each>
          </phase-wheel>
        </topology>
        <runtime law="{$program?runtime?law}">
          <xsl:for-each select="$program?runtime?stages?*">
            <stage name="{?name}" verb="{?verb}" phase="{?phase}" status="declared"/>
          </xsl:for-each>
        </runtime>
        <authority-boundary
            semantic-authority="{k:bool($program?authority_boundary?semantic_authority)}"
            topology-authority="{k:bool($program?authority_boundary?topology_authority)}"
            verification-authority="{k:bool($program?authority_boundary?verification_authority)}"
            commit-authority="{k:bool($program?authority_boundary?commit_authority)}"
            semantic-edges-invoke="{k:bool(not($program?authority_boundary?semantic_edges_do_not_invoke))}"
            xul-required-for-promotion="{k:bool($program?authority_boundary?xul_required_for_promotion)}"/>
      </program>

      <micronauts>
        <xsl:for-each select="$program?registry?micronauts?*">
          <xsl:variable name="micronaut" as="map(*)" select="."/>
          <micronaut key="{$micronaut?key}"
                     track="{$micronaut?track_id}"
                     phase="{$micronaut?phase}"
                     route-contract-required="{k:bool($micronaut?route_contract_required)}"
                     registration="not_inferred">
            <patterns>
              <xsl:for-each select="$micronaut?patterns?*">
                <pattern status="declared">{.}</pattern>
              </xsl:for-each>
            </patterns>
            <guards>
              <xsl:for-each select="$micronaut?guards?*">
                <guard status="declarative">{.}</guard>
              </xsl:for-each>
            </guards>
            <continuations>
              <xsl:for-each select="$micronaut?continuations?*">
                <continuation status="not-invoked">{.}</continuation>
              </xsl:for-each>
            </continuations>
            <semantic-edges>
              <xsl:for-each select="$micronaut?semantic_edges?*">
                <edge kind="semantic" status="data_only">{.}</edge>
              </xsl:for-each>
            </semantic-edges>
            <callable-edge-proposals>
              <xsl:for-each select="$micronaut?callable_edges?*">
                <edge target="{.}" route-contract-required="true"
                      admission="external_per_invocation" dispatch="not_invoked"/>
              </xsl:for-each>
            </callable-edge-proposals>
            <wcr weight="{$micronaut?wcr?weight}"
                 confidence="{$micronaut?wcr?confidence}"
                 score="not_computed"/>
            <xsl:if test="$micronaut?model instance of map(*)">
              <model-binding backend="{$micronaut?model?backend}"
                             profile="declared_only"
                             credential="not_projected"/>
            </xsl:if>
            <xsl:if test="$micronaut?authority instance of map(*)">
              <authority-claims>
                <xsl:for-each select="map:keys($micronaut?authority)">
                  <claim name="{.}" value="{k:bool($micronaut?authority(.))}"/>
                </xsl:for-each>
              </authority-claims>
            </xsl:if>
          </micronaut>
        </xsl:for-each>
      </micronauts>

      <edges>
        <semantic>
          <xsl:for-each select="$program?edges?semantic?*">
            <edge from="{?from}" relation="{?rel}" to="{?to}"
                  weight="{?weight}" status="data_only"/>
          </xsl:for-each>
        </semantic>
        <callable-proposals>
          <xsl:for-each select="$program?edges?callable?*">
            <edge from="{?from}" to="{?to}" relation="{?rel}"
                  phase="{?phase}"
                  route-contract-required="{k:bool(?route_contract_required)}"
                  admission="external_per_invocation" dispatch="not_invoked"/>
          </xsl:for-each>
        </callable-proposals>
      </edges>

      <learning policy="{$program?learning?law}"
                promotion-threshold="{$program?learning?promotionThreshold}"
                promotion-requires-xul="{k:bool($program?learning?promotion_requires_xul)}"
                update="not_performed"/>
    </micronaut-program-projection>
  </xsl:template>
</xsl:stylesheet>
