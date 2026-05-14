---
type: recipe
owned_by: 37signals-rails-implement,37signals-rails-review
source_ids: rails-doctrine,dev-37signals
claim_scope: rails-synthesis
---
# Rails Events

Use event/activity records when users need history, auditability, webhooks, or
timeline context. Keep event payloads source-backed and durable enough to read
later.

Do: decide creator, subject, timestamp, tenant, visibility, and replay needs.

Avoid: event sourcing language for a plain activity feed.
