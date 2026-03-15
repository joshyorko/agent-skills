# Fizzy API Quick Reference

## Authentication Modes

- Personal access token:
`Authorization: Bearer <token>`
- Magic link flow:
1. `POST /session` with `{ "email_address": "..." }`
2. `POST /session/magic_link` with `{ "code": "ABC123" }` and `pending_authentication_token` cookie
3. Use returned `session_token` cookie for authenticated requests
4. `DELETE /session` to log out

## Script Environment Variables

- `FIZZY_BASE_URL` (default: `https://fizzy.joshyorko.com`)
- `FIZZY_TOKEN`
- `FIZZY_SESSION_TOKEN`
- `FIZZY_PENDING_AUTH_TOKEN`
- `FIZZY_VERBOSE=1` for request diagnostics
- `FIZZY_RAW_OUTPUT=1` to disable JSON pretty printing

If exported variables are missing, `scripts/fizzy.sh` will read the same `FIZZY_*` keys from a local `.env` file in the current working directory.

## Core Endpoint Groups

- Identity: `GET /my/identity`
- Boards: `GET/POST /:account_slug/boards`, `GET/PUT/DELETE /:account_slug/boards/:board_id`
- Cards: list/get/create/update/delete + card state actions under `/:account_slug/cards/:card_number/...`
- Comments: list/get/create/update/delete under `/:account_slug/cards/:card_number/comments`
- Tags, users, columns, notifications: account-scoped endpoints under `/:account_slug/...`

## Request Patterns

### JSON request

```bash
scripts/fizzy.sh call POST /123456/boards --json '{"board":{"name":"Roadmap"}}'
```

### Multipart upload

```bash
scripts/fizzy.sh form PUT /123456/users/abc123 \
  user[name]='Jane Doe' \
  user[avatar]=@/tmp/avatar.png
```

### Pagination

```bash
scripts/fizzy.sh paginate '/123456/cards?assignee_ids[]=u1'
```

The script follows `Link` headers containing `rel="next"` until exhausted or `--max-pages` is reached.

### ETag revalidation

```bash
scripts/fizzy.sh call GET /123456/cards/42 --etag '"abc123"'
```

A `304 Not Modified` means no new payload.

### Markdown comment create/update

```bash
COMMENT_MD="$(cat <<'MD'
## Progress Update

### Changes
- Item one
- Item two

### Validation
- Added/ran relevant checks
MD
)"
jq -n --arg body "$COMMENT_MD" '{comment:{body:$body}}' >/tmp/comment.json
scripts/fizzy.sh call POST /123456/cards/42/comments --json-file /tmp/comment.json
scripts/fizzy.sh call PUT /123456/cards/42/comments/987 --json-file /tmp/comment.json
```

### Markdown card description update

```bash
CARD_MD="$(cat <<'MD'
## Summary

### Fix Applied
- Change details

### Verification
- Validation details
MD
)"
jq -n --arg description "$CARD_MD" '{card:{description:$description}}' >/tmp/card-update.json
scripts/fizzy.sh call PUT /123456/cards/42 --json-file /tmp/card-update.json
```

`jq --arg` safely escapes newlines and quotes so Fizzy receives valid JSON while preserving markdown formatting.

## Notes

- List parameters repeat the same key and end with `[]`, e.g. `tag_ids[]=a&tag_ids[]=b`.
- Prefer markdown sections and bullet lists for human-facing card/comment content; avoid single-line paragraph dumps.
- Validation errors often return `422`; malformed or unexpected data can return `500`.
- Some rich text/file features use ActiveStorage direct upload flows.
