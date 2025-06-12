FROM python:3.12-slim

# Install LaTeX and dependencies
RUN apt-get update && apt-get install -y --no-install-recommends \
    texlive-latex-base \
    texlive-fonts-recommended \
    texlive-fonts-extra \
    texlive-latex-extra \
    lmodern \
    texlive-science \
    texlive-plain-generic \
    texlive-lang-english \
    latexmk \
    && rm -rf /var/lib/apt/lists/*

# Install Python packages
RUN pip install --no-cache-dir pyyaml jinja2

# Set working directory
WORKDIR /app

# Copy everything
COPY . .

# Run script
CMD ["python", "compile_resume.py"]