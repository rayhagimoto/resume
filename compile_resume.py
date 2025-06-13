#!/usr/bin/env python3

import os
import subprocess
import yaml
import jinja2
import argparse
import shutil

def get_default_filename(content):
    """Get the default filename based on content.yaml data."""
    candidate_name = content["profile"]["name"].replace(" ", "_")
    target_company = content.get("target_company", "")
    target_company = None if target_company in [None, "", "None"] else target_company.replace(" ", "")
    
    if target_company:
        return f"{candidate_name}_Resume_{target_company}.pdf"
    else:
        return f"{candidate_name}_Resume.pdf"

def render_latex(content_file='content.yaml'):
    # Load YAML content
    with open(content_file, 'r') as f:
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
    template = env.get_template('resume_template.tex')
    output = template.render(content)

    # Ensure src/ exists
    os.makedirs('src', exist_ok=True)

    # Write main.tex
    with open('src/main.tex', 'w') as f:
        f.write(output)

    return content

def compile_pdf(resume_name, output_dir):
    # Compile LaTeX with latexmk inside src/
    subprocess.run(["latexmk", "-pdf", "main.tex"], cwd="src", check=True)

    # Ensure output directory exists
    os.makedirs(output_dir, exist_ok=True)
    
    # Move final PDF to output directory
    src_pdf = os.path.join("src", "main.pdf")
    dst_pdf = os.path.join(output_dir, resume_name)
    print(f"Built PDF: {dst_pdf}")
    
    # Move the new file
    shutil.move(src_pdf, dst_pdf)

    # Clean up
    subprocess.run(["latexmk", "-c"], cwd="src", check=True)
    for ext in [".aux", ".log", ".fls", ".fdb_latexmk", ".out", ".synctex.gz"]:
        try:
            os.remove(f"src/main{ext}")
        except FileNotFoundError:
            pass

def main():
    parser = argparse.ArgumentParser(description='Compile resume from YAML content')
    parser.add_argument('--content', default='content.yaml',
                      help='Path to content.yaml file (default: content.yaml)')
    parser.add_argument('--filename', default=None,
                      help='Custom filename for the output PDF (default: auto-generated)')
    args = parser.parse_args()

    content = render_latex(args.content)

    # Get output directory from environment variable
    output_dir = os.environ.get("OUTPUT_DIR", "output")

    # Determine the filename
    if args.filename:
        resume_name = args.filename
    else:
        resume_name = get_default_filename(content)

    compile_pdf(resume_name, output_dir)
    print(f"✅ Resume has been built successfully as {resume_name}")

if __name__ == '__main__':
    main()