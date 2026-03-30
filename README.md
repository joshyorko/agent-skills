# Agent Skills

A focused set of Codex skills for four jobs:
- `codex/37signals-*` for focused 37signals-style Rails specialists
- `codex/rails-37signals-*` for workflow-level Rails implementation, refactoring, and review
- `codex/fizzy/` for self-hosted Fizzy workflows via the upstream CLI
- `codex/rcc-skill/` for RCC automation, isolated environments, and robot scaffolding

## Structure

```text
agent-skills/
├── README.md
└── codex/
    ├── 37signals-api/
    ├── 37signals-auth/
    ├── 37signals-caching/
    ├── 37signals-concerns/
    ├── 37signals-crud/
    ├── 37signals-events/
    ├── 37signals-implement/
    ├── 37signals-jobs/
    ├── 37signals-mailer/
    ├── 37signals-migration/
    ├── 37signals-model/
    ├── 37signals-multi-tenant/
    ├── 37signals-refactoring/
    ├── 37signals-review/
    ├── 37signals-state-records/
    ├── 37signals-stimulus/
    ├── 37signals-test/
    ├── 37signals-turbo/
    ├── fizzy/
    │   ├── SKILL.md
    │   ├── agents/
    │   └── scripts/
    ├── rails-37signals-implement/
    │   ├── SKILL.md
    │   ├── agents/
    │   └── references/
    ├── rails-37signals-refactor/
    │   ├── SKILL.md
    │   ├── agents/
    │   └── references/
    ├── rails-37signals-review/
    │   ├── SKILL.md
    │   ├── agents/
    │   └── references/
    └── rcc-skill/
        ├── SKILL.md
        ├── agents/
        ├── assets/
        ├── references/
        └── scripts/
```

## Skills

### 37signals Rails Specialists

The `codex/37signals-*` skills cover focused Rails patterns and conventions inspired by 37signals-style applications. Across the set, the defaults lean toward rich models, CRUD resources, Hotwire, Solid Queue, explicit `Current.account` scoping, UUID-backed schemas, and Minitest with fixtures.

**Architecture and workflow**
- [`37signals-implement`](codex/37signals-implement/SKILL.md) — orchestrates complete Rails feature work across the specialist skills.
- [`37signals-refactoring`](codex/37signals-refactoring/SKILL.md) — orchestrates incremental refactors toward 37signals Rails patterns.
- [`37signals-review`](codex/37signals-review/SKILL.md) — reviews Rails code for convention alignment, CRUD shape, model design, and Hotwire fit.

**Domain, data, and tenancy**
- [`37signals-auth`](codex/37signals-auth/SKILL.md) — custom passwordless authentication without Devise.
- [`37signals-concerns`](codex/37signals-concerns/SKILL.md) — shared model and controller behavior via focused concerns.
- [`37signals-migration`](codex/37signals-migration/SKILL.md) — UUID-first, account-scoped migrations without foreign key constraints.
- [`37signals-model`](codex/37signals-model/SKILL.md) — rich domain models with business logic, scopes, validations, and associations.
- [`37signals-multi-tenant`](codex/37signals-multi-tenant/SKILL.md) — URL-based multi-tenancy and explicit account scoping.
- [`37signals-state-records`](codex/37signals-state-records/SKILL.md) — models business state as records instead of booleans.

**Delivery, UI, and operations**
- [`37signals-api`](codex/37signals-api/SKILL.md) — REST APIs using `respond_to` blocks with Jbuilder templates.
- [`37signals-caching`](codex/37signals-caching/SKILL.md) — HTTP caching, ETags, `fresh_when`, `stale?`, and fragment caching.
- [`37signals-crud`](codex/37signals-crud/SKILL.md) — RESTful controllers built around the “everything is CRUD” philosophy.
- [`37signals-events`](codex/37signals-events/SKILL.md) — event tracking, activity feeds, and webhook-friendly event models.
- [`37signals-jobs`](codex/37signals-jobs/SKILL.md) — shallow background jobs and async workflows using Solid Queue.
- [`37signals-mailer`](codex/37signals-mailer/SKILL.md) — minimal Action Mailer patterns and bundled notifications.
- [`37signals-stimulus`](codex/37signals-stimulus/SKILL.md) — focused Stimulus controllers for progressive enhancement.
- [`37signals-test`](codex/37signals-test/SKILL.md) — Minitest and fixtures for fast, readable Rails test coverage.
- [`37signals-turbo`](codex/37signals-turbo/SKILL.md) — Turbo Streams, Frames, and morphing for real-time UI updates.

These specialist skills preserve source metadata in their frontmatter and were adapted from the broader `rails_ai_agents` 37signals pattern set.

### Rails 37signals Workflows

The `codex/rails-37signals-*` folders are standalone workflow skills for common Rails jobs, not just aliases. Each one includes an `agents/openai.yaml` file plus a focused `references/` set.

- [`rails-37signals-implement`](codex/rails-37signals-implement/SKILL.md) — end-to-end feature implementation in dependency order. See `references/conventions.md` and `references/implementation-workflow.md`.
- [`rails-37signals-refactor`](codex/rails-37signals-refactor/SKILL.md) — incremental, behavior-preserving refactors toward 37signals conventions. See `references/conventions.md` and `references/refactoring-guide.md`.
- [`rails-37signals-review`](codex/rails-37signals-review/SKILL.md) — code review and architecture auditing for 37signals-style Rails codebases. See `references/conventions.md` and `references/review-checklist.md`.

### Fizzy

This repo standardizes on a CLI-only Fizzy workflow for the hosted instance at `https://fizzy.joshyorko.com`.

Rule: use the upstream [`fizzy` CLI](https://github.com/basecamp/fizzy-cli) only. Do not fall back to raw API calls, endpoint probing, or HTML scraping.

Bootstrap the CLI with the local wrapper:

```bash
bash codex/fizzy/scripts/install.sh
```

That wrapper follows the upstream release/checksum install flow, preserves the hosted default `FIZZY_API_URL`, and prints the exact `PATH` fix when the binary lands outside the current shell path.

Once the CLI is installed, the intended flow is:

```bash
fizzy skill
fizzy setup --api-url "https://fizzy.joshyorko.com"
```

Or, for token-based setup:

```bash
export FIZZY_API_URL=https://fizzy.joshyorko.com
export FIZZY_TOKEN=fizzy_your_token_here
fizzy auth login "$FIZZY_TOKEN" --api-url "$FIZZY_API_URL"
fizzy identity show --api-url "$FIZZY_API_URL" --json | jq .
fizzy board list --api-url "$FIZZY_API_URL" --limit 5
```

Primary docs:
- [Fizzy skill](codex/fizzy/SKILL.md)
- [Fizzy install wrapper](codex/fizzy/scripts/install.sh)

### RCC

The RCC skill focuses on repeatable, isolated Python automation environments and robot scaffolding.

Use it for:
- new robot setup
- holotree-backed environment validation
- work item flows
- bundling/distribution
- hook-based setup and verification

Primary docs:
- [RCC skill](codex/rcc-skill/SKILL.md)
- [RCC installation guide](codex/rcc-skill/references/installation.md)
- [RCC reference](codex/rcc-skill/references/reference.md)
- [RCC examples](codex/rcc-skill/references/examples.md)
- [RCC work items](codex/rcc-skill/references/workitems.md)

## Quick Start

### Codex

Point Codex at the folder that matches the job:
- any `codex/37signals-*/` folder for a focused Rails pattern
- `codex/rails-37signals-implement/` for end-to-end Rails feature work
- `codex/rails-37signals-refactor/` for incremental Rails refactors
- `codex/rails-37signals-review/` for pull request review and architecture audits
- `codex/fizzy/` for Fizzy CLI workflows
- `codex/rcc-skill/` for RCC automation workflows

If you're unsure where to start on a Rails task, begin with one of the `rails-37signals-*` workflow skills and then drill into the specialist `37signals-*` folders as needed.

For Fizzy specifically, install the CLI first with:

```bash
bash codex/fizzy/scripts/install.sh
```

Then install the upstream skill from the CLI if desired:

```bash
fizzy skill
```

## License

See the relevant upstream projects and individual skill directories for licensing context.
