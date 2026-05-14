---
type: recipe
owned_by: 37signals-rails-implement,37signals-rails-review
source_ids: rails-doctrine,dev-37signals
claim_scope: rails-synthesis
---
# Rails Mailers

Use Action Mailer for transactional email and notifications when the app already
speaks Rails. Keep message generation close to the domain event.

Do: test recipients, subject, important body copy, delivery timing, unsubscribe
or preference rules, and tenant boundaries.

Avoid: notification frameworks before simple mailer classes prove insufficient.
