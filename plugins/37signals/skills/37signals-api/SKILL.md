---
name: 37signals-api
description: >-
  Use when a Rails app needs JSON responses, Jbuilder views, API tokens,
  machine-client endpoints, REST payloads, or same-controller multi-format output.
license: MIT
metadata:
  author: agent-skills
  version: "1.0"
  source: public-basecamp-style-synthesis
  compatibility: Ruby 3.3+, Rails 8.x, Jbuilder
---
## Source Grounding

Community-maintained and 37signals-inspired, not official Basecamp guidance. Read `../../references/basecamp-style.md`; target app conventions and installed versions win.

# API

Prefer extending existing resource controllers with explicit JSON formats when that fits. Add a parallel API namespace only when versioning, auth boundary, or client contract needs it.

## Workflow

1. Inspect routes, controller format handling, auth layer, serializers/Jbuilder usage, pagination, and existing API tests.
2. Choose controller shape: existing resource with `respond_to`, or explicit namespace when the contract demands it.
3. Render JSON in `*.json.jbuilder` templates or existing app serializer style. Do not invent a new payload layer just for one endpoint.
4. Keep endpoints resource-oriented. Use nested resources for ownership; avoid custom verbs unless the external contract requires them.
5. Add scoped auth. Browser sessions for browser JSON; digest-backed API tokens with expiry/scope/rate limits for machine access.
6. Verify tenant/account scoping, preloads, error status codes, and request tests.

## Guardrails

- Ask before introducing OAuth, GraphQL, serializer gems, versioned API namespaces, or long-lived machine credentials.
- Never store raw API tokens.
- Do not reuse browser session tokens as bearer API tokens.
- Do not expose cross-account records through JSON includes or unscoped lookups.

## Output

Report controller shape, payload files, auth model, scoped queries, tests run, and unverified client compatibility.
