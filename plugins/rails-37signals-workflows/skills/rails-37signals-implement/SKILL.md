---
name: rails-37signals-implement
description: Use when implementing or extending a Rails feature in a 37signals-inspired codebase, especially when the user wants rich models, CRUD-first controllers, Hotwire, Solid Queue, Minitest with fixtures, and explicit account scoping instead of service-object-heavy Rails patterns.
license: MIT
metadata:
  author: agent-skills
  version: "1.0"
  source: public-basecamp-style-synthesis
---
## Source Grounding

This workflow is community-maintained and 37signals-inspired. It is not an official Basecamp style guide. Read `../../references/basecamp-style.md` first; target repo conventions and user intent win when they conflict.

# Rails 37signals Implement

## Overview

Use this skill for end-to-end feature work in a Rails app that follows 37signals-inspired conventions. It is a source-grounded workflow for sequencing schema, domain, UI, async, deploy, and test changes.

## Quick Start

1. Confirm the feature shape: data changes, domain rules, UI flow, async work, and tests.
2. Read `../../references/basecamp-style.md` for the source-grounded defaults and boundaries.
3. Implement in dependency order: database, models, controllers, views, jobs or mailers, then tests.
4. Verify with the smallest relevant Rails test commands before finishing.

## Core Defaults

- Prefer rich models over `app/services/`.
- Prefer CRUD resources over custom controller actions.
- Model business state as records, not booleans, when the state has lifecycle or audit value.
- Choose the tenancy model explicitly: shared database with `Current.account`, or separate databases with `with_tenant`.
- Prefer Hotwire and server-rendered Rails over client-side stateful frontends.
- Prefer Minitest with fixtures when the codebase follows that stack.
- Include deploy/runtime work when the feature changes startup, workers, dependencies, or secrets.

## Implementation Workflow

### 1. Frame the change

- List the schema changes, tenancy model, domain objects, controller endpoints, views, async work, deploy/runtime changes, and tests that will move.
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
- Check naming, tenancy consistency, fixture references, Turbo response behavior, and deploy/runtime impact.

## Reference

- Shared source-grounding and boundaries live in `../../references/basecamp-style.md`.
