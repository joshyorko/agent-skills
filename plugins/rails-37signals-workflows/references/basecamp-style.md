# Public Basecamp Rails Style Grounding

These workflow skills orchestrate community-maintained, 37signals-inspired Rails
patterns. They are not official Basecamp or 37signals style guides unless a
claim is tied to a Basecamp-owned repo or public 37signals engineering article.

Source order:

1. Target app conventions and user intent.
2. Public Basecamp repo docs such as `basecamp/fizzy/STYLE.md` and `AGENTS.md`.
3. Public 37signals engineering articles and upstream Rails/Hotwire/Kamal docs.
Operate from these sourced defaults:

- Prefer vanilla Rails first: RESTful controllers, server-rendered HTML,
  Hotwire, Active Record domain models, Active Job, Minitest fixtures, and
  Kamal where the deployment boundary fits.
- Use rich model APIs before inventing a service layer, while allowing cohesive
  POROs or operation-like domain objects when the model concept deserves them.
- Use CRUD/resource modeling as the first lens, not as a ceremony that overrides
  webhooks, imports, external callbacks, or established app contracts.
- Prefer Solid Queue on Rails 8 or where installed, but verify production queue
  DBs, worker roles, monitoring, and shutdown behavior.
- Choose one tenancy model per feature area: shared database with explicit
  account scoping, or Active Record Tenanted with a tenant context and separate
  tenant stores.
- Use Minitest/fixtures as the default testing flavor, but preserve existing
  test stack unless the task is an explicit migration.
- Reserve "never" for security, data-loss, and correctness hazards. Use
  "prefer" and "ask before" for style defaults.

Do not overclaim ECS, Litestream, "no JavaScript", "no operation objects", or
"every app uses SQLite" as 37signals doctrine.
