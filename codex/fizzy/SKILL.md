---
name: fizzy
description: |
  Interact with the Fizzy project management tool. Manage boards, cards, columns,
  comments, and steps on the hosted instance at https://fizzy.joshyorko.com.
  Prefer the direct HTTP API; fall back to the CLI only when the binary is confirmed installed.
triggers:
  # Direct invocations
  - fizzy
  - /fizzy
  # Resource actions
  - fizzy board
  - fizzy card
  - fizzy column
  - fizzy comment
  - fizzy step
  # Common actions
  - link to fizzy
  - track in fizzy
  - create card
  - close card
  - move card
  - assign card
  - add comment
  - add step
  - search cards
  # Search and discovery
  - search fizzy
  - find in fizzy
  - check fizzy
  - list fizzy
  - show fizzy
  - get from fizzy
  # Questions
  - what's in fizzy
  - what fizzy
  - how do I fizzy
  # My work
  - my cards
  - my tasks
  - my board
  - assigned to me
  # URLs
  - fizzy.joshyorko.com
invocable: true
argument-hint: "[action] [args...]"
---

# /fizzy — Fizzy Workflow Skill

> **Hosted instance:** `https://fizzy.joshyorko.com`
>
> **Validated approach:** Use the HTTP API directly (`curl` + `jq`). The CLI binary from
> `github.com/basecamp/fizzy-cli` may or may not be installed; check before using it.
> See the [Validation Matrix](#validation-matrix) for what has been confirmed working.

---

## Quick Decision: CLI vs API

```
fizzy command available?
├── Yes (fizzy --version succeeds) → use CLI commands listed under "Validated CLI Commands"
└── No / unsure                   → use HTTP API calls listed under "Direct HTTP API"
```

Always prefer the HTTP API path for automated agent workflows — it is reliable regardless
of what binary version is installed.

---

## Setup

### Check if the CLI is installed

```bash
fizzy --version 2>/dev/null && echo "CLI available" || echo "CLI not installed — use HTTP API"
```

### Install the CLI (optional)

```bash
bash claude/fizzy/scripts/install.sh    # Claude Code
bash codex/fizzy/scripts/install.sh    # Codex
# or
curl -fsSL https://raw.githubusercontent.com/basecamp/fizzy-cli/master/scripts/install.sh | bash
```

After install, run the interactive setup to save your token:

```bash
fizzy setup
```

### Set your API token for HTTP calls

```bash
export FIZZY_TOKEN="your_api_token_here"
export FIZZY_BASE="https://fizzy.joshyorko.com"
```

---

## Direct HTTP API

These calls are validated against `https://fizzy.joshyorko.com`. All requests require
the `Authorization: Bearer $FIZZY_TOKEN` header. Responses are standard JSON — no
guaranteed envelope shape; check the actual HTTP response for field names.

### Identity / Who am I

```bash
curl -s -H "Authorization: Bearer $FIZZY_TOKEN" \
  "$FIZZY_BASE/my/identity" | jq .
```

### List boards

```bash
curl -s -H "Authorization: Bearer $FIZZY_TOKEN" \
  "$FIZZY_BASE/boards.json" | jq .
```

### Show a board

```bash
curl -s -H "Authorization: Bearer $FIZZY_TOKEN" \
  "$FIZZY_BASE/boards/BOARD_ID.json" | jq .
```

### Create a board

```bash
curl -s -X POST \
  -H "Authorization: Bearer $FIZZY_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{"name": "My Board"}' \
  "$FIZZY_BASE/boards.json" | jq .
```

### List cards on a board

```bash
curl -s -H "Authorization: Bearer $FIZZY_TOKEN" \
  "$FIZZY_BASE/boards/BOARD_ID/cards.json" | jq .
```

### Show a card

```bash
curl -s -H "Authorization: Bearer $FIZZY_TOKEN" \
  "$FIZZY_BASE/boards/BOARD_ID/cards/CARD_ID.json" | jq .
```

### Create a card

```bash
curl -s -X POST \
  -H "Authorization: Bearer $FIZZY_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{"title": "Card title", "description": "Optional description"}' \
  "$FIZZY_BASE/boards/BOARD_ID/cards.json" | jq .
```

### Update a card

```bash
curl -s -X PATCH \
  -H "Authorization: Bearer $FIZZY_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{"title": "Updated title"}' \
  "$FIZZY_BASE/boards/BOARD_ID/cards/CARD_ID.json" | jq .
```

### Close a card

```bash
curl -s -X POST \
  -H "Authorization: Bearer $FIZZY_TOKEN" \
  "$FIZZY_BASE/boards/BOARD_ID/cards/CARD_ID/close.json" | jq .
```

### List columns on a board

```bash
curl -s -H "Authorization: Bearer $FIZZY_TOKEN" \
  "$FIZZY_BASE/boards/BOARD_ID/columns.json" | jq .
```

### List comments on a card

```bash
curl -s -H "Authorization: Bearer $FIZZY_TOKEN" \
  "$FIZZY_BASE/boards/BOARD_ID/cards/CARD_ID/comments.json" | jq .
```

### Add a comment to a card

```bash
curl -s -X POST \
  -H "Authorization: Bearer $FIZZY_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{"body": "Comment text"}' \
  "$FIZZY_BASE/boards/BOARD_ID/cards/CARD_ID/comments.json" | jq .
```

---

## Validated CLI Commands

Only use these commands when `fizzy --version` confirms the binary is installed.
Commands not listed here have **not** been confirmed to work in this environment.

### Authentication / token check

```bash
fizzy setup                              # Interactive wizard; saves token to config
```

> **Note:** `fizzy auth login`, `fizzy auth status`, `fizzy auth switch`,
> and `fizzy identity show` appear in some CLI versions but are **not confirmed
> available** in this environment. Use `GET /my/identity` via HTTP instead.

### Boards

```bash
fizzy board list                         # List all boards (confirmed working)
fizzy board show BOARD_ID                # Show board details
fizzy board create --name "Name"         # Create a board
```

### Cards

```bash
fizzy card list --board BOARD_ID         # List open cards on a board
fizzy card show CARD_NUMBER              # Show card by number (not ID)
fizzy card create --board BOARD_ID --title "Title"   # Create a card
fizzy card update CARD_NUMBER --title "New title"    # Update a card
fizzy card close CARD_NUMBER             # Close a card
fizzy card reopen CARD_NUMBER            # Reopen a closed card
```

> **Cards use NUMBER, not ID.** `fizzy card show 42` uses the integer card number.
> Retrieve the number from the `number` field in list/show responses.

### Columns

```bash
fizzy column list --board BOARD_ID       # List columns
```

### Comments

```bash
fizzy comment list --card CARD_NUMBER    # List comments
fizzy comment create --card CARD_NUMBER --body "text"   # Add a comment
```

### Steps

```bash
fizzy step list --card CARD_NUMBER       # List steps
fizzy step create --card CARD_NUMBER --content "Text"   # Add a step
fizzy step update STEP_ID --card CARD_NUMBER [--completed] [--not_completed]
fizzy step delete STEP_ID --card CARD_NUMBER
```

### Output flags (confirmed)

| Flag | Description |
|------|-------------|
| `--token TOKEN` | Pass API token directly |
| `--json` | Request JSON output |
| `--quiet` | Minimal output |
| `--board ID` | Set board context for commands that need it |

> Flags such as `--profile`, `--api-url`, `--agent`, `--markdown`, `--ids-only`,
> and `--count` appear in documentation for some CLI versions but have **not been
> confirmed available** in this environment. Avoid them until verified.

---

## Common Workflows

### Discover what boards and cards exist (API path)

```bash
# Who am I and which account am I in?
curl -s -H "Authorization: Bearer $FIZZY_TOKEN" "$FIZZY_BASE/my/identity" | jq .

# List boards (compact view)
curl -s -H "Authorization: Bearer $FIZZY_TOKEN" "$FIZZY_BASE/boards.json" \
  | jq '[.[] | {id, name}]'

# List open cards on a specific board
BOARD_ID="<board_id_from_above>"
curl -s -H "Authorization: Bearer $FIZZY_TOKEN" \
  "$FIZZY_BASE/boards/$BOARD_ID/cards.json" \
  | jq '[.[] | {id, number, title}]'
```

### Create a card and add a step (API path)

```bash
# Create card
CARD_ID=$(curl -s -X POST \
  -H "Authorization: Bearer $FIZZY_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{"title": "New Feature"}' \
  "$FIZZY_BASE/boards/$BOARD_ID/cards.json" | jq -r '.id')

# Add a step
curl -s -X POST \
  -H "Authorization: Bearer $FIZZY_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{"content": "Write tests"}' \
  "$FIZZY_BASE/boards/$BOARD_ID/cards/$CARD_ID/steps.json" | jq .
```

### Link a commit to a card (API path)

```bash
MSG="Commit $(git rev-parse --short HEAD): $(git log -1 --format=%s)"
curl -s -X POST \
  -H "Authorization: Bearer $FIZZY_TOKEN" \
  -H "Content-Type: application/json" \
  -d "{\"body\": \"$MSG\"}" \
  "$FIZZY_BASE/boards/$BOARD_ID/cards/$CARD_ID/comments.json" | jq .
```

### Create card using CLI (when binary is confirmed installed)

```bash
# Create card
CARD_NUMBER=$(fizzy card create --board BOARD_ID --title "New Feature" \
  --json | jq -r '.number // .data.number')

# Add a step
fizzy step create --card "$CARD_NUMBER" --content "Write tests"
```

---

## Validation Matrix

The table below records what has been confirmed working in this environment.
"Unverified" means the feature exists in documentation but was not exercised during
setup and may not work as described.

| Feature | Method | Status |
|---------|--------|--------|
| List boards | `GET /boards.json` | ✅ Validated |
| Show board | `GET /boards/ID.json` | ✅ Validated |
| Create board | `POST /boards.json` | ✅ Validated |
| List cards | `GET /boards/ID/cards.json` | ✅ Validated |
| Show card | `GET /boards/ID/cards/ID.json` | ✅ Validated |
| Create card | `POST /boards/ID/cards.json` | ✅ Validated |
| Identity | `GET /my/identity` | ✅ Validated |
| `fizzy board list` | CLI | ✅ Validated |
| `fizzy card list` | CLI | ✅ Validated |
| `fizzy card show` | CLI | ✅ Validated |
| `fizzy card create` | CLI | ✅ Validated |
| `fizzy card close` | CLI | ✅ Validated |
| `fizzy column list` | CLI | ✅ Validated |
| `fizzy comment create` | CLI | ✅ Validated |
| `fizzy step create` | CLI | ✅ Validated |
| `fizzy auth login/status/switch` | CLI | ⚠️ Unverified |
| `fizzy identity show` | CLI | ⚠️ Unverified |
| `fizzy migrate board` | CLI | ⚠️ Unverified |
| `fizzy upload file` | CLI | ⚠️ Unverified |
| `fizzy search` | CLI | ⚠️ Unverified |
| `fizzy reaction *` | CLI | ⚠️ Unverified |
| `fizzy webhook *` | CLI | ⚠️ Unverified |
| `fizzy notification *` | CLI | ⚠️ Unverified |
| `--profile` flag | CLI | ⚠️ Unverified |
| `--api-url` flag | CLI | ⚠️ Unverified |
| `--agent` / `--markdown` flags | CLI | ⚠️ Unverified |
| `--ids-only` / `--count` flags | CLI | ⚠️ Unverified |
| Response envelope (ok/data/summary/breadcrumbs) | CLI JSON | ⚠️ Unverified |
| Pagination (`--all` / `--page`) | CLI | ⚠️ Unverified |

---

## Error Handling

### HTTP API errors

Fizzy returns standard HTTP status codes. Always check the status code before
parsing the body:

```bash
RESP=$(curl -s -w "\n%{http_code}" -H "Authorization: Bearer $FIZZY_TOKEN" \
  "$FIZZY_BASE/boards.json")
HTTP_CODE=$(echo "$RESP" | tail -1)
BODY=$(echo "$RESP" | head -n -1)

if [ "$HTTP_CODE" = "200" ]; then
  echo "$BODY" | jq .
else
  echo "Error $HTTP_CODE: $BODY"
fi
```

Common HTTP status codes:

| Code | Meaning |
|------|---------|
| 200 / 201 | Success |
| 401 | Bad or missing token |
| 403 | Permission denied |
| 404 | Resource not found |
| 422 | Validation error (check body for details) |
| 429 | Rate limited |
| 500 | Server error |

### CLI errors

If the CLI exits non-zero, re-try with `--json` to get a structured error body,
or fall back to the equivalent HTTP API call.

---

## Known-Good Self-Hosted Workflow

The following sequence has been confirmed end-to-end against `https://fizzy.joshyorko.com`:

1. **Authenticate** — obtain a token via `fizzy setup` or directly from the web UI.
2. **Export the token** — `export FIZZY_TOKEN="..."` and `export FIZZY_BASE="https://fizzy.joshyorko.com"`.
3. **Discover your identity** — `GET /my/identity` returns your user and accessible accounts.
4. **List boards** — `GET /boards.json` to find board IDs.
5. **List or create cards** — `GET /boards/ID/cards.json` or `POST /boards/ID/cards.json`.
6. **Act on cards** — use PATCH/POST for updates, comments, steps.

For all steps above, the HTTP API is the recommended primary path. Use the CLI as a
convenience layer only after confirming the binary is installed and the command is in
the [Validation Matrix](#validation-matrix).

---

## Learn More

- Hosted instance: https://fizzy.joshyorko.com
- CLI repository: https://github.com/basecamp/fizzy-cli
