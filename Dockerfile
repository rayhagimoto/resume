FROM python:3.12-slim

# Install LaTeX, Pandoc, and dependencies
RUN apt-get update && apt-get install -y --no-install-recommends \
    texlive-latex-base \
    texlive-latex-recommended \
    texlive-latex-extra \
    lmodern \
    latexmk \
    pandoc \
    curl \
    && rm -rf /var/lib/apt/lists/*

# Set working directory
WORKDIR /app

# Copy requirements first for better caching
COPY requirements.txt .

# Install Python packages
RUN pip install --no-cache-dir -r requirements.txt

# Copy only necessary files for the build
COPY compile_resume.py .
COPY src/ ./src/
COPY bibstyles/ ./bibstyles/
COPY contents/ ./contents/

# Default command to build the resume
CMD ["python", "compile_resume.py"]
