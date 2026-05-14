---
name: 37signals-caching
description: >-
  Use when a Rails app needs HTTP caching, ETags, `fresh_when`, `stale?`,
  fragment caching, cache keys, Solid Cache, or performance review.
license: MIT
metadata:
  author: agent-skills
  version: "1.0"
  source: public-basecamp-style-synthesis
  compatibility: Ruby 3.3+, Rails 8.x, Solid Cache
---
## Source Grounding

Community-maintained and 37signals-inspired, not official Basecamp guidance. Read `../../references/basecamp-style.md`; target app cache store and Rails version win.

# Caching

Prefer HTTP and view caching before new infrastructure. Cache only content whose authorization, tenant scope, and invalidation path are clear.

## Workflow

1. Inspect current cache store, controller freshness checks, fragment usage, model `touch` relationships, tenancy, auth, and production config.
2. For show/index pages, consider `fresh_when` or `stale?` with tenant/account-aware cache keys.
3. For repeated partials, use Rails collection caching such as `render partial:, collection:, cached: true` when supported.
4. Tie invalidation to real record updates through timestamps, `touch: true`, or explicit cache version inputs.
5. Use Solid Cache only when Rails version, database topology, and ops model support it.
6. Verify with request tests or manual header checks plus the smallest performance check available.

## Guardrails

- Ask before changing production cache store, adding cache tables, or removing Redis/Memcached.
- Never cache personalized or tenant-scoped content without user/account in the key.
- Do not use stale APIs from examples; verify against installed Rails.
- Do not hide authorization work behind cached fragments.

## Output

Report cached surfaces, cache-key inputs, invalidation path, headers or tests verified, and unverified production assumptions.
