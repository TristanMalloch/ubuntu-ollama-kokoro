# Proxmox VM Setup with GPU Passthrough

## Prerequisites
- Proxmox VE 7.x or later.
- NVIDIA GPU e.g. RTX 2000 ADA installed.
- Ubuntu Server 22.04 or 24.04 (LTS) ISO.

## Steps
1. **Disable Secure Boot**:
   - Secure Boot must be disabled to allow the NVIDIA driver’s kernel module to load.
   - **In Proxmox VM**:
     - Shut down the VM.
     - In Proxmox, edit the VM’s settings and ensure the firmware is set to UEFI (OVMF).
     - Boot the VM and press the key to enter the UEFI setup (e.g., `F2`, `Del`, or as shown during boot).
     - Navigate to the Secure Boot settings (often under “Boot” or “Security”).
     - Disable Secure Boot and save changes.
   - **In Ubuntu (if already installed)**:
     - Boot into the VM and run:
       ```bash
       sudo mokutil --disable-validation
       ```
     - Follow prompts to set a password and reboot. On reboot, enter the MOK management menu, select “Change Secure Boot state,” and confirm disabling with the password.
     - Verify with: `mokutil --sb-state` (should show “SecureBoot disabled”).

2. **Enable IOMMU**:
   - Edit `/etc/default/grub`:
     ```bash
     sudo nano /etc/default/grub
     GRUB_CMDLINE_LINUX_DEFAULT="quiet intel_iommu=on iommu=pt"  # For Intel CPUs
     # or
     GRUB_CMDLINE_LINUX_DEFAULT="quiet amd_iommu=on iommu=pt"  # For AMD CPUs
     ```
   - Update GRUB:
     ```bash
     sudo update-grub
     ```

3. **Blacklist NVIDIA Nouveau Driver**:
   - Edit `/etc/modprobe.d/blacklist-nouveau.conf`:
     ```bash
     sudo nano /etc/modprobe.d/blacklist-nouveau.conf
     ```
     Add:
     ```ini
     blacklist nouveau
     options nouveau modeset=0
     ```
   - Update initramfs:
     ```bash
     sudo update-initramfs -u
     ```

4. **Add VFIO Modules**:
   - Edit `/etc/modules`:
     ```bash
     sudo nano /etc/modules
     ```
     Add:
     ```ini
     vfio
     vfio_iommu_type1
     vfio_pci
     vfio_virqfd
     ```

5. **Configure GPU Passthrough**:
   - Find GPU PCI ID:
     ```bash
     lspci -nn | grep NVIDIA
     ```
   - Add GPU to VFIO:
     - Edit `/etc/modprobe.d/vfio.conf`:
       ```bash
       sudo nano /etc/modprobe.d/vfio.conf
       ```
       Add:
       ```ini
       options vfio-pci ids=10de:xxxx  # Replace with your GPU's PCI ID
       ```
   - Update initramfs:
     ```bash
     sudo update-initramfs -u
     ```

6. **Create VM**:
   - In Proxmox, create an Ubuntu Server VM with:
     - QEMU Guest Agent enabled.
     - CPU: `host` type.
     - Machine: `q35`.
     - Enable PCIe passthrough for the GPU.

7. **Install Ubuntu Server**:
   - Boot the VM with the Ubuntu ISO and follow the installation prompts.

8. **Verify GPU Passthrough**:
   - Inside the VM, run:
     ```bash
     lspci | grep NVIDIA
     ```
   - If the GPU appears, passthrough is successful.

## Notes
- Ensure VT-d (Intel) or AMD-Vi (AMD) is enabled in the host BIOS.
- Reboot the Proxmox host after enabling IOMMU and VFIO.
- Disabling Secure Boot is critical for the NVIDIA driver installation (see `scripts/install-nvidia-driver.sh`).
