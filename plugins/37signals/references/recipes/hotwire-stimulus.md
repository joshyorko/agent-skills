---
type: recipe
owned_by: 37signals-hotwire,37signals-rails-implement,37signals-rails-review
source_ids: dhh-rails,rails-doctrine,dev-37signals
claim_scope: dhh-rails
---
# Hotwire Stimulus

Use Stimulus for modest DOM behavior around existing HTML. Controllers should be
small, local, and named after the behavior they enhance.

Do: keep data attributes clear, avoid global state, and preserve no-JavaScript or
server-rendered fallbacks where practical.

Avoid: using Stimulus as an SPA framework.
