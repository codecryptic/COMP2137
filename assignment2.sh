#!/usr/bin/env bash
# assignment2.sh by Brady Smith
# Automates network, hosts, services, and user setup for server1

set -euo pipefail

# Start message
echo "=== Assignment2 Script Starting ==="

# 1. Netplan configuration
echo "-- Locating existing netplan file --"
NETPLAN_FILE=$(ls /etc/netplan/*.yaml | head -n1)
if [[ -z "$NETPLAN_FILE" ]]; then
  echo "[ERROR] No netplan file found in /etc/netplan" >&2
  exit 1
fi

echo "-- Backing up $NETPLAN_FILE --"
cp "$NETPLAN_FILE" "${NETPLAN_FILE}.bak"

echo "-- Writing new netplan configuration --"
cat > "$NETPLAN_FILE" <<EOF
network:
  version: 2
  renderer: networkd
  ethernets:
    $(ip -4 route | awk '/default/ {print $5; exit}'):
      dhcp4: no
      addresses: [192.168.16.21/24]
      gateway4: 192.168.16.2
      nameservers:
        addresses: [8.8.8.8,8.8.4.4]
EOF

echo "-- Applying netplan --"
netplan apply

# 2. /etc/hosts update
echo "-- Updating /etc/hosts --"
sed -i '/server1/d' /etc/hosts
echo "192.168.16.21 server1" >> /etc/hosts

# 3. Install and start services
echo "-- Installing apache2 and squid --"
apt-get update
apt-get install -y apache2 squid

echo "-- Enabling and starting services --"
for svc in apache2 squid; do
  systemctl enable "$svc"
  systemctl restart "$svc"
done

# 4. User accounts and SSH keys
echo "-- Creating user accounts and setting up SSH keys --"
USERS=(dennis aubrey captain snibbles brownie scooter sandy perrier cindy tiger yoda)
den_key="ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIG4rT3vTt99Ox5kndS4HmgTrKBT8SKzhK4rhGkEVGlCI student@generic-vm"

for user in "${USERS[@]}"; do
  # Create user if missing
  if ! id "$user" &>/dev/null; then
    useradd -m -s /bin/bash "$user"
    echo "Created user $user"
  fi

  # Add dennis to sudo group
  if [[ "$user" == "dennis" ]]; then
    usermod -aG sudo dennis
    echo "Added dennis to sudo group"
  fi

  # Setup SSH directory
  ssh_dir="/home/$user/.ssh"
  mkdir -p "$ssh_dir"
  chmod 700 "$ssh_dir"
  chown "$user:$user" "$ssh_dir"

  # Generate SSH keys if missing
  if [[ ! -f "$ssh_dir/id_rsa.pub" ]]; then
    sudo -u "$user" ssh-keygen -t rsa -b 2048 -f "$ssh_dir/id_rsa" -N "" -q
    echo "Generated RSA key for $user"
  fi
  if [[ ! -f "$ssh_dir/id_ed25519.pub" ]]; then
    sudo -u "$user" ssh-keygen -t ed25519 -f "$ssh_dir/id_ed25519" -N "" -q
    echo "Generated ED25519 key for $user"
  fi

  # Build authorized_keys
auth_keys="$ssh_dir/authorized_keys"
  cat "$ssh_dir/id_rsa.pub" "$ssh_dir/id_ed25519.pub" > "$auth_keys"

  # Import custom keys if provided
  if [[ -d "/root/keys/$user" ]]; then
    cat /root/keys/$user/*.pub >> "$auth_keys"
    echo "Imported custom keys for $user"
  fi

  # Add external dennis key
  if [[ "$user" == "dennis" ]]; then
    grep -qxF "$den_key" "$auth_keys" || echo "$den_key" >> "$auth_keys"
  fi

  chmod 600 "$auth_keys"
  chown "$user:$user" "$auth_keys"
  echo "Configured SSH for $user"
done

# Completion message
echo "=== Assignment2 Script Completed Successfully ==="
