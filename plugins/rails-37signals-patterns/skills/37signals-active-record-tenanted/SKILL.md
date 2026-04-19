---
name: 37signals-active-record-tenanted
description: >-
  Implements separate-database multi-tenancy with Active Record Tenanted using
  tenant-aware Rails conventions, resolver configuration, and safety guardrails.
  Use when adding activerecord-tenanted, isolating each tenant in its own
  database, or adapting 37signals-style Rails apps to database-per-tenant
  architecture.
license: MIT
metadata:
  author: 37signals
  version: "1.0"
  source: activerecord-tenanted
  source_repo: basecamp/activerecord-tenanted
  source_ref: main
  source_path: README.md, GUIDE.md
  compatibility: Ruby 3.3+, Rails 8.2+, sqlite3
---

# 37signals Active Record Tenanted

Use this skill when the app should isolate tenant data in separate databases and let Rails carry the tenant context for you.

This is the database-per-tenant path. Use `37signals-multi-tenant` instead when the app intentionally keeps all tenants in one shared database and scopes through `Current.account` plus `account_id`.

## Core approach

- Tenanting lives in the framework layer, not in ad hoc query scopes.
- A tenant key resolves to a tenant-specific database name or path.
- Tenanted code should feel single-tenant inside the current tenant context.
- Shared/global data should stay explicitly outside the tenanted connection.

Prefer this:

```ruby
class ApplicationRecord < ActiveRecord::Base
  primary_abstract_class
  tenanted
end

Rails.application.configure do
  config.active_record_tenanted.connection_class = "ApplicationRecord"
  config.active_record_tenanted.tenant_resolver = ->(request) { request.subdomain }
end
```

Not this:

```ruby
class Project < ApplicationRecord
  scope :for_account, ->(account_id) { where(account_id: account_id) }
end
```

## Repo decision rule

Choose one tenancy model per feature area and stay consistent:

- Shared DB: `Current.account`, `account_id`, explicit account scoping, normal shared tables.
- Separate DB: `tenanted`, `with_tenant`, separate tenant databases, explicit shared/global models outside the tenanted connection.

Hybrid apps are possible, but the boundary must be explicit:

- shared models inherit from a non-tenanted abstract class
- tenant-owned models inherit from the tenanted connection class
- jobs, caches, broadcasts, and scripts must know which side they are operating on

## Current upstream posture

- `sqlite3` is the only fully supported adapter today.
- The gem is built on Rails horizontal sharding APIs.
- Access without a tenant context should raise `ActiveRecord::Tenanted::NoTenantError`.
- The upstream GUIDE is still a work in progress, so some framework integrations should be treated as provisional and verified against the gem version in use.

## Baseline setup

1. Add the gem.

```ruby
gem "activerecord-tenanted"
```

2. Tenant the abstract base class.

```ruby
class ApplicationRecord < ActiveRecord::Base
  primary_abstract_class
  tenanted
end
```

3. Mark the tenant database configuration as tenanted.

```yaml
production:
  primary:
    adapter: sqlite3
    database: storage/tenants/%{tenant}/main.sqlite3
    tenanted: true
    max_connection_pools: 20
```

4. Configure the connection class and resolver.

```ruby
Rails.application.configure do
  config.active_record_tenanted.connection_class = "ApplicationRecord"
  config.active_record_tenanted.tenant_resolver = ->(request) { request.subdomain }
end
```

5. If only part of the app is tenant-isolated, use a separate abstract class.

```ruby
class TenantedApplicationRecord < ActiveRecord::Base
  self.abstract_class = true
  tenanted "tenant_db"
end
```

## Tenant key guidance

Pick one canonical tenant key and use it consistently in the resolver, lifecycle code, and provisioning flow. In practice this is usually a slug or subdomain, not an internal numeric ID.

- Normalize case and whitespace once.
- Validate characters based on the backing database naming/path rules.
- Do not let arbitrary user input become a database name without normalization and validation.
- If routes expose `account_id`, make sure it resolves to the canonical tenant key instead of using raw path data blindly.

## Runtime patterns

### Requests

Inside a resolved request, controllers should read like ordinary Rails controllers:

```ruby
class ProjectsController < ApplicationController
  def index
    @projects = Project.order(:name)
  end
end
```

### Scripts, console, and one-off work

Outside a request, always set the tenant explicitly:

```ruby
ApplicationRecord.with_tenant(account.slug) do
  ProjectImporter.new.call
end
```

Use explicit tenant blocks in console tasks, data backfills, repair scripts, and maintenance commands.

### Jobs, caches, and broadcasts

Do not copy shared-database `Current.account` examples into a database-per-tenant app.

- Jobs should restore the tenant context before touching tenanted models.
- Cache keys, stream names, and broadcast channels should include tenant identity when they escape the database boundary.
- Be cautious with direct `Rails.cache` access and global cache namespaces; verify how the installed gem version integrates with fragment caching and cache key derivation.
- Treat Action Cable, Turbo streams, and Active Job integration as something to verify against the gem version in use, not as magic you can assume blindly.

## Tenant lifecycle

Separate-database tenancy is not just query scoping. You need a lifecycle plan:

- tenant creation: provision the tenant database before routing traffic there
- tenant migration: know whether you are migrating one tenant or all tenants
- tenant archival or deletion: remove access first, then archive or drop the tenant database intentionally
- tenant bootstrap: seed required tenant-owned records after provisioning

Be explicit about database tasks in scripts and docs:

```bash
bundle add activerecord-tenanted
bin/rails db:migrate
ARTENANT=acme bin/rails db:migrate:primary
bin/rails test
bin/rails console
```

If a tenant database is missing required migrations, treat that as an operational problem to fix, not something to paper over with a fallback tenant.

## Testing guidance

Test the tenant boundary directly:

```ruby
test "requires a tenant context" do
  assert_raises(ActiveRecord::Tenanted::NoTenantError) do
    Project.count
  end
end

test "isolates records by tenant" do
  ApplicationRecord.with_tenant("alpha") { Project.create!(name: "Alpha") }
  ApplicationRecord.with_tenant("beta")  { Project.create!(name: "Beta") }

  ApplicationRecord.with_tenant("alpha") do
    assert_equal ["Alpha"], Project.order(:name).pluck(:name)
  end
end
```

Also cover:

- tenant resolver behavior in request tests
- job execution restoring the correct tenant
- provisioning and migration flows for new tenants
- any test helper or fixture behavior that sets a default tenant for convenience
- cleanup for tenant databases created during tests

## Boundaries

### Always

- Keep tenant resolution in one place.
- Require an explicit tenant context before touching tenanted models.
- Keep shared/global data separate from tenant-owned data.
- Verify framework integrations that cross request boundaries.

### Ask first

- Using MySQL or PostgreSQL as the tenanted adapter.
- Cross-tenant reporting or admin flows.
- Hybrid designs where some models are shared and some are tenanted.
- Custom connection management beyond the gem defaults.

### Never

- Fall back silently to a default tenant in normal app flow.
- Rebuild tenant isolation with ad hoc `where(account_id: ...)` filters everywhere.
- Assume IDs, cache entries, or stream names are globally unique across tenants.

## Related skills

- `37signals-multi-tenant` for shared-database account scoping
- `37signals-migration` for schema and database lifecycle changes
- `37signals-model` for boundaries inside tenanted models
- `37signals-kamal` for deploy, secrets, roles, and runtime operations
