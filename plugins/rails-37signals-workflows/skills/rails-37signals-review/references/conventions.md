# 37signals Rails Conventions

Source adapted from `ThibautBaissac/rails_ai_agents` `.claude_37signals`.

## What good looks like

- Thin RESTful controllers.
- Rich models with clear public methods.
- Concerns for shared behavior, not for hiding unrelated code.
- Explicit tenant scoping.
- State modeled as records when lifecycle matters.
- Turbo and Stimulus used as small enhancements to server-rendered Rails.
- Jobs and mailers kept shallow.
- Minitest plus fixtures in codebases that follow the 37signals stack.

## Common anti-patterns

- `app/services/` as the main home for business logic.
- Controller actions like `archive`, `approve`, or `publish` instead of dedicated resources.
- Boolean lifecycle columns such as `archived` or `published`.
- Broad `Model.find` calls in a tenant-aware app.
- Heavy client-side state management where Rails and Turbo would be simpler.
