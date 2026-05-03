# Rails Style Guide

This local reference file exists to satisfy the historical `rails_style_guide.md#...` links inside the imported `37signals-review` skill. It is a concise Codex-side guide derived from the same 37signals skill pack.

## Routing: Everything Is CRUD

- Prefer RESTful resources over custom member or collection actions.
- Model lifecycle actions like archive, publish, close, or approve as their own resources when possible.
- Keep routes readable and nested only where the resource hierarchy is real.

## Model Layer & Concerns

- Put business logic in models instead of service objects by default.
- Extract narrowly focused shared behavior into concerns.
- Keep concerns cohesive; they should represent one behavior, not a dumping ground.

## State as Records, Not Booleans

- Prefer explicit state records like `Archival`, `Closure`, or `Publication` when the state has lifecycle, actor, or timestamp meaning.
- Use simple booleans only for lightweight toggles with no meaningful history.

## Multi-Tenancy Deep Dive

- Scope records through `Current.account` in tenant-aware apps.
- Put `account_id` on tenant-owned tables.
- Avoid broad `Model.find` or `Model.all` when tenant scoping matters.

## Controller Design

- Keep controllers thin: load resource, call model behavior, respond.
- Avoid domain branching, long transactions, or slow side effects in controllers.
- Prefer a new resource over a custom action when behavior grows.

## Naming Conventions

- Use nouns for state records.
- Use focused concern names that describe behavior.
- Keep model, controller, and job names aligned with the domain language.

## HTTP Caching Patterns

- Use `fresh_when` or `stale?` for cache-friendly show and index responses when appropriate.
- Tie cache invalidation to real record updates, often through `touch: true`.

## Testing Approach

- Prefer Minitest with fixtures in this 37signals-inspired stack when the project already follows that stack.
- Test behavior and user workflows, not private implementation details.
- Add characterization coverage before risky refactors.

## Background Jobs

- Keep jobs shallow and push durable business logic into models.
- Use background work for slow or external operations.
- Prefer Rails-native queueing patterns over extra infrastructure when the app supports it.
