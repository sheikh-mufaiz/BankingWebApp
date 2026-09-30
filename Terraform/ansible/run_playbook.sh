#!/usr/bin/env bash
# ==========================================================
# Convenience runner for Ansible Playbooks
# ==========================================================
set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

PLAYBOOK="${1:-site.yml}"
INVENTORY="${2:-inventory.ini}"

echo "=========================================================="
echo "Executing Ansible Playbook: $PLAYBOOK"
echo "Inventory: $INVENTORY"
echo "=========================================================="

ansible-playbook -i "$INVENTORY" "$PLAYBOOK"
