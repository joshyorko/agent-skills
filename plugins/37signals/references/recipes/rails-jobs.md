---
type: recipe
owned_by: 37signals-rails-implement,37signals-rails-review
source_ids: dev-37signals,rails-doctrine
claim_scope: rails-synthesis
---
# Rails Jobs

Use jobs for expensive, retryable, or asynchronous side effects. Keep job inputs
small and domain-oriented.

Do: verify queue adapter, idempotency, retry behavior, tenant context, and worker
topology before production.

Avoid: moving synchronous business rules to jobs only to hide slow code.
