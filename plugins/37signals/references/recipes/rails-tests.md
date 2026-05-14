---
type: recipe
owned_by: 37signals-rails-implement,37signals-rails-review,37signals-rails-refactor
source_ids: dev-37signals,rails-doctrine
claim_scope: rails-synthesis
---
# Rails Tests

Prefer fast behavior tests with the target app's test stack. In Rails-flavored
work, Minitest and fixtures are a good default unless the app already chose
something else.

Do: test real behavior, important integration paths, permissions, tenancy, jobs,
mailers, and user-visible states.

Avoid: mock-heavy tests that only prove implementation details.
