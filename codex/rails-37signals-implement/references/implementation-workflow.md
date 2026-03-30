# Implementation Workflow

Source adapted from the upstream `implement-agent.md` and shared 37signals rules.

## Preferred sequence

1. Database
2. Models and concerns
3. Controllers and routes
4. Views, Turbo, and Stimulus
5. Jobs and mailers
6. Tests

## Per-layer guidance

### Database

- Add the table or columns before writing dependent code.
- Prefer simple, reversible migrations.
- Add tenant and lookup indexes that match real query patterns.

### Models

- Add associations, validations, scopes, and public domain methods.
- If behavior is reused across multiple models, extract a focused concern.
- If the change introduces business state, consider a state record instead of a boolean column.

### Controllers

- Keep actions to resource loading, one model call, and response handling.
- Use nested resources when a lifecycle event becomes its own noun.
- Scope lookups through the current tenant context.

### Views

- Start from server-rendered HTML.
- Add Turbo Stream or Frame behavior when the interaction benefits from partial refreshes.
- Use Stimulus only for a small client-side enhancement.

### Jobs and mailers

- Put durable logic on the model and let the job call it.
- Prefer async delivery or processing for slow work.

### Tests

- Add or update model, controller, and system tests based on the surface area changed.
- Use fixtures when the app already does.

## Common decisions

- New resource or custom action: choose the new resource if the change has its own lifecycle.
- Model method or service object: choose the model method unless the codebase already has a justified service boundary.
- Sync or async: choose async when the work is slow, retryable, or external.
