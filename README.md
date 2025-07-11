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
*   **(Optional) Docker** (for reproducible, dependency-free builds, slower than local builds)

---
## Quickstart

Copy the example resume at contents/resume.yaml and fill in the fields with your own data. Each top-level field defines a section, and the sections which will be included in the rendered resume will be in the `sections:` field. For example,

```
sections:
  - 'profile'

profile:
  name: 'Jane Doe'
  title: 'Awesome job title'
  phone: '(123) 456-7890'
  email: 'janedoe@example.com'
  location: 'City, ST'
  linkedin: 'https://linkedin.com/in/janedoe'
  website: 'https://janedoe.me'

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

# other sections below
```

would only render the `profile` section. This makes the design a bit more modular on the fly. You can swap in and out different sections in case one might be relevant for some jobs, and not for others. You could also use it to write up the content for your entire CV and then choose which sections you actually want to include in your resume. 

If you have all the prerequisites installed you could then render the PDF with 

```
python compile_resume.py --content /path/to/content.yaml --output /path/to/resume.pdf --build /path/to/build_dir
```

By default this script will write the .tex file that's rendered using the YAML to the `/build` directory and make the output directory structure if needed.

## 📄 Configuration Overview

Resume content is defined in a structured `YAML` file (e.g., [`contents/resume.yaml`](contents/resume.yaml)). The build script processes this file through a Jinja2 template engine. Individual strings are rendered directly into LaTeX. This enables easy formatting while supporting raw LaTeX for advanced users.

### ✅ Format and Rendering Flow

1.  **Define content** in a `YAML` file. The file's structure is a set of sections (e.g., `profile`, `experience`).
2.  **Control section order** using the `sections` list at the top of your YAML file. The renderer will iterate through this list and include the corresponding `.tex` templates from `src/sections/`.
3.  **Write content** using Markdown-style strings for formatting (basic support).
4.  **The build script** automatically renders the content into LaTeX.
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
├── build/                    # Where the main.tex gets rendered from the resume.yaml
├── contents/
│   ├── resume.yaml           # Default resume data
│   └── jobs/                 # Directory for company-specific YAML files
│   └── mypapers.bib          # Bibliography file
├── compile_resume.py       # Main script to render and compile
├── scripts/
│   ├── build_docker.sh       # Docker-based build script
│   └── build_local.sh        # Local build script (for VSCode tasks)
├── Dockerfile              # To build image with all build tools
├── requirements.txt        # Python dependencies (jinja2, pyyaml)
├── output/                 # Example compiled PDF is here, but you can output wherever you want
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
./scripts/build_docker.sh --content contents/resume.yaml --output output/Your_Name_Resume.pdf --build build
```
This command will build the Docker image if it doesn't exist, then run the compilation using the specified YAML file, and place the output in the `output/` directory.

#### Custom Docker Builds

You can specify a different content file, output directory, or filename.

```bash
# Build a specific YAML file
./scripts/build_docker.sh --content contents/jobs/MyCustomResume.yaml --output output/MyCustomResume.pdf --build build
```

Build script options:
* `--content`: Path to the input YAML file.
* `--output`: Output PDF file path (default: auto-generated from profile name).
* `--build`: Build directory for intermediate files (required).
* `-y, --yes`: Skip the prompt to overwrite an existing file.

### 🐍 Local Development (No Docker)

For local development, you must have **Python** and a **LaTeX** distribution installed.

First, set up the Python environment:
```bash
python -m venv .venv
source .venv/bin/activate  # Windows: .venv\Scripts\activate
pip install -r requirements.txt
```

You can run `compile_resume.py` directly:
```bash
python compile_resume.py --content contents/resume.yaml --output output/Your_Name_Resume.pdf --build build
```

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
3.  Build it using the `--content` and `--output` flags:
    ```bash
    ./scripts/build_docker.sh --content contents/jobs/CompanyA.yaml --output output/CompanyA_Resume.pdf --build build
    ```
    The output will be named `CompanyA_Resume.pdf`.

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
