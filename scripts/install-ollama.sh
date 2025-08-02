#!/bin/bash
set -e

# Check if sudo is available
if ! command -v sudo &> /dev/null; then
  echo "Error: sudo is required but not installed."
  exit 1
fi

# Variables
SERVICE_FILE="/etc/systemd/system/ollama.service"
BACKUP_FILE="/etc/systemd/system/ollama.service.bak"

# Check if Ollama is already installed
if command -v ollama &> /dev/null; then
  echo "Ollama is already installed. Checking current version..."
  ollama version
  echo "Proceeding to update Ollama to the latest version..."
else
  echo "Ollama not found. Installing Ollama..."
fi

# Backup existing service file
if [ -f "$SERVICE_FILE" ]; then
  echo "Backing up $SERVICE_FILE to $BACKUP_FILE..."
  sudo cp "$SERVICE_FILE" "$BACKUP_FILE"
fi

# Install or update Ollama
echo "Running Ollama install/update script..."
curl -fsSL https://ollama.com/install.sh | sh

# Verify installation or update
if command -v ollama &> /dev/null; then
  echo "Ollama installation/update successful. Version:"
  ollama version
else
  echo "Ollama installation/update failed. Check logs or consult docs/troubleshooting.md."
  exit 1
fi

# Restore or update service file
if [ -f "$BACKUP_FILE" ]; then
  echo "Checking if $SERVICE_FILE was modified..."
  if ! sudo cmp -s "$SERVICE_FILE" "$BACKUP_FILE"; then
    echo "Restoring original $SERVICE_FILE..."
    sudo cp "$BACKUP_FILE" "$SERVICE_FILE"
  else
    echo "$SERVICE_FILE unchanged. No restore needed."
  fi
else
  # Update service file to allow network access
  echo "Configuring $SERVICE_FILE for network access..."
  sudo tee "$SERVICE_FILE" > /dev/null << EOL
[Unit]
Description=Ollama Service
After=network-online.target

[Service]
ExecStart=/usr/local/bin/ollama serve
User=ollama
Group=ollama
Restart=always
RestartSec=3
Environment="OLLAMA_HOST=0.0.0.0"

[Install]
WantedBy=default.target
EOL
fi

# Reload systemd and restart Ollama
echo "Reloading systemd and restarting Ollama..."
sudo systemctl daemon-reload
sudo systemctl enable ollama
sudo systemctl restart ollama

# Verify Ollama service is running
if systemctl is-active --quiet ollama; then
  echo "Ollama service is running."
else
  echo "Ollama service failed to start. Check status with 'systemctl status ollama' or consult docs/troubleshooting.md."
  exit 1
fi

echo "Ollama setup complete."
