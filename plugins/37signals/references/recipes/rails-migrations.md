---
type: recipe
owned_by: 37signals-rails-implement,37signals-rails-review
source_ids: rails-doctrine,dev-37signals
claim_scope: rails-synthesis
---
# Rails Migrations

Design schema changes around the app's database policy, deploy constraints, and
tenant model. There is no universal 37signals rule requiring UUIDs or forbidding
foreign keys.

Do: prefer reversible changes, explicit null/default decisions, backfill safety,
and constraints that protect important invariants.

Ask before destructive migrations, production data changes, or tenant-isolation
changes.
