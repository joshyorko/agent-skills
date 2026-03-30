# Review Checklist

Source adapted from the upstream `review-agent.md` and shared rules.

## Review order

1. Structure scan
2. Controllers and routes
3. Models and concerns
4. Tests
5. Jobs and mailers
6. Views and frontend behavior

## High-priority checks

### CRUD violations

- Look for custom actions that should be separate resources.

### Service-object drift

- Look for business logic centered in `app/services/` instead of models.

### Boolean state

- Look for lifecycle columns like `archived`, `closed`, or `published`.

### Tenant safety

- Look for unscoped `find`, `all`, or `where` calls in multi-tenant flows.

### Fat controllers and jobs

- Look for multi-step branching, external calls, or durable business rules outside the model layer.

## Medium-priority checks

- Missing concerns for clearly shared behavior.
- Test style mismatches with the surrounding Rails stack.
- Missing Turbo response handling where the UI flow expects partial updates.

## Review output

- Summary: one sentence.
- Findings: severity, file, problem, fix direction, why it matters.
- Residual risks: note testing gaps, assumptions, or areas not inspected.
