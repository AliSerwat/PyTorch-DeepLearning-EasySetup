#!/bin/bash

# Default values
IMAGE_NAME="aliserwat/dlwpt:hybrid"
DOCKERFILE_PATH=~/dlwpt.dockerfile
BUILD_CONTEXT=~/dlwpt-code

# Parse command line arguments
while getopts "n:f:c:" opt; do
    case $opt in
    n) IMAGE_NAME="$OPTARG" ;;
    f) DOCKERFILE_PATH="$OPTARG" ;;
    c) BUILD_CONTEXT="$OPTARG" ;;
    \?)
        echo "Invalid option: -$OPTARG" >&2
        exit 1
        ;;
    esac
done

# Ensure build context directory exists
mkdir -p "$BUILD_CONTEXT"

# Remove existing container with the same name if it exists
docker rm -f "$IMAGE_NAME" >/dev/null 2>&1

# Build Docker image
echo "Building Docker image $IMAGE_NAME..."
if docker build -t "$IMAGE_NAME" -f "$DOCKERFILE_PATH" "$BUILD_CONTEXT"; then
    echo "Docker image $IMAGE_NAME built successfully"
else
    echo "Failed to build Docker image $IMAGE_NAME" >&2
    exit 1
fi

# Verify the image exists
if docker image inspect "$IMAGE_NAME" >/dev/null 2>&1; then
    echo "Image $IMAGE_NAME is available in your local Docker registry"
else
    echo "Warning: Image $IMAGE_NAME was not found after build" >&2
fi

# Optionally, push the image to a registry
# docker push "$IMAGE_NAME"
