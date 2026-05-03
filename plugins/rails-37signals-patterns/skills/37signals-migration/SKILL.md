---
name: 37signals-migration
description: >-
  Use when creating or reviewing Rails migrations, schema changes, tenant keys,
  primary keys, constraints, indexes, backfills, or data migration safety.
license: MIT
metadata:
  author: agent-skills
  version: "1.0"
  source: public-basecamp-style-synthesis
  compatibility: Ruby 3.3+, Rails 8.x, MySQL/SQLite
---
## Source Grounding

Community-maintained and 37signals-inspired, not official Basecamp guidance. Read `../../references/basecamp-style.md`; target database and schema policy win.

# Migration

Design schema changes around the app's actual database, primary-key policy, tenancy model, and deploy constraints. There is no universal 37signals rule requiring UUID primary keys or forbidding foreign keys.

## Workflow

1. Inspect existing migrations, schema format, database adapter, primary keys, foreign-key policy, tenant/account keys, indexes, and deploy process.
2. Classify change: new table, safe column add, index, constraint, backfill, rename, destructive change, tenant migration.
3. Make changes reversible when practical. Split risky changes into add/backfill/switch/remove.
4. Add tenant/account keys only for records that are tenant-owned in this app's chosen tenancy model.
5. Add indexes for common lookup, uniqueness, and tenant-scoped access paths.
6. Verify with migration rollback where safe, schema diff, model tests, and query paths affected.

## Guardrails

- Ask before destructive migrations, large backfills, lock-heavy indexes, PK changes, tenant data moves, or constraint policy changes.
- Do not remove foreign keys because a style guide says so.
- Do not add tenant keys to global tables by reflex.
- Do not assume MySQL, PostgreSQL, or SQLite behavior without checking adapter.

## Output

State adapter, schema policy followed, migration sequence, rollback/backfill story, tests run, and deploy/lock risk.
