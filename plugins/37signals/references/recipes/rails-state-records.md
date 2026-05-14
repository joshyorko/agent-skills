---
type: recipe
owned_by: 37signals-rails-implement,37signals-rails-review,37signals-rails-refactor
source_ids: dev-37signals
claim_scope: rails-synthesis
---
# Rails State Records

Use records for state when history, ownership, timestamps, permissions, or
reversal matter. Keep simple booleans when the state is truly trivial.

Do: name lifecycle events as domain records, preserve auditability, and keep
current-state queries explicit.

Avoid: piles of booleans that can contradict each other.
