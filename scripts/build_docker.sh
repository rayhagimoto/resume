#!/usr/bin/bash
# ------------------------------------------------------------------------------
set -e

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
PROJECT_ROOT="$(realpath "$SCRIPT_DIR/..")"

IMAGE_NAME=rayhagimoto-resume-builder
DEFAULT_OUTPUT_DIR="$PROJECT_ROOT/output"
CONTENT_FILE="$PROJECT_ROOT/contents/resume.yaml"
OUTPUT_DIR="$PROJECT_ROOT/output"
FILENAME=""
FORCE=false
CI_MODE=false

print_help() {
    echo "Usage: $0 [options]"
    echo ""
    echo "Options:"
    echo "  --content PATH        Path to content.yaml (default: contents/resume.yaml)"
    echo "  -o, --output PATH     Full path for the output PDF (e.g., /path/to/output.pdf)"
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
        -o|--output)
            FINAL_OUTPUT_PATH="$2"
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

# Resolve absolute paths
if [ -n "$FINAL_OUTPUT_PATH" ]; then
    ABSOLUTE_OUTPUT_PATH="$(realpath "$FINAL_OUTPUT_PATH")"
else
    # If no output path is given, determine a default name
    # We need to build the image first to run the python script that can determine the name
    docker build -t "$IMAGE_NAME" "$PROJECT_ROOT"
    DEFAULT_FILENAME=$(docker run --rm -v "$(realpath "$CONTENT_FILE")":/app/content.yaml "$IMAGE_NAME" \
        bash -c "cd /app && python3 -c \"from compile_resume import get_default_output_path; import yaml; content=yaml.safe_load(open('content.yaml')); print(get_default_output_path(content))\"")
    # The default path from the script is relative to the project root inside the container
    ABSOLUTE_OUTPUT_PATH="$PROJECT_ROOT/$DEFAULT_FILENAME"
fi

ABSOLUTE_CONTENT_PATH="$(realpath "$CONTENT_FILE")"
OUTPUT_DIR=$(dirname "$ABSOLUTE_OUTPUT_PATH")
FILENAME=$(basename "$ABSOLUTE_OUTPUT_PATH")

# Verify content file exists
if [ ! -f "$ABSOLUTE_CONTENT_PATH" ]; then
    echo "Error: Content file not found: $ABSOLUTE_CONTENT_PATH"
    exit 1
fi

mkdir -p "$OUTPUT_DIR"

# CI-specific build flags
if [ "$CI_MODE" = true ]; then
    DOCKER_BUILD_FLAGS=""
else
    DOCKER_BUILD_FLAGS=""
fi

# Build Docker image if not already built
if [[ "$(docker images -q $IMAGE_NAME 2> /dev/null)" == "" ]]; then
  docker build -t "$IMAGE_NAME" $DOCKER_BUILD_FLAGS "$PROJECT_ROOT"
fi

# Overwrite check
if [ -f "$ABSOLUTE_OUTPUT_PATH" ]; then
    if [ "$FORCE" = true ] || [ "$CI_MODE" = true ]; then
        echo "Overwriting existing file: $ABSOLUTE_OUTPUT_PATH"
    else
        echo "Warning: $ABSOLUTE_OUTPUT_PATH already exists."
        read -p "Overwrite? [y/N] " resp
        [[ ! "$resp" =~ ^[Yy]$ ]] && echo "Cancelled." && exit 1
    fi
fi

# Mount project dir and a dedicated output volume
# Convert absolute path to relative path for use inside the container
RELATIVE_CONTENT_PATH=$(realpath --relative-to="$PROJECT_ROOT" "$CONTENT_FILE")
docker run --rm \
    -v "$PROJECT_ROOT":/app \
    -v "$OUTPUT_DIR":/output \
    "$IMAGE_NAME" \
    bash -c "cd /app && python3 compile_resume.py --content \"$RELATIVE_CONTENT_PATH\" --output \"/output/$FILENAME\""

echo "✅ Resume built successfully: $ABSOLUTE_OUTPUT_PATH"
ls -lh "$ABSOLUTE_OUTPUT_PATH"