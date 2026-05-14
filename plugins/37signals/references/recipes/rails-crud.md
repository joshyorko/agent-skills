---
type: recipe
owned_by: 37signals-rails-implement,37signals-rails-review,37signals-rails-refactor
source_ids: rails-doctrine,dev-37signals
claim_scope: rails-synthesis
---
# Rails Resources

Start with REST resources and domain nouns. Model state changes as resources
when doing so clarifies routing, authorization, and tests.

Do: keep controllers small, name routes around user-visible objects, use custom
actions only when they are clearer than a forced resource.

Avoid: controller verbs that hide domain state or make permissions ambiguous.
