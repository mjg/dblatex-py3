<?xml version='1.0'?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version='1.0'>

<!--############################################################################
    XSLT Stylesheet DocBook -> LaTeX 
    ############################################################################ -->


<xsl:variable name="doc.section.depth">5</xsl:variable>
<xsl:variable name="toc.section.depth">5</xsl:variable>
<xsl:variable name="latex.use.hyperref">0</xsl:variable>

<xsl:variable name="latex.book.preamblestart">
  <xsl:text>% -----------------------------------------  &#10;</xsl:text>
  <xsl:text>% Autogenerated LaTeX file from XML DocBook  &#10;</xsl:text>
  <xsl:text>% -----------------------------------------  &#10;</xsl:text>
  <xsl:text>\documentclass</xsl:text>
  <xsl:if test="$latex.class.options!=''">
    <xsl:text>[</xsl:text>
    <xsl:value-of select="$latex.class.options"/>
    <xsl:text>]</xsl:text>
  </xsl:if>
  <xsl:text>{report}&#10;</xsl:text>
  <xsl:text>\usepackage[T1]{fontenc}&#10;</xsl:text>
  <xsl:text>\usepackage[latin1]{inputenc}&#10;</xsl:text>
  <xsl:text>%\usepackage{a4wide}&#10;</xsl:text>
  <xsl:text>\setcounter{secnumdepth}{5}&#10;</xsl:text>
  <xsl:text>\usepackage{fancybox}&#10;</xsl:text>
  <xsl:text>\usepackage{makeidx}&#10;</xsl:text>
</xsl:variable>

<xsl:variable name="latex.article.preamblestart">
  <xsl:text>% -----------------------------------------  &#10;</xsl:text>
  <xsl:text>% Autogenerated LaTeX file from XML DocBook  &#10;</xsl:text>
  <xsl:text>% -----------------------------------------  &#10;</xsl:text>
  <xsl:text>\documentclass</xsl:text>
  <xsl:if test="$latex.class.options!=''">
    <xsl:text>[</xsl:text>
    <xsl:value-of select="$latex.class.options"/>
    <xsl:text>]</xsl:text>
  </xsl:if>
  <xsl:text>{article}&#10;</xsl:text>
  <xsl:text>\usepackage[T1]{fontenc}&#10;</xsl:text>
  <xsl:text>\usepackage[latin1]{inputenc}&#10;</xsl:text>
  <xsl:text>%\usepackage{a4wide}&#10;</xsl:text>
  <xsl:text>\setcounter{secnumdepth}{5}&#10;</xsl:text>
  <xsl:text>\usepackage{fancybox}&#10;</xsl:text>
  <xsl:text>\usepackage{makeidx}&#10;</xsl:text>
</xsl:variable>

<xsl:template name="use.babel">
  <!-- first find the language actually set -->
  <xsl:variable name="lang">
    <xsl:call-template name="l10n.language">
      <xsl:with-param name="target" select="(/set|/book|/article)[1]"/>
      <xsl:with-param name="xref-context" select="true()"/>
    </xsl:call-template>
  </xsl:variable>

  <!-- then select the corresponding babel language -->
  <xsl:variable name="babel">
    <xsl:choose>
      <xsl:when test="$latex.babel.language!=''">
        <xsl:value-of select="$latex.babel.language"/>
      </xsl:when>
      <xsl:when test="starts-with($lang,'af')">afrikaans</xsl:when>
      <xsl:when test="starts-with($lang,'br')">breton</xsl:when>
      <xsl:when test="starts-with($lang,'ca')">catalan</xsl:when>
      <xsl:when test="starts-with($lang,'cs')">czech</xsl:when>
      <xsl:when test="starts-with($lang,'cy')">welsh</xsl:when>
      <xsl:when test="starts-with($lang,'da')">danish</xsl:when>
      <xsl:when test="starts-with($lang,'de')">ngerman</xsl:when>
      <xsl:when test="starts-with($lang,'el')">greek</xsl:when>
      <xsl:when test="starts-with($lang,'en')">
        <xsl:choose>
          <xsl:when test="starts-with($lang,'en-CA')">canadian</xsl:when>
          <xsl:when test="starts-with($lang,'en-GB')">british</xsl:when>
          <xsl:when test="starts-with($lang,'en-US')">USenglish</xsl:when>
          <xsl:otherwise></xsl:otherwise>
        </xsl:choose>
      </xsl:when>
      <xsl:when test="starts-with($lang,'eo')">esperanto</xsl:when>
      <xsl:when test="starts-with($lang,'es')">spanish</xsl:when>
      <xsl:when test="starts-with($lang,'et')">estonian</xsl:when>
      <xsl:when test="starts-with($lang,'fi')">finnish</xsl:when>
      <xsl:when test="starts-with($lang,'fr')">french</xsl:when>
      <xsl:when test="starts-with($lang,'ga')">irish</xsl:when>
      <xsl:when test="starts-with($lang,'gd')">scottish</xsl:when>
      <xsl:when test="starts-with($lang,'gl')">galician</xsl:when>
      <xsl:when test="starts-with($lang,'he')">hebrew</xsl:when>
      <xsl:when test="starts-with($lang,'hr')">croatian</xsl:when>
      <xsl:when test="starts-with($lang,'hu')">hungarian</xsl:when>
      <xsl:when test="starts-with($lang,'id')">bahasa</xsl:when>
      <xsl:when test="starts-with($lang,'it')">italian</xsl:when>
      <xsl:when test="starts-with($lang,'nl')">dutch</xsl:when>
      <xsl:when test="starts-with($lang,'nn')">norsk</xsl:when>
      <xsl:when test="starts-with($lang,'pl')">polish</xsl:when>
      <xsl:when test="starts-with($lang,'pt')">
        <xsl:choose>
          <xsl:when test="starts-with($lang,'pt-BR')">brazil</xsl:when>
          <xsl:otherwise>portugese</xsl:otherwise>
        </xsl:choose>
      </xsl:when>
      <xsl:when test="starts-with($lang,'ro')">romanian</xsl:when>
      <xsl:when test="starts-with($lang,'ru')">russian</xsl:when>
      <xsl:when test="starts-with($lang,'sk')">slovak</xsl:when>
      <xsl:when test="starts-with($lang,'sl')">slovene</xsl:when>
      <xsl:when test="starts-with($lang,'sv')">swedish</xsl:when>
      <xsl:when test="starts-with($lang,'tr')">turkish</xsl:when>
      <xsl:when test="starts-with($lang,'uk')">ukrainian</xsl:when>
    </xsl:choose>
  </xsl:variable>

  <xsl:if test="$babel!=''">
    <xsl:text>\usepackage[</xsl:text>
    <xsl:value-of select="$babel"/>
    <xsl:text>]{babel}&#10;</xsl:text>
  </xsl:if>
</xsl:template>

<xsl:template match="releaseinfo">
  <xsl:apply-templates/>
</xsl:template>

<xsl:template match="bookinfo|articleinfo" mode="docinfo">
  <xsl:if test="releaseinfo">
    <xsl:text>\renewcommand{\DBKreleaseinfo}{</xsl:text>
    <xsl:apply-templates select="releaseinfo"/>
    <xsl:text>}&#10;</xsl:text>
  </xsl:if>
  <xsl:if test="pubsnumber">
    <xsl:text>\renewcommand{\DBKreference}{</xsl:text>
    <xsl:value-of select="normalize-space(pubsnumber)"/>
    <xsl:text>}&#10;</xsl:text>
  </xsl:if>
  <xsl:if test="pubdate">
    <xsl:text>\renewcommand{\DBKpubdate}{</xsl:text>
    <xsl:value-of select="normalize-space(pubdate)"/>
    <xsl:text>}&#10;</xsl:text>
  </xsl:if>
  <xsl:if test="address">
    <xsl:text>\renewcommand{\DBKsite}{</xsl:text>
    <xsl:value-of select="normalize-space(address)"/>
    <xsl:text>}&#10;</xsl:text>
  </xsl:if>
  <xsl:if test="edition">
    <xsl:text>\renewcommand{\DBKedition}{</xsl:text>
    <xsl:call-template name="normalize-scape">
      <xsl:with-param name="string" select="edition"/>
    </xsl:call-template>
    <xsl:text>}&#10;</xsl:text>
  </xsl:if>
  <xsl:if test="copyright">
    <xsl:text>\renewcommand{\DBKcopyright}{</xsl:text>
    <xsl:apply-templates select="copyright" mode="bibliography.mode"/>
    <xsl:text>}&#10;</xsl:text>
  </xsl:if>
  <xsl:if test="subtitle">
    <xsl:text>\renewcommand{\DBKsubtitle}{</xsl:text>
    <xsl:call-template name="normalize-scape">
      <xsl:with-param name="string" select="subtitle"/>
    </xsl:call-template>
    <xsl:text>}&#10;</xsl:text>
  </xsl:if>
  <!-- Override the date definition if specified -->
  <xsl:if test="date">
    <xsl:text>\renewcommand{\DBKdate}{</xsl:text>
    <xsl:value-of select="normalize-space(date)"/>
    <xsl:text>}&#10;</xsl:text>
  </xsl:if>
</xsl:template>

<xsl:template name="user.params.set">
  <xsl:if test="$latex.hyperparam">
    <xsl:text>\def\hyperparam{</xsl:text>
    <xsl:value-of select="$latex.hyperparam"/>
    <xsl:text>}&#10;</xsl:text>
  </xsl:if>
  <xsl:if test="$literal.layout.options">
    <xsl:text>\def\lstparamset{\lstset{</xsl:text>
    <xsl:value-of select="$literal.layout.options"/>
    <xsl:text>}}&#10;</xsl:text>
  </xsl:if>
</xsl:template>

<xsl:template match="book">
  <xsl:value-of select="$latex.book.preamblestart"/>
  <xsl:call-template name="user.params.set"/>
  <xsl:if test="@lang">
    <xsl:text>\def\DBKlocale{</xsl:text>
    <xsl:value-of select="@lang"/>
    <xsl:text>}&#10;</xsl:text>
  </xsl:if>
  <xsl:text>\usepackage[hyperlink]{</xsl:text>
  <xsl:value-of select="$latex.style"/>
  <xsl:text>}&#10;</xsl:text>

  <xsl:if test="$latex.babel.use='1'">
    <xsl:call-template name="use.babel"/>
  </xsl:if>

  <xsl:apply-templates select="bookinfo" mode="docinfo"/>

  <!-- Override the infos if specified here -->
  <xsl:if test="subtitle">
    <xsl:text>\renewcommand{\DBKsubtitle}{</xsl:text>
    <xsl:call-template name="normalize-scape">
      <xsl:with-param name="string" select="subtitle"/>
    </xsl:call-template>
    <xsl:text>}&#10;</xsl:text>
  </xsl:if>

  <xsl:text>\title{</xsl:text>
    <xsl:call-template name="normalize-scape">
      <xsl:with-param name="string">
        <xsl:choose>
        <xsl:when test="title">
          <xsl:value-of select="title"/>
        </xsl:when>
        <xsl:otherwise>
          <xsl:value-of select="bookinfo/title"/>
        </xsl:otherwise>
        </xsl:choose>
      </xsl:with-param>
    </xsl:call-template>
  <xsl:text>}&#10;</xsl:text>

  <!-- Get the Author -->
  <xsl:variable name="author">
    <xsl:choose>
      <xsl:when test="bookinfo/authorgroup/author">
        <xsl:apply-templates select="bookinfo/authorgroup"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:apply-templates select="bookinfo/author"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:variable>

  <xsl:text>\author{</xsl:text>
  <xsl:value-of select="$author"/>
  <xsl:text>}&#10;</xsl:text>

<!-- Set the indexation table -->
% ------------------
% Table d'Indexation
% ------------------
\renewcommand{\DBKindexation}{
\begin{DBKindtable}
\DBKinditem{\writtenby}{<xsl:value-of select="$author"/>}
<xsl:apply-templates select=".//othercredit"/>
\end{DBKindtable}
}

  <xsl:value-of select="$latex.book.afterauthor"/>
  <xsl:text>&#10;\setcounter{tocdepth}{</xsl:text>
  <xsl:value-of select="$toc.section.depth"/>
  <xsl:text>}&#10;</xsl:text>
  <xsl:text>&#10;\setcounter{secnumdepth}{</xsl:text>
  <xsl:value-of select="$doc.section.depth"/>
  <xsl:text>}&#10;</xsl:text>

  <!-- Apply the revision history here -->
  <xsl:apply-templates select="bookinfo/revhistory"/>

  <!-- Apply the legalnotices here -->
  <xsl:call-template name="print.legalnotice">
    <xsl:with-param name="nodes" select="bookinfo/legalnotice"/>
  </xsl:call-template>

  <xsl:value-of select="$latex.book.begindocument"/>
  <xsl:text>\long\def\hyper@section@backref#1#2#3{%&#10;</xsl:text>
  <xsl:text>\typeout{BACK REF #1 / #2 / #3}%&#10;</xsl:text>
  <xsl:text>\hyperlink{#3}{#2}}&#10;</xsl:text>
  <xsl:text>&#10;</xsl:text>
  <xsl:text>\maketitle&#10;</xsl:text>
  <xsl:text>\tableofcontents&#10;</xsl:text>
  <xsl:call-template name="label.id"/>

  <xsl:apply-templates select="bookinfo/abstract"/>

  <!-- Apply templates -->
  <xsl:apply-templates/>
  <xsl:if test="*//indexterm|*//keyword">
   <xsl:text>\printindex&#10;</xsl:text>
  </xsl:if>
  <xsl:value-of select="$latex.book.end"/>
</xsl:template>

<xsl:template match="othercredit">
  <xsl:text>\DBKinditem{</xsl:text>
  <xsl:value-of select="contrib"/>
  <xsl:text>}{</xsl:text>
  <xsl:value-of select="firstname"/>
  <xsl:text> </xsl:text>
  <xsl:value-of select="surname"/>
  <xsl:text>}&#10;</xsl:text>
</xsl:template>


<!-- ************
     For articles
     ************ -->

<xsl:template match="article">
  <xsl:value-of select="$latex.article.preamblestart"/>
  <xsl:call-template name="user.params.set"/>
  <xsl:if test="@lang">
    <xsl:text>\def\DBKlocale{</xsl:text>
    <xsl:value-of select="@lang"/>
    <xsl:text>}&#10;</xsl:text>
  </xsl:if>
  <xsl:text>\usepackage[article,hyperlink]{</xsl:text>
  <xsl:value-of select="$latex.style"/>
  <xsl:text>}&#10;</xsl:text>

  <xsl:if test="$latex.babel.use='1'">
    <xsl:call-template name="use.babel"/>
  </xsl:if>

  <xsl:apply-templates select="articleinfo" mode="docinfo"/>

  <!-- Override the infos if specified here -->
  <xsl:if test="subtitle">
    <xsl:text>\renewcommand{\DBKsubtitle}{</xsl:text>
    <xsl:call-template name="normalize-scape">
      <xsl:with-param name="string" select="subtitle"/>
    </xsl:call-template>
    <xsl:text>}&#10;</xsl:text>
  </xsl:if>

  <!-- Output title information -->
  <xsl:text>\title{</xsl:text>
    <xsl:call-template name="normalize-scape">
      <xsl:with-param name="string">
        <xsl:choose>
        <xsl:when test="./title">
          <xsl:value-of select="./title"/>
        </xsl:when>
        <xsl:when test="./articleinfo/title">
          <xsl:value-of select="./articleinfo/title"/>
        </xsl:when>
        <xsl:otherwise>
          <xsl:value-of select="./artheader/title"/>
        </xsl:otherwise>
        </xsl:choose>
      </xsl:with-param>
    </xsl:call-template>
  <xsl:text>}&#10;</xsl:text>

  <!-- Get the Author -->
  <xsl:variable name="author">
    <xsl:choose>
      <xsl:when test="articleinfo/authorgroup/author">
        <xsl:apply-templates select="articleinfo/authorgroup"/>
      </xsl:when>
      <xsl:when test="artheader/author">
        <xsl:apply-templates select="artheader/author"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:apply-templates select="articleinfo/author"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:variable>

  <xsl:text>\author{</xsl:text>
  <xsl:value-of select="$author"/>
  <xsl:text>}&#10;</xsl:text>

<!-- Set the indexation table -->
% ------------------
% Table d'Indexation
% ------------------
\renewcommand{\DBKindexation}{
\begin{DBKindtable}
\DBKinditem{\writtenby}{<xsl:value-of select="$author"/>}
<xsl:apply-templates select=".//othercredit"/>
\end{DBKindtable}
}

  <xsl:value-of select="$latex.book.afterauthor"/>
  <xsl:text>&#10;\setcounter{tocdepth}{</xsl:text>
  <xsl:value-of select="$toc.section.depth"/>
  <xsl:text>}&#10;</xsl:text>
  <xsl:text>&#10;\setcounter{secnumdepth}{</xsl:text>
  <xsl:value-of select="$doc.section.depth"/>
  <xsl:text>}&#10;</xsl:text>

  <!-- Apply the revision history here -->
  <xsl:if test="articleinfo/revhistory">
    <xsl:apply-templates select="articleinfo/revhistory"/>
  </xsl:if>

  <xsl:value-of select="$latex.book.begindocument"/>
  <xsl:text>\long\def\hyper@section@backref#1#2#3{%&#10;</xsl:text>
  <xsl:text>\typeout{BACK REF #1 / #2 / #3}%&#10;</xsl:text>
  <xsl:text>\hyperlink{#3}{#2}}&#10;</xsl:text>
  <xsl:text>&#10;</xsl:text>
  <xsl:text>\maketitle&#10;</xsl:text>
  <xsl:text>\tableofcontents&#10;</xsl:text>
  <xsl:call-template name="label.id"/>

  <!-- Apply templates -->
  <xsl:apply-templates/>
  <xsl:if test="*//indexterm|*//keyword">
   <xsl:text>\printindex&#10;</xsl:text>
  </xsl:if>
  <xsl:value-of select="$latex.book.end"/>
</xsl:template>

<xsl:template match="book/title"/>
<xsl:template match="article/title"/>
<xsl:template match="bookinfo"/>
<xsl:template match="articleinfo"/>

<!-- what to do with set? -->
<xsl:template match="set">
  <xsl:call-template name="label.id"/>
  <xsl:apply-templates/>
</xsl:template>

<xsl:template match="set/setinfo"></xsl:template>
<xsl:template match="set/title"></xsl:template>
<xsl:template match="set/subtitle"></xsl:template>

</xsl:stylesheet>
