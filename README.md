# Resume Builder

A LaTeX-based resume builder that generates professional, ATS-friendly PDF resumes from a YAML configuration file using Jinja2 templating.

## Features

*   YAML-based resume content management
*   Jinja2-powered LaTeX templating system with custom delimiters to avoid syntax conflicts
*   Docker and Python CLI support for builds
*   Modular templates and reusable section macros
*   ATS (Applicant Tracking System) optimized

## Prerequisites

*   **Python 3.12+** and `pip` (for local development)
*   **LaTeX Distribution** (e.g., TeX Live, MiKTeX) with `latexmk`
*   **Pandoc**
*   **(Optional) Docker** (for reproducible, dependency-free builds, slower than local builds)

---

## 📄 Configuration Overview

Resume content is defined in a structured `YAML` file (e.g., [`contents/resume.yaml`](contents/resume.yaml). The build script processes this file through a Jinja2 template engine. Individual strings are converted from Markdown to LaTeX using [Pandoc](https://pandoc.org) via `pypandoc`. This enables easy formatting while supporting raw LaTeX for advanced users.

### ✅ Format and Rendering Flow

1.  **Define content** in a `YAML` file. The file's structure is a set of sections (e.g., `profile`, `experience`).
2.  **Control section order** using the `sections` list at the top of your YAML file. The renderer will iterate through this list and include the corresponding `.tex` templates from `src/sections/`.
3.  **Write content** using Markdown-style strings for formatting.
4.  **The build script** automatically converts Markdown strings to LaTeX.
5.  **Jinja2 templates** render the content into a final `.tex` file, which is then compiled into a PDF using `latexmk`.

You may write your resume in clean, readable YAML with light formatting, while still gaining full LaTeX output fidelity.

---

### 🔤 Custom Template Syntax

To avoid conflicts with LaTeX's special characters, this project uses custom Jinja2 delimiters:

| Jinja2 Syntax | Custom Delimiter | Purpose                 |
| :------------ | :--------------- | :---------------------- |
| `{% ... %}`   | `\BLOCK{...}`    | Statements (loops, ifs) |
| `{{ ... }}`   | `\VAR{...}`      | Expressions, variables  |
| `{# ... #}`   | `\#{...}`        | Comments                |

This ensures that you can freely use standard LaTeX syntax within your templates without it being misinterpreted by the Jinja2 engine.

---

### 👤 Basic Info (Header)

The `profile` section in your YAML populates the resume header.

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
  - institution: Prestige University
    degree: Doctor of Philosophy in [Your Subject]
    location: City, ST
    dates: Aug 2020 – Dec 2024
    bullets:
      - I studied **bold-faced useful skill**.
  - institution: UTSA
    degree: Bachelor of Science in [Your Subject]
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
  - title: Quantitative Research Intern
    organization: Company Name
    location: City, ST
    dates: Summer 2023
    bullets:
      - Built a trading strategy with **Sharpe ratio > 1,000,000**.
      - Collaborated with traders to improve model risk metrics.
      - Documented workflows using \LaTeX{} and Markdown syntax.
```

---

## 🧱 Project Structure

```
.
├── contents/
│   ├── resume.yaml           # Default resume data
│   └── jobs/                 # Directory for company-specific YAML files
│   └── mypapers.bib          # Bibliography file
├── compile_resume.py       # Main script to render and compile
├── scripts/
│   ├── build_docker.sh       # Docker-based build script
│   └── build_local.sh        # Local build script (for VSCode tasks)
├── Dockerfile              # Image with all build tools
├── requirements.txt        # Python dependencies (jinja2, pyyaml, pypandoc)
├── output/                 # Compiled PDFs appear here
└── src/
    ├── main.tex              # Top-level LaTeX template
    ├── styles.cls            # Custom LaTeX class & formatting
    ├── partials/
    │   └── macros.tex        # Reusable LaTeX and Jinja2 macros
    └── sections/             # Jinja2 templates for each resume section
```

Each section template uses LaTeX macros like `\BaseSection`, `\BaseEntry`, and `\TightFrame` for consistent layout.

---

## 🛠️ Building Your Resume

### 🐳 Docker (Recommended)

The Docker build is the simplest way to compile your resume, as it requires no local installation of LaTeX or other dependencies.

From the project root, run:
```bash
./scripts/build_docker.sh
```
This command will build the Docker image if it doesn't exist, then run the compilation using `contents/resume.yaml`, and place the output in the `output/` directory.

#### Custom Docker Builds

You can specify a different content file, output directory, or filename.

```bash
# Build a specific YAML file
./scripts/build_docker.sh --content contents/jobs/MyCustomResume.yaml

# Specify output directory and filename
./scripts/build_docker.sh --output-dir ./pdfs --filename my_resume.pdf
```

Build script options:
* `--content`: Path to the input YAML file.
* `--output-dir`: Output directory (default: `./output`).
* `--filename`: Output file name (default: auto-generated from profile name).
* `-y, --yes`: Skip the prompt to overwrite an existing file.

### 🐍 Local Development (No Docker)

For local development, you must have **Python**, **Pandoc**, and a **LaTeX** distribution installed.

First, set up the Python environment:
```bash
python -m venv .venv
source .venv/bin/activate  # Windows: .venv\Scripts\activate
pip install -r requirements.txt
```

While you can run `compile_resume.py` directly, the recommended way to build locally is via the provided VSCode task, which uses `scripts/build_local.sh`.

1.  Open the project in VSCode.
2.  Open the YAML file you wish to compile (e.g., `contents/resume.yaml`).
3.  Open the command palette (`Ctrl+Shift+P` or `Cmd+Shift+P`).
4.  Run the task `Tasks: Run Task` and select `Compile YAML`.

The compiled PDF will appear in the `output/` directory. If you compile a file from `contents/jobs/`, the PDF will be placed in `output/jobs/`.

---
## ✍️ Customization

### Adding a New Section

1.  Add a new data block to your `contents/resume.yaml` file (e.g., `volunteering: ...`).
2.  Create a corresponding template file `src/sections/volunteering.tex`.
3.  Add `"volunteering"` to the `sections` list at the top of your `resume.yaml` to include it in the output.

### Creating Resume Variants

To create a resume tailored for a specific company:

1.  Create a new YAML file, e.g., `contents/jobs/CompanyA.yaml`.
2.  Customize the content as needed.
3.  Build it using the `--content` flag:
    ```bash
    ./scripts/build_docker.sh --content contents/jobs/CompanyA.yaml
    ```
    The output will be named `[Your_Name]_Resume_CompanyA.pdf`.

### Editing Styles

*   Modify `src/styles.cls` to change fonts, colors, and spacing.
*   Edit `src/partials/macros.tex` to adjust how section items are rendered.

---

## ✅ ATS Compliance

This template is designed to produce PDFs that are easily parsed by Applicant Tracking Systems.

*   **Plaintext-friendly PDF**: The output can be cleanly copied and pasted into a plain text editor.
*   **Standard Encoding**: Uses UTF-8 and standard fonts.
*   **No Ligatures**: Disables ligatures (e.g., `ff`, `fi`) that can confuse parsers.
*   **Simple Dashes**: Automatically converts all dash types (en-dash, em-dash, `--`) into a simple hyphen (`-`) for consistency.
*   **Clean Bullets**: Bullet points are rendered as a simple `*` that copies correctly.

You can verify the result by opening the PDF, selecting all text (`Ctrl+A`), and pasting it into a text file. The layout should be preserved and all symbols should be standard ASCII characters.
