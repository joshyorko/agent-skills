#!/usr/bin/env bash
set -euo pipefail

REPO_URL_DEFAULT="https://github.com/joshyorko/agent-skills.git"
REPO_PATH_DEFAULT="${HOME}/src/agent-skills"
CODEX_HOME_DEFAULT="${HOME}/.codex"
AGENTS_HOME_DEFAULT="${HOME}/.agents"
MARKETPLACE_NAME_DEFAULT="agent-skills"
SKILL_MODE_DEFAULT="link"

REPO_URL="${REPO_URL:-$REPO_URL_DEFAULT}"
REPO_PATH="$REPO_PATH_DEFAULT"
CODEX_HOME="$CODEX_HOME_DEFAULT"
AGENTS_HOME="$AGENTS_HOME_DEFAULT"
MARKETPLACE_NAME="$MARKETPLACE_NAME_DEFAULT"
SKILL_MODE="$SKILL_MODE_DEFAULT"
FORCE=0

usage() {
  cat <<'EOF'
Usage: scripts/install-codex-assets.sh [options]

Bootstrap Codex plugins and skills from this repository into a user-level installation.

Options:
  --repo-path PATH        Destination for the agent-skills clone (default: ~/src/agent-skills)
  --repo-url URL          Git clone URL to use (default: https://github.com/joshyorko/agent-skills.git)
  --codex-home PATH       Codex user directory (default: ~/.codex)
  --agents-home PATH      Agents user directory for marketplace metadata (default: ~/.agents)
  --marketplace-name NAME Marketplace name to register (default: agent-skills)
  --link                  Symlink skills into Codex (default)
  --copy                  Copy skills into Codex instead of symlinking
  --force                 Replace conflicting skill entries
  -h, --help              Show this help message

Environment overrides:
  REPO_URL   Default clone URL

Examples:
  # Fresh environment: clone once, then install from the stable checkout
  if [ ! -d ~/src/agent-skills/.git ]; then git clone https://github.com/joshyorko/agent-skills.git ~/src/agent-skills; fi && bash ~/src/agent-skills/scripts/install-codex-assets.sh --repo-path ~/src/agent-skills

  # Install into a custom location with copies instead of symlinks
  bash ~/code/agent-skills/scripts/install-codex-assets.sh --repo-path ~/code/agent-skills --copy --force
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
    --repo-url)
      REPO_URL="$2"
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
    --link)
      SKILL_MODE="link"
      shift
      ;;
    --copy)
      SKILL_MODE="copy"
      shift
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
CATALOG_PATH="${REPO_PATH}/marketplaces/catalog.json"

clone_or_update_repo() {
  if [[ -d "${REPO_PATH}/.git" ]]; then
    log "Updating existing repository at ${REPO_PATH}"
    git -C "${REPO_PATH}" fetch --tags --prune
    git -C "${REPO_PATH}" pull --ff-only
  elif [[ -e "${REPO_PATH}" ]]; then
    echo "Target path ${REPO_PATH} exists but is not a git repository." >&2
    exit 1
  else
    mkdir -p "$(dirname "${REPO_PATH}")"
    log "Cloning ${REPO_URL} into ${REPO_PATH}"
    git clone "${REPO_URL}" "${REPO_PATH}"
  fi
}

merge_marketplace() {
  local marketplace_file="${AGENTS_HOME}/plugins/marketplace.json"
  mkdir -p "$(dirname "${marketplace_file}")"

  python3 - "$CATALOG_PATH" "$marketplace_file" "$MARKETPLACE_NAME" "$REPO_PATH" <<'PY'
import json
import sys
from pathlib import Path

catalog_path = Path(sys.argv[1])
marketplace_file = Path(sys.argv[2])
marketplace_name = sys.argv[3]
repo_path = Path(sys.argv[4])

catalog = json.loads(catalog_path.read_text())

entry = {
    "name": marketplace_name,
    "interface": catalog.get("interface", {}),
    "plugins": [],
}

for plugin in catalog["plugins"]:
    entry["plugins"].append(
        {
            "name": plugin["name"],
            "source": {
                "source": "local",
                "path": str(repo_path / "plugins" / plugin["name"]),
            },
            "policy": {
                "installation": plugin.get("installation", "AVAILABLE"),
                "authentication": plugin.get("authentication", "ON_INSTALL"),
            },
            "category": plugin["category"],
        }
    )

if marketplace_file.exists():
    data = json.loads(marketplace_file.read_text())
    if isinstance(data, dict) and "marketplaces" in data and isinstance(data["marketplaces"], list):
        existing = data["marketplaces"]
        style = "list"
    elif isinstance(data, dict) and "plugins" in data:
        if data.get("name") != marketplace_name:
            existing_name = data.get("name", "unknown")
            raise SystemExit(
                f"{marketplace_file} already uses a single-marketplace format for "
                f'"{existing_name}". Refusing to convert it automatically; '
                "update or remove the existing file first, or re-run with "
                f"--marketplace-name {existing_name}."
            )
        existing = [data]
        style = "single"
    else:
        raise SystemExit(f"Unexpected marketplace format in {marketplace_file}")
else:
    existing = []
    style = "single"

if style == "list":
    existing = [m for m in existing if m.get("name") != marketplace_name]
    existing.append(entry)
    output = {"marketplaces": existing}
elif existing:
    current = existing[0]
    if current.get("name") not in (None, marketplace_name):
        raise SystemExit(
            f"{marketplace_file} contains single-marketplace entry "
            f"{current.get('name')!r}; refusing to auto-convert to multi-marketplace format. "
            f"Either replace the file intentionally for {marketplace_name!r} or convert it "
            f"manually to {{\"marketplaces\": [...]}} before rerunning."
        )
    output = entry
else:
    output = entry

marketplace_file.write_text(json.dumps(output, indent=2) + "\n")
print(f"wrote marketplace entry to {marketplace_file}")
PY
}

link_skill() {
  local source="$1"
  local target="$2"

  if [[ -L "$target" ]]; then
    local current
    current="$(readlink -f "$target")"
    if [[ "$current" == "$source" ]]; then
      return 0
    fi
    if [[ "$FORCE" -eq 0 ]]; then
      warn "skill ${target} already points to ${current}; use --force to replace"
      return 1
    fi
    rm -f "$target"
  elif [[ -e "$target" ]]; then
    if [[ "$FORCE" -eq 0 ]]; then
      warn "skill ${target} exists; use --force to replace"
      return 1
    fi
    rm -rf "$target"
  fi

  ln -s "$source" "$target"
  return 0
}

copy_skill() {
  local source="$1"
  local target="$2"

  if [[ -e "$target" || -L "$target" ]]; then
    if [[ "$FORCE" -eq 0 ]]; then
      warn "skill ${target} exists; use --force to replace"
      return 1
    fi
    rm -rf "$target"
  fi

  cp -R "$source" "$target"
  return 0
}

install_skills() {
  mkdir -p "$SKILLS_ROOT"
  local linked=0
  local copied=0
  local skipped=0

  for skill_dir in "${REPO_PATH}"/plugins/*/skills/*; do
    [[ -d "$skill_dir" ]] || continue
    local name target
    name="$(basename "$skill_dir")"
    target="${SKILLS_ROOT}/${name}"

    if [[ "$SKILL_MODE" == "copy" ]]; then
      if copy_skill "$skill_dir" "$target"; then
        ((++copied))
      else
        ((++skipped))
      fi
    else
      if link_skill "$skill_dir" "$target"; then
        ((++linked))
      else
        ((++skipped))
      fi
    fi
  done

  log "Skills installed: linked=${linked} copied=${copied} skipped=${skipped}"
}

main() {
  clone_or_update_repo

  if [[ ! -f "$CATALOG_PATH" ]]; then
    echo "Catalog not found at ${CATALOG_PATH}" >&2
    exit 1
  fi

  merge_marketplace
  install_skills

  cat <<EOF

Codex assets installed.
- Repository path: ${REPO_PATH}
- Marketplace: ${AGENTS_HOME}/plugins/marketplace.json (entry "${MARKETPLACE_NAME}")
- Skills directory: ${SKILLS_ROOT}

Next steps:
- Restart Codex to pick up the marketplace change.
- Run "/plugins" or inspect available skills in your client.
EOF
}

main "$@"
