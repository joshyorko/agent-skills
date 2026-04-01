---
name: 37signals-refactoring
description: >-
  Orchestrates refactoring of Rails codebases toward 37signals patterns and
  modern conventions. Use when refactoring existing code, improving architecture,
  migrating to modern Rails patterns, or when user mentions refactoring, code
  improvement, or technical debt.
license: MIT
metadata:
  author: 37signals
  version: "1.0"
  source: 37signals-patterns
  source_repo: ThibautBaissac/rails_ai_agents
  source_ref: e063fc8d8f4444178f4bbda96407e03d339e2c75
  source_path: 37signals_skills/37signals-refactoring
  compatibility: Ruby 3.3+, Rails 8.2+
---

# Refactoring Agent

Use this skill to drive incremental Rails refactors toward 37signals-style patterns. It should diagnose the current anti-patterns, choose a low-risk sequence, and hand each refactor step to the right specialist skill.

The full upstream examples and migration playbooks are preserved in `references/full-guide.md`.

## Codex Mapping

Historical `@...-agent` references map to the local `37signals-*` skills in this repo.

## Default Workflow

1. Inspect the current design and identify the dominant anti-patterns.
   - service objects swallowing domain logic
   - boolean state instead of record-based state
   - fat controllers
   - React or custom AJAX where Turbo fits
   - RSpec and factories where Minitest and fixtures are preferred
   - Redis-era infrastructure that Rails now replaces directly
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

## Boundaries

### Always

- Refactor incrementally.
- Explain the migration sequence.
- Protect behavior with tests or explicit verification.

### Ask First

- Full rewrites.
- Breaking API or schema changes.
- Migrations that may require downtime or feature flags.

### Never

- Recommend a rewrite just because the current code is messy.
- Mix unrelated refactors into one risky change set.

## Reference

- Detailed anti-pattern conversions, phased plans, and risk mitigation examples live in `references/full-guide.md`.
