#!/bin/bash
set -e

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

IMAGE_NAME=rayhagimoto-resume-builder
CONTAINER_NAME=resume-container
DEFAULT_OUTPUT_DIR="$SCRIPT_DIR/output"
CONTENT_FILE="$SCRIPT_DIR/content.yaml"
OUTPUT_DIR=""
FILENAME=""
FORCE=false

print_help() {
    echo "Usage: $0 [options]"
    echo ""
    echo "Options:"
    echo "  --content PATH        Path to content.yaml (default: ./content.yaml)"
    echo "  --output-dir DIR      Directory to save the output PDF (default: ./output)"
    echo "  --filename NAME       Output PDF filename (default determined from content)"
    echo "  -y, --yes             Overwrite output without prompting"
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
ABSOLUTE_CONTENT_PATH="$(realpath "$CONTENT_FILE")"
ABSOLUTE_OUTPUT_PATH="$(realpath "$OUTPUT_DIR")"

# If filename is specified, sanitize it: trim whitespace, remove ".pdf" (if present), and re-append ".pdf"
if [ -n "$FILENAME" ]; then
    FILENAME="$(echo "$FILENAME" | sed -e 's/^[[:space:]]*//' -e 's/[[:space:]]*$//' -e 's/\.pdf$//').pdf"
else
    # Get default filename from container
    FILENAME=$(docker run --rm \
        -v "$ABSOLUTE_CONTENT_PATH":/app/content.yaml \
        "$IMAGE_NAME" \
        python3 -c "
from compile_resume import get_default_filename
import yaml
content = yaml.safe_load(open('content.yaml'))
print(get_default_filename(content))
")
fi

# Remove old container if exists
docker rm -f "$CONTAINER_NAME" 2>/dev/null || true

# Start a container that builds resume inside and leaves output in /tmp/final.pdf
docker run --name "$CONTAINER_NAME" \
    -v "$ABSOLUTE_CONTENT_PATH":/app/content.yaml \
    "$IMAGE_NAME" \
    bash -c "
        python3 compile_resume.py --content content.yaml --filename $FILENAME --output-dir=/tmp
    "

# Determine final path
FINAL_OUTPUT_PATH="$ABSOLUTE_OUTPUT_PATH/$FILENAME"

# Check overwrite
if [ -f "$FINAL_OUTPUT_PATH" ]; then
    if [ "$FORCE" = true ]; then
        echo "Overwriting existing file: $FINAL_OUTPUT_PATH"
    else
        echo "Warning: $FINAL_OUTPUT_PATH already exists."
        read -p "Overwrite? [y/N] " resp
        [[ ! "$resp" =~ ^[Yy]$ ]] && echo "Cancelled." && exit 1
    fi
fi

# Copy the built PDF from container
docker cp "$CONTAINER_NAME:/tmp/$FILENAME" "$FINAL_OUTPUT_PATH"
docker rm -f "$CONTAINER_NAME" >/dev/null

# Done
echo "✅ Resume built successfully: $FINAL_OUTPUT_PATH"
ls -lh "$FINAL_OUTPUT_PATH"
