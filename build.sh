#!/bin/bash
set -e

# Run the Python script to generate the LaTeX file
python compile_template.py

# Compile the LaTeX document
cd src
latexmk -pdf main.tex

# Clean up auxiliary files
latexmk -c

# Move the PDF to the root directory and rename it
mv main.pdf ../hagimoto-resume.pdf

# Clean up any remaining auxiliary files
rm -f *.aux *.log *.fls *.fdb_latexmk *.out *.synctex.gz

echo "Resume has been built successfully as hagimoto-resume.pdf" 