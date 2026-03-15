#!/usr/bin/env bash
set -euo pipefail

PROGRAM="$(basename "$0")"

BASE_URL="${FIZZY_BASE_URL:-https://fizzy.joshyorko.com}"
TOKEN="${FIZZY_TOKEN:-}"
SESSION_TOKEN="${FIZZY_SESSION_TOKEN:-}"
PENDING_AUTH_TOKEN="${FIZZY_PENDING_AUTH_TOKEN:-}"
RAW_OUTPUT="${FIZZY_RAW_OUTPUT:-0}"
VERBOSE="${FIZZY_VERBOSE:-0}"
DOTENV_FILE="${FIZZY_DOTENV_FILE:-.env}"

RESP_STATUS=""
RESP_HEADERS_FILE=""
RESP_BODY_FILE=""
LAST_URL=""
declare -a TMP_FILES=()

cleanup() {
  local file
  for file in "${TMP_FILES[@]:-}"; do
    if [[ -f "$file" ]]; then
      rm -f "$file"
    fi
  done
}
trap cleanup EXIT

usage() {
  cat <<'EOF'
Fizzy API CLI

Usage:
  fizzy.sh [global options] <command> [args]

Global options:
  --base-url URL         Override Fizzy API base URL (default: https://fizzy.joshyorko.com)
  --token TOKEN          Override FIZZY_TOKEN
  --session-token TOKEN  Override FIZZY_SESSION_TOKEN
  --pending-token TOKEN  Override FIZZY_PENDING_AUTH_TOKEN
  --raw                  Output raw response body (disable JSON pretty print)
  --verbose              Print request/response status details to stderr
  -h, --help             Show this help

Commands:
  identity
  auth request-link <email>
  auth verify-code <code> [pending_token]
  auth logout
  boards list <account_slug>
  boards get <account_slug> <board_id>
  boards create <account_slug> <name>
  cards list <account_slug> [query_string]
  cards get <account_slug> <card_number>
  comments list <account_slug> <card_number>
  call <METHOD> <PATH> [--json STRING | --json-file FILE] [--header "K: V"] [--etag VALUE]
  form <METHOD> <PATH> <field=value|field=@/path/file>... [--header "K: V"]
  paginate <PATH> [--header "K: V"] [--etag VALUE] [--max-pages N]

Examples:
  fizzy.sh identity
  fizzy.sh auth request-link person@example.com
  fizzy.sh auth verify-code ABC123
  fizzy.sh boards list 123456
  fizzy.sh cards list 123456 'board_ids[]=abc123&tag_ids[]=t1'
  fizzy.sh call POST /123456/boards --json '{"board":{"name":"Planning"}}'
  fizzy.sh form PUT /123456/users/user123 user[name]='Jane' user[avatar]=@/tmp/pic.png
  fizzy.sh paginate '/123456/cards?assignee_ids[]=user123'

Token loading order:
  1) CLI options (--token, --session-token, --pending-token)
  2) Exported environment variables (FIZZY_*)
  3) Local .env file (FIZZY_* keys only, if present)
EOF
}

die() {
  echo "error: $*" >&2
  exit 1
}

need_command() {
  local cmd="$1"
  if ! command -v "$cmd" >/dev/null 2>&1; then
    die "required command not found: $cmd"
  fi
}

dotenv_get_value() {
  local file="$1"
  local key="$2"
  local line
  local value

  [[ -f "$file" ]] || return 1

  line="$(grep -E "^[[:space:]]*(export[[:space:]]+)?${key}[[:space:]]*=" "$file" | tail -n1 || true)"
  [[ -n "$line" ]] || return 1

  value="$(printf '%s' "$line" | sed -E "s/^[[:space:]]*(export[[:space:]]+)?${key}[[:space:]]*=[[:space:]]*//")"
  value="${value%$'\r'}"

  case "$value" in
    \"*\")
      value="${value:1:${#value}-2}"
      value="${value//\\\"/\"}"
      value="${value//\\\\/\\}"
      ;;
    \'*\')
      value="${value:1:${#value}-2}"
      ;;
    *)
      value="${value%%#*}"
      value="$(printf '%s' "$value" | sed -E 's/[[:space:]]+$//')"
      ;;
  esac

  printf '%s' "$value"
}

load_dotenv_defaults() {
  local file="${1:-$DOTENV_FILE}"
  local value

  [[ -f "$file" ]] || return 0

  if [[ -z "$TOKEN" ]]; then
    value="$(dotenv_get_value "$file" "FIZZY_TOKEN" || true)"
    [[ -n "$value" ]] && TOKEN="$value"
  fi

  if [[ -z "$SESSION_TOKEN" ]]; then
    value="$(dotenv_get_value "$file" "FIZZY_SESSION_TOKEN" || true)"
    [[ -n "$value" ]] && SESSION_TOKEN="$value"
  fi

  if [[ -z "$PENDING_AUTH_TOKEN" ]]; then
    value="$(dotenv_get_value "$file" "FIZZY_PENDING_AUTH_TOKEN" || true)"
    [[ -n "$value" ]] && PENDING_AUTH_TOKEN="$value"
  fi

  if [[ -z "${FIZZY_BASE_URL:-}" ]]; then
    value="$(dotenv_get_value "$file" "FIZZY_BASE_URL" || true)"
    [[ -n "$value" ]] && BASE_URL="$value"
  fi

  return 0
}

require_auth() {
  if [[ -z "$TOKEN" && -z "$SESSION_TOKEN" ]]; then
    die "missing auth: set FIZZY_TOKEN or FIZZY_SESSION_TOKEN (export or add to .env)"
  fi
}

json_escape() {
  local value="$1"
  python3 - "$value" <<'PY'
import json
import sys
print(json.dumps(sys.argv[1]))
PY
}

normalize_slug() {
  local slug="$1"
  slug="${slug#/}"
  printf '%s' "$slug"
}

to_url() {
  local path="$1"
  if [[ "$path" =~ ^https?:// ]]; then
    printf '%s' "$path"
    return
  fi
  printf '%s/%s' "${BASE_URL%/}" "${path#/}"
}

render_body_stdout() {
  local file="$1"
  [[ -s "$file" ]] || return 0

  if [[ "$RAW_OUTPUT" -eq 1 ]]; then
    cat "$file"
    return 0
  fi

  if command -v jq >/dev/null 2>&1 && jq -e . "$file" >/dev/null 2>&1; then
    jq . "$file"
  else
    cat "$file"
  fi
}

render_body_stderr() {
  local file="$1"
  [[ -s "$file" ]] || return 0

  if command -v jq >/dev/null 2>&1 && jq -e . "$file" >/dev/null 2>&1; then
    jq . "$file" >&2
  else
    cat "$file" >&2
  fi
}

add_auth_headers() {
  local -n args_ref=$1
  local cookie_header
  local -a cookies=()

  if [[ -n "$TOKEN" ]]; then
    args_ref+=(-H "Authorization: Bearer $TOKEN")
  fi

  if [[ -n "$SESSION_TOKEN" ]]; then
    cookies+=("session_token=$SESSION_TOKEN")
  fi

  if [[ -n "$PENDING_AUTH_TOKEN" ]]; then
    cookies+=("pending_authentication_token=$PENDING_AUTH_TOKEN")
  fi

  if ((${#cookies[@]} > 0)); then
    cookie_header="$(IFS='; '; printf '%s' "${cookies[*]}")"
    args_ref+=(-H "Cookie: $cookie_header")
  fi
}

http_request() {
  local method="$1"
  local path="$2"
  local body="$3"
  local content_type="$4"
  shift 4
  local -a extra_headers=("$@")

  local url
  local headers_file
  local body_file
  local status
  local header
  local -a curl_args

  url="$(to_url "$path")"
  LAST_URL="$url"

  headers_file="$(mktemp)"
  body_file="$(mktemp)"
  TMP_FILES+=("$headers_file" "$body_file")

  curl_args=(-sS -X "$method" -H "Accept: application/json")
  add_auth_headers curl_args

  if [[ -n "$content_type" ]]; then
    curl_args+=(-H "Content-Type: $content_type")
  fi

  for header in "${extra_headers[@]}"; do
    curl_args+=(-H "$header")
  done

  if [[ -n "$body" ]]; then
    curl_args+=(-d "$body")
  fi

  if [[ "$VERBOSE" -eq 1 ]]; then
    echo ">>> $method $url" >&2
  fi

  status="$(curl "${curl_args[@]}" -D "$headers_file" -o "$body_file" "$url" -w '%{http_code}')"

  RESP_STATUS="$status"
  RESP_HEADERS_FILE="$headers_file"
  RESP_BODY_FILE="$body_file"
}

http_form_request() {
  local method="$1"
  local path="$2"
  local form_count="$3"
  shift 3
  local -a form_fields=()
  local -a extra_headers=("$@")

  local url
  local headers_file
  local body_file
  local status
  local field
  local header
  local -a curl_args

  if ((form_count > 0)); then
    form_fields=("${@:1:$form_count}")
    shift "$form_count"
    extra_headers=("$@")
  fi

  url="$(to_url "$path")"
  LAST_URL="$url"

  headers_file="$(mktemp)"
  body_file="$(mktemp)"
  TMP_FILES+=("$headers_file" "$body_file")

  curl_args=(-sS -X "$method" -H "Accept: application/json")
  add_auth_headers curl_args

  for header in "${extra_headers[@]}"; do
    curl_args+=(-H "$header")
  done

  for field in "${form_fields[@]}"; do
    curl_args+=(-F "$field")
  done

  if [[ "$VERBOSE" -eq 1 ]]; then
    echo ">>> $method $url (multipart/form-data)" >&2
  fi

  status="$(curl "${curl_args[@]}" -D "$headers_file" -o "$body_file" "$url" -w '%{http_code}')"

  RESP_STATUS="$status"
  RESP_HEADERS_FILE="$headers_file"
  RESP_BODY_FILE="$body_file"
}

handle_response() {
  if ((RESP_STATUS >= 400)); then
    echo "HTTP $RESP_STATUS for $LAST_URL" >&2
    render_body_stderr "$RESP_BODY_FILE"
    return 1
  fi

  if [[ "$VERBOSE" -eq 1 ]]; then
    echo "HTTP $RESP_STATUS for $LAST_URL" >&2
  fi

  render_body_stdout "$RESP_BODY_FILE"
}

extract_next_link() {
  local headers_file="$1"
  grep -i '^link:' "$headers_file" \
    | tr -d '\r' \
    | grep -o '<[^>]*>; rel="next"' \
    | head -n1 \
    | sed -E 's/^<([^>]*)>.*/\1/'
}

cmd_identity() {
  require_auth
  http_request "GET" "/my/identity" "" ""
  handle_response
}

cmd_auth() {
  local subcommand="${1:-}"
  local email
  local code
  local token_override
  local previous_pending
  local body
  local rc

  shift || true

  case "$subcommand" in
    request-link)
      email="${1:-}"
      [[ -n "$email" ]] || die "usage: $PROGRAM auth request-link <email>"
      body="{\"email_address\":$(json_escape "$email")}"
      http_request "POST" "/session" "$body" "application/json"
      handle_response
      ;;
    verify-code)
      code="${1:-}"
      token_override="${2:-}"
      [[ -n "$code" ]] || die "usage: $PROGRAM auth verify-code <code> [pending_token]"

      previous_pending="$PENDING_AUTH_TOKEN"
      if [[ -n "$token_override" ]]; then
        PENDING_AUTH_TOKEN="$token_override"
      fi
      [[ -n "$PENDING_AUTH_TOKEN" ]] || die "pending auth token required (set FIZZY_PENDING_AUTH_TOKEN or pass as arg)"

      body="{\"code\":$(json_escape "$code")}"
      http_request "POST" "/session/magic_link" "$body" "application/json"
      rc=0
      handle_response || rc=$?
      PENDING_AUTH_TOKEN="$previous_pending"
      return "$rc"
      ;;
    logout)
      http_request "DELETE" "/session" "" ""
      handle_response
      ;;
    *)
      die "usage: $PROGRAM auth <request-link|verify-code|logout> ..."
      ;;
  esac
}

cmd_boards() {
  local subcommand="${1:-}"
  local account_slug
  local board_id
  local board_name
  local body

  shift || true
  require_auth

  case "$subcommand" in
    list)
      account_slug="$(normalize_slug "${1:-}")"
      [[ -n "$account_slug" ]] || die "usage: $PROGRAM boards list <account_slug>"
      http_request "GET" "/$account_slug/boards" "" ""
      handle_response
      ;;
    get)
      account_slug="$(normalize_slug "${1:-}")"
      board_id="${2:-}"
      [[ -n "$account_slug" && -n "$board_id" ]] || die "usage: $PROGRAM boards get <account_slug> <board_id>"
      http_request "GET" "/$account_slug/boards/$board_id" "" ""
      handle_response
      ;;
    create)
      account_slug="$(normalize_slug "${1:-}")"
      board_name="${2:-}"
      [[ -n "$account_slug" && -n "$board_name" ]] || die "usage: $PROGRAM boards create <account_slug> <name>"
      body="{\"board\":{\"name\":$(json_escape "$board_name")}}"
      http_request "POST" "/$account_slug/boards" "$body" "application/json"
      handle_response
      ;;
    *)
      die "usage: $PROGRAM boards <list|get|create> ..."
      ;;
  esac
}

cmd_cards() {
  local subcommand="${1:-}"
  local account_slug
  local card_number
  local query_string
  local path

  shift || true
  require_auth

  case "$subcommand" in
    list)
      account_slug="$(normalize_slug "${1:-}")"
      query_string="${2:-}"
      [[ -n "$account_slug" ]] || die "usage: $PROGRAM cards list <account_slug> [query_string]"
      path="/$account_slug/cards"
      if [[ -n "$query_string" ]]; then
        path+="?$query_string"
      fi
      http_request "GET" "$path" "" ""
      handle_response
      ;;
    get)
      account_slug="$(normalize_slug "${1:-}")"
      card_number="${2:-}"
      [[ -n "$account_slug" && -n "$card_number" ]] || die "usage: $PROGRAM cards get <account_slug> <card_number>"
      http_request "GET" "/$account_slug/cards/$card_number" "" ""
      handle_response
      ;;
    *)
      die "usage: $PROGRAM cards <list|get> ..."
      ;;
  esac
}

cmd_comments() {
  local subcommand="${1:-}"
  local account_slug
  local card_number

  shift || true
  require_auth

  case "$subcommand" in
    list)
      account_slug="$(normalize_slug "${1:-}")"
      card_number="${2:-}"
      [[ -n "$account_slug" && -n "$card_number" ]] || die "usage: $PROGRAM comments list <account_slug> <card_number>"
      http_request "GET" "/$account_slug/cards/$card_number/comments" "" ""
      handle_response
      ;;
    *)
      die "usage: $PROGRAM comments list <account_slug> <card_number>"
      ;;
  esac
}

cmd_call() {
  local method="${1:-}"
  local path="${2:-}"
  local json_payload=""
  local json_file=""
  local option=""
  local -a headers=()

  shift $(( $# >= 2 ? 2 : $# ))

  [[ -n "$method" && -n "$path" ]] || die "usage: $PROGRAM call <METHOD> <PATH> [--json STRING|--json-file FILE] [--header 'K: V'] [--etag VALUE]"

  while [[ $# -gt 0 ]]; do
    option="$1"
    case "$option" in
      --json)
        [[ $# -ge 2 ]] || die "missing value for --json"
        json_payload="$2"
        shift 2
        ;;
      --json-file)
        [[ $# -ge 2 ]] || die "missing value for --json-file"
        json_file="$2"
        shift 2
        ;;
      --header)
        [[ $# -ge 2 ]] || die "missing value for --header"
        headers+=("$2")
        shift 2
        ;;
      --etag)
        [[ $# -ge 2 ]] || die "missing value for --etag"
        headers+=("If-None-Match: $2")
        shift 2
        ;;
      *)
        die "unknown option for call: $option"
        ;;
    esac
  done

  if [[ -n "$json_payload" && -n "$json_file" ]]; then
    die "use only one of --json or --json-file"
  fi

  if [[ -n "$json_file" ]]; then
    [[ -f "$json_file" ]] || die "json file not found: $json_file"
    json_payload="$(cat "$json_file")"
  fi

  method="${method^^}"
  if [[ -n "$json_payload" ]]; then
    http_request "$method" "$path" "$json_payload" "application/json" "${headers[@]}"
  else
    http_request "$method" "$path" "" "" "${headers[@]}"
  fi

  handle_response
}

cmd_form() {
  local method="${1:-}"
  local path="${2:-}"
  local option
  local -a headers=()
  local -a form_fields=()

  shift $(( $# >= 2 ? 2 : $# ))

  [[ -n "$method" && -n "$path" ]] || die "usage: $PROGRAM form <METHOD> <PATH> <field=value|field=@file>... [--header 'K: V']"

  while [[ $# -gt 0 ]]; do
    option="$1"
    case "$option" in
      --header)
        [[ $# -ge 2 ]] || die "missing value for --header"
        headers+=("$2")
        shift 2
        ;;
      *)
        form_fields+=("$1")
        shift
        ;;
    esac
  done

  if ((${#form_fields[@]} == 0)); then
    die "form requires at least one field"
  fi

  method="${method^^}"
  http_form_request "$method" "$path" "${#form_fields[@]}" "${form_fields[@]}" "${headers[@]}"
  handle_response
}

cmd_paginate() {
  local path="${1:-}"
  local max_pages=100
  local option=""
  local next_url=""
  local page=1
  local -a headers=()

  shift || true
  require_auth

  [[ -n "$path" ]] || die "usage: $PROGRAM paginate <PATH> [--header 'K: V'] [--etag VALUE] [--max-pages N]"

  while [[ $# -gt 0 ]]; do
    option="$1"
    case "$option" in
      --header)
        [[ $# -ge 2 ]] || die "missing value for --header"
        headers+=("$2")
        shift 2
        ;;
      --etag)
        [[ $# -ge 2 ]] || die "missing value for --etag"
        headers+=("If-None-Match: $2")
        shift 2
        ;;
      --max-pages)
        [[ $# -ge 2 ]] || die "missing value for --max-pages"
        max_pages="$2"
        shift 2
        ;;
      *)
        die "unknown option for paginate: $option"
        ;;
    esac
  done

  while [[ -n "$path" ]]; do
    http_request "GET" "$path" "" "" "${headers[@]}"

    if ((RESP_STATUS == 304)); then
      if [[ "$VERBOSE" -eq 1 ]]; then
        echo "HTTP 304 for $LAST_URL" >&2
      fi
      return 0
    fi

    handle_response || return 1

    next_url="$(extract_next_link "$RESP_HEADERS_FILE")"
    if [[ -z "$next_url" ]]; then
      return 0
    fi

    if ((page >= max_pages)); then
      echo "Reached --max-pages=$max_pages; stopping pagination." >&2
      return 0
    fi

    if [[ "$VERBOSE" -eq 1 ]]; then
      echo ">>> next page: $next_url" >&2
    fi

    printf '\n'
    path="$next_url"
    page=$((page + 1))
  done
}

main() {
  local cmd

  need_command curl
  need_command python3
  load_dotenv_defaults "$DOTENV_FILE"

  while [[ $# -gt 0 ]]; do
    case "$1" in
      --base-url)
        [[ $# -ge 2 ]] || die "missing value for --base-url"
        BASE_URL="$2"
        shift 2
        ;;
      --token)
        [[ $# -ge 2 ]] || die "missing value for --token"
        TOKEN="$2"
        shift 2
        ;;
      --session-token)
        [[ $# -ge 2 ]] || die "missing value for --session-token"
        SESSION_TOKEN="$2"
        shift 2
        ;;
      --pending-token)
        [[ $# -ge 2 ]] || die "missing value for --pending-token"
        PENDING_AUTH_TOKEN="$2"
        shift 2
        ;;
      --raw)
        RAW_OUTPUT=1
        shift
        ;;
      --verbose)
        VERBOSE=1
        shift
        ;;
      -h|--help)
        usage
        exit 0
        ;;
      --)
        shift
        break
        ;;
      -* )
        die "unknown global option: $1"
        ;;
      *)
        break
        ;;
    esac
  done

  cmd="${1:-help}"
  shift || true

  case "$cmd" in
    help)
      usage
      ;;
    identity)
      cmd_identity "$@"
      ;;
    auth)
      cmd_auth "$@"
      ;;
    boards)
      cmd_boards "$@"
      ;;
    cards)
      cmd_cards "$@"
      ;;
    comments)
      cmd_comments "$@"
      ;;
    call)
      cmd_call "$@"
      ;;
    form)
      cmd_form "$@"
      ;;
    paginate)
      cmd_paginate "$@"
      ;;
    *)
      die "unknown command: $cmd (run --help)"
      ;;
  esac
}

main "$@"
