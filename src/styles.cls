%==========================================================
% styles.cls — ATS-compatible Custom Resume Class
%==========================================================
% Contains:
% Font, spacing, margins, enumitem setup, no logic/macros

\NeedsTeXFormat{LaTeX2e}
\ProvidesClass{styles}[2025/06/12 ATS-safe resume class]

% Load base class
\LoadClass[10pt,letterpaper]{article}

% Unicode-safe font and encoding
\RequirePackage[utf8]{inputenc}
\RequirePackage[T1]{fontenc}
\RequirePackage{lmodern}
\RequirePackage{microtype}
\DisableLigatures{encoding = *, family = *}
\pdfgentounicode=1
\pdfinclusioncopyfonts=1
\renewcommand{\labelitemi}{\textasteriskcentered} % bullet points use asterisk


% Layout and formatting
\RequirePackage[top=0.5in,left=0.5in,right=0.5in,bottom=0.5in]{geometry}
\RequirePackage{enumitem}
\RequirePackage[hidelinks]{hyperref}
\RequirePackage{xstring}
\RequirePackage{xspace}
\RequirePackage{titlesec}
\RequirePackage{titling}
\RequirePackage{mdframed}
\AtBeginDocument{\sloppy}

%----------------------------------------------------------
% Section formatting
%----------------------------------------------------------
\titleformat{\section}
  {\bfseries}{}{0pt}{}[{\vspace{0.1em} \titlerule[0.1pt]}]
\titlespacing*{\section}
  {0pt}     % left margin 
  {0em}     % padding before, or 0em or 0.2em
  {0.6em}   % padding after 


%----------------------------------------------------------
% Strip "<scheme>://" from URL for display
%----------------------------------------------------------
\newcommand{\ShortURL}[1]{%
  \IfSubStr{#1}{://}{%
    \StrBehind{#1}{://}[\urlbody]%
    \urlbody
  }{#1}%
}

%----------------------------------------------------------
% No paragraph indent or skip
%----------------------------------------------------------
\setlength{\parindent}{0pt}
\setlength{\parskip}{0pt} % 0pt or 2pt

%----------------------------------------------------------
% Tighter itemize formatting
%----------------------------------------------------------
\setlist[itemize]{%
topsep=0pt,
itemsep=0pt, % 0pt or 2pt
parsep=0pt,
partopsep=0pt,
leftmargin=1em
}

%----------------------------------------------------------
% Custom mdframed block
%----------------------------------------------------------
\newmdenv[
  linewidth=0pt,
  innerleftmargin=0pt,
  innerrightmargin=0pt,
  innertopmargin=0pt,
  innerbottommargin=0pt,
  skipabove=0.3em, 
  skipbelow=0.3em,
  nobreak=true,
]{TightFrame}

%----------------------------------------------------------
% No page numbers
%----------------------------------------------------------
\pagenumbering{gobble}

%----------------------------------------------------------
% === PERSONAL INFO MACROS ===
%----------------------------------------------------------
\newcommand{\Name}{}
\newcommand{\Title}{}
\newcommand{\Phone}{}
\newcommand{\Email}{}
\newcommand{\Location}{}
\newcommand{\LinkedInURL}{}
\newcommand{\WebsiteURL}{}

%----------------------------------------------------------
% === HEADER MACRO ===
%----------------------------------------------------------
\newcommand{\MakeHeader}{%
  \noindent
  \parbox{\textwidth}{%
    \centering
    {\Large\bfseries \Name}\\[0.2em]
    { \itshape \Title}\\[0.2em]
    \Phone \,$|$\,
    \href{mailto:\Email}{\Email} \,$|$\,
    \href{\LinkedInURL}{\ShortURL{\LinkedInURL}} \,$|$\,
    \href{\WebsiteURL}{\ShortURL{\WebsiteURL}}\\[0.2em]
    Address: \Location
  }%
  % \vspace*{0em}
}

% \newcommand{\MakeHeader}{%
%   \begin{center}
%     {\large\bfseries \MakeUppercase{\Name}}\\
%     \vspace{0.2em}
%     {\large \itshape \Title}\\
%     \vspace{0.2em}
%     \Phone \,$|$\, 
%     \href{mailto:\Email}{\Email} \,$|$\, 
%     \href{\LinkedInURL}{\ShortURL{\LinkedInURL}} \,$|$\, 
%     \href{\WebsiteURL}{\ShortURL{\WebsiteURL}}\\
%     \vspace{0.2em}
%     Address: \Location
%   \end{center}
% }

%----------------------------------------------------------
% === PROFILE SLOT ===
%----------------------------------------------------------
\newcommand{\ProfileText}{}

%----------------------------------------------------------
% Bold everything up to the first comma
%----------------------------------------------------------
\newcommand{\BoldBeforeComma}[1]{%
  \expandafter\BoldBeforeCommaAux#1,\relax
}
\def\BoldBeforeCommaAux#1,#2\relax{%
  {\bfseries #1}%
  \ifx\relax#2\relax
  \else ,#2
  \fi
}