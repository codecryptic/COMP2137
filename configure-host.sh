#!/bin/bash
# configure-host.sh by Brady — set hostname, IP on eth0, and update /etc/hosts
# Includes fallback to `ip addr` if no netplan file is present

trap '' TERM HUP INT  # ignore termination signals

VERBOSE=0
while [[ $# -gt 0 ]]; do
  case "$1" in
    -verbose) VERBOSE=1; shift ;;
    -name)     WANT_NAME="$2"; shift 2 ;;      # desired hostname
    -ip)       WANT_IP="$2";   shift 2 ;;      # desired eth0 IP
    -hostentry) HE_NAME="$2"; HE_IP="$3"; shift 3 ;;  # separate hosts entry
    *) echo "Bad option: $1"; exit 1 ;;
  esac
done

log_change() {
  logger -t configure-host.sh "$1"
  (( VERBOSE )) && echo "$1"
}

# 1) Hostname change
if [[ -n "${WANT_NAME-}" ]]; then
  CUR=$(hostname)
  if [[ "$CUR" != "$WANT_NAME" ]]; then
    log_change "Hostname changed: $CUR → $WANT_NAME"
    echo "$WANT_NAME" >/etc/hostname
    hostname "$WANT_NAME"
    sed -i "s/$CUR/$WANT_NAME/g" /etc/hosts
  else
    (( VERBOSE )) && echo "Hostname already $WANT_NAME"
  fi
fi

# 2) IP configuration on eth0
if [[ -n "${WANT_IP-}" ]]; then
  # Clean old hosts line
  sed -i "/[[:space:]]${WANT_NAME}\$/d" /etc/hosts
  echo "${WANT_IP}    ${WANT_NAME}" >> /etc/hosts

  NETPLAN_FILE=/etc/netplan/01-netcfg.yaml
  if [[ -f "$NETPLAN_FILE" ]]; then
    # use netplan if available
    if ! grep -q "addresses:.*${WANT_IP}" "$NETPLAN_FILE"; then
      log_change "Netplan update: eth0 → $WANT_IP"
      sed -i "/eth0:/!b;n;c\      addresses: [${WANT_IP}/24]" "$NETPLAN_FILE"
      netplan apply
    fi
    (( VERBOSE )) && echo "Netplan applied, IP = $WANT_IP"
  else
    # fallback: apply immediately via ip(8)
    log_change "No netplan file; applying IP $WANT_IP to eth0 via ip addr"
    ip addr flush dev eth0
    ip addr add "${WANT_IP}/24" dev eth0
    ip link set eth0 up
    (( VERBOSE )) && echo "eth0 set to $WANT_IP via ip cmd"
  fi
fi

# 3) Standalone /etc/hosts entry
if [[ -n "${HE_NAME-}" ]]; then
  if ! grep -q "${HE_IP}[[:space:]]*${HE_NAME}" /etc/hosts; then
    log_change "Adding hosts entry: $HE_NAME → $HE_IP"
    echo "${HE_IP}    ${HE_NAME}" >> /etc/hosts
    (( VERBOSE )) && echo "Hosts entry added for $HE_NAME"
  else
    (( VERBOSE )) && echo "Hosts entry already exists for $HE_NAME"
  fi
fi

exit 0
