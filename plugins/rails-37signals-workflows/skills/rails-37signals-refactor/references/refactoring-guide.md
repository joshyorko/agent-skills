# Refactoring Guide

Source adapted from the upstream `refactoring-agent.md`.

## Safe loop

1. Add or improve tests for existing behavior.
2. Make one small change.
3. Run targeted tests.
4. Continue only when green.

## Common migrations

### Service object to model method

- Identify the true domain owner.
- Move the public API to the model first.
- Inline or retire the service only after callers are updated.

### Boolean to state record

- Add the new state table or relation.
- Backfill existing rows.
- Switch reads and writes to the new relation.
- Remove the old boolean in a later step.

### Fat controller to CRUD resource

- Extract lifecycle actions like archive, close, publish, or approve into nested resources.
- Push branching logic into model methods.

### Queueing and async work

- Keep the job shallow.
- Move durable logic onto the model or a stable domain boundary.

### Tenancy cleanup

- Pick one tenancy model for the affected area before refactoring around it.
- Shared-database refactors should converge on `Current.account` plus explicit account scoping.
- Separate-database refactors should converge on `tenanted` plus `with_tenant`.

### Runtime cleanup

- When the refactor changes workers, env vars, or dependencies, update deploy/runtime config in the same change.
- Remove stale role commands or secrets wiring once the new runtime path is proven.

## Risk management

- Use staged deployments for data shape changes.
- Pair app refactors with Kamal/runtime changes when startup or process topology changes.
- Use deprecation warnings when public interfaces move.
- Prefer compatibility layers over sudden removals when external callers may exist.
