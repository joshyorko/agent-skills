---
name: rails-37signals-refactor
description: Use when incrementally refactoring a Rails codebase toward 37signals-style conventions, such as moving service-object logic into models, replacing boolean state with state records, slimming controllers, shifting from Sidekiq or RSpec patterns, or tightening multi-tenant scoping without a risky rewrite.
---

# Rails 37signals Refactor

## Overview

Use this skill when the goal is not a brand-new feature, but a safer path from an existing Rails shape toward 37signals-style architecture. The emphasis is incremental change, behavior preservation, and keeping tests green between steps.

## Quick Start

1. Read the current code and identify all callers, side effects, and tests.
2. Read `references/conventions.md` for the destination architecture.
3. Read `references/refactoring-guide.md` before changing multiple files or data structures.
4. Add or strengthen characterization tests if behavior is under-specified.
5. Make one small step, run targeted tests, then continue.

## Non-Negotiables

- Do not do a big-bang rewrite.
- Prefer one responsibility shift at a time.
- Keep old and new paths working together during transitions when risk is non-trivial.
- Use feature flags or staged migrations for sensitive auth, API, or data changes.
- Remove old code only after the replacement is proven.

## Default Refactoring Targets

- Service objects to model methods or concerns.
- Boolean state columns to explicit state records.
- Fat controllers to CRUD resources plus model methods.
- RSpec or FactoryBot-heavy tests toward Minitest plus fixtures when the repo is already moving there.
- Sidekiq or Redis-specific background work toward Rails-native queueing patterns.
- Missing tenant scoping toward explicit `Current.account` access.

## Workflow

### 1. Lock down behavior

- Find the public behavior first.
- Add tests before moving code if coverage is weak.

### 2. Choose the smallest viable step

- Move one method, one action, or one state representation at a time.
- Prefer parallel-safe migrations: add, backfill, switch reads and writes, then remove.

### 3. Verify after every step

- Run the narrowest relevant tests after each meaningful change.
- Watch for scope leaks, renamed interfaces, and stale fixtures.

## Load These References When Needed

- `references/conventions.md`: baseline architecture and style defaults.
- `references/refactoring-guide.md`: common migration patterns and safety rails.
