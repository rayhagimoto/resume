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

Resume content is defined in a `YAML` file (`content.yaml`) and rendered using Jinja2.

### Basic Info (Header)

```yaml
profile:
  name: Ray Hagimoto
  title: Computational Physicist
  phone: (123) 456-7890
  email: ray@example.com
  location: Houston, TX
  linkedin: https://linkedin.com/in/rayhagimoto
  website: https://rayhagimoto.dev
```

### Supported Sections

* `profile`: Basic header info (rendered at top)
* `education`
* `experience`
* `skills`
* `leadership`
* `awards`

Each section is optional and rendered via modular Jinja2 templates in `src/sections/`.

### Section Format Example: `education`

```yaml
education:
  - organization: Rice University
    title: Doctor of Philosophy in Physics
    location: Houston, TX
    dates: Aug 2020 – Dec 2024
    bullets:
      - Coursework includes computational physics (Python), probability theory, and quantum field theory.
  - organization: UTSA
    title: Bachelor of Science in Physics
    location: San Antonio, TX
    dates: Aug 2016 – May 2020
    bullets:
      - Coursework includes linear algebra, calculus, and classical mechanics.
```

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
* Bullet points copy cleanly

This accomplished using the following setup:
```latex
% Unicode-safe font and encoding
\RequirePackage[utf8]{inputenc}
\RequirePackage[T1]{fontenc}
\RequirePackage{lmodern}
\RequirePackage{microtype}
\DisableLigatures{encoding = *, family = *}
\pdfgentounicode=1
```

You can check the plain text by opening up the PDF, selecting the whole document, then copying and pasting into a text editor. You should find that the layout is preserved, bullet points render as unicode characters, and there are no special characters or incorrectly interpreted symbols.

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
