#!/usr/bin/env bash
set -euo pipefail

REPO_PATH_DEFAULT="${HOME}/src/agent-skills"
CODEX_HOME_DEFAULT="${HOME}/.codex"
AGENTS_HOME_DEFAULT="${HOME}/.agents"
MARKETPLACE_NAME_DEFAULT="agent-skills"

REPO_PATH="$REPO_PATH_DEFAULT"
CODEX_HOME="$CODEX_HOME_DEFAULT"
AGENTS_HOME="$AGENTS_HOME_DEFAULT"
MARKETPLACE_NAME="$MARKETPLACE_NAME_DEFAULT"
FORCE=0

usage() {
  cat <<'EOF'
Usage: scripts/uninstall-codex-assets.sh [options]

Remove Codex skill symlinks and marketplace entries created by install-codex-assets.sh.

Options:
  --repo-path PATH        Location of the agent-skills clone (default: ~/src/agent-skills)
  --codex-home PATH       Codex user directory (default: ~/.codex)
  --agents-home PATH      Agents user directory for marketplace metadata (default: ~/.agents)
  --marketplace-name NAME Marketplace name to remove (default: agent-skills)
  --force                 Remove copy-mode skill directories that exactly match the repo source
  -h, --help              Show this help message
EOF
}

log() {
  printf '[codex-bootstrap] %s\n' "$*"
}

warn() {
  printf '[codex-bootstrap] warning: %s\n' "$*" >&2
}

normalize_path() {
  python3 - "$1" <<'PY'
import sys
from pathlib import Path

print(Path(sys.argv[1]).expanduser().resolve())
PY
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    --repo-path)
      REPO_PATH="$2"
      shift 2
      ;;
    --codex-home)
      CODEX_HOME="$2"
      shift 2
      ;;
    --agents-home)
      AGENTS_HOME="$2"
      shift 2
      ;;
    --marketplace-name)
      MARKETPLACE_NAME="$2"
      shift 2
      ;;
    --force)
      FORCE=1
      shift
      ;;
    -h|--help)
      usage
      exit 0
      ;;
    *)
      echo "Unknown option: $1" >&2
      usage
      exit 1
      ;;
  esac
done

REPO_PATH="$(normalize_path "$REPO_PATH")"
CODEX_HOME="$(normalize_path "$CODEX_HOME")"
AGENTS_HOME="$(normalize_path "$AGENTS_HOME")"
MARKETPLACE_NAME="${MARKETPLACE_NAME:-$MARKETPLACE_NAME_DEFAULT}"

SKILLS_ROOT="${CODEX_HOME}/skills"

remove_marketplace() {
  local marketplace_file="${AGENTS_HOME}/plugins/marketplace.json"
  [[ -f "$marketplace_file" ]] || { log "Marketplace file not found, skipping removal."; return; }

  python3 - "$marketplace_file" "$MARKETPLACE_NAME" <<'PY'
import json
import sys
from pathlib import Path

marketplace_file = Path(sys.argv[1])
marketplace_name = sys.argv[2]

data = json.loads(marketplace_file.read_text())
if isinstance(data, dict) and "marketplaces" in data and isinstance(data["marketplaces"], list):
    entries = data["marketplaces"]
    style = "list"
elif isinstance(data, dict) and "plugins" in data:
    entries = [data]
    style = "single"
else:
    raise SystemExit(f"Unexpected marketplace format in {marketplace_file}")

filtered = [m for m in entries if m.get("name") != marketplace_name]

if not filtered:
    marketplace_file.unlink()
    print(f"removed marketplace file {marketplace_file}")
    sys.exit(0)

if style == "list" or len(filtered) > 1:
    output = {"marketplaces": filtered}
else:
    output = filtered[0]

marketplace_file.write_text(json.dumps(output, indent=2) + "\n")
print(f"removed marketplace entry \"{marketplace_name}\" from {marketplace_file}")
PY
}

remove_skill_target() {
  local target="$1"

  if [[ -L "$target" ]]; then
    local current
    current="$(readlink "$target")"
    if [[ "$current" == "${REPO_PATH}"/plugins/*/skills/* ]]; then
      rm -f "$target"
      return 0
    fi
    warn "skipping ${target}; symlink points to ${current}"
    return 1
  fi

  if [[ -d "$target" && "$FORCE" -eq 1 ]]; then
    local name source
    name="$(basename "$target")"
    for source in "${REPO_PATH}"/plugins/*/skills/"${name}"; do
      [[ -d "$source" ]] || continue
      if diff -qr "$source" "$target" >/dev/null 2>&1; then
        rm -rf "$target"
        return 0
      fi
    done
  fi

  return 1
}

remove_skills() {
  [[ -d "$SKILLS_ROOT" ]] || { log "Skills directory not found, skipping skill removal."; return; }

  local removed=0
  local skipped=0

  for target in "${SKILLS_ROOT}"/*; do
    [[ -e "$target" || -L "$target" ]] || continue

    if remove_skill_target "$target"; then
      removed=$((removed + 1))
    else
      skipped=$((skipped + 1))
    fi
  done

  log "Skills removed: ${removed}; skipped: ${skipped}"
}

main() {
  remove_marketplace
  remove_skills

  cat <<EOF

Codex assets removed where possible.
- Repository path checked: ${REPO_PATH}
- Marketplace removed (if present): ${MARKETPLACE_NAME}
- Skills directory scanned: ${SKILLS_ROOT}
EOF
}

main "$@"
