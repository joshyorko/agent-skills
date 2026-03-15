#!/usr/bin/env bash
# Fizzy hosted-instance setup for https://fizzy.joshyorko.com
#
# There is no stable self-hosted CLI binary for this instance.
# The supported and validated approach is direct HTTP API calls with a Bearer token.
# This script configures the environment and verifies connectivity.
set -euo pipefail

FIZZY_API_URL="${FIZZY_API_URL:-https://fizzy.joshyorko.com}"

echo "=== Fizzy hosted-instance setup ==="
echo "API URL: $FIZZY_API_URL"
echo ""

# Require a token
if [ -z "${FIZZY_TOKEN:-}" ]; then
  echo "ERROR: FIZZY_TOKEN is not set."
  echo ""
  echo "Set your API token before running this script:"
  echo "  export FIZZY_TOKEN=fizzy_your_token_here"
  echo ""
  echo "Then re-run:"
  echo "  bash claude/fizzy/scripts/install.sh"
  exit 1
fi

echo "Verifying token against $FIZZY_API_URL/my/identity ..."
HTTP_STATUS=$(curl -s -o /tmp/fizzy_identity.json -w "%{http_code}" \
  -H "Authorization: Bearer $FIZZY_TOKEN" \
  "$FIZZY_API_URL/my/identity")

if [ "$HTTP_STATUS" != "200" ]; then
  echo "ERROR: Authentication failed (HTTP $HTTP_STATUS)."
  echo "Check that FIZZY_TOKEN is correct and that the instance is reachable."
  rm -f /tmp/fizzy_identity.json
  exit 1
fi

echo "Authentication successful."
if command -v jq >/dev/null 2>&1; then
  jq -r '"Logged in as: \(.name // .email // "unknown")"' /tmp/fizzy_identity.json 2>/dev/null || true
fi
rm -f /tmp/fizzy_identity.json

echo ""
echo "=== Setup complete ==="
echo ""
echo "Environment variables for this session:"
echo "  export FIZZY_TOKEN=<your-token>"
echo "  export FIZZY_API_URL=$FIZZY_API_URL"
echo ""
echo "Quick API reference:"
echo "  # Identity"
echo "  curl -s -H \"Authorization: Bearer \$FIZZY_TOKEN\" \$FIZZY_API_URL/my/identity | jq ."
echo ""
echo "  # List boards"
echo "  curl -s -H \"Authorization: Bearer \$FIZZY_TOKEN\" \$FIZZY_API_URL/1/boards | jq ."
echo ""
echo "  # Create a board"
echo "  curl -s -X POST -H \"Authorization: Bearer \$FIZZY_TOKEN\" \\"
echo "    -H \"Content-Type: application/json\" \\"
echo "    -d '{\"name\": \"My Board\"}' \\"
echo "    \$FIZZY_API_URL/1/boards | jq ."
echo ""
echo "See claude/fizzy/SKILL.md for the full HTTP API reference."
