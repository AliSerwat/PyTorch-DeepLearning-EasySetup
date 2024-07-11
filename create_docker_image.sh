#!/bin/bash

# Default values
IMAGE_NAME="aliserwat/dlwpt:hybrid"
DOCKERFILE_PATH=~/Easy_setup_for_Deep_Learning_with_PyTorch/dlwpt.dockerfile
BUILD_CONTEXT=~/dlwpt-code
CONTAINER_NAME="dlwpt_container"

# Function to show usage information
usage() {
    echo "Usage: $0 [-n IMAGE_NAME] [-f DOCKERFILE_PATH] [-c BUILD_CONTEXT]"
    echo "Options:"
    echo "  -n IMAGE_NAME        Docker image name (default: $IMAGE_NAME)"
    echo "  -f DOCKERFILE_PATH   Path to Dockerfile (default: $DOCKERFILE_PATH)"
    echo "  -c BUILD_CONTEXT     Build context directory (default: $BUILD_CONTEXT)"
    exit 1
}

# Parse command line arguments
while getopts "n:f:c:" opt; do
    case $opt in
    n) IMAGE_NAME="$OPTARG" ;;
    f) DOCKERFILE_PATH="$OPTARG" ;;
    c) BUILD_CONTEXT="$OPTARG" ;;
    \?) usage ;;
    esac
done

# Ensure build context directory exists
mkdir -p "$BUILD_CONTEXT"

# Remove existing container with the same name if it exists
docker rm -f "$CONTAINER_NAME" >/dev/null 2>&1

# Build Docker image
echo "Building Docker image $IMAGE_NAME from $DOCKERFILE_PATH in $BUILD_CONTEXT..."
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
    exit 1
fi

# Create and start Docker container
echo "Creating and starting Docker container $CONTAINER_NAME from image $IMAGE_NAME..."
if docker run -d --name "$CONTAINER_NAME" "$IMAGE_NAME"; then
    echo "Container $CONTAINER_NAME created and started successfully"
else
    echo "Failed to create or start container $CONTAINER_NAME" >&2
    exit 1
fi
