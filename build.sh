#!/bin/bash
set -e

# Get the directory where the script is located
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

# Default values
IMAGE_NAME=resume-builder
CONTAINER_NAME=resume-container
DEFAULT_OUTPUT_DIR="$SCRIPT_DIR/output"
CONTENT_FILE="$SCRIPT_DIR/content.yaml"
OUTPUT_DIR=""
FILENAME=""
FORCE=false

# Parse command line arguments
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
        -y|--yes)
            FORCE=true
            shift
            ;;
        *)
            CONTENT_FILE="$1"
            shift
            ;;
    esac
done

# Set default output directory if not specified
if [ -z "$OUTPUT_DIR" ]; then
    OUTPUT_DIR="$DEFAULT_OUTPUT_DIR"
fi

# Clean up old container if it exists
docker rm -f "$CONTAINER_NAME" 2>/dev/null || true

# Ensure output directory exists
mkdir -p "$OUTPUT_DIR"

# Build Docker image from the script directory
docker build -t "$IMAGE_NAME" "$SCRIPT_DIR"

# Get the absolute path of the content file
if [[ "$CONTENT_FILE" == /* ]]; then
    # If it's already an absolute path, use it as is
    ABSOLUTE_CONTENT_PATH="$CONTENT_FILE"
else
    # If it's a relative path, make it absolute relative to the current working directory
    ABSOLUTE_CONTENT_PATH="$(cd "$(dirname "$CONTENT_FILE")" && pwd)/$(basename "$CONTENT_FILE")"
fi

# Get the absolute path of the output directory
if [[ "$OUTPUT_DIR" == /* ]]; then
    ABSOLUTE_OUTPUT_PATH="$OUTPUT_DIR"
else
    ABSOLUTE_OUTPUT_PATH="$(cd "$(dirname "$OUTPUT_DIR")" && pwd)/$(basename "$OUTPUT_DIR")"
fi

# If no filename is specified, get it from compile_resume.py
if [ -z "$FILENAME" ]; then
    # Create a temporary container to get the default filename
    TEMP_CONTAINER="temp-filename-extractor"
    docker run --rm --name "$TEMP_CONTAINER" \
        -v "$ABSOLUTE_CONTENT_PATH":/app/content.yaml \
        "$IMAGE_NAME" \
        python3 -c "
from compile_resume import get_default_filename
import yaml
content = yaml.safe_load(open('content.yaml'))
print(get_default_filename(content))
"
    FILENAME=$(docker logs "$TEMP_CONTAINER")
    docker rm -f "$TEMP_CONTAINER" >/dev/null
fi

# Create a temporary output directory for the Docker container
TEMP_OUTPUT_DIR="$SCRIPT_DIR/temp_output"
mkdir -p "$TEMP_OUTPUT_DIR"

# Build the docker run command
DOCKER_CMD="docker run --rm --name $CONTAINER_NAME \
  -e OUTPUT_DIR=/app/temp_output \
  -v $TEMP_OUTPUT_DIR:/app/temp_output \
  -v $ABSOLUTE_CONTENT_PATH:/app/content.yaml \
  $IMAGE_NAME \
  python3 compile_resume.py --content content.yaml --filename $FILENAME"

# Run the container
eval $DOCKER_CMD

# Clean up the container
docker rm -f "$CONTAINER_NAME" >/dev/null

# Check if the output file exists and handle overwrite warning
FINAL_OUTPUT_PATH="$ABSOLUTE_OUTPUT_PATH/$FILENAME"
if [ -f "$FINAL_OUTPUT_PATH" ]; then
    if [ "$FORCE" = true ]; then
        echo "Overwriting existing file: $FINAL_OUTPUT_PATH"
    else
        echo "Warning: File $FINAL_OUTPUT_PATH already exists and will be overwritten."
        read -p "Do you want to continue? [y/N] " response
        if [[ ! "$response" =~ ^[Yy]$ ]]; then
            echo "Operation cancelled."
            rm -rf "$TEMP_OUTPUT_DIR"
            exit 1
        fi
    fi
else
    echo "File not found, will create: $FINAL_OUTPUT_PATH"
fi

# Move the file from temporary directory to final location
mv "$TEMP_OUTPUT_DIR/$FILENAME" "$FINAL_OUTPUT_PATH"

# Clean up temporary directory
rm -rf "$TEMP_OUTPUT_DIR"

# List the result
echo "✅ Resume has been built successfully as $FILENAME in $OUTPUT_DIR:"
ls "$OUTPUT_DIR"
