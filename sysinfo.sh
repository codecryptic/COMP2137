#!/bin/bash

echo "===== System Identification Script ====="

# Hostname
hostname=$(hostname)
echo "Hostname: $hostname"

# IP Address (first non-loopback IPv4)
ip_address=$(ip -4 addr show | grep -oP '(?<=inet\s)\d+(\.\d+){3}' | grep -v '^127' | head -n 1)
echo "IP Address: $ip_address"

# Default Gateway
gateway=$(ip route | grep default | awk '{print $3}')
echo "Default Gateway: $gateway"
