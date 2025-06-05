#!/bin/bash

# Change to the directory of this script
cd "$(dirname "$0")"

# Make sure the build directory exists
mkdir -p ../build

# Run pdflatex from the src directory
cd src
pdflatex -output-directory=../build main.tex

# Move the generated PDF to the final location
mv ../build/main.pdf ../hagimoto-resume.pdf
