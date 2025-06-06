#!/bin/bash

# Build the Docker image
docker build -t resume-builder .

# Run the container with the current directory mounted
docker run --rm -v "$(pwd):/resume" resume-builder ./build.sh 