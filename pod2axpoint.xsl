<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
version="1.0">

<xsl:output method="xml" indent="yes"/>

<xsl:key name="headings" match="para|head2|head3|verbatim|orderedlist|itemizedlist" use="generate-id(preceding::head1[1])"/>

<xsl:template match="/">
<slideshow>
  <title><xsl:value-of select="/pod/head1[1]"/></title>
  <metadata>
    <speaker>Ask Bjorn Hansen</speaker>
    <email>ask@perl.org</email>
  </metadata>
    
  <xsl:apply-templates select="/pod/head1[position() > 1]"/>

</slideshow>
</xsl:template>

<xsl:template match="head1">
  <xsl:variable name="this-id">
    <xsl:value-of select="generate-id(.)"/>
  </xsl:variable>
  
    <slide>
      <title><xsl:apply-templates/></title>
      <xsl:apply-templates select="key('headings', $this-id)"/>
    </slide>
</xsl:template>

<xsl:template match="para">
  <point>
  <xsl:apply-templates/>
  </point>
</xsl:template>

<xsl:template match="verbatim">
  <source-code>
  <xsl:apply-templates/>
  </source-code>
</xsl:template>

<xsl:template match="head2">
  <point><b><i>
  <xsl:apply-templates/>
  </i></b></point>
</xsl:template>

<xsl:template match="head3">
  <point><b>
  <xsl:apply-templates/>
  </b></point>
</xsl:template>

<xsl:template match="orderedlist">
  <xsl:apply-templates/>
</xsl:template>

<xsl:template match="itemizedlist">
  <xsl:apply-templates/>
</xsl:template>

<xsl:template match="listitem">
  <point>
  <xsl:apply-templates/>
  </point>
</xsl:template>

<xsl:template match="link">
  <xsl:apply-templates/>
</xsl:template>

<xsl:template match="B">
  <b><xsl:apply-templates/></b>
</xsl:template>

<xsl:template match="C">
  <span style="font-family: monospace">
  <xsl:apply-templates/>
  </span>
</xsl:template>

<xsl:template match="I">
  <i><xsl:apply-templates/></i>
</xsl:template>

<xsl:template match="F">
  <xsl:apply-templates/>
</xsl:template>

</xsl:stylesheet>