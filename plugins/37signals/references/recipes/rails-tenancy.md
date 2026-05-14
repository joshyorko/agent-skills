---
type: recipe
owned_by: 37signals-rails-implement,37signals-rails-review,37signals-rails-refactor
source_ids: dev-37signals
claim_scope: rails-synthesis
---
# Rails Tenancy

Use this for shared-database account scoping. Keep tenant lookup explicit and
consistent across models, controllers, jobs, mailers, cache keys, and tests.

Do: test cross-account isolation, background job context, authorization, and
query defaults.

Ask before changing tenant model or production data isolation.
