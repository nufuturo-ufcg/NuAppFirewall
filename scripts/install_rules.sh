#!/bin/bash
set -e

RULES_PATH="$1"
TEAM_ID="$2"

if [ -z "$RULES_PATH" ] || [ -z "$TEAM_ID" ]; then
  echo "Usage: $0 /path/to/rules.json TEAM_ID"
  exit 1
fi

DEST="/private/var/root/Library/Group Containers/${TEAM_ID}.com.nufuturo.nuappfirewall/Library/Application Support/"

sudo mkdir -p "$DEST"
sudo cp "$RULES_PATH" "$DEST"

echo "Rules installed at: $DEST"
