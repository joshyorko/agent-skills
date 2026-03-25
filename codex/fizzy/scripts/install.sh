#!/usr/bin/env bash
# Fizzy CLI setup for the hosted instance at https://fizzy.joshyorko.com
set -euo pipefail

REPO="basecamp/fizzy-cli"
FIZZY_API_URL="${FIZZY_API_URL:-https://fizzy.joshyorko.com}"
INSTALL_DIR="${FIZZY_BIN_DIR:-$HOME/.local/bin}"
FIZZY_BIN=""
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
    mingw*|msys*|cygwin*) printf 'windows\n' ;;
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

checksum_command() {
  if command -v sha256sum >/dev/null 2>&1; then
    printf 'sha256sum\n'
  elif command -v shasum >/dev/null 2>&1; then
    printf 'shasum -a 256\n'
  else
    echo "ERROR: Neither sha256sum nor shasum is available."
    exit 1
  fi
}

resolve_fizzy_bin() {
  if command -v fizzy >/dev/null 2>&1; then
    command -v fizzy
  elif [ -x "$INSTALL_DIR/fizzy" ]; then
    printf '%s\n' "$INSTALL_DIR/fizzy"
  else
    return 1
  fi
}

print_path_hint() {
  if echo "$PATH" | tr ':' '\n' | grep -qx "$INSTALL_DIR"; then
    return
  fi

  echo ""
  echo "Add $INSTALL_DIR to your PATH:"
  case "$(basename "${SHELL:-bash}")" in
    zsh)
      echo "  echo 'export PATH=\"$INSTALL_DIR:\$PATH\"' >> ~/.zshrc && source ~/.zshrc"
      ;;
    fish)
      echo "  fish_add_path $INSTALL_DIR"
      ;;
    *)
      echo "  echo 'export PATH=\"$INSTALL_DIR:\$PATH\"' >> ~/.bashrc && source ~/.bashrc"
      ;;
  esac
}

install_fizzy() {
  local os arch version asset url checksums_url expected actual checksum_tool
  os=$(detect_os)
  arch=$(detect_arch)
  version=$(latest_version)

  if [ -z "$version" ]; then
    echo "ERROR: Failed to determine the latest fizzy release version."
    exit 1
  fi

  asset="fizzy-${os}-${arch}"
  if [ "$os" = "windows" ]; then
    asset="${asset}.exe"
  fi
  url="https://github.com/$REPO/releases/download/${version}/${asset}"
  checksums_url="https://github.com/$REPO/releases/download/${version}/SHA256SUMS-${os}-${arch}.txt"
  INSTALL_TMPDIR=$(mktemp -d)

  echo "Installing upstream Fizzy CLI ${version}..."
  echo "Downloading ${asset}..."
  curl -fsSL "$url" -o "$INSTALL_TMPDIR/$asset"
  curl -fsSL "$checksums_url" -o "$INSTALL_TMPDIR/checksums.txt"

  echo "Verifying checksum..."
  expected=$(awk '{print $1}' "$INSTALL_TMPDIR/checksums.txt")
  if [ -z "$expected" ]; then
    echo "ERROR: Failed to read release checksum."
    exit 1
  fi

  checksum_tool=$(checksum_command)
  actual=$($checksum_tool "$INSTALL_TMPDIR/$asset" | awk '{print $1}')
  if [ "$expected" != "$actual" ]; then
    echo "ERROR: Checksum mismatch."
    echo "  Expected: $expected"
    echo "  Actual:   $actual"
    exit 1
  fi

  mkdir -p "$INSTALL_DIR"
  install -m 0755 "$INSTALL_TMPDIR/$asset" "$INSTALL_DIR/fizzy"

  FIZZY_BIN="$INSTALL_DIR/fizzy"
}

echo "=== Fizzy CLI setup ==="
echo "API URL: $FIZZY_API_URL"
echo "Install dir: $INSTALL_DIR"
echo ""

if ! FIZZY_BIN=$(resolve_fizzy_bin); then
  install_fizzy
fi

echo "Using fizzy at: $FIZZY_BIN"
echo "Version: $("$FIZZY_BIN" version 2>/dev/null || echo unknown)"

if [ -n "${FIZZY_TOKEN:-}" ]; then
  echo ""
  echo "Verifying CLI auth against $FIZZY_API_URL ..."
  if "$FIZZY_BIN" identity show --api-url "$FIZZY_API_URL" --json > /tmp/fizzy_identity.json; then
    echo "Authentication successful."
    if command -v jq >/dev/null 2>&1; then
      jq -r '"Logged in as: \(.data.name // .data.email_address // .data.email // \"unknown\")"' /tmp/fizzy_identity.json 2>/dev/null || true
    fi
    "$FIZZY_BIN" board list --api-url "$FIZZY_API_URL" --count >/dev/null
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
print_path_hint
echo ""
echo "Environment variables for this session:"
echo "  export FIZZY_API_URL=$FIZZY_API_URL"
echo "  export FIZZY_TOKEN=<your-token>"
echo ""
echo "Recommended next steps:"
echo "  1) Install the upstream Fizzy skill if you want it:"
echo "     \"$FIZZY_BIN\" skill"
echo ""
echo "  2) Run interactive setup for the hosted instance:"
echo "     \"$FIZZY_BIN\" setup --api-url \"$FIZZY_API_URL\""
echo ""
echo "  3) Or save a token non-interactively:"
echo "     \"$FIZZY_BIN\" auth login \"\$FIZZY_TOKEN\" --api-url \"$FIZZY_API_URL\""
echo ""
echo "  4) Verify CLI access:"
echo "     \"$FIZZY_BIN\" identity show --api-url \"$FIZZY_API_URL\" --json | jq ."
echo "     \"$FIZZY_BIN\" board list --api-url \"$FIZZY_API_URL\" --limit 5"
echo ""
echo "See codex/fizzy/SKILL.md for the full CLI workflow reference."
