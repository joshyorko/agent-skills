---
name: 37signals-auth
description: >-
  Use when a Rails app needs passwordless login, session records, magic links,
  password reset flow, auth review, or token/session hardening.
license: MIT
metadata:
  author: agent-skills
  version: "1.0"
  source: public-basecamp-style-synthesis
  compatibility: Ruby 3.3+, Rails 8.x
---
## Source Grounding

Community-maintained and 37signals-inspired, not official Basecamp guidance. Read `../../references/basecamp-style.md`; target app conventions and security requirements win.

# Auth

Keep auth small, boring, and secure. Favor Rails-native records and signed cookies, but preserve Devise or another existing auth stack unless the user asks to migrate.

## Workflow

1. Inspect current auth, session storage, password reset/magic link code, account scoping, rate limits, mailers, and tests.
2. Identify the flow: browser session, passwordless login, password reset, API token, or admin impersonation.
3. Store only digests for session and magic-link tokens. Raw tokens may exist only in cookies, generated URLs, or transient local variables.
4. Make token APIs explicit, such as `Session.authenticate(raw_token)` and `MagicLink.authenticate(raw_token)`.
5. Prevent account/email enumeration: success response copy should not reveal whether an account exists.
6. Add expiry, single-use semantics where appropriate, rotation, auditability, and rate limits.
7. Test happy path, expiry, replay, bad token, cross-account access, and logout.

## Guardrails

- Ask before replacing Devise, changing production session schema, or invalidating all users.
- Never store raw `token`, `code`, or magic-link secrets in the database.
- Never use browser session tokens as API bearer tokens.
- Do not log raw auth tokens or include them in fixtures.

## Output

State the auth surface changed, token storage model, enumeration behavior, tests run, and any production rollout risk.
