#!/usr/bin/env bash
# Fizzy CLI setup for the hosted instance at https://fizzy.joshyorko.com
set -euo pipefail

FIZZY_API_URL="${FIZZY_API_URL:-https://fizzy.joshyorko.com}"
FIZZY_FORMULA="${FIZZY_FORMULA:-joshyorko/tools/fizzy-cli-master}"
FIZZY_BIN=""

require_brew() {
  if command -v brew >/dev/null 2>&1; then
    return
  fi

  echo "ERROR: Homebrew/Linuxbrew is required to install $FIZZY_FORMULA."
  echo "Install Homebrew first, then rerun this helper."
  exit 1
}

resolve_fizzy_bin() {
  if command -v fizzy >/dev/null 2>&1; then
    command -v fizzy
    return 0
  fi

  local brew_prefix
  brew_prefix=$(brew --prefix)
  if [ -x "$brew_prefix/bin/fizzy" ]; then
    printf '%s\n' "$brew_prefix/bin/fizzy"
    return 0
  fi

  return 1
}

print_path_hint() {
  local brew_bin
  brew_bin="$(brew --prefix)/bin"

  if echo "$PATH" | tr ':' '\n' | grep -qx "$brew_bin"; then
    return
  fi

  echo ""
  echo "Add $brew_bin to your PATH:"
  case "$(basename "${SHELL:-bash}")" in
    zsh)
      echo "  echo 'export PATH=\"$brew_bin:\$PATH\"' >> ~/.zshrc && source ~/.zshrc"
      ;;
    fish)
      echo "  fish_add_path $brew_bin"
      ;;
    *)
      echo "  echo 'export PATH=\"$brew_bin:\$PATH\"' >> ~/.bashrc && source ~/.bashrc"
      ;;
  esac
}

echo "=== Fizzy CLI setup ==="
echo "API URL: $FIZZY_API_URL"
echo "Formula: $FIZZY_FORMULA"
echo ""

require_brew

echo "Installing Fizzy from the self-managed Homebrew tap..."
brew tap joshyorko/tools >/dev/null
brew install "$FIZZY_FORMULA"

if ! FIZZY_BIN=$(resolve_fizzy_bin); then
  echo "ERROR: Installed $FIZZY_FORMULA but could not find the fizzy executable on PATH."
  print_path_hint
  exit 1
fi

echo "Using fizzy at: $FIZZY_BIN"
echo "Version: $("$FIZZY_BIN" --version 2>/dev/null || "$FIZZY_BIN" version 2>/dev/null || echo unknown)"

if [ -n "${FIZZY_TOKEN:-}" ]; then
  echo ""
  echo "Verifying CLI auth against $FIZZY_API_URL ..."
  if "$FIZZY_BIN" identity show --api-url "$FIZZY_API_URL" --markdown >/dev/null; then
    echo "Authentication successful."
    "$FIZZY_BIN" board list --api-url "$FIZZY_API_URL" --limit 1 --markdown >/dev/null
  else
    echo "ERROR: Fizzy CLI could not authenticate with the provided token."
    echo "Check FIZZY_TOKEN or run the interactive setup below."
    exit 1
  fi
fi

echo ""
echo "=== Setup complete ==="
print_path_hint
echo ""
echo "Environment variables for this session:"
echo "  export FIZZY_API_URL=$FIZZY_API_URL"
echo "  export FIZZY_TOKEN=<your-token>"
echo ""
echo "Recommended next steps:"
echo "  1) Run the health check:"
echo "     \"$FIZZY_BIN\" doctor"
echo ""
echo "  2) Review the effective config:"
echo "     \"$FIZZY_BIN\" config show"
echo ""
echo "  3) Install the upstream Fizzy skill if you want it:"
echo "     \"$FIZZY_BIN\" skill"
echo ""
echo "  4) Run interactive setup for the hosted instance:"
echo "     \"$FIZZY_BIN\" setup --api-url \"$FIZZY_API_URL\""
echo ""
echo "  5) Or save a token non-interactively:"
echo "     \"$FIZZY_BIN\" auth login \"\$FIZZY_TOKEN\" --api-url \"$FIZZY_API_URL\""
echo ""
echo "  6) Verify CLI access:"
echo "     \"$FIZZY_BIN\" identity show --api-url \"$FIZZY_API_URL\" --markdown"
echo "     \"$FIZZY_BIN\" board list --api-url \"$FIZZY_API_URL\" --limit 5 --markdown"
echo ""
echo "See plugins/fizzy/skills/fizzy/SKILL.md for the full CLI workflow reference."
