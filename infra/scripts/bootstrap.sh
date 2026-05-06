#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
cd "$ROOT_DIR"

vagrant up
ansible-playbook -i infra/inventory.ini infra/site.yml "$@"
