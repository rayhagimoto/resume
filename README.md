# Resume Builder

A LaTeX-based resume builder that generates professional PDF resumes from a YAML configuration file. The project uses Docker to ensure consistent builds across different environments.

[Example Output](https://rayhagimoto.github.io/resume/Ray_Hagimoto_Resume.pdf)

## Features

- YAML-based resume content management
- LaTeX-based PDF generation
- Docker support for consistent builds
- Support for company-specific resume versions
- Clean and professional output
- ATS (Applicant Tracking System) optimized - ensures proper text extraction and character encoding when copying content from the PDF

## Prerequisites

- Docker (for containerized builds)
- Python 3.12+ (for local development)

## Configuration

The resume content is managed through `content.yaml`. Here's a breakdown of the configuration structure:

### Basic Information
```yaml
target_company: # Optional company name for targeted resumes
candidate:
  name: Your Name
  title: Your Title
  summary: |
    Your professional summary
  location: Your Location
  phone: Your Phone
  email: Your Email
  website: Your Website
  linkedin: Your LinkedIn URL
  github: Your GitHub URL
```

### Sections

#### Currently Implemented Sections
These sections are fully supported in the current template:
- `education`: List of educational background
- `skills`: List of technical skills
- `experience`: Work experience entries
- `leadership`: Leadership roles and responsibilities
- `awards`: Achievements and recognitions
- `projects`: Personal or professional projects

#### Planned Sections (Not Yet Implemented)
These sections are defined in the YAML but not yet rendered in the template:
- `talks`: Presentations and speaking engagements
- `coursework`: Relevant academic courses
- `technologies`: Technical skills breakdown

Each section follows a specific format as shown in the example `content.yaml` file. The template is designed to be modular, allowing for easy addition of new sections in the future.

#### 📦 Custom Sections

This resume template organizes each section (e.g. Education, Experience, Projects) into an `mdframed` block to **prevent section titles from being visually separated from their content**.

The content is populated by using a Python script to interpret the `content.yaml`, then create the LaTeX source code using `jinja2` templating. The `jinja2` template can be found at [resume_template.tex](src/resume_template.tex). 
Most of the sections are styled using the `\BaseSection` and `\BaseEntry` LaTeX macros which are defined in [styles.cls](src/styles.cls).

Here's an example of how the `education:` section is defined in YAML:

```yaml
education:
  - organization: Generic University A
    title: Doctor of Philosophy in [Your Field]
    location: City A, State A
    dates: Aug 20XX – Dec 20YY
    gpa: 3.50
    bullets: 
      - Advanced studies and research in [Your Field].
      - Completed comprehensive coursework in core theoretical and applied areas.
  - organization: Generic University B
    title: Bachelor of Science in [Your Field]
    location: City B, State B
    dates: Aug 20XX – May 20YY
    gpa: 3.50
    bullets: 
      - Foundational coursework in [Your Field] and related disciplines.
      - Developed strong analytical and problem-solving skills.
```

The template is then something like the following pseudocode:

```latex
% PSEUDOCODE
\BaseSection{EDUCATION}{% % automatically converted to all caps using jinja template
FOR entry IN section:
  \BaseEntry%
    {entry.arg1}% <-- user needs to choose which fields to access by editing the template.
    {entry.arg2}%
    {entry.arg3}%
    {entry.arg4}%
    {entry.arg5}%
}%
END FOR
```

Where:
- `arg1`: Appears **bolded**, top-left (e.g. job title or degree)
- `arg2`: Appears **top-right**, same line (e.g. date range)
- `arg3`: Appears in *italics* beneath, left-aligned (e.g. organization or university)
- `arg4`: Appended to `#3` after a comma (e.g. location); omitted if empty
- `arg5`: Optional additional content (e.g. bullets or description), placed in a nested `TightFrame`

---

#### ✨ Rendered Example

This YAML entry:

```yaml
- organization: Organization Name
  title: Job Title
  location: Houston, TX
  dates: June 2024 – Aug 2024
  bullets:
    - I did something cool which made a measurable impact.
```

Will render approximately as:

```
┌────────────────────────────────────────────────────────────────┐
│ **Job Title**                             June 2024 – Aug 2024 │
│ _Organization Name,_ Houston, TX                               │
│   • I did something cool which made a measurable impact.       │
└────────────────────────────────────────────────────────────────┘
```

> Note: By default box outline is not printed since the custom `mdframed` environment I defined in `[styles.cls](src/styles.cls)` has no border (`linewidth=0pt`).



## Building the Resume

### Using Docker (Recommended)

1. Make sure Docker is installed on your system
2. Run the build script with your desired options:
```bash
# Basic usage (uses content.yaml in current directory)
./build.sh

# Specify a custom content.yaml location
./build.sh /path/to/your/content.yaml

# Specify a custom output directory
./build.sh --output-dir /path/to/output /path/to/your/content.yaml

# Specify a custom output filename
./build.sh --filename my_resume.pdf /path/to/your/content.yaml

# Force overwrite existing files without prompting
./build.sh -y /path/to/your/content.yaml

# Combine multiple options
./build.sh -y --output-dir /path/to/output --filename my_resume.pdf /path/to/your/content.yaml
```

The build script options are:
- `--output-dir`: Specify a custom output directory (default: `./output`)
- `--filename`: Specify a custom output filename (default: auto-generated based on name and company)
- `-y` or `--yes`: Automatically overwrite existing files without prompting

The script will:
- Build a Docker image with all necessary dependencies
- Compile your resume
- Output the PDF to the specified directory (or `output` by default)
- Prompt for confirmation before overwriting existing files (unless `-y` is used)

### Using as a Submodule

You can include this repository as a submodule in your own project to maintain your resume content separately:

1. Add the repository as a submodule:
```bash
git submodule add https://github.com/rayhagimoto/resume.git
```

2. Create your `content.yaml` in your project's root directory:
```bash
touch content.yaml
```

3. Build your resume using the submodule's build script:
```bash
./resume/build.sh ../content.yaml
```

This setup allows you to:
- Keep your resume content in your own repository
- Update the resume builder independently
- Maintain multiple content files for different purposes
- Use the resume builder in multiple projects

### Local Development

1. Create and activate a Python virtual environment:
```bash
# Create virtual environment
python -m venv .venv

# Activate virtual environment
# On Windows:
.venv\Scripts\activate
# On Unix or MacOS:
source .venv/bin/activate
```

2. Install required Python packages:
```bash
pip install -r requirements.txt
```

3. Install LaTeX dependencies:

On Ubuntu/Debian:
```bash
sudo apt-get update && sudo apt-get install -y \
    texlive-latex-base \
    texlive-fonts-recommended \
    texlive-fonts-extra \
    texlive-latex-extra \
    lmodern \
    latexmk
```

On macOS (using Homebrew):
```bash
brew install --cask mactex
```

On Windows:
1. Download and install MiKTeX from https://miktex.org/download
2. Install the following packages using MiKTeX Console:
   - latexmk
   - lmodern
   - geometry
   - enumitem
   - hyperref
   - xstring
   - titlesec
   - titling

4. Run the compilation script:
```bash
python compile_resume.py
```

The compiled resume will be saved in the `output` directory.

To deactivate the virtual environment when you're done:
```bash
deactivate
```

## Output

The compiled resume will be saved in the `output` directory with the following naming convention:
- Generic resume: `{Your_Name}_Resume.pdf`
- Company-specific resume: `{Your_Name}_Resume_{Company_Name}.pdf`

## Project Structure

```
.
├── content.yaml          # Resume content configuration
├── compile_resume.py     # Python compilation script
├── build.sh             # Docker build script
├── Dockerfile           # Docker configuration
├── src/                 # LaTeX templates and resources
└── output/             # Generated PDF files
```

## Customization

### LaTeX Template
The LaTeX template is located in `src/template.tex`. You can modify this file to change the resume's layout and styling.

### Adding Sections
To add new sections:
1. Add the section to `content.yaml`
2. Update the LaTeX template to include the new section
3. Modify `compile_resume.py` if necessary to handle the new section

## Contributing

Feel free to submit issues and enhancement requests!

## ATS Compatibility

The resume is specifically designed to be ATS-friendly with the following features:

- Unicode-safe text encoding ensures proper character rendering
- Standard bullet points that copy-paste correctly
- Clean text structure that maintains formatting when extracted
- No special characters that could break ATS parsing
- Proper PDF metadata and text layer for accurate content extraction

When you copy text from the generated PDF, you'll get clean, properly formatted text with:
- Correct bullet points (•)
- Proper hyphens and dashes
- Accurate spacing and line breaks
- No broken or special characters

This makes the resume compatible with most ATS systems and ensures your content is properly parsed when submitted through job application portals. 