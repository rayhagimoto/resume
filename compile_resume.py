#!/usr/bin/env python3

import os
import subprocess
import yaml
import jinja2

def render_latex():
    # Load YAML content
    with open('content.yaml', 'r') as f:
        content = yaml.safe_load(f)

    # Set up Jinja2 environment
    env = jinja2.Environment(
        block_start_string=r'\BLOCK{',
        block_end_string=r'}',
        variable_start_string=r'\VAR{',
        variable_end_string=r'}',
        comment_start_string=r'\#{',
        comment_end_string=r'}',
        line_statement_prefix=r'%%',
        line_comment_prefix=r'%#',
        trim_blocks=True,
        autoescape=False,
        loader=jinja2.FileSystemLoader('src')
    )

    # Render template
    template = env.get_template('template.tex')
    output = template.render(**content)

    # Ensure src/ exists
    os.makedirs('src', exist_ok=True)

    # Write main.tex
    with open('src/main.tex', 'w') as f:
        f.write(output)

    return content

import shutil

def compile_pdf(resume_name):
    # Compile LaTeX with latexmk inside src/
    subprocess.run(["latexmk", "-pdf", "main.tex"], cwd="src", check=True)

    # Move final PDF to output directory
    output_dir = os.environ.get("OUTPUT_DIR", "out")
    os.makedirs(output_dir, exist_ok=True)
    src_pdf = os.path.join("src", "main.pdf")
    dst_pdf = os.path.join(output_dir, resume_name)
    print(dst_pdf)
    shutil.move(src_pdf, dst_pdf)

    # Clean up
    subprocess.run(["latexmk", "-c"], cwd="src", check=True)
    for ext in [".aux", ".log", ".fls", ".fdb_latexmk", ".out", ".synctex.gz"]:
        try:
            os.remove(f"src/main{ext}")
        except FileNotFoundError:
            pass



def main():
    content = render_latex()

    # Extract name and company
    candidate_name = content["candidate"]["name"].replace(" ", "_")
    target_company = content.get("target_company", "")
    target_company = None if target_company in [None, "", "None"] else target_company.replace(" ", "")

    # Build filename
    if target_company:
        resume_name = f"{candidate_name}_Resume_{target_company}.pdf"
    else:
        resume_name = f"{candidate_name}_Resume.pdf"

    compile_pdf(resume_name)
    print(f"✅ Resume has been built successfully as {resume_name}")

if __name__ == '__main__':
    main()
