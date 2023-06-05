<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform">

    <xsl:template name="taxonomic_coverage" match="/">
        <div class="table-responsive">
            <table class="table table-striped">
                <tr>
			  <th>Family</th>
                    <th>Genus</th>
			  <th>Species</th>
                    <th>Common name</th>
                </tr>
      			<xsl:for-each select="//dataset/coverage/taxonomicCoverage/taxonomicClassification/taxonomicClassification/taxonomicClassification/taxonomicClassification/taxonomicClassification">
					<tr>
						<td><xsl:value-of select="taxonRankValue"/></td>
						<td><xsl:value-of select="taxonomicClassification/taxonRankValue"/></td>
                        		<td><xsl:value-of select="taxonomicClassification/taxonomicClassification/taxonRankValue"/></td>
                        		<td><xsl:value-of select="commonName"/></td>
                    		</tr>
				</xsl:for-each>
            </table>
        </div>
    </xsl:template>
</xsl:stylesheet>