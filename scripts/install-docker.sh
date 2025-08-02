#!/bin/bash
set -e

# Check if sudo is available
if ! command -v sudo &> /dev/null; then
  echo "Error: sudo is required but not installed."
  exit 1
fi

# Install prerequisites
echo "Installing prerequisites..."
sudo apt update && sudo apt upgrade -y
sudo apt install -y curl

# Install Docker
echo "Installing Docker..."
curl -fsSL https://get.docker.com -o get-docker.sh
sudo sh get-docker.sh
sudo usermod -aG docker "$USER"

# Install NVIDIA Container Toolkit
echo "Installing NVIDIA Container Toolkit..."
curl -s -L https://nvidia.github.io/nvidia-docker/gpgkey | sudo apt-key add -
curl -s -L https://nvidia.github.io/nvidia-docker/ubuntu$(lsb_release -rs)/nvidia-docker.list | sudo tee /etc/apt/sources.list.d/nvidia-docker.list
sudo apt update
sudo apt install -y nvidia-docker2
sudo systemctl restart docker

# Verify NVIDIA Docker
if docker run --rm --gpus all nvidia/cuda:12.2.0-base-ubuntu22.04 nvidia-smi; then
  echo "NVIDIA Docker installed successfully."
else
  echo "NVIDIA Docker installation failed."
  exit 1
fi

echo "Docker setup complete."
