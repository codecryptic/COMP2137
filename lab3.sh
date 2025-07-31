#!/bin/bash
# This script runs the configure-host.sh script from the current directory
# to modify two servers (server1-mgmt and server2-mgmt) and then update
# the local /etc/hosts file using sudo for the final steps.

set -euo pipefail   # exit on error, unset var, or pipeline failure

# Pass -verbose through to remote scripts if provided
VERB=""
if [[ "${1-:-}" == "-verbose" ]]; then
  VERB="-verbose"
fi

# SSH user on each container
USER="remoteadmin"

# Management hostnames for containers (as seen via incus list)
S1="server1-mgmt"
S2="server2-mgmt"

# LAN eth0 IPs for each container (from incus list)
IP1="192.168.16.200"
IP2="192.168.16.201"

echo "Starting Lab3 deployment…"

# 1) Copy and run on server1-mgmt
scp configure-host.sh "${USER}@${S1}:/root/"
ssh "${USER}@${S1}" -- /root/configure-host.sh ${VERB} -name loghost -ip ${IP1} -hostentry webhost ${IP2}

# 2) Copy and run on server2-mgmt
scp configure-host.sh "${USER}@${S2}:/root/"
ssh "${USER}@${S2}" -- /root/configure-host.sh ${VERB} -name webhost -ip ${IP2} -hostentry loghost ${IP1}

# 3) Update this VM’s /etc/hosts (needs sudo)
sudo ./configure-host.sh ${VERB} -hostentry loghost ${IP1}
sudo ./configure-host.sh ${VERB} -hostentry webhost ${IP2}

echo "lab3.sh has finished applying all changes."
