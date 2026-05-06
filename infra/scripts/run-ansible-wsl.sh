#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
cd "$ROOT_DIR"

mkdir -p "$HOME/.ssh"
if [ ! -f "$HOME/.ssh/vagrant_insecure_key" ]; then
  cp "$ROOT_DIR/.vagrant.d/insecure_private_key" "$HOME/.ssh/vagrant_insecure_key"
  chmod 600 "$HOME/.ssh/vagrant_insecure_key"
fi

WINDOWS_HOST_IP="$(awk '/nameserver/ { print $2; exit }' /etc/resolv.conf)"
NAT_INVENTORY="/tmp/tp-final-inventory-nat.ini"
sed "s/WINDOWS_HOST_IP/${WINDOWS_HOST_IP}/g" infra/inventory-wsl.ini > "$NAT_INVENTORY"

if ssh -o BatchMode=yes -o StrictHostKeyChecking=no -o ConnectTimeout=3 -i "$HOME/.ssh/vagrant_insecure_key" -p 2222 "vagrant@${WINDOWS_HOST_IP}" "echo ok" >/dev/null 2>&1; then
  INVENTORY="$NAT_INVENTORY"
elif ssh -o BatchMode=yes -o StrictHostKeyChecking=no -o ConnectTimeout=3 -i "$HOME/.ssh/vagrant_insecure_key" "vagrant@192.168.56.10" "echo ok" >/dev/null 2>&1; then
  INVENTORY="infra/inventory-hostonly.ini"
else
  echo "Impossible de joindre k3s via ${WINDOWS_HOST_IP}:2222 ou 192.168.56.10:22" >&2
  exit 1
fi

ANSIBLE_CONFIG="$ROOT_DIR/ansible.cfg" ansible-playbook -i "$INVENTORY" infra/site.yml "$@"