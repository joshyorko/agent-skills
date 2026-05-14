---
type: recipe
owned_by: 37signals-rails-implement,37signals-rails-review,37signals-rails-refactor
source_ids: rails-doctrine,dev-37signals
claim_scope: rails-synthesis
---
# Rails Models

Use rich domain models when behavior belongs with persisted state. Prefer clear
model APIs, validations, scopes, associations, and small cohesive domain objects
over service objects that only hide ordinary Rails flow.

Do: name behavior in domain language, keep callbacks modest, test public model
behavior, and keep query scopes readable.

Avoid: anemic models, generic `Manager` objects, hidden global state, and
services that only call one model method.
