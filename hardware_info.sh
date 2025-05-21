#!/bin/bash

# Show network interface names
echo "Network Interfaces:"
ip link show | grep ": " | awk -F': ' '{print $2}'
echo ""

# Show CPU model and number of cores
echo "CPU Info:"
grep -m1 "model name" /proc/cpuinfo
echo "Number of Cores:"
nproc
echo ""

# Show memory size and manufacturer
echo "Memory Info:"
sudo dmidecode --type memory | grep -E 'Size:|Manufacturer:' | grep -v "No Module"
echo ""

# Show disk drive names and model
echo "Disk Drives:"
lsblk -d -o NAME,MODEL,SIZE
echo ""

# Show video card model
echo "Video Card:"
lspci | grep -i vga
