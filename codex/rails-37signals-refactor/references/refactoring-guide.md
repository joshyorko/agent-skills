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

## Risk management

- Use staged deployments for data shape changes.
- Use deprecation warnings when public interfaces move.
- Prefer compatibility layers over sudden removals when external callers may exist.
