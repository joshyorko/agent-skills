#!/usr/bin/env bash
set -euo pipefail

readonly DEFAULT_AGENT_COLUMN="Ready for Agents"
readonly DEFAULT_DONE_COLUMN="Done"
readonly DEFAULT_BACKEND="codex"
readonly DEFAULT_TITLE="Repo Agent"
readonly DEFAULT_PROMPT="You are working in this repository. Inspect the card request, read relevant files, make the smallest safe change, run appropriate local checks, and summarize what changed. Do not commit unless the card explicitly asks for a commit."
readonly DEFAULT_SMOKE_TITLE="Smoke test the agent loop"
readonly DEFAULT_SMOKE_DESCRIPTION="Inspect this repository and post a short summary of what it is."

readonly BACKEND_TAGS=(codex claude opencode anthropic openai command)
readonly DEFAULT_STEPS=(
  "Inspect the repository and the card request"
  "Make the smallest safe change that satisfies the request"
  "Run the appropriate local checks"
  "Summarize what changed and any follow-up needed"
)

BOARD_ID=""
BACKEND="$DEFAULT_BACKEND"
AGENT_COLUMN="$DEFAULT_AGENT_COLUMN"
COMPLETION="move-to-done"
DONE_COLUMN="$DEFAULT_DONE_COLUMN"
TITLE="$DEFAULT_TITLE"
PROMPT="$DEFAULT_PROMPT"
SMOKE_CARD=0
SMOKE_TITLE="$DEFAULT_SMOKE_TITLE"
SMOKE_DESCRIPTION="$DEFAULT_SMOKE_DESCRIPTION"
DRY_RUN=0
FORCE_TAGS=0
FIZZY_ARGS=()

usage() {
  cat <<'EOF'
Usage:
  bootstrap-fizzy-popper-board.sh --board BOARD_ID [options]

Options:
  --board BOARD_ID                 Existing Fizzy board to prepare (required)
  --backend BACKEND                codex, claude, opencode, anthropic, openai, or command (default: codex)
  --agent-column NAME              Agent-enabled column name (default: Ready for Agents)
  --completion MODE                move-to-done, move-to:Column Name, or close-on-complete
  --done-column NAME               Alias for --completion move-to:NAME
  --title TITLE                    Golden-ticket title (default: Repo Agent)
  --prompt TEXT                    Golden-ticket prompt
  --prompt-file PATH               Read golden-ticket prompt from a file
  --smoke-card                     Create a smoke-test work card in the agent column
  --smoke-title TITLE              Smoke-test card title
  --smoke-description TEXT         Smoke-test card description
  --api-url URL                    Pass through to fizzy
  --profile NAME                   Pass through to fizzy
  --dry-run                        Print intended mutations without changing Fizzy
  --force-tags                     Replace conflicting backend/completion tags on an existing golden ticket
  -h, --help                       Show this help
EOF
}

die() {
  printf 'ERROR: %s\n' "$*" >&2
  exit 1
}

contains() {
  local needle="$1"
  shift
  local item
  for item in "$@"; do
    [[ "$item" == "$needle" ]] && return 0
  done
  return 1
}

slugify() {
  python3 - "$1" <<'PY'
import re
import sys

slug = re.sub(r"[^a-z0-9]+", "-", sys.argv[1].strip().lower()).strip("-")
print(slug or "done")
PY
}

completion_tag_for_column() {
  printf 'move-to-%s\n' "$(slugify "$1")"
}

json_data_rows_expr='
def rows(payload):
    data = payload.get("data", payload) if isinstance(payload, dict) else payload
    if isinstance(data, list):
        return data
    if isinstance(data, dict):
        for key in ("columns", "cards", "steps", "items"):
            value = data.get(key)
            if isinstance(value, list):
                return value
    return []

def tags_for(card):
    tags = []
    for tag in card.get("tags") or []:
        if isinstance(tag, str):
            tags.append(tag)
        elif isinstance(tag, dict):
            tags.append(tag.get("title") or tag.get("name") or tag.get("tag") or "")
    return [tag for tag in tags if tag]

def column_id_for(card):
    column = card.get("column")
    if isinstance(column, dict):
        return column.get("id")
    return card.get("column_id")
'

json_board_name() {
  python3 - "$1" <<PY
import json
import sys

payload = json.load(open(sys.argv[1], encoding="utf-8"))
data = payload.get("data", payload)
print(data.get("name", ""))
PY
}

json_find_column_id() {
  python3 - "$1" "$2" <<PY
import json
import sys

$json_data_rows_expr

payload = json.load(open(sys.argv[1], encoding="utf-8"))
name = sys.argv[2]
for column in rows(payload):
    if column.get("name") == name:
        print(column.get("id", ""))
        break
PY
}

json_card_number() {
  python3 - "$1" <<PY
import json
import sys

payload = json.load(open(sys.argv[1], encoding="utf-8"))
data = payload.get("data", payload)
print(data.get("number", ""))
PY
}

json_golden_numbers() {
  python3 - "$1" "$2" <<PY
import json
import sys

$json_data_rows_expr

payload = json.load(open(sys.argv[1], encoding="utf-8"))
agent_column_id = sys.argv[2]
for card in rows(payload):
    if column_id_for(card) == agent_column_id and "agent-instructions" in tags_for(card):
        print(card.get("number"))
PY
}

json_card_tags() {
  python3 - "$1" "$2" <<PY
import json
import sys

$json_data_rows_expr

payload = json.load(open(sys.argv[1], encoding="utf-8"))
number = int(sys.argv[2])
for card in rows(payload):
    if int(card.get("number")) == number:
        for tag in tags_for(card):
            print(tag)
        break
PY
}

json_step_contents() {
  python3 - "$1" <<PY
import json
import sys

$json_data_rows_expr

payload = json.load(open(sys.argv[1], encoding="utf-8"))
for step in rows(payload):
    if isinstance(step, str):
        print(step)
    else:
        print(step.get("content", ""))
PY
}

parse_args() {
  while (($#)); do
    case "$1" in
      --board)
        BOARD_ID="${2:?missing value for --board}"
        shift 2
        ;;
      --backend)
        BACKEND="${2:?missing value for --backend}"
        shift 2
        ;;
      --agent-column)
        AGENT_COLUMN="${2:?missing value for --agent-column}"
        shift 2
        ;;
      --completion)
        COMPLETION="${2:?missing value for --completion}"
        shift 2
        ;;
      --done-column)
        DONE_COLUMN="${2:?missing value for --done-column}"
        COMPLETION="move-to:$DONE_COLUMN"
        shift 2
        ;;
      --title)
        TITLE="${2:?missing value for --title}"
        shift 2
        ;;
      --prompt)
        PROMPT="${2:?missing value for --prompt}"
        shift 2
        ;;
      --prompt-file)
        PROMPT="$(<"${2:?missing value for --prompt-file}")"
        shift 2
        ;;
      --smoke-card)
        SMOKE_CARD=1
        shift
        ;;
      --smoke-title)
        SMOKE_TITLE="${2:?missing value for --smoke-title}"
        shift 2
        ;;
      --smoke-description)
        SMOKE_DESCRIPTION="${2:?missing value for --smoke-description}"
        shift 2
        ;;
      --api-url)
        FIZZY_ARGS+=(--api-url "${2:?missing value for --api-url}")
        shift 2
        ;;
      --profile)
        FIZZY_ARGS+=(--profile "${2:?missing value for --profile}")
        shift 2
        ;;
      --dry-run)
        DRY_RUN=1
        shift
        ;;
      --force-tags)
        FORCE_TAGS=1
        shift
        ;;
      -h|--help)
        usage
        exit 0
        ;;
      *)
        die "Unknown argument: $1"
        ;;
    esac
  done
}

fizzy_json() {
  fizzy "$@" "${FIZZY_ARGS[@]}" --json
}

mutate_json() {
  if ((DRY_RUN)); then
    printf 'DRY RUN: fizzy'
    printf ' %q' "$@"
    printf '\n'
    printf '{"ok":true,"data":{}}\n'
  else
    fizzy_json "$@"
  fi
}

ensure_column() {
  local columns_file="$1"
  local name="$2"
  local column_id
  column_id="$(json_find_column_id "$columns_file" "$name")"
  if [[ -n "$column_id" ]]; then
    printf '%s\n' "$column_id"
    return
  fi

  if ((DRY_RUN)); then
    printf 'DRY RUN: would create column %q on board %q\n' "$name" "$BOARD_ID" >&2
    printf '__dry_run_%s\n' "$(slugify "$name")"
    return
  fi

  local result_file="$TMPDIR/column-create.json"
  mutate_json column create --board "$BOARD_ID" --name "$name" >"$result_file"
  python3 - "$result_file" <<'PY'
import json
import sys

payload = json.load(open(sys.argv[1], encoding="utf-8"))
data = payload.get("data", payload)
print(data.get("id", ""))
PY
}

create_card() {
  local title="$1"
  local description="$2"
  if ((DRY_RUN)); then
    printf 'DRY RUN: would create card %q on board %q\n' "$title" "$BOARD_ID" >&2
    printf '0\n'
    return
  fi

  local result_file="$TMPDIR/card-create.json"
  mutate_json card create --board "$BOARD_ID" --title "$title" --description "$description" >"$result_file"
  json_card_number "$result_file"
}

move_card_to_column() {
  local number="$1"
  local column_id="$2"
  mutate_json card column "$number" --column "$column_id" >/dev/null
}

toggle_tag() {
  local number="$1"
  local tag="$2"
  mutate_json card tag "$number" --tag "$tag" >/dev/null
}

add_step() {
  local number="$1"
  local content="$2"
  mutate_json step create --card "$number" --content "$content" >/dev/null
}

has_line() {
  local needle="$1"
  local line
  while IFS= read -r line; do
    [[ "$line" == "$needle" ]] && return 0
  done
  return 1
}

completion_setup() {
  case "$COMPLETION" in
    close-on-complete)
      COMPLETION_TAG="close-on-complete"
      COMPLETION_LABEL="close card on complete"
      COMPLETION_COLUMN_ID=""
      ;;
    move-to-done)
      DONE_COLUMN="$DEFAULT_DONE_COLUMN"
      COMPLETION_TAG="move-to-done"
      COMPLETION_LABEL="move to Done"
      COMPLETION_COLUMN_ID="$(ensure_column "$COLUMNS_FILE" "$DONE_COLUMN")"
      ;;
    move-to:*)
      DONE_COLUMN="${COMPLETION#move-to:}"
      [[ -n "$DONE_COLUMN" ]] || die "--completion move-to: requires a column name"
      COMPLETION_TAG="$(completion_tag_for_column "$DONE_COLUMN")"
      COMPLETION_LABEL="move to $DONE_COLUMN"
      COMPLETION_COLUMN_ID="$(ensure_column "$COLUMNS_FILE" "$DONE_COLUMN")"
      ;;
    *)
      die "Unsupported --completion value: $COMPLETION"
      ;;
  esac
}

validate_inputs() {
  [[ -n "$BOARD_ID" ]] || die "--board BOARD_ID is required"
  contains "$BACKEND" "${BACKEND_TAGS[@]}" || die "Unsupported --backend value: $BACKEND"
  command -v fizzy >/dev/null 2>&1 || die "fizzy CLI is not on PATH"
  command -v python3 >/dev/null 2>&1 || die "python3 is required for JSON parsing"
}

refresh_cards() {
  fizzy_json card list --board "$BOARD_ID" --all >"$CARDS_FILE"
}

ensure_tags() {
  local number="$1"
  shift
  local current_tags_file="$TMPDIR/card-tags.txt"
  json_card_tags "$CARDS_FILE" "$number" >"$current_tags_file"

  local desired_tags=("$@")
  local conflicting=()
  local tag desired
  while IFS= read -r tag; do
    [[ -z "$tag" ]] && continue
    for desired in "${desired_tags[@]}"; do
      [[ "$tag" == "$desired" ]] && continue 2
    done
    if contains "$tag" "${BACKEND_TAGS[@]}" || [[ "$tag" == close-on-complete || "$tag" == move-to-* ]]; then
      conflicting+=("$tag")
    fi
  done <"$current_tags_file"

  if ((${#conflicting[@]})) && ((!FORCE_TAGS)); then
    die "Golden ticket #$number already has conflicting tag(s): ${conflicting[*]}. Rerun with --force-tags to replace them."
  fi

  if ((${#conflicting[@]})); then
    for tag in "${conflicting[@]}"; do
      toggle_tag "$number" "$tag"
    done
  fi

  for tag in "${desired_tags[@]}"; do
    if ! has_line "$tag" <"$current_tags_file"; then
      toggle_tag "$number" "$tag"
    fi
  done
}

ensure_steps() {
  local number="$1"
  local steps_file="$TMPDIR/steps-$number.json"
  local contents_file="$TMPDIR/step-contents-$number.txt"

  if ((DRY_RUN)) && [[ "$number" == "0" ]]; then
    local step
    for step in "${DEFAULT_STEPS[@]}"; do
      printf 'DRY RUN: would create step %q on the new golden ticket\n' "$step" >&2
    done
    return
  fi

  fizzy_json step list --card "$number" >"$steps_file"
  json_step_contents "$steps_file" >"$contents_file"

  local step
  for step in "${DEFAULT_STEPS[@]}"; do
    if ! has_line "$step" <"$contents_file"; then
      add_step "$number" "$step"
    fi
  done
}

main() {
  parse_args "$@"
  validate_inputs

  TMPDIR="$(mktemp -d)"
  trap 'rm -rf "$TMPDIR"' EXIT
  readonly TMPDIR

  BOARD_FILE="$TMPDIR/board.json"
  COLUMNS_FILE="$TMPDIR/columns.json"
  CARDS_FILE="$TMPDIR/cards.json"
  readonly BOARD_FILE COLUMNS_FILE CARDS_FILE

  fizzy_json board show "$BOARD_ID" >"$BOARD_FILE"
  BOARD_NAME="$(json_board_name "$BOARD_FILE")"
  if ((DRY_RUN)); then
    printf 'DRY RUN: no Fizzy mutations will be performed.\n'
  fi

  fizzy_json column list --board "$BOARD_ID" >"$COLUMNS_FILE"
  AGENT_COLUMN_ID="$(ensure_column "$COLUMNS_FILE" "$AGENT_COLUMN")"

  completion_setup
  if ((!DRY_RUN)); then
    fizzy_json column list --board "$BOARD_ID" >"$COLUMNS_FILE"
  fi

  refresh_cards
  mapfile -t golden_numbers < <(json_golden_numbers "$CARDS_FILE" "$AGENT_COLUMN_ID")

  if ((${#golden_numbers[@]} > 1)); then
    die "Multiple golden-ticket cards found in '$AGENT_COLUMN': ${golden_numbers[*]}. Keep one #agent-instructions card per fizzy-popper agent column."
  fi

  if ((${#golden_numbers[@]} == 0)); then
    GOLDEN_NUMBER="$(create_card "$TITLE" "$PROMPT")"
    move_card_to_column "$GOLDEN_NUMBER" "$AGENT_COLUMN_ID"
    if ((!DRY_RUN)); then
      refresh_cards
    fi
  else
    GOLDEN_NUMBER="${golden_numbers[0]}"
  fi

  ensure_tags "$GOLDEN_NUMBER" agent-instructions "$BACKEND" "$COMPLETION_TAG"
  ensure_steps "$GOLDEN_NUMBER"

  SMOKE_NUMBER=""
  if ((SMOKE_CARD)); then
    SMOKE_NUMBER="$(create_card "$SMOKE_TITLE" "$SMOKE_DESCRIPTION")"
    move_card_to_column "$SMOKE_NUMBER" "$AGENT_COLUMN_ID"
  fi

  cat <<EOF
Fizzy Popper board bootstrap complete.
Board: ${BOARD_NAME:-$BOARD_ID} ($BOARD_ID)
Agent column: $AGENT_COLUMN ($AGENT_COLUMN_ID)
Completion: $COMPLETION_LABEL (#$COMPLETION_TAG)
Golden ticket: #$GOLDEN_NUMBER $TITLE
EOF

  if [[ -n "$SMOKE_NUMBER" ]]; then
    printf 'Smoke-test card: #%s %s - may be picked up when fizzy-popper start runs.\n' "$SMOKE_NUMBER" "$SMOKE_TITLE"
  else
    printf 'Smoke-test card: not created.\n'
  fi
  printf 'Next: run fizzy-popper start when the daemon config is ready.\n'
}

main "$@"
