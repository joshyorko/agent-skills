#!/usr/bin/env bash
# Fizzy CLI setup for the hosted instance at https://fizzy.joshyorko.com
set -euo pipefail

REPO="basecamp/fizzy-cli"
FIZZY_API_URL="${FIZZY_API_URL:-https://fizzy.joshyorko.com}"
INSTALL_DIR="${FIZZY_BIN_DIR:-$HOME/.local/bin}"
INSTALL_TMPDIR=""

cleanup() {
  if [ -n "$INSTALL_TMPDIR" ] && [ -d "$INSTALL_TMPDIR" ]; then
    rm -rf "$INSTALL_TMPDIR"
  fi
}

trap cleanup EXIT

detect_os() {
  local os
  os=$(uname -s | tr '[:upper:]' '[:lower:]')
  case "$os" in
    linux|darwin) printf '%s\n' "$os" ;;
    *)
      echo "ERROR: Unsupported OS: $os"
      exit 1
      ;;
  esac
}

detect_arch() {
  local arch
  arch=$(uname -m)
  case "$arch" in
    x86_64|amd64) printf 'amd64\n' ;;
    aarch64|arm64) printf 'arm64\n' ;;
    *)
      echo "ERROR: Unsupported architecture: $arch"
      exit 1
      ;;
  esac
}

latest_version() {
  curl -fsSI "https://github.com/$REPO/releases/latest" \
    | awk 'BEGIN {IGNORECASE=1} /^location:/ {print $2}' \
    | tr -d '\r\n' \
    | sed 's#.*/tag/##'
}

install_fizzy() {
  local os arch version asset url
  os=$(detect_os)
  arch=$(detect_arch)
  version=$(latest_version)

  if [ -z "$version" ]; then
    echo "ERROR: Failed to determine the latest fizzy release version."
    exit 1
  fi

  asset="fizzy-${os}-${arch}"
  url="https://github.com/$REPO/releases/download/${version}/${asset}"
  INSTALL_TMPDIR=$(mktemp -d)

  echo "Installing upstream Fizzy CLI ${version}..."
  echo "Downloading ${asset}..."
  curl -fsSL "$url" -o "$INSTALL_TMPDIR/fizzy"

  mkdir -p "$INSTALL_DIR"
  install -m 0755 "$INSTALL_TMPDIR/fizzy" "$INSTALL_DIR/fizzy"

  export PATH="$INSTALL_DIR:$PATH"
}

echo "=== Fizzy CLI setup ==="
echo "API URL: $FIZZY_API_URL"
echo "Install dir: $INSTALL_DIR"
echo ""

if ! command -v fizzy >/dev/null 2>&1; then
  install_fizzy
fi

echo "Using fizzy at: $(command -v fizzy)"
echo "Version: $(fizzy version 2>/dev/null || echo unknown)"

if [ -n "${FIZZY_TOKEN:-}" ]; then
  echo ""
  echo "Verifying CLI auth against $FIZZY_API_URL ..."
  if fizzy identity show --api-url "$FIZZY_API_URL" --json > /tmp/fizzy_identity.json; then
    echo "Authentication successful."
    if command -v jq >/dev/null 2>&1; then
      jq -r '"Logged in as: \(.data.name // .data.email_address // .data.email // \"unknown\")"' /tmp/fizzy_identity.json 2>/dev/null || true
    fi
    fizzy board list --api-url "$FIZZY_API_URL" --count >/dev/null
  else
    echo "ERROR: Fizzy CLI could not authenticate with the provided token."
    echo "Check FIZZY_TOKEN or run the interactive setup below."
    rm -f /tmp/fizzy_identity.json
    exit 1
  fi
  rm -f /tmp/fizzy_identity.json
fi

echo ""
echo "=== Setup complete ==="
echo ""
echo "Environment variables for this session:"
echo "  export FIZZY_API_URL=$FIZZY_API_URL"
echo "  export FIZZY_TOKEN=<your-token>"
echo ""
echo "Recommended next steps:"
echo "  1) Add the install dir to your PATH if needed:"
echo "     export PATH=\"$INSTALL_DIR:\$PATH\""
echo ""
echo "  2) Run interactive setup for the hosted instance:"
echo "     fizzy setup --api-url \"$FIZZY_API_URL\""
echo ""
echo "  3) Or save a token non-interactively:"
echo "     fizzy auth login \"\$FIZZY_TOKEN\" --api-url \"$FIZZY_API_URL\""
echo ""
echo "  4) Verify CLI access:"
echo "     fizzy identity show --api-url \"$FIZZY_API_URL\" --json | jq ."
echo "     fizzy board list --api-url \"$FIZZY_API_URL\" --limit 5"
echo ""
echo "See claude/fizzy/SKILL.md for the full CLI workflow reference."
