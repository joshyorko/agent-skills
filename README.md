# Agent Skills

A plugin-first skill repo for four jobs:

- `plugins/rails-37signals-patterns/` for focused 37signals-style Rails specialists
- `plugins/rails-37signals-workflows/` for workflow-level Rails implementation, refactoring, and review
- `plugins/fizzy/` for self-hosted Fizzy workflows via the upstream CLI
- `plugins/rcc/` for RCC automation, isolated environments, and robot scaffolding

The canonical source of truth now lives under `plugins/`. The old `codex/` tree and `.agents/skills/` are generated compatibility views made of symlinks back into those canonical plugin-owned skills.

## Structure

```text
agent-skills/
├── AGENTS.md
├── README.md
├── .agents/
│   ├── plugins/
│   │   └── marketplace.json
│   └── skills/
├── .claude-plugin/
│   └── marketplace.json
├── marketplaces/
│   └── catalog.json
├── plugins/
│   ├── rails-37signals-patterns/
│   │   ├── .codex-plugin/
│   │   ├── .claude-plugin/
│   │   └── skills/
│   ├── rails-37signals-workflows/
│   │   ├── .codex-plugin/
│   │   ├── .claude-plugin/
│   │   └── skills/
│   ├── fizzy/
│   │   ├── .codex-plugin/
│   │   ├── .claude-plugin/
│   │   └── skills/
│   └── rcc/
│       ├── .codex-plugin/
│       ├── .claude-plugin/
│       └── skills/
├── scripts/
│   ├── build_marketplaces.py
│   ├── build_runtime_views.py
│   └── validate_repo.py
└── codex/  # generated compatibility symlinks
```

## Skills

### Rails 37signals Patterns

The `plugins/rails-37signals-patterns/skills/37signals-*` skills cover focused Rails patterns and conventions inspired by 37signals-style applications. Across the set, the defaults lean toward rich models, CRUD resources, Hotwire, Solid Queue, explicit `Current.account` scoping, UUID-backed schemas, and Minitest with fixtures.

**Architecture and workflow**

- [`37signals-implement`](plugins/rails-37signals-patterns/skills/37signals-implement/SKILL.md) — orchestrates complete Rails feature work across the specialist skills.
- [`37signals-refactoring`](plugins/rails-37signals-patterns/skills/37signals-refactoring/SKILL.md) — orchestrates incremental refactors toward 37signals Rails patterns.
- [`37signals-review`](plugins/rails-37signals-patterns/skills/37signals-review/SKILL.md) — reviews Rails code for convention alignment, CRUD shape, model design, and Hotwire fit.

**Domain, data, and tenancy**

- [`37signals-auth`](plugins/rails-37signals-patterns/skills/37signals-auth/SKILL.md) — custom passwordless authentication without Devise.
- [`37signals-concerns`](plugins/rails-37signals-patterns/skills/37signals-concerns/SKILL.md) — shared model and controller behavior via focused concerns.
- [`37signals-migration`](plugins/rails-37signals-patterns/skills/37signals-migration/SKILL.md) — UUID-first, account-scoped migrations without foreign key constraints.
- [`37signals-model`](plugins/rails-37signals-patterns/skills/37signals-model/SKILL.md) — rich domain models with business logic, scopes, validations, and associations.
- [`37signals-multi-tenant`](plugins/rails-37signals-patterns/skills/37signals-multi-tenant/SKILL.md) — URL-based multi-tenancy and explicit account scoping.
- [`37signals-state-records`](plugins/rails-37signals-patterns/skills/37signals-state-records/SKILL.md) — models business state as records instead of booleans.

**Delivery, UI, and operations**

- [`37signals-api`](plugins/rails-37signals-patterns/skills/37signals-api/SKILL.md) — REST APIs using `respond_to` blocks with Jbuilder templates.
- [`37signals-caching`](plugins/rails-37signals-patterns/skills/37signals-caching/SKILL.md) — HTTP caching, ETags, `fresh_when`, `stale?`, and fragment caching.
- [`37signals-crud`](plugins/rails-37signals-patterns/skills/37signals-crud/SKILL.md) — RESTful controllers built around the “everything is CRUD” philosophy.
- [`37signals-events`](plugins/rails-37signals-patterns/skills/37signals-events/SKILL.md) — event tracking, activity feeds, and webhook-friendly event models.
- [`37signals-jobs`](plugins/rails-37signals-patterns/skills/37signals-jobs/SKILL.md) — shallow background jobs and async workflows using Solid Queue.
- [`37signals-mailer`](plugins/rails-37signals-patterns/skills/37signals-mailer/SKILL.md) — minimal Action Mailer patterns and bundled notifications.
- [`37signals-stimulus`](plugins/rails-37signals-patterns/skills/37signals-stimulus/SKILL.md) — focused Stimulus controllers for progressive enhancement.
- [`37signals-test`](plugins/rails-37signals-patterns/skills/37signals-test/SKILL.md) — Minitest and fixtures for fast, readable Rails test coverage.
- [`37signals-turbo`](plugins/rails-37signals-patterns/skills/37signals-turbo/SKILL.md) — Turbo Streams, Frames, and morphing for real-time UI updates.

These specialist skills preserve source metadata in their frontmatter and were adapted from the broader `rails_ai_agents` 37signals pattern set.

### Rails 37signals Workflows

The `plugins/rails-37signals-workflows/skills/rails-37signals-*` folders are standalone workflow skills for common Rails jobs, not just aliases. Each one includes an `agents/openai.yaml` file plus a focused `references/` set.

- [`rails-37signals-implement`](plugins/rails-37signals-workflows/skills/rails-37signals-implement/SKILL.md) — end-to-end feature implementation in dependency order. See `references/conventions.md` and `references/implementation-workflow.md`.
- [`rails-37signals-refactor`](plugins/rails-37signals-workflows/skills/rails-37signals-refactor/SKILL.md) — incremental, behavior-preserving refactors toward 37signals conventions. See `references/conventions.md` and `references/refactoring-guide.md`.
- [`rails-37signals-review`](plugins/rails-37signals-workflows/skills/rails-37signals-review/SKILL.md) — code review and architecture auditing for 37signals-style Rails codebases. See `references/conventions.md` and `references/review-checklist.md`.

### Fizzy

This repo standardizes on a CLI-only Fizzy workflow for the hosted instance at `https://fizzy.joshyorko.com`.

Rule: use the upstream [`fizzy` CLI](https://github.com/basecamp/fizzy-cli) only. Do not fall back to raw API calls, endpoint probing, or HTML scraping.

Bootstrap the CLI with the local wrapper:

```bash
bash plugins/fizzy/skills/fizzy/scripts/install.sh
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

- [Fizzy skill](plugins/fizzy/skills/fizzy/SKILL.md)
- [Fizzy install wrapper](plugins/fizzy/skills/fizzy/scripts/install.sh)

### RCC

The RCC skill focuses on repeatable, isolated Python automation environments and robot scaffolding.

Use it for:

- new robot setup
- holotree-backed environment validation
- work item flows
- bundling/distribution
- hook-based setup and verification

Primary docs:

- [RCC skill](plugins/rcc/skills/rcc/SKILL.md)
- [RCC installation guide](plugins/rcc/skills/rcc/references/installation.md)
- [RCC reference](plugins/rcc/skills/rcc/references/reference.md)
- [RCC examples](plugins/rcc/skills/rcc/references/examples.md)
- [RCC work items](plugins/rcc/skills/rcc/references/workitems.md)

## Quick Start

### Build Generated Views

After editing anything under `plugins/` or `marketplaces/catalog.json`, rebuild the generated compatibility views and marketplaces:

```bash
python3 scripts/build_marketplaces.py
python3 scripts/build_runtime_views.py
bin/check
```

### Codex Compatibility

Codex can still use the generated compatibility directories:

- `codex/` for the legacy flat skill view
- `.agents/skills/` for standard Codex skill discovery
- `.agents/plugins/marketplace.json` for local Codex plugin installation

If you're unsure where to start on a Rails task, begin with one of the `rails-37signals-*` workflow skills and then drill into the specialist `37signals-*` skills as needed.

For Fizzy specifically, install the CLI first with:

```bash
bash plugins/fizzy/skills/fizzy/scripts/install.sh
```

Then install the upstream skill from the CLI if desired:

```bash
fizzy skill
```

### Claude Compatibility

The repo now also emits Claude-compatible marketplace metadata:

- `.claude-plugin/marketplace.json`
- `plugins/*/.claude-plugin/plugin.json`

That keeps the same plugin-owned source tree usable from both Codex and Claude-style plugin ecosystems.

## License

See the relevant upstream projects and individual skill directories for licensing context.
