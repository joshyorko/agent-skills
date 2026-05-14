---
type: recipe
owned_by: 37signals-rails-implement,37signals-rails-review
source_ids: basecamp-repos,dev-37signals
claim_scope: local-repo
---
# Active Record Tenanted

Use this for Basecamp's public `activerecord-tenanted` gem and database-per-
tenant Rails designs. Verify installed gem version before applying advice.

Do: confirm tenant switching, tenant-aware jobs/cache/storage/cable, and
`NoTenantError` or equivalent guardrails.

Do not claim ECS or Litestream is official guidance unless separately sourced.
