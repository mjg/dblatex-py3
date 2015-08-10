<?xml version='1.0'?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version='1.0'>

<!--############################################################################
    XSLT Stylesheet DocBook -> LaTeX 
    ############################################################################ -->

<xsl:variable name="latex.use.hyperref">0</xsl:variable>
<xsl:param name="doc.section.depth">5</xsl:param>
<xsl:param name="toc.section.depth">5</xsl:param>
<xsl:param name="doc.pdfcreator.show">1</xsl:param>
<xsl:param name="doc.publisher.show">0</xsl:param>
<xsl:param name="doc.collab.show">1</xsl:param>
<xsl:param name="doc.alignment"/>
<xsl:param name="doc.layout">coverpage toc frontmatter mainmatter index</xsl:param>
<xsl:param name="draft.mode">maybe</xsl:param>
<xsl:param name="draft.watermark">1</xsl:param>


<xsl:variable name="latex.begindocument">
  <xsl:text>\begin{document}&#10;</xsl:text>
</xsl:variable>

<xsl:variable name="latex.enddocument">
  <xsl:text>&#10;\end{document}&#10;</xsl:text>
</xsl:variable>

<xsl:variable name="frontmatter" select="'\frontmatter&#10;'"/>
<xsl:variable name="mainmatter" select="'\mainmatter&#10;'"/>
<xsl:variable name="backmatter" select="'\backmatter&#10;'"/>

<xsl:template match="book|article" mode="preamble">
  <xsl:param name="lang"/>
  <xsl:variable name="info" select="bookinfo|articleinfo|artheader|info"/>

  <xsl:text>% -----------------------------------------  &#10;</xsl:text>
  <xsl:text>% Autogenerated LaTeX file from XML DocBook  &#10;</xsl:text>
  <xsl:text>% -----------------------------------------  &#10;</xsl:text>
  <!-- Parameters to pass to python parser -->
  <xsl:call-template name="py.params.set"/>
  <xsl:text>\documentclass</xsl:text>
  <xsl:if test="$latex.class.options!=''">
    <xsl:value-of select="concat('[',$latex.class.options,']')"/>
  </xsl:if>
  <xsl:text>{</xsl:text>
  <xsl:choose>
    <xsl:when test="self::book">
      <xsl:value-of select="$latex.class.book"/>
    </xsl:when>
    <xsl:otherwise>
      <xsl:value-of select="$latex.class.article"/>
    </xsl:otherwise>
  </xsl:choose>
  <xsl:text>}&#10;</xsl:text>

  <xsl:variable name="external.docs">
    <xsl:call-template name="make.external.docs"/>
  </xsl:variable>
  
  <xsl:call-template name="encode.before.style">
    <xsl:with-param name="lang" select="$lang"/>
  </xsl:call-template>
  <xsl:text>\usepackage{fancybox}&#10;</xsl:text>
  <xsl:text>\usepackage{makeidx}&#10;</xsl:text>

  <xsl:call-template name="user.params.set"/>
  <!-- Load babel before the style (bug #babel/3875) -->
  <xsl:call-template name="babel.setup"/>

  <!-- Load xr before hyperref -->
  <xsl:if test="$external.docs != ''">
    <xsl:text>\usepackage{xr-hyper}&#10;</xsl:text>
  </xsl:if>

  <!-- Paper and Page setup -->
  <xsl:call-template name="page.setup"/>

  <xsl:text>\usepackage[hyperlink]{</xsl:text>
  <xsl:value-of select="$latex.style"/>
  <xsl:text>}&#10;</xsl:text>

  <xsl:call-template name="encode.after.style">
    <xsl:with-param name="lang" select="$lang"/>
  </xsl:call-template>
  <xsl:call-template name="lang.setup"/>
  <xsl:call-template name="image.setup"/>
  <xsl:call-template name="citation.setup"/>
  <xsl:call-template name="biblio.setup"/>
  <xsl:call-template name="footnote.setup"/>
  <xsl:call-template name="annotation.setup"/>
  <xsl:call-template name="user.params.set2"/>
  <xsl:call-template name="inline.setup"/>
  <xsl:apply-templates select="." mode="docinfo"/>

  <!-- Document title -->
  <xsl:variable name="title">
    <xsl:apply-templates select="(title
                                 |info/title
                                 |bookinfo/title
                                 |articleinfo/title
                                 |artheader/title)[1]" mode="coverpage"/>
  </xsl:variable>

  <!-- Get the Authors -->
  <xsl:variable name="authors">
    <xsl:if test="$info">
      <xsl:choose>
        <xsl:when test="$info/authorgroup/author">
          <xsl:apply-templates select="$info/authorgroup"/>
        </xsl:when>
        <xsl:when test="$info/author">
          <xsl:call-template name="person.name.list">
            <xsl:with-param name="person.list" select="$info/author"/>
          </xsl:call-template>
        </xsl:when>
      </xsl:choose>
    </xsl:if>
  </xsl:variable>

  <xsl:text>\title{</xsl:text>
  <xsl:value-of select="$title"/>
  <xsl:text>}&#10;</xsl:text>
  <xsl:text>\author{</xsl:text>
  <xsl:value-of select="$authors"/>
  <xsl:text>}&#10;</xsl:text>

  <!-- Fill the PDF metadata -->
  <xsl:call-template name="pdf-document-information">
    <xsl:with-param name="pdfauthor" select="$authors"/>
  </xsl:call-template>

  <!-- The external documents -->
  <xsl:if test="$external.docs != ''">
    <xsl:value-of select="$external.docs"/>
  </xsl:if>

  <!-- Set the collaborator table -->
  <xsl:call-template name="collab.setup">
    <xsl:with-param name="authors" select="$authors"/>
  </xsl:call-template>

  <xsl:text>\makeindex&#10;</xsl:text>
  <xsl:text>\makeglossary&#10;</xsl:text>

  <!-- Apply the revision history here -->
  <xsl:apply-templates select="$info/revhistory"/>

  <xsl:call-template name="verbatim.setup"/>
</xsl:template>

<!-- FIXME: currently does nothing more than default rendering -->
<xsl:template match="title" mode="coverpage">
  <xsl:apply-templates/>
</xsl:template>


<!-- ##################################
     # Preamble setup from parameters #
     ################################## -->

<!-- Setup from the user parameters -->
<xsl:template name="user.params.set">
  <xsl:if test="$latex.hyperparam!=''">
    <xsl:text>\def\hyperparam{</xsl:text>
    <xsl:value-of select="$latex.hyperparam"/>
    <xsl:text>}&#10;</xsl:text>
  </xsl:if>
  <xsl:if test="$doc.publisher.show='1'">
    <xsl:text>\def\DBKpublisher{</xsl:text>
    <xsl:text>\includegraphics{dblatex}</xsl:text>
    <xsl:text>}&#10;</xsl:text>
  </xsl:if>
  <xsl:if test="$literal.layout.options">
    <xsl:text>\def\lstparamset{\lstset{</xsl:text>
    <xsl:value-of select="$literal.layout.options"/>
    <xsl:text>}}&#10;</xsl:text>
  </xsl:if>
  <xsl:if test="$doc.alignment!='' and $doc.alignment!='justify'">
    <xsl:text>\usepackage{ragged2e}&#10;</xsl:text>
    <xsl:choose>
    <xsl:when test="$doc.alignment='center'">
      <xsl:text>\Centering&#10;</xsl:text>
    </xsl:when>
    <xsl:when test="$doc.alignment='left'">
      <xsl:text>\RaggedRight&#10;</xsl:text>
    </xsl:when>
    <xsl:when test="$doc.alignment='right'">
      <xsl:text>\RaggedLeft&#10;</xsl:text>
    </xsl:when>
    <xsl:otherwise>
      <xsl:message>Unknown doc.alignment='<xsl:value-of
      select="$doc.alignment"/>'</xsl:message>
    </xsl:otherwise>
    </xsl:choose>
  </xsl:if>
</xsl:template>

<!-- Setup to do when the docbook package is loaded -->
<xsl:template name="user.params.set2">
  <xsl:if test="$pdf.annot.options">
    <xsl:text>\commentsetup{</xsl:text>
    <xsl:value-of select="$pdf.annot.options"/>
    <xsl:text>}&#10;</xsl:text>
  </xsl:if>

  <xsl:variable name="draft">
    <xsl:choose>
    <xsl:when test="$draft.mode='yes'">1</xsl:when>
    <xsl:when test="$draft.mode='no'">0</xsl:when>
    <xsl:when test="$draft.mode='maybe' and
                    @status and @status='draft'">1</xsl:when>
    <xsl:otherwise>0</xsl:otherwise>
    </xsl:choose>
  </xsl:variable>
  
  <xsl:choose>
    <xsl:when test="$draft='0'">
      <xsl:text>\renewcommand{\DBKreleaseinfo}{}&#10;</xsl:text>
    </xsl:when>
    <xsl:when test="$draft.watermark!='0'">
      <xsl:text>\showwatermark{</xsl:text>
      <!--
      <xsl:call-template name="gentext">
        <xsl:with-param name="key" select="'Draft'"/>
      </xsl:call-template>
      -->
      <xsl:text>DRAFT</xsl:text>
      <xsl:text>}&#10;</xsl:text>
    </xsl:when>
  </xsl:choose>

  <xsl:if test="$latex.output.revhistory=0">
    <xsl:text>\renewcommand{\DBKrevhistory}{}&#10;</xsl:text>
  </xsl:if>
  <xsl:text>\setcounter{tocdepth}{</xsl:text>
  <xsl:value-of select="$toc.section.depth"/>
  <xsl:text>}&#10;</xsl:text>
  <xsl:text>\setcounter{secnumdepth}{</xsl:text>
  <xsl:value-of select="$doc.section.depth"/>
  <xsl:text>}&#10;</xsl:text>
</xsl:template>

<!-- #################
     # Collaborators #
     ################# -->

<xsl:template name="collab.setup">
  <xsl:param name="authors"/>
  <xsl:choose>
  <xsl:when test="$doc.collab.show!='0'">
    <xsl:text>% ------------------
% Collaborators
% ------------------
\renewcommand{\DBKindexation}{
\begin{DBKindtable}
\DBKinditem{\writtenby}{</xsl:text>
    <xsl:value-of select="$authors"/>
    <xsl:text>}</xsl:text>
    <xsl:apply-templates select=".//othercredit" mode="collab"/>
    <xsl:text>&#10;\end{DBKindtable}&#10;}&#10;</xsl:text>
  </xsl:when>
  <xsl:otherwise>
    <xsl:text>\renewcommand{\DBKindexation}{}&#10;</xsl:text>
  </xsl:otherwise>
  </xsl:choose>
</xsl:template>

<xsl:template match="othercredit" mode="collab">
  <xsl:text>\DBKinditem{</xsl:text>
  <xsl:value-of select="contrib"/>
  <xsl:text>}{</xsl:text>
  <xsl:apply-templates select="firstname"/>
  <xsl:text> </xsl:text>
  <xsl:apply-templates select="surname"/>
  <xsl:text>}&#10;</xsl:text>
</xsl:template>

<!-- ########################
     # Document infos setup #
     ######################## -->

<xsl:template match="book|article" mode="docinfo">
  <xsl:apply-templates select="bookinfo|articleinfo|info" mode="docinfo"/>

  <!-- Override the infos if specified in the root element -->
  <xsl:apply-templates select="subtitle" mode="docinfo"/>
</xsl:template>

<xsl:template match="bookinfo|articleinfo|info" mode="docinfo">
  <!-- special case for copyrights, managed as a group -->
  <xsl:if test="copyright">
    <xsl:text>\def\DBKcopyright{</xsl:text>
    <xsl:apply-templates select="copyright" mode="titlepage.mode"/>
    <xsl:text>}&#10;</xsl:text>
  </xsl:if>
  <xsl:apply-templates mode="docinfo"/>
</xsl:template>

<xsl:template match="*" mode="docinfo"/>

<xsl:template match="address" mode="docinfo">
  <xsl:text>\renewcommand{\DBKsite}{</xsl:text>
  <xsl:variable name="content"><xsl:apply-templates/></xsl:variable>
  <xsl:value-of select="normalize-space($content)"/>
  <xsl:text>}&#10;</xsl:text>
</xsl:template>

<xsl:template match="releaseinfo" mode="docinfo">
  <xsl:variable name="draft">
    <xsl:choose>
    <xsl:when test="$draft.mode='yes'">1</xsl:when>
    <xsl:when test="$draft.mode='no'">0</xsl:when>
    <xsl:when test="$draft.mode='maybe' and
                  ancestor-or-self::*[@status][1]/@status='draft'">1</xsl:when>
    <xsl:otherwise>0</xsl:otherwise>
    </xsl:choose>
  </xsl:variable>

  <xsl:if test="$draft='1'">
    <xsl:text>\renewcommand{\DBKreleaseinfo}{</xsl:text>
    <xsl:apply-templates select="."/>
    <xsl:text>}&#10;</xsl:text>
  </xsl:if>
</xsl:template>

<xsl:template match="pubdate" mode="docinfo">
  <xsl:text>\renewcommand{\DBKpubdate}{</xsl:text>
  <xsl:variable name="content"><xsl:apply-templates/></xsl:variable>
  <xsl:value-of select="normalize-space($content)"/>
  <xsl:text>}&#10;</xsl:text>
</xsl:template>

<xsl:template match="pubsnumber" mode="docinfo">
  <xsl:text>\renewcommand{\DBKreference}{</xsl:text>
  <xsl:variable name="content"><xsl:apply-templates/></xsl:variable>
  <xsl:value-of select="normalize-space($content)"/>
  <xsl:text>}&#10;</xsl:text>
</xsl:template>

<!-- For backward compatibility, used only if pubsnumber not used -->
<xsl:template match="biblioid[not(parent::*/pubsnumber)]" mode="docinfo">
  <xsl:text>\renewcommand{\DBKreference}{</xsl:text>
  <xsl:variable name="content"><xsl:apply-templates/></xsl:variable>
  <xsl:value-of select="normalize-space($content)"/>
  <xsl:text>}&#10;</xsl:text>
</xsl:template>

<xsl:template match="edition" mode="docinfo">
  <xsl:text>\renewcommand{\DBKedition}{</xsl:text>
  <xsl:call-template name="normalize-scape">
    <xsl:with-param name="string" select="."/>
  </xsl:call-template>
  <xsl:text>}&#10;</xsl:text>
</xsl:template>

<xsl:template match="date" mode="docinfo">
  <!-- Override the date definition if specified -->
  <xsl:text>\renewcommand{\DBKdate}{</xsl:text>
  <xsl:variable name="content"><xsl:apply-templates/></xsl:variable>
  <xsl:value-of select="normalize-space($content)"/>
  <xsl:text>}&#10;</xsl:text>
</xsl:template>

<xsl:template match="subtitle" mode="docinfo">
  <xsl:text>\def\DBKsubtitle{</xsl:text>
  <xsl:call-template name="normalize-scape">
    <xsl:with-param name="string" select="."/>
  </xsl:call-template>
  <xsl:text>}&#10;</xsl:text>
</xsl:template>

<xsl:template match="releaseinfo">
  <xsl:apply-templates/>
</xsl:template>

<xsl:template match="holder" mode="titlepage.mode">
  <xsl:apply-templates/>
  <xsl:if test="position() &lt; last()">
    <xsl:text>, </xsl:text>
  </xsl:if>
</xsl:template>

<xsl:template match="copyright" mode="titlepage.mode">
  <xsl:text>\noindent </xsl:text>
  <xsl:call-template name="gentext">
    <xsl:with-param name="key" select="'Copyright'"/>
  </xsl:call-template>
  <xsl:call-template name="gentext.space"/>
  <xsl:call-template name="dingbat">
    <xsl:with-param name="dingbat">copyright</xsl:with-param>
  </xsl:call-template>
  <xsl:call-template name="gentext.space"/>
  <xsl:call-template name="copyright.years">
    <xsl:with-param name="years" select="year"/>
    <xsl:with-param name="print.ranges" select="$make.year.ranges"/>
    <xsl:with-param name="single.year.ranges"
                    select="$make.single.year.ranges"/>
  </xsl:call-template>
  <xsl:call-template name="gentext.space"/>
  <xsl:apply-templates select="holder" mode="titlepage.mode"/>
  <xsl:if test="following-sibling::copyright">
    <xsl:text>\par&#10;</xsl:text>
  </xsl:if>
</xsl:template>

<!-- #################
     # Main template #
     ################# -->

<!-- A DocBook subset does not contain coverpage and so on,
     so use a minimal layout
-->
<xsl:template match="book|article" mode="wrapper">
  <xsl:apply-templates select=".">
    <xsl:with-param name="layout">
      <xsl:if test="contains(concat($doc.layout, ' '), 'index ')">
        <xsl:text>index </xsl:text>
      </xsl:if>
    </xsl:with-param>
  </xsl:apply-templates>
</xsl:template>

<xsl:template match="book|article">
  <xsl:param name="layout" select="concat($doc.layout, ' ')"/>

  <xsl:variable name="info" select="bookinfo|articleinfo|artheader|info"/>
  <xsl:variable name="lang">
    <xsl:call-template name="l10n.language">
      <xsl:with-param name="target" select="(/set|/book|/article)[1]"/>
      <xsl:with-param name="xref-context" select="true()"/>
    </xsl:call-template>
  </xsl:variable>

  <!-- Latex preamble -->
  <xsl:apply-templates select="." mode="preamble">
    <xsl:with-param name="lang" select="$lang"/>
  </xsl:apply-templates>

  <xsl:value-of select="$latex.begindocument"/>
  <xsl:call-template name="lang.document.begin">
    <xsl:with-param name="lang" select="$lang"/>
  </xsl:call-template>
  <xsl:call-template name="label.id"/>

  <!-- Setup that must be performed after the begin of document -->
  <xsl:call-template name="verbatim.setup2"/>

  <!-- Apply the legalnotices here, when language is active -->
  <xsl:call-template name="print.legalnotice">
    <xsl:with-param name="nodes" select="$info/legalnotice"/>
  </xsl:call-template>

  <xsl:if test="contains($layout, 'frontmatter ')">
    <xsl:value-of select="$frontmatter"/>
  </xsl:if>

  <xsl:if test="contains($layout, 'coverpage ')">
    <xsl:text>\maketitle&#10;</xsl:text>
  </xsl:if>

  <!-- Print the TOC/LOTs -->
  <xsl:if test="contains($layout, 'toc ')">
    <xsl:apply-templates select="." mode="toc_lots"/>
  </xsl:if>

  <!-- Print the abstract and front matter content -->
  <xsl:apply-templates select="(abstract|$info/abstract)[1]"/>
  <xsl:apply-templates select="dedication|preface"/>

  <!-- Body content -->
  <xsl:if test="contains($layout, 'mainmatter ')">
    <xsl:value-of select="$mainmatter"/>
  </xsl:if>
  <xsl:apply-templates select="*[not(self::abstract or
                                     self::preface or
                                     self::dedication or
                                     self::colophon or
                                     self::appendix)]"/>

  <!-- Back matter -->
  <xsl:if test="contains($layout, 'backmatter ')">
    <xsl:value-of select="$backmatter"/>
  </xsl:if>

  <xsl:apply-templates select="appendix"/>
  <xsl:if test="contains($layout, 'index ')">
    <xsl:if test="*//indexterm|*//keyword">
      <xsl:call-template name="printindex"/>
    </xsl:if>
  </xsl:if>
  <xsl:apply-templates select="colophon"/>
  <xsl:call-template name="lang.document.end">
    <xsl:with-param name="lang" select="$lang"/>
  </xsl:call-template>
  <xsl:value-of select="$latex.enddocument"/>
</xsl:template>

<xsl:template match="book/title"/>
<xsl:template match="article/title"/>
<xsl:template match="bookinfo"/>
<xsl:template match="articleinfo"/>

</xsl:stylesheet>
