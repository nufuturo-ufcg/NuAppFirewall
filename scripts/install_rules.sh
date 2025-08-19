#!/bin/bash
set -e

RULES_PATH="$1"
if [ -z "$RULES_PATH" ]; then
  echo "Uso: $0 /caminho/para/rules.json"
  exit 1
fi

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/get_team_id.sh"

DEST="/private/var/root/Library/Group Containers/${TEAM_ID}.com.nufuturo.nuappfirewall/Library/Application Support/"

sudo mkdir -p "$DEST"

sudo cp "$RULES_PATH" "$DEST"

echo "Rules instaladas em: $DEST"

unset TEAM_ID
