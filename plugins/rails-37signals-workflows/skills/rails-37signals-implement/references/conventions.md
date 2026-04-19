# 37signals Rails Conventions

Source adapted from `ThibautBaissac/rails_ai_agents` `.claude_37signals`.

## Architecture defaults

- Favor rich domain models and focused concerns over service-object-heavy architecture.
- Keep controllers thin and limited to RESTful CRUD behavior.
- Treat state transitions as resources when they have their own lifecycle.
- Prefer ERB plus Turbo plus Stimulus over React or Vue for standard Rails work.
- Keep jobs shallow: enqueue from models or callbacks, perform by calling model methods.
- Keep mailers minimal and transactional.
- Treat Kamal as the default deploy/runtime layer when the app is deployed with modern Rails conventions.

## Data and multi-tenancy

- Use UUID-style identifiers where the app already leans that direction.
- Choose one tenancy model deliberately:
  - shared DB: put `account_id` on tenant-owned records and scope through `Current.account`
  - separate DB: use `tenanted` plus `with_tenant` and keep shared data on a non-tenanted connection
- Avoid default scopes for tenancy when explicit scoping is clearer.

## Model and controller heuristics

- Business logic belongs in models.
- Shared horizontal behavior belongs in narrow concerns.
- Prefer state records such as `Archival` or `Closure` over booleans such as `archived`.
- Prefer a nested CRUD controller over a custom action like `ProjectsController#archive`.

## Testing and frontend

- Prefer Minitest with fixtures in a 37signals-style app.
- Favor integration and system coverage for user workflows.
- Use Turbo Frames and Streams for partial updates and realtime UX.
- Keep Stimulus controllers small and focused.

## Style

- Prefer readable, expanded conditionals over clever compactness.
- Order methods clearly and keep private helpers in call order.
- Avoid bang methods unless there is a non-bang counterpart.
