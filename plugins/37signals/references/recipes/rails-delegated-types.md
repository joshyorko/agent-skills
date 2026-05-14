---
type: recipe
owned_by: 37signals-rails-implement,37signals-rails-review,37signals-rails-refactor
source_ids: rails-doctrine,dev-37signals,recordables-delegated-types
claim_scope: rails-synthesis
---
# Rails Delegated Types

Use this when several domain objects share lifecycle, access, timeline, copy,
versioning, or movement behavior but keep different tables or content shapes.

Do: verify the shared operations first, keep the delegating table lean, name the
common interface in domain language, and test capability differences through
real records.

Avoid: using delegated types for every polymorphic relationship, hiding access
rules in the wrong layer, or treating Basecamp/HEY recordables as a universal
schema.
