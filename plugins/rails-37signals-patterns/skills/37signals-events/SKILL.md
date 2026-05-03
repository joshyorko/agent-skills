---
name: 37signals-events
description: >-
  Builds event tracking and activity systems with webhooks following
  37signals-inspired patterns. Use when implementing audit trails, activity
  feeds, event sourcing, or when user mentions events, tracking, webhooks, or
  activity logs.
license: MIT
metadata:
  author: agent-skills
  version: "1.0"
  source: public-basecamp-style-synthesis
  compatibility: Ruby 3.3+, Rails 8.x, Solid Queue
---
## Source Grounding

This skill is community-maintained and 37signals-inspired. It is not an official Basecamp style guide. Read `../../references/basecamp-style.md` first; target repo conventions and installed versions win when they conflict.

# Events Agent

Model events as domain records, not as generic blobs. The event itself should usually be a first-class record that can drive activity feeds, audit trails, and webhook delivery.

## Core Approach

- Prefer specific event records such as `CardMoved`, `CommentAdded`, or `MemberInvited` over a catch-all `Event` table.
- Use polymorphic activity records when you need a unified timeline over many event types.
- Deliver webhooks from persisted event records through background jobs.
- Treat state changes as records when the state history matters.
- Keep everything database-backed unless there is a strong operational reason to introduce external streaming infrastructure.

## Default Workflow

1. Identify the business event that actually happened.
2. Decide whether it deserves a dedicated event model, a state record, an activity entry, or all three.
3. Persist the event with explicit associations to the subject, actor, and account.
4. Trigger side effects after commit: broadcast updates, activity creation, webhook delivery, or reporting aggregation.
5. Add tests for event creation, fan-out behavior, and failure handling for async delivery.

## Default Patterns

### Domain Events

- Use dedicated models for business-significant events.
- Put domain meaning in associations and method names, not only in JSON metadata.
- Prefer `after_create_commit` fan-out over synchronous controller orchestration.

### Activity Feeds

- Store activity as a polymorphic record pointing to the concrete event.
- Keep timeline presentation separate from event creation.
- Scope activities by account and preload the referenced subject when rendering.

### Webhooks

- Persist endpoints and deliveries.
- Queue webhook delivery in Solid Queue or the app’s normal background system.
- Record attempt counts, statuses, and response bodies where useful for retries and support.

### Tracking and Audit

- Use record-based history when teams need to answer who changed what and when.
- Use JSON metadata only for flexible supplemental facts, not as the primary domain model.

## Boundaries

### Prefer

- Model meaningful events explicitly.
- Scope all events to the current account or tenant.
- Persist before broadcasting or delivering webhooks.
- Keep retryable side effects async.

### Ask First

- Full event sourcing.
- Large-volume analytics pipelines.
- Cross-service event contracts that need versioning or signing.

### Avoid

- Hide important domain events inside anonymous JSON blobs.
- Use boolean timestamps when the lifecycle itself matters.
- Deliver expensive webhook work inline with the user request unless latency is irrelevant.

## Reference

- Shared source-grounding and boundaries live in `../../references/basecamp-style.md`.
