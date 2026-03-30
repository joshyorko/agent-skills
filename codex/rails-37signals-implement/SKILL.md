---
name: rails-37signals-implement
description: Use when implementing or extending a Rails feature in a 37signals-style codebase, especially when the user wants rich models, CRUD-only controllers, Hotwire, Solid Queue, Minitest with fixtures, and explicit account scoping instead of service-object-heavy Rails patterns.
---

# Rails 37signals Implement

## Overview

Use this skill for end-to-end feature work in a Rails app that follows 37signals-style conventions. It translates the original Claude-oriented 37signals agent into a Codex-native workflow.

## Quick Start

1. Confirm the feature shape: data changes, domain rules, UI flow, async work, and tests.
2. Read `references/conventions.md` for the default architecture and style assumptions.
3. Read `references/implementation-workflow.md` before substantial feature work or when the request spans multiple layers.
4. Implement in dependency order: database, models, controllers, views, jobs or mailers, then tests.
5. Verify with the smallest relevant Rails test commands before finishing.

## Core Defaults

- Prefer rich models over `app/services/`.
- Prefer CRUD resources over custom controller actions.
- Model business state as records, not booleans, when the state has lifecycle or audit value.
- Scope reads and writes through `Current.account` in multi-tenant apps.
- Prefer Hotwire and server-rendered Rails over client-side stateful frontends.
- Prefer Minitest with fixtures when the codebase follows that stack.

## Implementation Workflow

### 1. Frame the change

- List the schema changes, domain objects, controller endpoints, views, async work, and tests that will move.
- If the request suggests a state transition like archive, publish, close, or approve, consider a separate resource first.

### 2. Build from the bottom up

- Create migrations before model code.
- Add or update model behavior before controller logic.
- Keep controllers thin: find resource, call a model method, respond.
- Add views after the controller contract is clear.
- Push long-running work into jobs that call model methods.

### 3. Keep the architecture honest

- If logic starts drifting into controllers, move it back into models or narrowly scoped concerns.
- If you are tempted to add a custom action, check whether a new nested resource is cleaner.
- If a boolean starts representing business state, consider a state record instead.

### 4. Verify

- Run targeted tests first, then broader verification only if needed.
- Check naming, account scoping, fixture references, and Turbo response behavior.

## Load These References When Needed

- `references/conventions.md`: baseline 37signals Rails conventions and tradeoffs.
- `references/implementation-workflow.md`: dependency order, heuristics, and implementation checkpoints.
