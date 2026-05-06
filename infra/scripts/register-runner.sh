#!/usr/bin/env bash
set -euo pipefail

if [ "$#" -ne 2 ]; then
  echo "Usage: $0 <github_repo_url> <runner_registration_token>" >&2
  exit 1
fi

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
cd "$ROOT_DIR"

# Détection automatique du réseau (WSL vs Natif)
INVENTORY="infra/inventory.ini"
if ssh -o BatchMode=yes -o StrictHostKeyChecking=no -o ConnectTimeout=3 -i "$HOME/.ssh/vagrant_insecure_key" "vagrant@192.168.56.10" "echo ok" >/dev/null 2>&1; then
  echo "Réseau Host-Only (VirtualBox) détecté."
  INVENTORY="infra/inventory-hostonly.ini"
else
  echo "Réseau par défaut détecté."
fi

echo "Lancement d'Ansible avec l'inventaire : $INVENTORY"

ansible-playbook -i "$INVENTORY" infra/site.yml \
  --limit k3s \
  --tags runner \
  -e "github_repo_url=$1" \
  -e "github_runner_token=$2"