#!/bin/bash
set -e

# Check if sudo is available
if ! command -v sudo &> /dev/null; then
  echo "Error: sudo is required but not installed."
  exit 1
fi

# Check if git is available
if ! command -v git &> /dev/null; then
  echo "Installing git..."
  sudo apt update
  sudo apt install -y git
fi

# Cache sudo credentials
sudo -v

# Update Kokoro Fast API
echo "Updating Kokoro Fast API..."
docker pull ghcr.io/remsky/kokoro-fastapi-gpu:latest
docker stop kokoro-fastapi || true
docker rm kokoro-fastapi || true
sudo docker run -d --gpus all -p 8880:8880 --name kokoro-fastapi --restart unless-stopped ghcr.io/remsky/kokoro-fastapi-gpu:latest

# Verify Kokoro Fast API
if docker ps | grep kokoro-fastapi; then
  echo "Kokoro Fast API updated and running."
else
  echo "Failed to update Kokoro Fast API. Check logs with 'docker logs kokoro-fastapi'."
  exit 1
fi

# Update Wyoming OpenAI
echo "Updating Wyoming OpenAI..."
cd ~/wyoming_openai
git pull origin main
docker pull ghcr.io/roryeckel/wyoming_openai:latest
sudo docker compose -f docker-compose.fastapi-kokoro.yml down
sudo docker compose -f docker-compose.fastapi-kokoro.yml up -d

# Verify Wyoming OpenAI
if docker ps | grep wyoming_openai; then
  echo "Wyoming OpenAI updated and running."
else
  echo "Failed to update Wyoming OpenAI. Check logs with 'docker logs wyoming_openai'."
  exit 1
fi

echo "Docker services update complete."
