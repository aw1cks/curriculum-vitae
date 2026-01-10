%%%%%%

\ProvidesClass{cv}[Alex Wicks Curriculum Vitae]

%%%%%%

\DeclareOption*{\PassOptionsToClass{\CurrentOption}{extarticle}} % Pass through any options to the base class
\ProcessOptions\relax % Process given options

\LoadClass{extarticle} % Load the base class

%%%%%%

\usepackage[hidelinks]{hyperref} % Required for links but hide the default boxes around links

\pagestyle{empty} % No headers or footers

%%%%%%

\usepackage{geometry} % Required for adjusting page dimensions and margins
\usepackage{multicol} % Multi-column bullet points

\geometry{
	paper=a4paper, % Paper size, change to letterpaper for US letter size
	top=1cm, % Top margin
	bottom=1cm, % Bottom margin
	left=1.5cm, % Left margin
	right=1.5cm, % Right margin
	headheight=0.1cm, % Header height
	footskip=0.1cm, % Space from the bottom margin to the baseline of the footer
	headsep=0.1cm, % Space from the top margin to the baseline of the header
}
\setlength{\parindent}{20pt} % disable paragraph indentation

%%%%%%

\usepackage[dvipsnames]{xcolor}
\definecolor{fg}{HTML}{242424}
\definecolor{accent}{HTML}{0E508D}

%%%%%%

\usepackage{moresize}
\usepackage{fontspec}
\usepackage{xunicode}

\defaultfontfeatures{Mapping=tex-text}
\setmainfont{IBM Plex Sans}
\setmonofont{IBM Plex Mono}

%%%%%%

\newcommand{\accentText}[1]{\textcolor{accent}{\textbf{#1}}}

\usepackage{fontawesome5}
\newcommand{\contactEntry}[2]{
  \textcolor{accent}{\small{\faIcon{#1}}}
  \textcolor{fg}{\normalsize{#2}}
}
\newcommand{\contacts}[1]{
  \begin{tabular}{c}
    #1
  \end{tabular}
}

\newcommand{\cvName}[1]{
  \textcolor{black}{\textbf{\texttt{\huge{#1}}}}
}

\usepackage{adjustbox}
\newcommand{\cvHeading}[2]{
  \raggedright\cvName{#1}
  \smallskip
  \\#2
}

\newcommand{\cvSection}[1]{
  \medskip
  \raggedright
  \textcolor{accent}{\texttt{\textbf{\Large{#1}}}}
  \medskip
}

\newcommand{\cvParagraph}[1]{%
  \hfill\begin{minipage}{\dimexpr\textwidth-0.2cm}
  \par\raggedright\small\textcolor{fg}{#1}%
  \end{minipage}
}

\newcommand{\cvSkillsGrid}[2]{
  \begin{minipage}[t]{0.48\textwidth}
    #1
  \end{minipage}
  \hfill
  \begin{minipage}[t]{0.48\textwidth}
    #2
  \end{minipage}
}

\newcommand{\cvSkillCategory}[2]{
  \textcolor{accent}{\textbf{#1}} \\
  \textcolor{fg}{\small{#2}}
  \vspace{0.3em}
}

\newcommand{\cvSkillsDivider}{
  \vspace{0.3em}
  \noindent{\rule{\textwidth}{0.25pt}}
}

\newcommand{\cvCertifications}[1]{
  \noindent\textcolor{accent}{\textbf{Certifications}} \\
  \textcolor{fg}{\small{#1}}
}

\newcommand{\cvDateRange}[2]{
  \scriptsize{\textit{\textbf{#1 - #2}}}
}

\newcommand{\cvJob}[3]{
  \par
  \smallskip
  \raggedright
  \-\hspace{0.1cm}\textcolor{accent}{\textbf{#1}}
  \hfill
  \textcolor{black}{#2}
  \par
  \smallskip
  \cvParagraph{#3}
}

\newcommand{\cvCompany}[3][]{
  \par
  \raggedright\textcolor{black}{\textbf{\large{#2}}} \textcolor{fg}{#1}
  #3
  \medskip
}
