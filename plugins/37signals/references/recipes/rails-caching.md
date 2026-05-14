---
type: recipe
owned_by: 37signals-rails-implement,37signals-rails-review
source_ids: rails-doctrine,dev-37signals
claim_scope: rails-synthesis
---
# Rails Caching

Use HTTP caching, ETags, `fresh_when`, `stale?`, and fragment caching when they
solve measured user or server pain.

Do: verify cache keys, invalidation, permissions, tenant isolation, and stale
content behavior.

Avoid: adding cache layers before the slow path and correctness boundaries are
clear.
