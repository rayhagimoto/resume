# Resume Builder

A LaTeX-based resume builder that generates professional PDF resumes from a YAML configuration file using Jinja2 templating. Designed for modularity, customization, and clean ATS-friendly output.

[Example Output](https://rayhagimoto.github.io/resume/Ray_Hagimoto_Resume.pdf)

## Features

* YAML-based resume content management
* Jinja2-powered LaTeX templating system
* Docker and Python CLI support for builds
* Modular templates and reusable section macros
* ATS (Applicant Tracking System) optimized
* Company-specific resume variants

## Prerequisites

* **Python 3.12+** (for local development)
* **Docker** (for reproducible builds)

---

## 📄 Configuration Overview

Resume content is defined in a structured `YAML` file (`content.yaml`). Each section is passed through a Jinja2 template engine, and individual strings are converted from Markdown to LaTeX using [Pandoc](https://pandoc.org) via `pypandoc`. This enables easy formatting while supporting raw LaTeX for advanced users.

---

### ✅ Format and Rendering Flow

1. **Write content** in `YAML` format, using Markdown-style strings for formatting.
2. **Each section** (e.g., `education`, `experience`) corresponds to a Jinja2 template in [src/sections](src/sections).
3. **Markdown strings** are automatically converted to LaTeX using `pandoc`.
4. **LaTeX templates** (e.g., `macros.tex`) render this content into a PDF using `latexmk`.

You may write your resume in clean, readable YAML with light formatting, while still gaining full LaTeX output fidelity.

---

### 🔤 Supported Markdown Formatting

Pandoc supports most inline Markdown. You may also include raw LaTeX.

| Input (YAML)                        | Renders as (LaTeX)                     |
| ----------------------------------- | -------------------------------------- |
| `"**Bold** and *italic*"`           | `\textbf{Bold} and \textit{italic}`    |
| `"This is \\LaTeX{} code"`          | `This is \LaTeX{}`                     |
| `"Use [link](https://example.com)"` | `Use \href{https://example.com}{link}` |
| `"Ends with sentence.  "`           | Adds proper spacing in LaTeX           |

---

### 👤 Basic Info (Header)

```yaml
profile:
  name: Jane Doe
  title: Awesome job title
  phone: (123) 456-7890
  email: janedoe@example.com
  location: City, ST
  linkedin: https://linkedin.com/in/janedoe
  website: https://janedoe.me
```

This section is rendered using `\renewcommand` and the `\MakeHeader` macro in LaTeX.

---

### 🎓 Section Example: `education`

```yaml
education:
  - organization: Prestige University
    title: Doctor of Philosophy in [Your Subject]
    location: City, ST
    dates: Aug 2020 – Dec 2024
    bullets:
      - I studied **bold-faced useful skill**.
  - organization: UTSA
    title: Bachelor of Science in [Your Subject]
    location: City, ST
    dates: Aug 2016 – May 2020
    bullets:
      - _Italicized skill_.
```

Each entry (marked by `-`) is passed to a Jinja2 macro called `BaseEntry`, then rendered into a `TightFrame` block for layout consistency.

---

### 💼 Section Example: `experience`

```yaml
experience:
  - organization: Company Name
    title: Quantitative Research Intern
    location: City, ST
    dates: Summer 2023
    bullets:
      - Built a trading strategy with **Sharpe ratio > 1,000,000**.
      - Collaborated with traders to improve model risk metrics.
      - Documented workflows using \LaTeX{} and Markdown syntax.
```

---

### 🧠 Tips for Authors

* You may mix raw LaTeX (e.g., `\LaTeX{}`) and Markdown (e.g., `**bold**`) in the same string.
* Sentence endings followed by double spaces (`.  `) will properly trigger LaTeX spacing.
* Trailing and leading whitespace is trimmed automatically during rendering.
* If both `bullets` and `description` are provided in a section item, `bullets` will appear first.
---

## 🧱 Project Structure

```
.
├── content.yaml            # YAML resume data
├── compile_resume.py       # Main script to render and compile
├── build.sh                # Docker wrapper for build
├── Dockerfile              # Image with LaTeX build tools
├── requirements.txt        # Python deps (jinja2, pyyaml)
├── output/                 # Compiled PDFs
└── src/
    ├── template.tex        # Top-level LaTeX template
    ├── styles.cls          # Custom LaTeX class & macros
    ├── macros.tex          # Jinja2 macro definitions
    ├── sections/           # Jinja2 templates for each section
```

Each section template uses LaTeX macros like `\BaseSection`, `\BaseEntry`, and `\TightFrame` for consistent layout.

---

## 🛠️ Building Your Resume

### 🐳 Docker (Recommended)

```bash
./build.sh
./build.sh --filename my_resume.pdf --output-dir ./pdfs content.yaml
```

Build script options:

* `--output-dir`: Output directory (default: `./output`)
* `--filename`: Output file name (default: auto-inferred)
* `-y`: Skip overwrite prompt

### 🐍 Local Development (No Docker)

```bash
python -m venv .venv
source .venv/bin/activate  # Windows: .venv\Scripts\activate
pip install -r requirements.txt
python compile_resume.py
```

Output PDF saved to `output/`.

---

## ✍️ Customization

### Adding a New Section

1. Add YAML block to `content.yaml`
2. Create a new Jinja2 template in `src/sections/`
3. Extend `compile_resume.py` if needed

### Editing Styles

* Modify `src/styles.cls` (LaTeX class)
* Header rendered via `\renewcommand{\Name}{...}` and `\MakeHeader`

### Example LaTeX Block

Each section is enclosed in a `\begin{TightFrame}` block to avoid section-title separation.

---

## ✅ ATS Compliance

* Plaintext-friendly PDF
* Standard UTF-8 encoding
* Clean structure, no hidden formatting
* Bullet points copy cleanly as `*`
* Hyphens rendered as `-` instead of en/em-dashes or `--`

This is accomplished using the following setup:

```latex
% Unicode-safe font and encoding
\RequirePackage[utf8]{inputenc}
\RequirePackage[T1]{fontenc}
\RequirePackage{lmodern}
\RequirePackage{microtype}
\DisableLigatures{encoding = *, family = *}
\pdfgentounicode=1
```

Additionally, a postprocessing step ensures:

* All en-dashes (`–`), em-dashes (`—`), and LaTeX `--` sequences are replaced with a simple hyphen (`-`) for clean copy-pasting
* Bullet points are explicitly rendered as `*` using `\textasteriskcentered{}` in LaTeX

You can verify the result by copying the entire PDF content into a plain text editor. The layout should be preserved, all symbols recognizable, and no ligature or dash substitutions that would confuse an ATS parser.

---

## 📦 Using as a Git Submodule

```bash
git submodule add https://github.com/rayhagimoto/resume.git
```

Then render with:

```bash
./resume/build.sh my_content.yaml
```

---

## Contributing

Pull requests and suggestions welcome.
