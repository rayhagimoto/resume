#!/bin/bash
set -e

IMAGE_NAME=resume-builder
CONTAINER_NAME=resume-container
OUTPUT_DIR=output

# Clean up old container if it exists
docker rm -f "$CONTAINER_NAME" 2>/dev/null || true

# Ensure output directory is clean
rm -rf "$OUTPUT_DIR"
mkdir -p "$OUTPUT_DIR"

# Build Docker image
docker build -t "$IMAGE_NAME" .

# Run the container, mounting the output directory
docker run --name "$CONTAINER_NAME" \
  -e OUTPUT_DIR="$OUTPUT_DIR" \
  -v "$(pwd)/$OUTPUT_DIR":/app/"$OUTPUT_DIR" \
  "$IMAGE_NAME"

# Clean up the container
docker rm -f "$CONTAINER_NAME" >/dev/null

# List the result
echo "✅ Resume(s) available in ./$OUTPUT_DIR:"
ls "$OUTPUT_DIR"
