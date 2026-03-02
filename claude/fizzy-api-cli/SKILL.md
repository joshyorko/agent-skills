---
name: fizzy-api-cli
description: Automate Fizzy API operations with a bundled Bash CLI and focused endpoint references. Use when Codex needs to authenticate with Fizzy (personal token or magic link), call or script Fizzy REST endpoints, handle pagination or ETag caching, upload files via multipart requests, or replace ad-hoc curl snippets with repeatable commands.
---

# Fizzy API CLI

Use this skill to execute Fizzy API workflows through `scripts/fizzy.sh` instead of rewriting curl commands.

## Quick Start

1. Provide credentials either via exported env var or local `.env`.

```bash
# Option A: export
export FIZZY_TOKEN="<personal-access-token>"

# Option B: .env in current directory
# FIZZY_TOKEN=<personal-access-token>

# Optional session-based auth:
# export FIZZY_SESSION_TOKEN="<session-token>"
# export FIZZY_PENDING_AUTH_TOKEN="<pending-auth-token>"
```

2. Run common commands.

```bash
scripts/fizzy.sh identity
scripts/fizzy.sh boards list 123456
scripts/fizzy.sh cards list 123456 'board_ids[]=abc123'
```

## Workflow

1. Choose auth mode.
`FIZZY_TOKEN` for service-style scripts. Use `auth request-link` + `auth verify-code` for magic-link session auth. If `FIZZY_TOKEN` is not exported, the script auto-loads `FIZZY_*` values from `.env`.

2. Prefer task commands first.
Use `identity`, `boards`, `cards`, and `comments` subcommands when they fit.

3. Use generic commands for uncovered endpoints.
Use `call` for JSON endpoints, `form` for multipart, and `paginate` for `Link: rel="next"` traversal.

4. Keep outputs machine-friendly.
Pipe to `jq` when you need transforms. Use `--raw` when you need unformatted response bodies.

## Command Surface

- `identity`: `GET /my/identity`
- `auth request-link <email>`: `POST /session`
- `auth verify-code <code> [pending_token]`: `POST /session/magic_link`
- `auth logout`: `DELETE /session`
- `boards list|get|create ...`
- `cards list|get ...`
- `comments list ...`
- `call METHOD PATH [--json ...|--json-file ...] [--header ...] [--etag ...]`
- `form METHOD PATH field=value field=@/path/file [--header ...]`
- `paginate PATH [--header ...] [--etag ...] [--max-pages N]`

## Resource Use

- Read `references/api-quick-reference.md` for endpoint patterns, auth notes, and command recipes.
- Use `scripts/fizzy.sh --help` for canonical syntax and examples.

## Guardrails

- Treat access tokens and session tokens as secrets.
- Use `--verbose` to inspect HTTP status and page traversal when debugging.
- Pass account slugs without leading `/` when possible; the script normalizes either form.
