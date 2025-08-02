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
- SSH access as a non-root user (e.g., `ubuntu`) with `sudo` privileges.
- Basic familiarity with Linux, Docker, and Git.

## Setup Instructions
Run all commands as the `ubuntu` user via SSH. You may be prompted for your `sudo` password.

1. **Create and Configure the VM**:
   - Follow `docs/vm-setup.md` to set up the Ubuntu VM with GPU passthrough.

2. **Install NVIDIA Driver**:
   ```bash
   bash scripts/install-nvidia-driver.sh
