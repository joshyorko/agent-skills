---
type: recipe
owned_by: 37signals-rails-implement,37signals-rails-review
source_ids: rails-doctrine,dev-37signals
claim_scope: rails-synthesis
---
# Rails Auth

Auth is a correctness boundary, not a style preference. Prefer Rails-native,
small, auditable flows when they meet the product and security requirements.

Do: protect tokens with digests, expire sessions, test reset/login paths, and
preserve auditability.

Ask before rewriting auth, sessions, password reset, OAuth, or token storage.
