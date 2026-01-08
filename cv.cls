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
\setlength{\parindent}{0pt} % disable paragraph indentation

%%%%%%

\usepackage[dvipsnames]{xcolor}
\definecolor{fg}{HTML}{4E4E4E}
\definecolor{accent}{HTML}{0E508D}

%%%%%%

\usepackage{moresize}
\usepackage{fontspec}
\usepackage{xunicode}

\defaultfontfeatures{Mapping=tex-text}
\setmainfont{IBM Plex Sans Condensed}
\setmonofont{IBM Plex Mono}

%%%%%%

\newcommand{\accentText}[1]{\textcolor{accent}{#1}}

\usepackage{fontawesome5}
\newcommand{\contactEntry}[2]{
  \textcolor{accent}{\large{\faIcon{#1}}}
  \textcolor{fg}{\normalsize{#2}}
}
\newcommand{\contacts}[1]{
  \begin{tabular}{c}
    #1
  \end{tabular}
  \bigskip
}

\newcommand{\cvName}[1]{
  \textcolor{black}{\textbf{\texttt{\huge{#1}}}}
}

\newcommand{\cvHeading}[2]{
  \begin{center}
    #2
    \par
    \cvName{#1}
  \end{center}
}

\newcommand{\cvSection}[1]{
  \smallskip
  \raggedright
  \textcolor{accent}{\texttt{\textbf{\large{#1}}}}
  \medskip
}

\newcommand{\cvParagraph}[1]{%
  \par\raggedright\small\textcolor{fg}{#1}\par%
}

\newcommand{\cvDateRange}[2]{
  #1
  \textemdash\:
  #2
}

\newcommand{\cvJob}[3]{
  \par
  \smallskip
  \raggedright
  \textcolor{accent}{\large{#1}}
  \textcolor{black}{\footnotesize{#2}}
  \par
  \smallskip
  \cvParagraph{#3}
}

\newcommand{\cvCompany}[3][]{
  \par
  \raggedright\textcolor{black}{\textbf{\large{#2}}} \textcolor{fg}{#1}
  #3
  \begin{center}
    \textcolor{fg}{\noindent\rule{\dimexpr\textwidth-1cm\relax}{0.125pt}}
  \end{center}
}
