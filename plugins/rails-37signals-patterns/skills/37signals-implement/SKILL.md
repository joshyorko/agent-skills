---
name: 37signals-implement
description: >-
  Use when explicitly delegated by a Rails 37signals workflow to coordinate
  multiple specialist pattern skills for one feature.
license: MIT
metadata:
  author: agent-skills
  version: "1.0"
  source: public-basecamp-style-synthesis
  compatibility: Ruby 3.3+, Rails 8.x, Turbo, Stimulus, Solid Queue
---
## Source Grounding

This skill is community-maintained and 37signals-inspired. It is not an official Basecamp style guide. Read `../../references/basecamp-style.md` first; target repo conventions and installed versions win when they conflict.

# Implement Orchestrator

Use this skill as the orchestrator for end-to-end Rails work. It should break a feature into the right 37signals specialist skills, sequence them in dependency order, and keep the final implementation coherent.

## Operating Model

- Start with requirements, constraints, and current code shape.
- Produce an implementation order before touching code.
- Hand each concern to the smallest matching skill instead of solving everything in one giant pass.
- Re-integrate at the end and check for missing tests, tenancy, authorization, Turbo behavior, and async boundaries.

## Default Workflow

1. Identify the feature shape.
   - CRUD resource
   - state transition
   - async workflow
   - notification system
   - activity/event flow
   - API endpoint
2. Break the work into layers.
   - data and migrations
   - tenancy model and runtime ownership
   - models and concerns
   - controllers and routes
   - views, Turbo, and Stimulus
   - jobs, mailers, and events
   - deploy and operations
   - tests
3. Invoke the right specialist skills in dependency order.
4. Re-check the combined implementation for account scoping, naming consistency, and user-visible behavior.
5. Summarize the final design and note any deferred tradeoffs.

## Delegation Guide

- `$37signals-migration` for schema and data changes.
- `$37signals-active-record-tenanted` or `$37signals-multi-tenant` for choosing the tenancy model and enforcing it consistently.
- `$37signals-model` and `$37signals-concerns` for core domain logic.
- `$37signals-crud` for controller and route shape.
- `$37signals-turbo` and `$37signals-stimulus` for interaction and real-time UX.
- `$37signals-jobs`, `$37signals-mailer`, and `$37signals-events` for async and notification behavior.
- `$37signals-api` for JSON endpoints.
- `$37signals-kamal` for deploy config, runtime roles, and shipping changes safely.
- `$37signals-test` for final coverage.

## Implementation Rules

- Prefer resources over custom verbs.
- Keep business logic in models and concerns.
- Maintain the chosen tenancy model consistently.
- Use background jobs for expensive side effects.
- Include deploy/runtime changes when the feature changes startup, workers, dependencies, or secrets.
- Add tests with the implementation, not after the fact.

## Boundaries

### Prefer

- Plan the implementation order first.
- Use specialist skills instead of monolithic generation.
- Validate integration points between layers.

### Ask First

- Major architectural shifts.
- New external dependencies.
- Large migrations or cross-cutting rewrites.

### Avoid

- Implement the whole feature as one undifferentiated code dump.
- Skip tests or tenancy review because the feature “seems straightforward.”

## Reference

- Shared source-grounding and boundaries live in `../../references/basecamp-style.md`.
