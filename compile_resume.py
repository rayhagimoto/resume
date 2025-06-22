#!/usr/bin/env python3

import os
import subprocess
import yaml
import jinja2
import argparse
import shutil
from pathlib import Path
import pypandoc
import time
import re

ROOT = Path(__file__).parent.resolve()
BUILD_DIR = ROOT / "build"
SRC_DIR = ROOT / "src"
BIB_DIR = ROOT / "bibstyles"
SKIP_FIELDS = {'phone', 'location', 'name', 'title'}  # Skip these fields in markdown to latex converter.

def get_default_output_path(content):
    name = content["profile"]["name"].replace(" ", "_")
    return Path("output") / f"{name}_Resume.pdf"


def convert_markdown_to_latex(obj, path=None):
    if path is None:
        path = []
    if isinstance(obj, dict):
        return {key: convert_markdown_to_latex(value, path + [key]) for key, value in obj.items()}
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
        section = section.strip().replace("/", "").replace("\\", "")
        template_path = f"sections/{section}.tex"
        try:
            tmpl = env.get_template(template_path)
            rendered.append(tmpl.render(**content))
        except jinja2.exceptions.TemplateNotFound:
            print(f"⚠️  Skipping unknown section: {section}")
    return "\n\n".join(rendered)

def normalize_dashes(s: str) -> str:
    return (
        s.replace("–", "-")
         .replace("—", "-")
         .replace("--", "-")
    )

def render_latex(content_file='content.yaml'):
    t0 = time.time()
    print("🔧 Starting render_latex")

    with open(content_file, 'r') as f:
        content = yaml.safe_load(f)
    print(f"⏱ YAML loaded in {time.time() - t0:.2f}s")

    t1 = time.time()
    content = convert_markdown_to_latex(content)
    print(f"⏱ Markdown to LaTeX converted in {time.time() - t1:.2f}s")

    t2 = time.time()
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
    print(f"⏱ Jinja environment created in {time.time() - t2:.2f}s")

    t3 = time.time()
    sections_tex = render_sections(env, content)
    print(f"⏱ Sections rendered in {time.time() - t3:.2f}s")

    t4 = time.time()
    main_template = env.get_template("main.tex")
    full_tex = main_template.render(sections=sections_tex, profile=content['profile'])
    print(f"⏱ Main template rendered in {time.time() - t4:.2f}s")

    build_main_tex = Path(BUILD_DIR) / "main.tex"
    build_main_tex.parent.mkdir(parents=True, exist_ok=True)
    with open(build_main_tex, "w", encoding="utf-8") as f:
        f.write(normalize_dashes(full_tex))
    print(f"✅ main.tex written at {build_main_tex}")

    return content

def cleanup_build_artifacts():
    """Removes temporary build artifacts like .bib and .bst files from the build directory."""
    print("🧹 Cleaning up copied build artifacts...")
    for ext in ["*.bib", "*.bst"]:
        for f in BUILD_DIR.glob(ext):
            try:
                os.remove(f)
                print(f"  - Removed {f.name}")
            except OSError as e:
                print(f"Error removing file {f}: {e}")

def compile_pdf(output_path, content):
    print("🔧 Starting compile_pdf")
    t0 = time.time()
    os.makedirs(BUILD_DIR, exist_ok=True)

    output_path = Path(output_path)
    output_dir = output_path.parent

    src_dir = (ROOT / "src").resolve()
    style_dir = (ROOT / "bibstyles").resolve()
    bib_file = content.get('bibliography', None)
    if bib_file:
        bib_file = bib_file.replace(".bib", "")
    bib_style = content.get('bibliographystyle', 'hplain').strip().replace(".bst", "")

    if bib_file:
        bib_src = ROOT / "contents" / f"{bib_file}.bib"
        if bib_src.exists():
            shutil.copy(bib_src, BUILD_DIR)
            print(f"📦 Copied bib file: {bib_src.name}")

    if bib_style:
        style_src = style_dir / f"{bib_style}.bst"
        if style_src.exists():
            shutil.copy(style_src, BUILD_DIR)
            print(f"📦 Copied bib style: {style_src.name}")

    env = os.environ.copy()
    env["TEXINPUTS"] = str(src_dir) + os.pathsep + str(style_dir) + os.pathsep + str(ROOT) + os.pathsep

    t1 = time.time()
    subprocess.run(
        ["latexmk", "-f", "-pdf", "-output-directory=.", "main.tex"],
        cwd=BUILD_DIR,
        check=True,
        env=env
    )
    print(f"⏱ latexmk finished in {time.time() - t1:.2f}s")

    output_dir.mkdir(parents=True, exist_ok=True)
    src_pdf = Path(BUILD_DIR) / "main.pdf"
    shutil.move(src_pdf, output_path)
    print(f"✅ Built PDF: {output_path}")


    print(f"⏱ Total compile_pdf time: {time.time() - t0:.2f}s")

def main():
    start = time.time()
    parser = argparse.ArgumentParser(description="Compile resume from YAML content")
    parser.add_argument('--content', default=None, help='Full path to content.yaml')
    parser.add_argument('-o', '--output', default=None, help='Full path for the output PDF, e.g., /path/to/output.pdf')
    args = parser.parse_args()

    content_file = args.content.strip()
    if content_file and not content_file.endswith((".yaml", ".yml")):
        content_file = content_file + ".yaml"

    content = render_latex(content_file)

    output_path_str = args.output
    if output_path_str:
        output_path = Path(output_path_str)
        if output_path.suffix != '.pdf':
            output_path = output_path.with_suffix('.pdf')
    else:
        output_path = get_default_output_path(content)

    compile_pdf(output_path, content)
    print(f"🏁 Total runtime: {time.time() - start:.2f}s")

if __name__ == '__main__':
    main()
