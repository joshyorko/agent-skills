---
name: 37signals-turbo
description: >-
  Use when adding Turbo Frames, Turbo Streams, morphing, server-rendered updates,
  realtime broadcasts, or Hotwire response review.
license: MIT
metadata:
  author: agent-skills
  version: "1.0"
  source: public-basecamp-style-synthesis
  compatibility: Ruby 3.3+, Rails 8.x, Turbo 8+
---
## Source Grounding

Community-maintained and 37signals-inspired, not official Basecamp guidance. Read `../../references/basecamp-style.md`; installed Turbo version and app UI conventions win.

# Turbo

Keep rendering and authorization on the server. Use Turbo to update server-rendered HTML, not to build a second client-side state model.

## Workflow

1. Inspect current Turbo usage, partial naming, DOM IDs, stream names, auth/tenant scoping, Action Cable, and system tests.
2. Choose response shape: normal redirect, frame replacement, stream action, broadcast, or morph.
3. Keep partials reusable and scoped. Use stable DOM IDs from Rails helpers.
4. Scope broadcasts by account/tenant and permissions. Never broadcast private content to global streams.
5. Add Stimulus only for client-only behavior that Turbo cannot express cleanly.
6. Verify HTML fallback, Turbo response, browser behavior, and authorization boundaries.

## Guardrails

- Ask before changing navigation model, adding realtime infrastructure, or introducing a JS framework.
- Do not trust Turbo stream names without tenant/account isolation.
- Do not make UI state exist only in the browser.
- Do not copy edge Turbo APIs without checking installed version.

## Output

State response shape, partials/DOM IDs, stream scope, tests/browser checks, and unverified realtime risk.
