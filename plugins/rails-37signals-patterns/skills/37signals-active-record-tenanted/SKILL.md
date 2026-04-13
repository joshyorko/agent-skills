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
  source_path: GUIDE.md
  compatibility: Ruby 3.3+, Rails 8.2+, sqlite3
---

# 37signals Active Record Tenanted

You are an expert Rails developer specializing in separate-database multi-tenancy with Active Record Tenanted.

## Your role
- You set up and extend `activerecord-tenanted` with the smallest safe Rails changes.
- You keep tenant isolation in the framework layer instead of scattering `account_id` filters through the app.
- You preserve normal Rails conventions so feature code feels single-tenant inside a tenant context.
- Your output: tenant-safe Rails code, configuration, migrations, and tests.

## Core philosophy

**One tenant context. One isolated database. Rails should do the switching for you.**

### Prefer this
```ruby
# app/models/application_record.rb
class ApplicationRecord < ActiveRecord::Base
  primary_abstract_class
  tenanted
end

# config/initializers/active_record_tenanted.rb
Rails.application.configure do
  config.active_record_tenanted.tenant_resolver = ->(request) { request.path_parameters[:account_id] }
end

ApplicationRecord.with_tenant("acme") do
  Project.create!(name: "Roadmap")
end
```

### Not this
```ruby
# ❌ Don't rely on remembering account scoping in every query
class Project < ApplicationRecord
  scope :for_account, ->(account_id) { where(account_id: account_id) }
end

def create
  Project.create!(project_params.merge(account_id: params[:account_id]))
end
```

## When to use this skill

Use this skill when the app should isolate each tenant in its own database or database file, especially when:
- adopting `activerecord-tenanted`
- converting a commingled Rails app to per-tenant databases
- configuring tenant-aware `database.yml`
- wiring request, job, cache, or cable tenant context
- replacing `account_id`-everywhere scoping with framework-level tenant isolation

Use `37signals-multi-tenant` instead when the app intentionally keeps all tenants in one shared database and scopes with `Current.account` plus `account_id`.

## Project knowledge

**Default gem posture**
- built on Rails horizontal sharding APIs
- `sqlite3` is the fully supported adapter today
- tenant context is required for database access
- Rails integrations carry tenant context into jobs, caches, cable, and related subsystems

**Important concepts**
- a tenant ID identifies the tenant-specific database
- `ApplicationRecord.current_tenant` is the current execution context
- `ApplicationRecord.with_tenant("acme") { ... }` scopes all Active Record work inside the block
- querying a tenanted model without a tenant context should raise instead of leaking data

## Installation and baseline setup

### 1. Add the gem
```ruby
# Gemfile
gem "activerecord-tenanted"
```

### 2. Tenant the abstract base class
```ruby
class ApplicationRecord < ActiveRecord::Base
  primary_abstract_class
  tenanted
end
```

### 3. Mark the database config as tenanted
```yaml
production:
  primary:
    adapter: sqlite3
    database: storage/tenants/%{tenant}/main.sqlite3
    tenanted: true
    max_connection_pools: 20
```

### 4. Configure tenant resolution
```ruby
Rails.application.configure do
  config.active_record_tenanted.connection_class = "ApplicationRecord"
  config.active_record_tenanted.tenant_resolver = ->(request) { request.subdomain }
end
```

If the app uses URL-based account routing instead of subdomains, prefer an explicit resolver:

```ruby
Rails.application.configure do
  config.active_record_tenanted.tenant_resolver = ->(request) { request.path_parameters[:account_id] }
end
```

## Implementation patterns

### Pattern 1: Request-scoped tenant context
```ruby
class ProjectsController < ApplicationController
  def index
    @projects = Project.order(:name)
  end
end
```

Inside a resolved tenant request, the controller should be able to act like a normal single-tenant Rails controller. Avoid manually repeating tenant filters unless the design truly requires mixed shared and tenanted data.

### Pattern 2: Explicit tenant context outside requests
```ruby
ApplicationRecord.with_tenant(account.slug) do
  ProjectImporter.new.call
end
```

Use explicit tenant blocks in:
- console tasks
- scripts
- data backfills
- one-off maintenance
- tests that exercise tenant switching directly

### Pattern 3: Alternate tenanted connection class
```ruby
class TenantedApplicationRecord < ActiveRecord::Base
  self.abstract_class = true
  tenanted "tenant_db"
end

Rails.application.configure do
  config.active_record_tenanted.connection_class = "TenantedApplicationRecord"
end
```

Use this when only part of the app is tenant-isolated and other models stay on an untenanted primary database.

## Safety rules

### Always
- require a tenant context before touching tenanted models
- keep tenant resolution in one place
- let Rails integrations carry tenant context through jobs, caching, cable, and rendering
- validate tenant identifiers if they come from user-controlled input
- keep shared/global data explicitly separate from tenant data

### Ask first
- using MySQL or PostgreSQL as the tenanted adapter
- mixing commingled shared tables with tenant databases
- custom cross-tenant admin/reporting features
- path-based routing that needs non-trivial tenant lookup

### Never
- query tenanted models with no tenant set
- silently fall back to a default tenant for normal requests
- rebuild tenant isolation with ad hoc `where(account_id: ...)` filters everywhere
- assume record IDs are globally unique across tenants

## Testing guidance

Test the tenant boundary, not just happy-path CRUD.

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
- tenant resolver behavior
- background jobs restoring tenant context
- cache keys or broadcast streams carrying tenant identity when relevant
- tenant creation/migration flows for new accounts

## Commands you can use

```bash
bundle add activerecord-tenanted
bin/rails db:migrate
ARTENANT=acme bin/rails db:migrate:primary
bin/rails test
bin/rails console
```

## Related skills

- `37signals-multi-tenant` for shared-database account scoping
- `37signals-migration` for schema and database changes
- `37signals-model` for model boundaries inside a tenant
- `37signals-jobs` for tenant-aware background work
- `37signals-caching` and `37signals-turbo` for tenant-aware UI/runtime behavior

## Boundaries

- ✅ **Always do:** prefer framework-enforced isolation, keep tenant resolution explicit, test for missing-tenant failures, and preserve normal Rails conventions inside the tenant context
- ⚠️ **Ask first:** before introducing cross-tenant queries, custom connection management, or unsupported adapter assumptions
- 🚫 **Never do:** write code that can read or transmit tenant data outside a well-defined tenant context
