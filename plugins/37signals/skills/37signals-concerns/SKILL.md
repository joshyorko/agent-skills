---
name: 37signals-concerns
description: >-
  Use when shared Rails model or controller behavior needs a focused concern,
  mixin cleanup, or review of concern boundaries.
license: MIT
metadata:
  author: agent-skills
  version: "1.0"
  source: public-basecamp-style-synthesis
  compatibility: Ruby 3.3+, Rails 8.x
---
## Source Grounding

Community-maintained and 37signals-inspired, not official Basecamp guidance. Read `../../references/basecamp-style.md`; target app style wins.

# Concerns

Use concerns for cohesive roles or traits. Do not use them as junk drawers for unrelated model code.

## Workflow

1. Inspect duplicated behavior, caller count, model roles, tests, and naming already used in `app/models/concerns` or `app/controllers/concerns`.
2. Name the behavior as a domain trait: `Archivable`, `Billable`, `AccountScoped`, not `Helpers`.
3. Keep the concern narrow: associations, scopes, callbacks, and methods should all serve one concept.
4. Prefer model-specific private methods when extraction would make behavior harder to read.
5. Add or update tests through the consuming models/controllers, not just a module unit test.

## Guardrails

- Ask before moving large business workflows into concerns.
- Avoid global callbacks that surprise every includer.
- Do not hide tenant scoping or authorization in a concern without tests at every entrypoint.
- Do not create concerns to avoid choosing the right model.

## Output

State the extracted behavior, includers, tests run, and any caller still needing cleanup.
