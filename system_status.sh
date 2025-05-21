#!/bin/bash

echo "===== System Status Script ====="

# CPU Activity (Load Average)
load=$(uptime | awk -F'load average:' '{ print $2 }' | sed 's/^ //')
echo "CPU Load Average (1, 5, 15 min):$load"

# Free Memory
free_mem=$(free -h | awk '/^Mem:/ { print $4 " free of " $2 }')
echo "Free Memory: $free_mem"

# Free Disk Space (on root partition)
disk_space=$(df -h / | awk 'NR==2 { print $4 " free of " $2 }')
echo "Free Disk Space on /: $disk_space"
