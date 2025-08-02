#!/bin/bash
set -e

# Check if sudo is available
if ! command -v sudo &> /dev/null; then
  echo "Error: sudo is required but not installed."
  exit 1
fi

# Install git if not present
echo "Installing git..."
sudo apt update
sudo apt install -y git

# Clone Wyoming OpenAI repository
echo "Cloning Wyoming OpenAI repository..."
if [ -d "wyoming_openai" ]; then
  rm -rf wyoming_openai
fi
git clone https://github.com/roryeckel/wyoming_openai.git
cd wyoming_openai

# Copy Docker Compose file from config
echo "Copying Docker Compose file..."
cp ../config/docker-compose.fastapi-kokoro.yml .

# Set TTS_OPENAI_URL dynamically
echo "Setting TTS_OPENAI_URL to VM's IP..."
export TTS_OPENAI_URL="http://$(hostname -I | awk '{print $1}'):8880/v1/audio/speech"

# Run Docker Compose
echo "Starting Wyoming OpenAI..."
sudo docker compose -f docker-compose.fastapi-kokoro.yml down
sudo docker compose -f docker-compose.fastapi-kokoro.yml up -d

# Verify service is running
if docker ps | grep wyoming_openai; then
  echo "Wyoming OpenAI is running."
else
  echo "Failed to start Wyoming OpenAI."
  exit 1
fi

echo "Wyoming OpenAI setup complete."
