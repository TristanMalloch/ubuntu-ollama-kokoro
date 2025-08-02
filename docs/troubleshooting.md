# Troubleshooting

## CUDA Version Issues
- **Error: Kokoro Fast API fails to start with CUDA error**:
  - **Cause**: Kokoro Fast API requires CUDA 12.8, but Ubuntu’s default NVIDIA driver packages (e.g., via `sudo ubuntu-drivers autoinstall` or `sudo apt install nvidia-cuda-toolkit`) may install an older version (e.g., CUDA 12.4).
  - **Solution**:
    - Uninstall any existing NVIDIA/CUDA packages:
      ```bash
      sudo apt purge -y 'nvidia-*' 'libnvidia-*' 'cuda-*'
      sudo apt autoremove -y
      sudo apt autoclean
      ```
    - Re-run the NVIDIA driver installation:
      ```bash
      bash scripts/install-nvidia-driver.sh
      ```
    - Verify CUDA version:
      ```bash
      nvcc --version
      ```
      Ensure it reports `release 12.8`. If `nvcc` is not found, check `nvidia-smi` output for the CUDA version.
- **Warning: Do not use `sudo ubuntu-drivers autoinstall` or `sudo apt install ubuntu-drivers-common nvidia-cuda-toolkit`, as these install outdated drivers incompatible with Kokoro Fast API.

## Secure Boot Issues
- **Error: NVIDIA driver fails to load or install**:
  - **Cause**: Secure Boot is enabled, preventing unsigned kernel modules.
  - **Solution**:
    - Verify Secure Boot state:
      ```bash
      mokutil --sb-state
      ```
    - If enabled, disable it:
      ```bash
      sudo mokutil --disable-validation
      ```
      Reboot, enter the MOK management menu (follow on-screen prompts), and confirm disabling with the password you set.
    - Alternatively, disable Secure Boot in the VM’s UEFI settings (see `docs/vm-setup.md`).
    - Re-run the driver installation:
      ```bash
      bash scripts/install-nvidia-driver.sh
      ```

## NVIDIA Driver Issues
- **Error: nvidia-smi not found**:
  - Verify driver installation: `lsmod | grep nvidia`.
  - Ensure Secure Boot is disabled (see above).
  - Reinstall driver: `bash scripts/install-nvidia-driver.sh`.
- **GPU not detected**:
  - Check passthrough configuration in Proxmox.
  - Ensure IOMMU is enabled in BIOS and Proxmox.

## Ollama Issues
- **Ollama not accessible over network**:
  - Verify `OLLAMA_HOST=0.0.0.0` in [`config/ollama.service`](../config/ollama.service).
  - Check firewall:
    ```bash
    sudo ufw allow 11434
    ```
- **Ollama version outdated**:
  - **Cause**: An older version of Ollama may cause compatibility issues.
  - **Solution**: Re-run the installation script to update to the latest version:
    ```bash
    bash scripts/install-ollama.sh
    ```
    Verify the version:
    ```bash
    ollama version
    ```
- **Ollama service not running**:
  - Check service status:
    ```bash
    systemctl status ollama
    ```
  - Restart the service:
    ```bash
    sudo systemctl restart ollama
    ```
  - Re-run the script if needed:
    ```bash
    bash scripts/install-ollama.sh
    ```

## Docker Issues
- **NVIDIA Docker not working**:
  - Verify NVIDIA Container Toolkit: `docker run --rm --gpus all nvidia/cuda:12.2.0-base-ubuntu22.04 nvidia-smi`.
  - Restart Docker: `sudo systemctl restart docker`.

## Docker Update Issues
- **Kokoro Fast API or Wyoming OpenAI not using the latest image**:
  - **Cause**: Docker caches images and doesn’t pull the latest `:latest` tag automatically on reboot.
  - **Solution**: Use the update script:
    ```bash
    bash scripts/update-services.sh
    ```
    Or manually update:
    - For Kokoro Fast API:
      ```bash
      docker pull ghcr.io/remsky/kokoro-fastapi-gpu:latest
      docker stop kokoro-fastapi
      docker rm kokoro-fastapi
      sudo docker run -d --gpus all -p 8880:8880 --name kokoro-fastapi --restart unless-stopped ghcr.io/remsky/kokoro-fastapi-gpu:latest
      ```
    - For Wyoming OpenAI:
      ```bash
      cd ~/wyoming_openai
      git pull origin main
      docker pull ghcr.io/roryeckel/wyoming_openai:latest
      sudo docker compose -f docker-compose.fastapi-kokoro.yml down
      sudo docker compose -f docker-compose.fastapi-kokoro.yml up -d
      ```
    Verify containers are running:
    ```bash
    docker ps
    ```
- **Wyoming OpenAI repository outdated**:
  - **Cause**: The cloned `wyoming_openai` repository may not have the latest configuration files.
  - **Solution**: Update the repository:
    ```bash
    cd ~/wyoming_openai
    git pull origin main
    ```
    Then restart the service:
    ```bash
    sudo docker compose -f docker-compose.fastapi-kokoro.yml down
    sudo docker compose -f docker-compose.fastapi-kokoro.yml up -d
    ```
## Sudo Issues
- **Error: User is not in sudoers file**:
  - Log in as root or another admin user and add the `ubuntu` user to the `sudo` group:
    ```bash
    usermod -aG sudo ubuntu
    ```
  - Verify with: `groups ubuntu`.
- **Frequent sudo prompts**:
  - Cache credentials: `sudo -v`.
  - Or run scripts as root: `sudo -i`.
