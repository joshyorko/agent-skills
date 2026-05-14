---
type: recipe
owned_by: 37signals-rails-implement,37signals-rails-review,37signals-rails-refactor
source_ids: dev-37signals,rails-doctrine
claim_scope: rails-synthesis
---
# Rails Concerns

Use concerns for cohesive traits or roles, not arbitrary chunks of a large file.
The concern should have a name that explains the domain capability it adds.

Do: keep dependencies visible, test through consuming models/controllers, and
prefer local methods when reuse is speculative.

Avoid: catch-all `Shared`, `Utils`, or `Helpers` concerns that hide unrelated
behavior.
