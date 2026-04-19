# 37signals Rails Conventions

Source adapted from `ThibautBaissac/rails_ai_agents` `.claude_37signals`.

## Destination architecture

- Rich models hold domain behavior.
- Concerns hold shared horizontal behavior.
- Controllers stay thin and RESTful.
- State transitions become resources when the state matters in its own right.
- Jobs call model methods instead of embedding business rules.
- Views stay server-rendered, with Turbo and small Stimulus controllers where needed.
- Deploy config should match the current app runtime instead of lagging behind it.

## Refactoring signals

- `app/services/` is growing faster than the models.
- Controllers own business logic or multi-step workflows.
- Boolean flags encode business lifecycle.
- Queries ignore tenant boundaries.
- The code mixes `Current.account` assumptions with database-per-tenant code.
- Worker or deploy config no longer matches the runtime the app now needs.
- The test stack is slow or over-isolated for normal Rails workflows.

## Style reminders

- Prefer clarity over indirection.
- Favor explicit tenant scoping.
- Keep private helpers in reading order.
- Avoid introducing new abstractions during refactors unless they remove real duplication.
