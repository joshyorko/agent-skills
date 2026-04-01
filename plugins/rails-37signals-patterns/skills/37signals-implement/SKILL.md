---
name: 37signals-implement
description: >-
  Orchestrates implementation of complete Rails features across models,
  controllers, views, and tests following 37signals conventions. Use when
  implementing a full feature end-to-end or when user mentions feature
  implementation, full-stack, or orchestration.
license: MIT
metadata:
  author: 37signals
  version: "1.0"
  source: 37signals-patterns
  source_repo: ThibautBaissac/rails_ai_agents
  source_ref: e063fc8d8f4444178f4bbda96407e03d339e2c75
  source_path: 37signals_skills/37signals-implement
  compatibility: Ruby 3.3+, Rails 8.2+, Turbo, Stimulus, Solid Queue
---

# Implement Agent

Use this skill as the orchestrator for end-to-end Rails work. It should break a feature into the right 37signals specialist skills, sequence them in dependency order, and keep the final implementation coherent.

The detailed upstream mappings, examples, and feature patterns are preserved in `references/full-guide.md`.

## Codex Mapping

Historical upstream examples refer to generic `@...-agent` names. In this repo, treat those as the local `37signals-*` skills.

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
   - models and concerns
   - controllers and routes
   - views, Turbo, and Stimulus
   - jobs, mailers, and events
   - tests
3. Invoke the right specialist skills in dependency order.
4. Re-check the combined implementation for account scoping, naming consistency, and user-visible behavior.
5. Summarize the final design and note any deferred tradeoffs.

## Delegation Guide

- `$37signals-migration` for schema and data changes.
- `$37signals-model` and `$37signals-concerns` for core domain logic.
- `$37signals-crud` for controller and route shape.
- `$37signals-turbo` and `$37signals-stimulus` for interaction and real-time UX.
- `$37signals-jobs`, `$37signals-mailer`, and `$37signals-events` for async and notification behavior.
- `$37signals-api` for JSON endpoints.
- `$37signals-test` for final coverage.

## Implementation Rules

- Prefer resources over custom verbs.
- Keep business logic in models and concerns.
- Maintain explicit account scoping.
- Use background jobs for expensive side effects.
- Add tests with the implementation, not after the fact.

## Boundaries

### Always

- Plan the implementation order first.
- Use specialist skills instead of monolithic generation.
- Validate integration points between layers.

### Ask First

- Major architectural shifts.
- New external dependencies.
- Large migrations or cross-cutting rewrites.

### Never

- Implement the whole feature as one undifferentiated code dump.
- Skip tests or tenancy review because the feature “seems straightforward.”

## Reference

- Full orchestration examples and feature-by-feature playbooks live in `references/full-guide.md`.
