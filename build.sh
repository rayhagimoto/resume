#!/bin/bash
# ------------------------------------------------------------------------------
# build.sh — Build a PDF resume from a YAML content file using Docker
#
# This script compiles a LaTeX resume using `compile_resume.py`, entirely inside
# a Docker container to ensure consistency across environments.
#
# Key features:
# - Accepts custom YAML content via --content (defaults to ./content.yaml)
# - Determines output PDF filename automatically unless --filename is given
# - Avoids host volume mounts by copying content into the build context
# - Supports safe overwrite behavior with -y/--yes and --ci flags
# - Runs cleanly in CI/CD pipelines (e.g. GitHub Actions)
#
# Example usage:
#   ./build.sh --content /path/to/content.yaml --output-dir /path/to/output --filename myresume.pdf
#
# Requirements:
# - Docker must be installed and accessible from the command line
# ------------------------------------------------------------------------------

set -e

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

IMAGE_NAME=rayhagimoto-resume-builder
CONTAINER_NAME=resume-container
DEFAULT_OUTPUT_DIR="$SCRIPT_DIR/output"
CONTENT_FILE="$SCRIPT_DIR/content.yaml"
OUTPUT_DIR=""
FILENAME=""
FORCE=false
CI_MODE=false

print_help() {
    echo "Usage: $0 [options]"
    echo ""
    echo "Options:"
    echo "  --content PATH        Path to content.yaml (default: ./content.yaml)"
    echo "  --output-dir DIR      Directory to save the output PDF (default: ./output)"
    echo "  --filename NAME       Output PDF filename (default determined from content)"
    echo "  -y, --yes             Overwrite output without prompting"
    echo "  --ci                  Run in CI mode (non-interactive overwrite)"
    echo "  --help                Show this help message and exit"
    echo ""
    echo "Example:"
    echo "  $0 --content cv.yaml --output-dir ./tmp --filename resume.pdf"
}

# Parse CLI args
while [[ $# -gt 0 ]]; do
    case $1 in
        --output-dir)
            OUTPUT_DIR="$2"
            shift 2
            ;;
        --filename)
            FILENAME="$2"
            shift 2
            ;;
        --content)
            CONTENT_FILE="$2"
            shift 2
            ;;
        -y|--yes)
            FORCE=true
            shift
            ;;
        --ci)
            CI_MODE=true
            shift
            ;;
        --help)
            print_help
            exit 0
            ;;
        *)
            echo "Unknown argument: $1"
            echo "Use --help to see available options."
            exit 1
            ;;
    esac
done

# Set default output dir
if [ -z "$OUTPUT_DIR" ]; then
    OUTPUT_DIR="$DEFAULT_OUTPUT_DIR"
fi
mkdir -p "$OUTPUT_DIR"

# Build Docker image
docker build -t "$IMAGE_NAME" "$SCRIPT_DIR"

# Resolve absolute paths
SCRIPT_DIR="$(realpath "$SCRIPT_DIR")"
ABSOLUTE_OUTPUT_PATH="$(realpath "$OUTPUT_DIR")"
CONTENT_FILE="$(realpath "$CONTENT_FILE")"

# If content file is outside the project directory, copy it locally
if [[ "$CONTENT_FILE" != "$SCRIPT_DIR/"* ]]; then
    echo "Content file is outside the project directory. Copying to tmp_content.yaml..."
    cp "$CONTENT_FILE" "$SCRIPT_DIR/tmp_content.yaml"
    CONTENT_FILE="$SCRIPT_DIR/tmp_content.yaml"
else
    cp "$CONTENT_FILE" "$SCRIPT_DIR/tmp_content.yaml"
    CONTENT_FILE="$SCRIPT_DIR/tmp_content.yaml"
fi

# Recompute absolute path of the copied file
ABSOLUTE_CONTENT_PATH="$(realpath "$CONTENT_FILE")"

# Determine output filename
if [ -n "$FILENAME" ]; then
    FILENAME="$(echo "$FILENAME" | sed -e 's/^[[:space:]]*//' -e 's/[[:space:]]*$//' -e 's/\.pdf$//').pdf"
else
    docker build -t "$IMAGE_NAME" --build-arg CONTENT_FILE=tmp_content.yaml .
    FILENAME=$(docker run --rm "$IMAGE_NAME" \
        python3 -c "
from compile_resume import get_default_filename
import yaml
content = yaml.safe_load(open('tmp_content.yaml'))
print(get_default_filename(content))
")
fi

# Remove old container if it exists
docker rm -f "$CONTAINER_NAME" 2>/dev/null || true

# Rebuild image to include the content file
docker build -t "$IMAGE_NAME" .

# Run build inside the container — no volume mounts
docker run --name "$CONTAINER_NAME" "$IMAGE_NAME" \
    bash -c "
        python3 compile_resume.py --content tmp_content.yaml --filename \"$FILENAME\" --output-dir=/tmp
    "

FINAL_OUTPUT_PATH="$ABSOLUTE_OUTPUT_PATH/$FILENAME"

# Handle overwrite logic
if [ -f "$FINAL_OUTPUT_PATH" ]; then
    if [ "$FORCE" = true ] || [ "$CI_MODE" = true ]; then
        echo "Overwriting existing file: $FINAL_OUTPUT_PATH"
    else
        echo "Warning: $FINAL_OUTPUT_PATH already exists."
        read -p "Overwrite? [y/N] " resp
        [[ ! "$resp" =~ ^[Yy]$ ]] && echo "Cancelled." && exit 1
    fi
fi

# Copy built PDF out of container
docker cp "$CONTAINER_NAME:/tmp/$FILENAME" "$FINAL_OUTPUT_PATH"
docker rm -f "$CONTAINER_NAME" >/dev/null

echo "✅ Resume built successfully: $FINAL_OUTPUT_PATH"
ls -lh "$FINAL_OUTPUT_PATH"