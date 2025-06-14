#!/usr/bin/env python3

import os
import subprocess
import yaml
import jinja2
import argparse
import shutil
from pathlib import Path
import pypandoc


ROOT = Path(__file__).parent.resolve()
BUILD_DIR = ROOT / "build"
SRC_DIR = ROOT / "src"
BIB_DIR = ROOT / "bibstyles"
SKIP_FIELDS = {'phone', 'location', 'name', 'title'} # Skip these fields in markdown to latex converter.

def get_default_filename(content):
    name = content["profile"]["name"].replace(" ", "_")
    company = content.get("target_company", "")
    company = company.replace(" ", "") if company and company.lower() != "none" else None
    return f"{name}_Resume_{company}.pdf" if company else f"{name}_Resume.pdf"

def convert_markdown_to_latex(obj, path=None):
    if path is None:
        path = []

    if isinstance(obj, dict):
        return {
            key: convert_markdown_to_latex(value, path + [key])
            for key, value in obj.items()
        }
    elif isinstance(obj, list):
        return [convert_markdown_to_latex(item, path + ['<list>']) for item in obj]
    elif isinstance(obj, str):
        key = path[-1] if path else ''
        if key in SKIP_FIELDS:
            return obj
        return pypandoc.convert_text(obj, to='latex', format='markdown').strip()
    else:
        return obj

def render_sections(env, content):
    rendered = []
    for section in content["sections"]:
        section = section.strip().replace("/", "").replace("\\","")
        template_path = f"sections/{section}.tex"
        print(f"Accessing at template_path = {template_path}")
        try:
            tmpl = env.get_template(template_path)
            items = content.get(section)
            rendered.append(tmpl.render(**content))
        except jinja2.exceptions.TemplateNotFound:
            print(f"⚠️  Skipping unknown section: {section}")
    return "\n\n".join(rendered)

# Normalize dashes to simple hyphen
def normalize_dashes(s: str) -> str:
    return (
        s.replace("–", "-")   # en-dash (U+2013)
         .replace("—", "-")   # em-dash (U+2014)
         .replace("--", "-")  # LaTeX double hyphen
    )

def render_latex(content_file='content.yaml'):
    # Load YAML
    with open(content_file, 'r') as f:
        content = yaml.safe_load(f)

    # Preprocess content to convert all markdown strings to LaTeX
    content = convert_markdown_to_latex(content)
    print("Phone no:", content.get('profile', None).get('phone', None))



    # Set up Jinja
    env = jinja2.Environment(
        block_start_string=r'\BLOCK{',
        block_end_string=r'}',
        variable_start_string=r'\VAR{',
        variable_end_string=r'}',
        comment_start_string=r'\#{',
        comment_end_string=r'}',
        trim_blocks=True,
        autoescape=False,
        loader=jinja2.FileSystemLoader(str(SRC_DIR))
    )
    print("📄 Available templates:", env.list_templates())


    # Render sections
    sections_tex = render_sections(env, content)

    # Render main.tex
    main_template = env.get_template("main.tex")
    full_tex = main_template.render(sections=sections_tex, profile=content['profile'])

    # Write main.tex to build/
    build_main_tex = Path(BUILD_DIR) / "main.tex"
    build_main_tex.parent.mkdir(parents=True, exist_ok=True)
    with open(build_main_tex, "w", encoding="utf-8") as f:
        f.write(normalize_dashes(full_tex))

    return content

def compile_pdf(resume_name, output_dir, content):
    os.makedirs(BUILD_DIR, exist_ok=True)

    # Get absolute paths
    src_dir = (ROOT / "src").resolve()
    style_dir = (ROOT / "bibstyles").resolve()
    bib_file = content.get('bibliography', None).replace(".bib", "")
    bib_style = content.get('bibliographystyle', f"hplain.bst").strip().replace(".bst", "")
    
    if bib_file:
        shutil.copy(ROOT / f"{bib_file}.bib", BUILD_DIR / f"{bib_file}.bib")
    if bib_style:
        style_src = (style_dir / f"{bib_style}.bst").resolve()
        style_dst = (BUILD_DIR / f"{bib_style}.bst").resolve()
        print(f"Copying bib_style at {str(style_src)} to {str(style_dst)}")
        shutil.copy(style_src, style_dst)


    # Set TEXINPUTS to allow LaTeX to find styles.cls in src/
    env = os.environ.copy()
    env["TEXINPUTS"] = str(src_dir) + os.pathsep + str(style_dir) + os.pathsep + str(ROOT) + os.pathsep

    # Then run the subprocess
    subprocess.run(
        ["latexmk", "-pdf", "-output-directory=.", "main.tex"],
        cwd=BUILD_DIR,
        check=True,
        env=env
    )

    os.makedirs(output_dir, exist_ok=True)
    src_pdf = Path(BUILD_DIR) / "main.pdf"
    dst_pdf = Path(output_dir) / resume_name
    shutil.move(src_pdf, dst_pdf)
    print(f"✅ Built PDF: {dst_pdf}")

    subprocess.run(["latexmk", "-c"], cwd=BUILD_DIR, check=True)
    for ext in [".aux", ".log", ".fls", ".fdb_latexmk", ".out", ".synctex.gz"]:
        try:
            os.remove(os.path.join(BUILD_DIR, f"main{ext}"))
        except FileNotFoundError:
            pass


def main():
    parser = argparse.ArgumentParser(description="Compile resume from YAML content")
    parser.add_argument('--content', default='content.yaml', help='Path to content.yaml (default: content.yaml)')
    parser.add_argument('--filename', default=None, help='Custom output PDF filename')
    parser.add_argument('--output-dir', default='output', help='Output directory')
    args = parser.parse_args()
    output_dir = args.output_dir

    if args.filename:
        filename = args.filename.strip().strip(".pdf") + ".pdf"

    content = render_latex(args.content)
    resume_name = filename or get_default_filename(content)
    compile_pdf(resume_name, output_dir, content)

if __name__ == '__main__':
    main()
