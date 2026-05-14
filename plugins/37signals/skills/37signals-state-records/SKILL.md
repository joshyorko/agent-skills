---
name: 37signals-state-records
description: >-
  Use when modeling lifecycle state, replacing boolean flags, adding audit-friendly
  state records, or reviewing archive/publish/close/approve flows.
license: MIT
metadata:
  author: agent-skills
  version: "1.0"
  source: public-basecamp-style-synthesis
  compatibility: Ruby 3.3+, Rails 8.x
---
## Source Grounding

Community-maintained and 37signals-inspired, not official Basecamp guidance. Read `../../references/basecamp-style.md`; target domain language wins.

# State Records

Use records when state has lifecycle, actor, timestamp, reason, permissions, audit value, or associated behavior. Keep booleans for cheap toggles with no domain history.

## Workflow

1. Inspect current columns, state transitions, callers, routes, permissions, history needs, and tests.
2. Name the state as a noun: `Archival`, `Publication`, `Closure`, `Approval`.
3. Model associations from subject to state record. Decide whether the state is singular, repeatable, reversible, or historical.
4. Expose model APIs such as `archive(actor:)`, `unarchive`, `published?`, not controller-side flag flips.
5. Pair with CRUD resource controllers when user actions create/destroy/update the state record.
6. Test transition rules, actor/account scoping, timestamps, reversals, and existing query behavior.

## Guardrails

- Ask before data migration from existing booleans/timestamps.
- Do not create state records for trivial feature flags.
- Do not lose existing historical meaning during backfill.
- Do not put transition authorization only in the controller.

## Output

State why record beats boolean, record shape, transition API, migration path, tests run, and backfill/deploy risk.
