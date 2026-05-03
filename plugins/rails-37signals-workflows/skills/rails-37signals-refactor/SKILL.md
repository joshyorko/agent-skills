---
name: rails-37signals-refactor
description: Use when incrementally refactoring Rails code toward 37signals-inspired conventions without a risky rewrite.
license: MIT
metadata:
  author: agent-skills
  version: "1.0"
  source: public-basecamp-style-synthesis
---
## Source Grounding

This workflow is community-maintained and 37signals-inspired. It is not an official Basecamp style guide. Read `../../references/basecamp-style.md` first; target repo conventions and user intent win when they conflict.

# Rails 37signals Refactor

## Overview

Use this skill when the goal is not a brand-new feature, but a safer path from an existing Rails shape toward 37signals-inspired architecture. The emphasis is incremental change, behavior preservation, and keeping tests green between steps.

## Quick Start

1. Read the current code and identify all callers, side effects, and tests.
2. Read `../../references/basecamp-style.md` for the source-grounded defaults and boundaries.
3. Add or strengthen characterization tests if behavior is under-specified.
4. Make one small step, run targeted tests, then continue.

## Non-Negotiables

- Do not do a big-bang rewrite.
- Prefer one responsibility shift at a time.
- Keep old and new paths working together during transitions when risk is non-trivial.
- Use feature flags or staged migrations for sensitive auth, API, or data changes.
- Remove old code only after the replacement is proven.

## High-Impact Gate

Ask before destructive migrations, auth/session rewrites, tenant isolation changes, public API changes, queue adapter changes, or production data operations.

## Default Refactoring Targets

- Service objects to model methods or concerns.
- Boolean state columns to explicit state records.
- Fat controllers to CRUD resources plus model methods.
- RSpec or FactoryBot-heavy tests toward Minitest plus fixtures only when the repo is already moving there.
- Sidekiq or Redis-specific background work toward Rails-native queueing patterns only when the app's Rails version and runtime support that move.
- Mixed or missing tenancy toward one explicit model: `Current.account` for shared DB or `with_tenant` for separate DB.
- Runtime drift toward explicit deploy config that matches the app’s current worker and dependency shape.

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

## Output Contract

Report behavior locked down, each refactor step, tests run after each step, compatibility path, and residual risk.

## Reference

- Shared source-grounding and boundaries live in `../../references/basecamp-style.md`.
