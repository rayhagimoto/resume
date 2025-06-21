#!/usr/bin/bash
# ------------------------------------------------------------------------------
set -e

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

IMAGE_NAME=rayhagimoto-resume-builder
DEFAULT_OUTPUT_DIR="$SCRIPT_DIR/output"
CONTENT_FILE="$SCRIPT_DIR/scripts/resume.yaml"
OUTPUT_DIR=""
FILENAME=""
FORCE=false
CI_MODE=false

print_help() {
    echo "Usage: $0 [options]"
    echo ""
    echo "Options:"
    echo "  --content PATH        Path to content.yaml (default: scripts/resume.yaml)"
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

# Resolve absolute paths
SCRIPT_DIR="$(realpath "$SCRIPT_DIR")"
ABSOLUTE_OUTPUT_PATH="$(realpath "$OUTPUT_DIR")"
CONTENT_FILE="$(realpath "$CONTENT_FILE")"

# Copy content file to safe local filename
cp "$CONTENT_FILE" "$SCRIPT_DIR/tmp_content.yaml"
CONTENT_FILE="$SCRIPT_DIR/tmp_content.yaml"
ABSOLUTE_CONTENT_PATH="$(realpath "$CONTENT_FILE")"

# CI-specific build flags
if [ "$CI_MODE" = true ]; then
    DOCKER_BUILD_FLAGS="--quiet"
else
    DOCKER_BUILD_FLAGS=""
fi

# Build Docker image once
docker build -t "$IMAGE_NAME" $DOCKER_BUILD_FLAGS "$SCRIPT_DIR"

# Determine output filename if not provided
if [ -z "$FILENAME" ]; then
    FILENAME=$(docker run --rm -v "$SCRIPT_DIR":/app "$IMAGE_NAME" \
        bash -c "
            cd /app && \
            python3 -c \"from compile_resume import get_default_filename; import yaml; content = yaml.safe_load(open('tmp_content.yaml')); print(get_default_filename(content))\"
        ")
    FILENAME="$(echo "$FILENAME" | sed -e 's/\.pdf$//').pdf"
else
    FILENAME="$(echo "$FILENAME" | sed -e 's/^[[:space:]]*//' -e 's/[[:space:]]*$//' -e 's/\.pdf$//').pdf"
fi

FINAL_OUTPUT_PATH="$ABSOLUTE_OUTPUT_PATH/$FILENAME"

# Overwrite check
if [ -f "$FINAL_OUTPUT_PATH" ]; then
    if [ "$FORCE" = true ] || [ "$CI_MODE" = true ]; then
        echo "Overwriting existing file: $FINAL_OUTPUT_PATH"
    else
        echo "Warning: $FINAL_OUTPUT_PATH already exists."
        read -p "Overwrite? [y/N] " resp
        [[ ! "$resp" =~ ^[Yy]$ ]] && echo "Cancelled." && exit 1
    fi
fi

# Mount project dir to preserve LaTeX cache (build/) between runs
docker run --rm \
    -v "$SCRIPT_DIR":/app \
    -v "$ABSOLUTE_OUTPUT_PATH":/output \
    "$IMAGE_NAME" \
    bash -c "cd /app && python3 compile_resume.py --content tmp_content.yaml --filename \"$FILENAME\" --output-dir=/output"

echo "✅ Resume built successfully: $FINAL_OUTPUT_PATH"
ls -lh "$FINAL_OUTPUT_PATH"