# Ubuntu Ollama + Kokoro Fast API Setup

This repository documents the setup of an Ubuntu Server VM on Proxmox, running **Ollama** and **Kokoro Fast API** with NVIDIA GPU acceleration (e.g. RTX 2000 ADA, 16GB). It also includes an optional **Wyoming OpenAI** integration for text-to-speech with Home Assistant. Although this is based on a VM running in Proxmox, this could apply to a baremetal install of Ubuntu Server or similar.

## Overview
This setup enables:
- **Ollama**: A platform for running large language models with GPU acceleration.
- **Kokoro Fast API**: A GPU-accelerated API for text-to-speech.
- **Wyoming OpenAI**: Integration with Home Assistant for text-to-speech.

The VM uses an NVIDIA RTX 2000 ADA GPU, passed through to the VM, with NVIDIA driver 570.172.08 and CUDA 12.8.

## Prerequisites
- Proxmox VE host with an NVIDIA GPU.
- Ubuntu Server 22.04 or 24.04 (LTS) installed as a VM.
- GPU passthrough configured in Proxmox (see `docs/vm-setup.md`).
- Secure Boot disabled in the VM’s UEFI settings or via `mokutil` (critical for NVIDIA driver installation; see `docs/vm-setup.md`).
- SSH access as a non-root user (e.g., `ubuntu`) with `sudo` privileges.
- Basic familiarity with Linux, Docker, and Git.
- **Important**: Kokoro Fast API requires NVIDIA driver version 570.133.07 or later and CUDA 12.8. Do **not** use Ubuntu’s default NVIDIA driver packages (`ubuntu-drivers-common`, `nvidia-cuda-toolkit`, or `sudo ubuntu-drivers autoinstall`), as they may install an older version (e.g., CUDA 12.4), which is incompatible with Kokoro Fast API.

## Setup Instructions
Run all commands as the `ubuntu` user via SSH. You may be prompted for your `sudo` password.

1. **Create and Configure the VM**:
   - Follow `docs/vm-setup.md` to set up the Ubuntu VM with GPU passthrough.
2. **Install NVIDIA Driver and CUDA 12.8**:
   - **Warning**: Do not use `sudo apt install ubuntu-drivers-common nvidia-cuda-toolkit` or `sudo ubuntu-drivers autoinstall`, as these may install an older CUDA version (e.g., 12.4), causing Kokoro Fast API to fail.
   - Run:
     ```bash
     bash scripts/install-nvidia-driver.sh
     ```
   - This script installs NVIDIA driver 570.172.08 with CUDA 12.8.

3. **Install and configure Ollama**:
   ```bash
   bash scripts/install-ollama.sh
4. **Install Docker with NVIDIA Support**:
   ```bash
   bash scripts/install-docker.sh
5. **Run Kokoro Fast API**:
   ```bash
   bash scripts/setup-kokoro.sh
2. **(Optional) Set Up Wyoming OpenAI**:
   ```bash
   bash scripts/setup-wyoming.sh

**Notes**:
- **Docker Group Membership**: After running `install-docker.sh`, log out and back in to apply the `docker` group membership, or run `newgrp docker` in the same session to avoid using `sudo` for Docker commands.
- **Sudo Prompts**: To minimize `sudo` password prompts, run `sudo -v` before executing scripts to cache credentials.
- **IP Configuration**: Update `TTS_OPENAI_URL` in [`config/docker-compose.fastapi-kokoro.yml`](./config/docker-compose.fastapi-kokoro.yml) to your VM’s IP (default: `192.168.50.136`), or rely on `setup-wyoming.sh` to set it automatically using the VM’s primary network interface.
- **Backup**: Before running scripts, create a Proxmox snapshot of your VM to revert if issues occur.
- **Firewall Configuration**: Allow necessary ports for external access:
  ```bash
  sudo ufw allow 11434  # Ollama
  sudo ufw allow 8880   # Kokoro Fast API
  sudo ufw allow 10200  # Wyoming OpenAI
  sudo ufw enable

## Configuration Files

- `config/ollama.service` (./config/ollama.service): Custom systemd service for Ollama.

- `config/docker-compose.fastapi-kokoro.yml` (./config/docker-compose.fastapi-kokoro.yml): Docker Compose for Wyoming OpenAI.

## Troubleshooting
See `docs/troubleshooting.md` (./docs/troubleshooting.md) for common issues and solutions, including Secure Boot and CUDA version errors.

## Contributing

Contributions are welcome! Please submit issues or pull requests.

## License

This project is licensed under the MIT License - see the LICENSE (./LICENSE) file for details.
