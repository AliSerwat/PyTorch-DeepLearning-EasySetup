#!/bin/bash

# Default values
IMAGE_NAME="aliserwat/dlwpt:hybrid"
DOCKERFILE_PATH="~/PyTorch-DeepLearning-EasySetup/dlwpt.dockerfile"
BUILD_CONTEXT="~/container-context"
CONTAINER_NAME="dlwpt_container"
SSH_PORT=2222
JUPYTER_PORT=8888

# Function to show usage information
usage() {
    echo "Usage: $0 [-n IMAGE_NAME] [-f DOCKERFILE_PATH] [-c BUILD_CONTEXT] [-s SSH_PORT] [-j JUPYTER_PORT]"
    echo "Options:"
    echo "  -n IMAGE_NAME        Docker image name (default: $IMAGE_NAME)"
    echo "  -f DOCKERFILE_PATH   Path to Dockerfile (default: $DOCKERFILE_PATH)"
    echo "  -c BUILD_CONTEXT     Build context directory (default: $BUILD_CONTEXT)"
    echo "  -s SSH_PORT          Host port to map to container's SSH port (default: $SSH_PORT)"
    echo "  -j JUPYTER_PORT      Host port to map to container's Jupyter port (default: $JUPYTER_PORT)"
    exit 1
}

# Parse command line arguments
while getopts "n:f:c:s:j:" opt; do
    case $opt in
    n) IMAGE_NAME="$OPTARG" ;;
    f) DOCKERFILE_PATH="$OPTARG" ;;
    c) BUILD_CONTEXT="$OPTARG" ;;
    s) SSH_PORT="$OPTARG" ;;
    j) JUPYTER_PORT="$OPTARG" ;;
    \?) usage ;;
    esac
done

# Expand paths
DOCKERFILE_PATH=$(eval echo "$DOCKERFILE_PATH")
BUILD_CONTEXT=$(eval echo "$BUILD_CONTEXT")

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

# Function to check if a port is available
port_is_available() {
    (echo >/dev/tcp/localhost/$1) >/dev/null 2>&1
    return $?
}

# Function to find an available port
find_available_port() {
    local port=$1
    while port_is_available $port && [ $port -lt 65535 ]; do
        port=$((port + 1))
    done
    echo $port
}

# Find available ports
SSH_PORT=$(find_available_port $SSH_PORT)
JUPYTER_PORT=$(find_available_port $JUPYTER_PORT)

# Create and start Docker container
echo "Creating and starting Docker container $CONTAINER_NAME from image $IMAGE_NAME..."
if docker run -d --name "$CONTAINER_NAME" -p $SSH_PORT:22 -p $JUPYTER_PORT:8888 "$IMAGE_NAME"; then
    echo "Container $CONTAINER_NAME created and started successfully"
    echo "SSH port mapped to: $SSH_PORT"
    echo "Jupyter port mapped to: $JUPYTER_PORT"

    # Start VSCode in the container
    echo "Starting VSCode in container $CONTAINER_NAME..."
    docker exec -d "$CONTAINER_NAME" /usr/local/bin/code-root --no-sandbox --user-data-dir=/root/.vscode-root

    # Create an alias for running VSCode with the correct arguments
    docker exec "$CONTAINER_NAME" bash -c "echo 'alias code=\"/usr/bin/code --no-sandbox --user-data-dir=/root/.vscode-root\"' >> /root/.bashrc"

    # Activate and work with the created container
    echo "Activating shell in container $CONTAINER_NAME..."
    docker exec -it "$CONTAINER_NAME" /bin/bash
else
    echo "Failed to create or start container $CONTAINER_NAME" >&2
    exit 1
fi
