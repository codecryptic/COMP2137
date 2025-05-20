#!/bin/bash

# Title: update_system.sh
# Description: A basic system update script that runs quietly and logs time-stamped actions.

echo "[$(date '+%Y-%m-%d %H:%M:%S')] Starting system update..."

# Update the package list
sudo apt update -y
echo "[$(date '+%Y-%m-%d %H:%M:%S')] Package list updated."

# Upgrade installed packages
sudo apt upgrade -y
echo "[$(date '+%Y-%m-%d %H:%M:%S')] Installed packages upgraded."

# Clean up unused packages
sudo apt autoremove -y
echo "[$(date '+%Y-%m-%d %H:%M:%S')] Unused packages removed."

echo "[$(date '+%Y-%m-%d %H:%M:%S')] System update complete."
