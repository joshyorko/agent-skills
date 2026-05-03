---
name: 37signals-refactoring
description: >-
  Use when explicitly delegated by a Rails 37signals workflow to coordinate
  multiple specialist pattern skills during an incremental refactor.
license: MIT
metadata:
  author: agent-skills
  version: "1.0"
  source: public-basecamp-style-synthesis
  compatibility: Ruby 3.3+, Rails 8.x
---
## Source Grounding

This skill is community-maintained and 37signals-inspired. It is not an official Basecamp style guide. Read `../../references/basecamp-style.md` first; target repo conventions and installed versions win when they conflict.

# Refactoring Orchestrator

Use this skill to drive incremental Rails refactors toward 37signals-inspired patterns when the user wants that direction. It should diagnose the current shape, choose a low-risk sequence, and hand each refactor step to the right specialist skill.

## Default Workflow

1. Inspect the current design and identify the dominant anti-patterns.
   - service objects swallowing domain logic
   - boolean state instead of record-based state
   - fat controllers
   - React or custom AJAX where Turbo fits
   - RSpec and factories where Minitest and fixtures are preferred
   - Redis-era infrastructure that Rails now replaces directly
   - drift between shared-database and separate-database tenancy patterns
   - deploy configuration that no longer matches the app runtime
2. Choose an incremental migration path.
3. Protect behavior with tests before large moves.
4. Refactor one concern at a time.
5. Re-run tests and verify that architecture actually improved.

## Delegation Guide

- `$37signals-model` when business logic belongs in models.
- `$37signals-concerns` when behavior should be extracted horizontally.
- `$37signals-state-records` when state history matters.
- `$37signals-crud` when custom controller verbs should become resources.
- `$37signals-turbo` and `$37signals-stimulus` when simplifying frontend complexity.
- `$37signals-test` for migration-safe coverage.
- `$37signals-caching`, `$37signals-jobs`, `$37signals-events`, and `$37signals-mailer` for infrastructure cleanup.
- `$37signals-active-record-tenanted` or `$37signals-multi-tenant` for tenancy cleanup.
- `$37signals-kamal` when runtime roles, secrets, or deploy config need to change with the refactor.

## Refactoring Rules

- Prefer safe sequences over rewrites.
- Keep compatibility while migrating unless the task explicitly allows breakage.
- Let tests define the safe boundary for each step.
- Make data migrations explicit and reversible where practical.
- Reduce moving parts rather than reshuffling them.

## High-Value Targets

- Move service object logic back into domain models.
- Convert booleans and timestamps into state records.
- Replace custom AJAX flows with Turbo-first interactions.
- Collapse unnecessary API/framework complexity into normal Rails controllers and views.
- Remove infrastructure carried forward from older Rails assumptions when Rails now has a simpler built-in answer.
- Untangle mixed tenancy patterns so the code stops switching between `Current.account` and `with_tenant`.

## Boundaries

### Prefer

- Refactor incrementally.
- Explain the migration sequence.
- Protect behavior with tests or explicit verification.

### Ask First

- Full rewrites.
- Breaking API or schema changes.
- Migrations that may require downtime or feature flags.

### Avoid

- Recommend a rewrite just because the current code is messy.
- Mix unrelated refactors into one risky change set.

## Reference

- Shared source-grounding and boundaries live in `../../references/basecamp-style.md`.
