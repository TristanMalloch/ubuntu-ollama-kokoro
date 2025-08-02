#!/bin/bash
set -e

# Check if sudo is available
if ! command -v sudo &> /dev/null; then
  echo "Error: sudo is required but not installed."
  exit 1
fi

# Run Kokoro Fast API container
echo "Starting Kokoro Fast API..."
sudo docker run -d --gpus all -p 8880:8880 --name kokoro-fastapi --restart unless-stopped ghcr.io/remsky/kokoro-fastapi-gpu:latest

# Verify container is running
if docker ps | grep kokoro-fastapi; then
  echo "Kokoro Fast API is running."
else
  echo "Failed to start Kokoro Fast API."
  exit 1
fi

echo "Kokoro Fast API setup complete."
