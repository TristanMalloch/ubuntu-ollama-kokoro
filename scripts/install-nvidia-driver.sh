#!/bin/bash
set -e

# Check if sudo is available
if ! command -v sudo &> /dev/null; then
  echo "Error: sudo is required but not installed."
  exit 1
fi

# Check Secure Boot state
if command -v mokutil &> /dev/null; then
  if mokutil --sb-state | grep -q "SecureBoot enabled"; then
    echo "Error: Secure Boot is enabled. This may prevent the NVIDIA driver from loading."
    echo "Please disable Secure Boot in the VM's UEFI settings or run:"
    echo "  sudo mokutil --disable-validation"
    echo "Then reboot and follow the MOK management prompts."
    exit 1
  else
    echo "Secure Boot is disabled. Proceeding with NVIDIA driver installation."
  fi
else
  echo "Warning: mokutil not found. Cannot verify Secure Boot state. Proceeding, but ensure Secure Boot is disabled."
fi

# Uninstall existing NVIDIA drivers installed via apt
echo "Checking for and removing existing NVIDIA drivers installed via apt..."
sudo apt purge -y 'nvidia-*' 'libnvidia-*' 'cuda-*' || true
sudo apt autoremove -y || true
sudo apt autoclean

# Install prerequisites
echo "Installing prerequisites..."
sudo apt update
sudo apt install -y build-essential linux-headers-$(uname -r)

# Variables
NVIDIA_DRIVER_URL="https://us.download.nvidia.com/XFree86/Linux-x86_64/570.172.08/NVIDIA-Linux-x86_64-570.172.08.run"
DRIVER_FILE="NVIDIA-Linux-x86_64-570.172.08.run"

# Download NVIDIA driver
echo "Downloading NVIDIA driver 570.172.08 with CUDA 12.8 (required for Kokoro Fast API)..."
wget -O "$DRIVER_FILE" "$NVIDIA_DRIVER_URL"

# Make executable and run
chmod +x "$DRIVER_FILE"
echo "Installing NVIDIA driver and CUDA 12.8 (you may be prompted for your sudo password)..."
sudo ./"$DRIVER_FILE" --no-cc-version-check

# Verify installation
if nvidia-smi; then
  echo "NVIDIA driver installed successfully."
  # Verify CUDA version
  if command -v nvcc &> /dev/null; then
    CUDA_VERSION=$(nvcc --version | grep -oP 'release \K[0-9]+\.[0-9]+')
    if [[ "$CUDA_VERSION" == "12.8" ]]; then
      echo "CUDA 12.8 verified."
    else
      echo "Error: CUDA version $CUDA_VERSION detected. Kokoro Fast API requires CUDA 12.8."
      exit 1
    fi
  else
    echo "Warning: nvcc not found. Cannot verify CUDA version, but proceeding."
  fi
else
  echo "NVIDIA driver installation failed. Check if Secure Boot is disabled or consult docs/troubleshooting.md."
  exit 1
fi

# Clean up
rm -f "$DRIVER_FILE"
echo "NVIDIA driver and CUDA 12.8 setup complete."
