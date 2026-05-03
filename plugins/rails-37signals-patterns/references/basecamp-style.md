# Public Basecamp Rails Style Grounding

These skills are community-maintained and 37signals-inspired. They are not
official Basecamp or 37signals style guides unless the cited source is a
Basecamp-owned project or a public 37signals engineering article.

Use this source order when skill advice conflicts:

1. The target app's existing conventions, Rails version, database, and tests.
2. Public Basecamp repo docs such as `basecamp/fizzy/STYLE.md` and `AGENTS.md`.
3. Public 37signals engineering articles and upstream Rails/Hotwire/Kamal docs.

## Sourced Defaults

- Rails is the center. Prefer server-rendered HTML, RESTful resources, rich
  domain models, Active Job, Hotwire, Minitest fixtures, and Kamal before adding
  parallel stacks.
- Controllers stay small and call domain model APIs directly. Do not create a
  service/interactor layer by default, but POROs and operation-like domain
  objects are acceptable when they are cohesive model concepts.
- CRUD is a strong default. Model state changes as resources when it clarifies
  routing and permissions, but do not contort webhooks, callbacks, imports, or
  existing app contracts just to avoid a custom action.
- Concerns should express cohesive traits or roles, often model-specific. Do
  not use concerns to hide arbitrary chunks of unrelated model code.
- Stimulus has modest ambitions: enhance existing HTML with small controllers.
  Turbo keeps most rendering and authorization on the server.
- Solid Queue is the Rails-native queue default in Rails 8. For production,
  verify the queue database, worker topology, monitoring, and shutdown behavior
  instead of assuming the default config is enough.
- Active Record Tenanted is SQLite-first today. Public sources support
  database-per-tenant, `with_tenant`, tenant-aware jobs/cache/storage/cable, and
  `NoTenantError`/`WrongTenantError` guardrails. They do not establish ECS or
  Litestream as official 37signals guidance.
- Kamal is a Basecamp project for Dockerized web apps on VMs or bare metal. It
  is not Rails-only and it is not a Kubernetes abstraction.
- Minitest and fixtures are the 37signals-flavored default. Test real behavior,
  avoid mock-heavy isolation, keep brittle system coverage small, and include
  manual product/accessibility QA when user-facing behavior changes.

## Writing Rules For Skills

- Say "prefer", "reach for first", and "ask before" for style defaults.
- Reserve "never" for security, data-loss, or correctness hazards.
- Mark inferred deployment guidance as inference when no public Basecamp source
  backs it.
- Treat existing project conventions as higher priority unless the user asked
  for a deliberate 37signals-inspired migration.

## Primary Sources

- `basecamp/fizzy/STYLE.md`
- `basecamp/fizzy/AGENTS.md`
- `basecamp/activerecord-tenanted` README, GUIDE, and CHANGELOG
- `basecamp/kamal` README
- `rails/solid_queue` README
- https://dev.37signals.com/a-vanilla-rails-stack-is-plenty/
- https://dev.37signals.com/vanilla-rails-is-plenty/
- https://dev.37signals.com/good-concerns/
- https://dev.37signals.com/rails-multi-tenancy/
- https://dev.37signals.com/solid-queue-v1-0/
- https://dev.37signals.com/the-rails-delegated-type-pattern/
- https://dev.37signals.com/pending-tests/
- https://dev.37signals.com/all-about-qa/
- https://world.hey.com/dhh/our-switch-to-kamal-is-complete-8e0de22e
