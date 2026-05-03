---
name: 37signals-active-record-tenanted
description: >-
  Use when a Rails app needs Active Record Tenanted, database-per-tenant
  isolation, tenant context resolution, or tenant-aware jobs/cache/storage/cable.
license: MIT
metadata:
  author: Mike Dalessio / 37signals
  version: "1.0"
  source: activerecord-tenanted
  source_repo: basecamp/activerecord-tenanted
  source_ref: main checked 2026-05-03
  source_note: Basecamp-owned source. Verify installed version and current docs before applying.
  source_path: README.md, GUIDE.md
  compatibility: Ruby 3.3+, Rails 8.x, sqlite3
---
## Source Grounding

Grounded in the Basecamp-owned `activerecord-tenanted` project. Read `../../references/basecamp-style.md`, then verify the installed gem version and app config before editing.

# Active Record Tenanted

Use this for separate database tenancy. Do not mix it casually with shared `account_id` scoping in the same feature area.

## Workflow

1. Inspect `Gemfile`, `config/database*.yml`, `ApplicationRecord`, routes, jobs, Action Cable, cache, storage, and tests.
2. Confirm tenant identity source: subdomain, path, explicit resolver, or test helper.
3. Configure only the records that belong in tenant databases with `ApplicationRecord.tenanted`; keep global records on shared connections.
4. Wrap tenant work in the gem's tenant context API and preserve its `NoTenantError`/`WrongTenantError` guardrails.
5. Update jobs, cache, storage, mailer URLs, cable connections, fixtures, and test helpers only where the app uses those surfaces.
6. Run tenant-specific model, integration, and job tests.

## Guardrails

- Ask before changing tenancy architecture or migrating existing tenant data.
- Do not claim ECS or Litestream is official 37signals guidance; public sources do not establish that.
- Do not bypass tenant context in tests to make failures disappear.
- Do not put global records, account lookup records, or cross-tenant admin data into tenant databases without an explicit design.

## Output

State tenant source, records made tenanted, runtime surfaces updated, commands run, and any migration/deploy risk still unverified.
