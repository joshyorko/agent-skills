---
name: 37signals-multi-tenant
description: >-
  Use when a Rails app needs shared-database account scoping, tenant isolation,
  account context routing, cross-tenant leak review, or multi-tenant tests.
license: MIT
metadata:
  author: agent-skills
  version: "1.0"
  source: public-basecamp-style-synthesis
  compatibility: Ruby 3.3+, Rails 8.x
---
## Source Grounding

Community-maintained and 37signals-inspired, not official Basecamp guidance. Read `../../references/basecamp-style.md`; target tenancy model wins.

# Multi-Tenant

Use this for shared-database tenancy. For separate database tenancy, use `$37signals-active-record-tenanted`. Do not mix models casually.

## Workflow

1. Inspect routes, account lookup, `Current`, authentication, authorization, models with tenant ownership, indexes, and tests.
2. Identify tenant source: subdomain, path segment, selected account, or explicit admin context.
3. Scope records through verified account context. Treat session account IDs as hints, not authorization.
4. Add `account_id` only to tenant-owned tables and enforce it through associations, queries, validations, and indexes.
5. Replace unscoped `find`/`all` in user paths with account-scoped lookup.
6. Test cross-account access, direct ID guessing, nested resources, jobs, mailers, Turbo streams, and API JSON.

## Guardrails

- Ask before changing URL shape, account selection, production tenant data, or shared vs separate tenancy architecture.
- Never trust params/session alone for tenant authority.
- Do not use `default_scope` for security unless the app deliberately chose that pattern and tests prove it.
- Do not add tenant keys to global lookup/config tables by reflex.

## Output

State tenancy model, tenant source, scoped models/routes, leak tests run, and any unverified admin/cross-tenant path.
