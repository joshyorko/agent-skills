---
type: recipe
owned_by: 37signals-rails-implement,37signals-rails-review
source_ids: rails-doctrine,dev-37signals
claim_scope: rails-synthesis
---
# Rails APIs

Prefer the app's existing controller and view conventions for JSON. Jbuilder or
equivalent templates are reasonable when the app already uses them.

Do: design stable response shapes, auth, pagination, error handling, and tests.

Avoid: a separate API architecture when same-controller different-format support
is enough.
