#!/bin/bash
set -e

TEAM_ID=""

# 1. Try to find Team ID in user's keychains
for KC in $(security list-keychains | tr -d '"'); do
  TEAM_ID=$(security find-certificate -a -p "$KC" 2>/dev/null \
    | openssl x509 -inform pem -noout -subject 2>/dev/null \
    | grep "Apple" \
    | grep -oE "OU=[A-Z0-9]{10}" \
    | cut -d= -f2 \
    | head -n 1)
  if [ -n "$TEAM_ID" ]; then break; fi
done

# 2. If not found, try to get it from provisioning profile
if [ -z "$TEAM_ID" ]; then
  PROFILE=$(ls ~/Library/MobileDevice/Provisioning\ Profiles/*.mobileprovision 2>/dev/null | head -n 1)
  if [ -f "$PROFILE" ]; then
    TEAM_ID=$(security cms -D -i "$PROFILE" 2>/dev/null | plutil -extract TeamIdentifier raw -o - -)
  fi
fi

# 3. Function to validate Team ID format
validate_team_id() {
  local ID="$1"
  [[ "$ID" =~ ^[A-Z0-9]{10}$ ]]
}

# 4. Ask user to confirm or input manually
if [ -n "$TEAM_ID" ]; then
  echo "Found Team ID: $TEAM_ID" >&2
  read -p "Use this Team ID? (y/n): " CONFIRM
  if [ "$CONFIRM" != "y" ]; then
    TEAM_ID=""
  fi
fi

# 5. If still empty or rejected, ask until valid
while ! validate_team_id "$TEAM_ID"; do
  read -p "Enter your Apple Developer Team ID (10 characters, A-Z0-9): " USER_TEAM_ID
  TEAM_ID=$(echo "$USER_TEAM_ID" | tr '[:lower:]' '[:upper:]')
  if ! validate_team_id "$TEAM_ID"; then
    echo "Invalid format. Must be exactly 10 letters/numbers." >&2
    TEAM_ID=""
  fi
done

# 6. Output only the raw Team ID (stdout)
echo "$TEAM_ID"
