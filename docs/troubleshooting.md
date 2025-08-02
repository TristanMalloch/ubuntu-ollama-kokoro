# Troubleshooting

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
  - Verify `OLLAMA_HOST=0.0.0.0` in `config/ollama.service`.
  - Check firewall: `sudo ufw allow 11434`.

## Docker Issues
- **NVIDIA Docker not working**:
  - Verify NVIDIA Container Toolkit: `docker run --rm --gpus all nvidia/cuda:12.2.0-base-ubuntu22.04 nvidia-smi`.
  - Restart Docker: `sudo systemctl restart docker`.

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
