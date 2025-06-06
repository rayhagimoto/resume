import os
import yaml
import jinja2
import subprocess
from pathlib import Path

# Define paths
ROOT = Path(__file__).parent
SRC_DIR = ROOT / "src"
BUILD_DIR = ROOT / "build"
CONFIG_PATH = ROOT / "content.yaml"
TEMPLATE_PATH = SRC_DIR / "template.tex"
OUTPUT_PATH = BUILD_DIR / "output.tex"
PDF_PATH = BUILD_DIR / "output.pdf"
FINAL_PDF_PATH = ROOT / "hagimoto-resume.pdf"

def main():
    # Create build directory if it doesn't exist
    BUILD_DIR.mkdir(exist_ok=True)

    # Load configuration
    with open(CONFIG_PATH, 'r', encoding='utf-8') as f:
        config = yaml.safe_load(f)

    # Set up Jinja2 environment with LaTeX-friendly delimiters
    env = jinja2.Environment(
        block_start_string=r'\BLOCK{',
        block_end_string='}',
        variable_start_string=r'\VAR{',
        variable_end_string='}',
        comment_start_string=r'\#{',
        comment_end_string='}',
        line_statement_prefix='%%',
        line_comment_prefix='%#',
        trim_blocks=True,
        autoescape=False,
        loader=jinja2.FileSystemLoader(str(SRC_DIR))
    )

    # Render template
    template = env.get_template(TEMPLATE_PATH.name)
    output = template.render(**config)

    # Write output
    with open(OUTPUT_PATH, 'w', encoding='utf-8') as f:
        f.write(output)

    # Change to build directory for LaTeX compilation
    os.chdir(BUILD_DIR)

    # Set up environment variables for LaTeX
    env = os.environ.copy()
    env['TEXINPUTS'] = str(SRC_DIR) + os.pathsep

    # Compile LaTeX to PDF using latexmk
    subprocess.run([
        'latexmk',
        '-pdf',  # Generate PDF
        '-interaction=nonstopmode',  # Non-interactive mode
        'output.tex'  # Input file (relative to build directory)
    ], check=True, env=env)

    # Change back to root directory
    os.chdir(ROOT)

    # Move PDF to root directory
    if PDF_PATH.exists():
        # Remove existing file if it exists
        if FINAL_PDF_PATH.exists():
            FINAL_PDF_PATH.unlink()
        PDF_PATH.rename(FINAL_PDF_PATH)

if __name__ == '__main__':
    main()