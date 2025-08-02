#!/bin/bash
set -e

# Check if sudo is available
if ! command -v sudo &> /dev/null; then
  echo "Error: sudo is required but not installed."
  exit 1
fi

# Cache sudo credentials
sudo -v

# Run all setup scripts in sequence
bash scripts/install-nvidia-driver.sh
bash scripts/install-ollama.sh
bash scripts/install-docker.sh
bash scripts/setup-kokoro.sh
bash scripts/setup-wyoming.sh

echo "All setup steps completed."
