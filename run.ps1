# Remove existing output file if it exists
Remove-Item -Force -ErrorAction SilentlyContinue hagimoto-resume.pdf

# Run the Python script to generate the LaTeX file
python compile_template.py

# Compile the LaTeX document
Set-Location src
latexmk -pdf main.tex

# Clean up auxiliary files
latexmk -c

# Move the PDF to the root directory and rename it
Move-Item -Path main.pdf -Destination ../hagimoto-resume.pdf

# Clean up any remaining auxiliary files
Remove-Item -Force -ErrorAction SilentlyContinue *.aux, *.log, *.fls, *.fdb_latexmk, *.out, *.synctex.gz

# Return to the root directory
Set-Location ..

Write-Host "Resume has been built successfully as hagimoto-resume.pdf" 