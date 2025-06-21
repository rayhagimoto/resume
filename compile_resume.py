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

def get_default_filename(content):
    name = content["profile"]["name"].replace(" ", "_")
    return f"{name}_Resume.pdf"


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

def compile_pdf(resume_name, output_dir, content):
    print("🔧 Starting compile_pdf")
    t0 = time.time()
    os.makedirs(BUILD_DIR, exist_ok=True)

    src_dir = (ROOT / "src").resolve()
    style_dir = (ROOT / "bibstyles").resolve()
    bib_file = content.get('bibliography', None)
    if bib_file:
        bib_file = bib_file.replace(".bib", "")
    bib_style = content.get('bibliographystyle', f"hplain.bst").strip().replace(".bst", "")

    if bib_file:
        bib_src = (ROOT / "contents/" f"{bib_file}.bib").resolve()
        bib_dst = (BUILD_DIR / f"{bib_file}.bib").resolve()
        print(f"📦 Copying bib: {bib_src} → {bib_dst}")
        shutil.copy(bib_src, bib_dst)

    if bib_style:
        style_src = (style_dir / f"{bib_style}.bst").resolve()
        style_dst = (BUILD_DIR / f"{bib_style}.bst").resolve()
        print(f"📦 Copying bibstyle: {style_src} → {style_dst}")
        shutil.copy(style_src, style_dst)

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

    os.makedirs(output_dir, exist_ok=True)
    src_pdf = Path(BUILD_DIR) / "main.pdf"
    dst_pdf = Path(output_dir) / resume_name
    shutil.move(src_pdf, dst_pdf)
    print(f"✅ Built PDF: {dst_pdf}")
    print(f"⏱ Total compile_pdf time: {time.time() - t0:.2f}s")

def main():
    start = time.time()
    parser = argparse.ArgumentParser(description="Compile resume from YAML content")
    parser.add_argument('--content', default='content.yaml', help='Path to content.yaml (default: content.yaml)')
    parser.add_argument('--filename', default=None, help='Custom output PDF filename')
    parser.add_argument('--output-dir', default='output', help='Output directory')
    args = parser.parse_args()

    filename = args.filename
    content = args.content
    if filename:
        filename = args.filename.strip().removesuffix(".pdf") + ".pdf"
    if content and not content.endswith((".yaml", ".yml")):
        content = content.strip().removesuffix(".yaml") + ".yaml"

    content = render_latex(content)
    resume_name = filename or get_default_filename(content)
    compile_pdf(resume_name, args.output_dir, content)
    print(f"🏁 Total runtime: {time.time() - start:.2f}s")

if __name__ == '__main__':
    main()
