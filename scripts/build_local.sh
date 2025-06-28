#!/bin/bash

# This script compiles a YAML content file into a PDF resume.
# It is designed to be called from a VSCode task.
# It dynamically determines the project root and runs from there.

set -e # Exit immediately if a command exits with a non-zero status.
set -u # Treat unset variables as an error when substituting.

# Determine script's directory and project root, then cd into the project root.
SCRIPT_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" &>/dev/null && pwd -P)
PROJECT_ROOT=$(dirname "$SCRIPT_DIR")
cd "$PROJECT_ROOT"

# --- Dependency Checks ---
echo "--- Checking for dependencies ---"

# Check for essential command-line tools
for cmd in pandoc latexmk; do
  if ! command -v "$cmd" &> /dev/null; then
    echo "Error: Required command '$cmd' is not installed or not in PATH." >&2
    exit 1
  fi
done
echo "Pandoc and LaTeXMk found."

# Find a valid python interpreter
PYTHON_CMD=""
if [ -f "./.venv/bin/python" ]; then
    PYTHON_CMD="./.venv/bin/python"
    echo "Found Python in virtual environment."
elif command -v python3 &>/dev/null; then
    PYTHON_CMD="python3"
    echo "Found system Python 3."
elif command -v python &>/dev/null; then
    PYTHON_CMD="python"
    echo "Found system Python."
else
    echo "Error: Python interpreter not found." >&2
    echo "Please install Python or create a virtual environment at ./.venv" >&2
    exit 1
fi

if [ "$#" -ne 3 ]; then
    echo "Usage: $0 <contentFile> <fileDirname> <fileBasenameNoExtension>" >&2
    exit 1
fi

# Arguments from VSCode task
CONTENT_FILE="$1"
FILE_DIRNAME="$2"
FILE_BASENAME_NO_EXTENSION="$3"

# Dynamically get the name from the 'name:' field under 'profile:' in the content YAML file.
# This uses sed and is suitable for simple YAML structures. For more complex files, a robust parser like 'yq' would be preferable.
# It replaces spaces with underscores to create a valid filename component.
# It will find 'profile:', then search for 'name:' on subsequent lines until a new top-level key is found.
NAME_FROM_YAML=$(sed -n '/^profile:/{:a;n;/^\s*name:/{s/^\s*name:\s*//; s/^\s\+//; s/\s\+$//; s/^["'\'']//; s/["'\'']$//; s/\s/_/g;p;q};/^[a-zA-Z#]/{q};ba}' "${CONTENT_FILE}")

if [ -z "$NAME_FROM_YAML" ]; then
    echo "Error: Could not extract name from 'profile:' section in ${CONTENT_FILE}" >&2
    echo "Ensure the YAML file has a structure like:" >&2
    echo "profile:" >&2
    echo "  name: Your Name" >&2
    exit 1
fi

OUTPUT_DIR_BASE="output"
OUTPUT_SUBDIR=""
FILENAME_PREFIX="${NAME_FROM_YAML}_"

# Check if compiling a job-specific resume from the 'contents/jobs' directory
if [[ "${FILE_DIRNAME}" =~ /contents/jobs$ ]]; then
  OUTPUT_SUBDIR="jobs"
  FILENAME_PREFIX="${NAME_FROM_YAML}_Resume_"
fi

FINAL_OUTPUT_DIR="${OUTPUT_DIR_BASE}/${OUTPUT_SUBDIR}"
FINAL_FILENAME="${FILENAME_PREFIX}${FILE_BASENAME_NO_EXTENSION}.pdf"

FINAL_OUTPUT_PATH="${FINAL_OUTPUT_DIR}/${FINAL_FILENAME}"

mkdir -p "$FINAL_OUTPUT_DIR"

# Run the python compiler using the discovered python command
"$PYTHON_CMD" "compile_resume.py" \
    --content "${CONTENT_FILE}" \
    --output "${FINAL_OUTPUT_PATH}"

echo "Successfully compiled: ${FINAL_OUTPUT_PATH}"
