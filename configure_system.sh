#!/bin/bash

# Set hostname
sudo hostnamectl set-hostname pc123456789

# Set timezone
sudo timedatectl set-timezone America/Toronto

# Sync time with NTP
sudo apt update
sudo apt install -y ntpdate
sudo ntpdate time.nist.gov

# Show summary
echo "Hostname:"
hostnamectl
echo "Time info:"
timedatectl
