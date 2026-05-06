#!/usr/bin/env bash
set -euo pipefail

if [ "$#" -ne 2 ]; then
  echo "Usage: $0 <github_repo_url> <runner_registration_token>" >&2
  exit 1
fi

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
cd "$ROOT_DIR"

ansible-playbook -i infra/inventory.ini infra/site.yml \
  --limit k3s \
  --tags runner \
  -e "github_repo_url=$1" \
  -e "github_runner_token=$2"
