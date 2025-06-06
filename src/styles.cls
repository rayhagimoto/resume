%==========================================================
% styles.cls — Custom document class
%==========================================================
\NeedsTeXFormat{LaTeX2e}
\ProvidesClass{styles}[2025/06/06 Custom CV/resume class]

% Load base class
\LoadClass[10pt,letterpaper]{article}

% Required packages
\RequirePackage[utf8]{inputenc}
\RequirePackage[top=0.5in,left=0.5in,right=0.5in,bottom=0.5in]{geometry}
\RequirePackage{enumitem}
\RequirePackage[hidelinks]{hyperref}
\RequirePackage{xstring}
\RequirePackage{titlesec}
\RequirePackage{titling}

%----------------------------------------------------------
% Redefine section to include spacing + rule
%----------------------------------------------------------
\titleformat{\section}
  {\bfseries}{}{0pt}{}[{\vspace{0.1em} \titlerule[0.1pt]}]
\titlespacing*{\section}{0pt}{0.6em}{0.6em}

%----------------------------------------------------------
% Strip off "<scheme>://" from a URL
%----------------------------------------------------------
\newcommand{\ShortURL}[1]{%
  \IfSubStr{#1}{://}{%
    \StrBehind{#1}{://}[\urlbody]%
    \urlbody
  }{#1}%
}

%----------------------------------------------------------
% No indent, no paragraph skip
%----------------------------------------------------------
\setlength{\parindent}{0pt}
\setlength{\parskip}{0pt}

%----------------------------------------------------------
% Tighter itemize formatting
%----------------------------------------------------------
\setlist[itemize]{%
  topsep=0pt,
  itemsep=0pt,
  parsep=0pt,
  partopsep=0pt,
  leftmargin=1em
}

%----------------------------------------------------------
% Remove page numbers
%----------------------------------------------------------
\pagenumbering{gobble}

%----------------------------------------------------------
% === PERSONAL INFO SLOTS ===
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
  \begin{center}
    {\large\bfseries \MakeUppercase{\Name}}\\
    \vspace{0.2em}
    {\itshape \Title}\\
    \vspace{0.2em}
    \Phone \,$|$\, 
    \href{mailto:\Email}{\Email} \,$|$\, 
    \href{\LinkedInURL}{\ShortURL{\LinkedInURL}} \,$|$\, 
    \href{\WebsiteURL}{\ShortURL{\WebsiteURL}}\\
    \vspace{0.2em}
    \Location
  \end{center}
}

%----------------------------------------------------------
% === PROFILE SLOT ===
%----------------------------------------------------------
\newcommand{\ProfileText}{}

%----------------------------------------------------------
% Helper → Bold everything up to the FIRST comma
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

%----------------------------------------------------------
% === EDUCATION ENTRY MACRO ===
%----------------------------------------------------------
\newcommand{\EducationEntry}[4]{%
  \noindent
  \begin{tabular*}{\textwidth}{l@{\extracolsep{\fill}}r}
    \BoldBeforeComma{#1} & #2 \\
    \multicolumn{2}{l}{\textit{#3}} \\
  \end{tabular*}%
  #4%
  \vspace{0.5em}
}

%----------------------------------------------------------
% === EXPERIENCE ENTRY MACRO ===
%----------------------------------------------------------
\newcommand{\ExperienceEntry}[4]{%
  \noindent
  \begin{tabular*}{\textwidth}{l@{\extracolsep{\fill}}r}
    \BoldBeforeComma{#1} & #2 \\
    \multicolumn{2}{l}{\textit{#3}} \\
  \end{tabular*}%
  #4%
  \vspace{0.5em}
}

%----------------------------------------------------------
% === LEADERSHIP ENTRY MACRO ===
%----------------------------------------------------------
\newcommand{\LeadershipEntry}[4]{%
  \noindent
  \begin{tabular*}{\textwidth}{l@{\extracolsep{\fill}}r}
    \BoldBeforeComma{#1} & #2 \\
    \multicolumn{2}{l}{\textit{#3}} \\
  \end{tabular*}%
  #4%
  \vspace{0.5em}
}

%----------------------------------------------------------
% === AWARD ENTRY MACRO ===
%----------------------------------------------------------
\newcommand{\AwardEntry}[1]{%
  \item #1
} 