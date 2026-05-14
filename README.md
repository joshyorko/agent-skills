[![Bootstrap Smoke](https://github.com/joshyorko/agent-skills/actions/workflows/bootstrap-smoke.yml/badge.svg)](https://github.com/joshyorko/agent-skills/actions/workflows/bootstrap-smoke.yml)

# Agent Skills

A plugin-first skill repo for three jobs:

- `plugins/37signals/` for Rails, product design, shaping, work, and DHH judgment inspired by public 37signals/Basecamp sources
- `plugins/fizzy/` for self-hosted Fizzy workflows via the upstream CLI
- `plugins/rcc/` for RCC automation, isolated environments, and robot scaffolding

The canonical source of truth lives under `plugins/`. The repo exposes a generated top-level `skills/` view for humans and standalone installers, plus `.agents/skills/` for in-repo agent discovery.

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
│   ├── 37signals/
│   │   ├── .codex-plugin/
│   │   ├── .claude-plugin/
│   │   ├── references/
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
└── skills/  # generated standalone symlinks
```

## Skills

### 37signals

The `plugins/37signals/skills/` skills cover Rails implementation, Rails review/refactoring, product/interface design, Shape Up style shaping, REWORK-style simplification, and DHH-inspired Rails judgment. They are community-maintained, source-grounded, and not official 37signals/Basecamp guidance.

Across the set, the Rails defaults lean toward rich models, CRUD resources, Hotwire, Solid Queue, Kamal-based deployment, explicit tenancy choices, project-aware schema policy, and Minitest with fixtures where the target app already follows that stack. The product/work defaults lean toward interface-first design, epicenter design, depth over surface area, shaped appetite, calm communication, and overkill reduction.

**Primary entrypoints**

- [`37signals-implement`](plugins/37signals/skills/37signals-implement/SKILL.md) — end-to-end Rails feature implementation using the focused specialist skills.
- [`37signals-refactor`](plugins/37signals/skills/37signals-refactor/SKILL.md) — incremental, behavior-preserving Rails refactors toward 37signals-inspired conventions.
- [`37signals-review`](plugins/37signals/skills/37signals-review/SKILL.md) — Rails code review and architecture auditing through a 37signals-inspired lens.
- [`37signals-product-design`](plugins/37signals/skills/37signals-product-design/SKILL.md) — interface-first product UI, frontend flow, and product copy design.
- [`37signals-shape-up`](plugins/37signals/skills/37signals-shape-up/SKILL.md) — shaped pitches with appetite, problem, solution sketch, rabbit holes, and no-gos.
- [`37signals-rework`](plugins/37signals/skills/37signals-rework/SKILL.md) — product/team/process simplification using REWORK, Getting Real, calm-work, and scope discipline.
- [`dhh-rails-judgment`](plugins/37signals/skills/dhh-rails-judgment/SKILL.md) — DHH-inspired Rails architecture judgment around monoliths, Hotwire, omakase defaults, and conceptual compression.

**Domain, data, and tenancy**

- [`37signals-auth`](plugins/37signals/skills/37signals-auth/SKILL.md) — small Rails-native passwordless authentication with digest-only token guidance.
- [`37signals-active-record-tenanted`](plugins/37signals/skills/37signals-active-record-tenanted/SKILL.md) — separate-database multi-tenancy with Active Record Tenanted and tenant-aware Rails configuration.
- [`37signals-concerns`](plugins/37signals/skills/37signals-concerns/SKILL.md) — shared model and controller behavior via focused concerns.
- [`37signals-migration`](plugins/37signals/skills/37signals-migration/SKILL.md) — project-aware migrations with explicit tenant keys, reversible changes, and constraint policy.
- [`37signals-model`](plugins/37signals/skills/37signals-model/SKILL.md) — rich domain models with business logic, scopes, validations, and associations.
- [`37signals-multi-tenant`](plugins/37signals/skills/37signals-multi-tenant/SKILL.md) — shared-database multi-tenancy and explicit account scoping.
- [`37signals-state-records`](plugins/37signals/skills/37signals-state-records/SKILL.md) — models business state as records instead of booleans.

**Delivery, UI, and operations**

- [`37signals-api`](plugins/37signals/skills/37signals-api/SKILL.md) — REST APIs using `respond_to` blocks with Jbuilder templates.
- [`37signals-caching`](plugins/37signals/skills/37signals-caching/SKILL.md) — HTTP caching, ETags, `fresh_when`, `stale?`, and fragment caching.
- [`37signals-crud`](plugins/37signals/skills/37signals-crud/SKILL.md) — RESTful controllers built around the “everything is CRUD” philosophy.
- [`37signals-events`](plugins/37signals/skills/37signals-events/SKILL.md) — event tracking, activity feeds, and webhook-friendly event models.
- [`37signals-kamal`](plugins/37signals/skills/37signals-kamal/SKILL.md) — Kamal deployment, roles, hooks, secrets, accessories, and deploy-safe Rails runtime operations.
- [`37signals-jobs`](plugins/37signals/skills/37signals-jobs/SKILL.md) — shallow background jobs and async workflows using Solid Queue.
- [`37signals-mailer`](plugins/37signals/skills/37signals-mailer/SKILL.md) — minimal Action Mailer patterns and bundled notifications.
- [`37signals-stimulus`](plugins/37signals/skills/37signals-stimulus/SKILL.md) — focused Stimulus controllers for progressive enhancement.
- [`37signals-test`](plugins/37signals/skills/37signals-test/SKILL.md) — Minitest and fixtures for fast, readable Rails test coverage.
- [`37signals-turbo`](plugins/37signals/skills/37signals-turbo/SKILL.md) — Turbo Streams, Frames, and morphing for real-time UI updates.

The shared source-grounding reference lives at [`plugins/37signals/references/basecamp-style.md`](plugins/37signals/references/basecamp-style.md). It includes Rails, Getting Real, Shape Up, REWORK/calm-work, and DHH/Jason Fried public sources.

### Fizzy

This repo standardizes on a CLI-only Fizzy workflow for the hosted instance at `https://fizzy.joshyorko.com`.

Rule: use the installed [`fizzy` CLI](https://github.com/basecamp/fizzy-cli) only. Do not fall back to raw API calls, endpoint probing, or HTML scraping.

Install the CLI from the self-managed tap:

```bash
brew install joshyorko/tools/fizzy-cli-master
```

The formula name stays unique as `fizzy-cli-master`, but the installed executable is still `fizzy`. If you want a repo-local helper for that same Homebrew flow, use:

```bash
bash plugins/fizzy/skills/fizzy/scripts/install.sh
```

Once the CLI is installed, the intended flow is:

```bash
fizzy doctor
fizzy config show
fizzy skill
fizzy setup --api-url "https://fizzy.joshyorko.com"
```

Or, for token-based setup:

```bash
export FIZZY_API_URL=https://fizzy.joshyorko.com
export FIZZY_TOKEN=fizzy_your_token_here
fizzy auth login "$FIZZY_TOKEN" --api-url "$FIZZY_API_URL"
fizzy identity show --api-url "$FIZZY_API_URL" --markdown
fizzy board list --api-url "$FIZZY_API_URL" --limit 5 --markdown
```

Primary docs:

- [Fizzy skill](plugins/fizzy/skills/fizzy/SKILL.md)
- [Fizzy install helper](plugins/fizzy/skills/fizzy/scripts/install.sh)

### RCC

The `plugins/rcc/` distribution is split into focused RCC-family skills.

- [`rcc`](plugins/rcc/skills/rcc/SKILL.md) — router for choosing the right RCC specialist.
- [`rcc-core`](plugins/rcc/skills/rcc-core/SKILL.md) — RCC itself: CLI/source orientation, holotree/cache internals, endpoints, templates, bundles, and remote cache/client behavior.
- [`rcc-robots`](plugins/rcc/skills/rcc-robots/SKILL.md) — RCC CLI, `robot.yaml`, `conda.yaml`, holotree, templates, freezes, bundles, and environment validation.
- [`rcc-workitems`](plugins/rcc/skills/rcc-workitems/SKILL.md) — classic `robocorp.workitems`, `actions-work-items`, producer/consumer/reporter flows, local queues, and custom adapters.
- [`action-server`](plugins/rcc/skills/action-server/SKILL.md) — ordinary Action Server packages, Josh's `actions` community branch, `package.yaml` v2, `sema4ai-actions`, `sema4ai-mcp`, secrets, dev tasks, and OpenAPI/MCP checks.
- [`rcc-ci-maintenance`](plugins/rcc/skills/rcc-ci-maintenance/SKILL.md) — RCC in GitHub Actions, `ROBOCORP_HOME` caching, pinned RCC installs, scheduled maintenance robots, allowlists, and bot PR workflows.

## Quick Start

### Codex Bootstrap

Install this repo once per machine and expose its plugins/skills globally.

macOS/Linux:

```bash
curl -fsSL https://raw.githubusercontent.com/joshyorko/agent-skills/main/install.sh | bash
```

Pinned macOS/Linux install:

```bash
curl -fsSL https://raw.githubusercontent.com/joshyorko/agent-skills/main/install.sh | bash -s -- --ref v1.2.3
```

Windows (PowerShell):

```powershell
irm https://raw.githubusercontent.com/joshyorko/agent-skills/main/install.ps1 | iex
```

Pinned Windows install:

```powershell
$env:AGENT_SKILLS_REF = "v1.2.3"
irm https://raw.githubusercontent.com/joshyorko/agent-skills/main/install.ps1 | iex
```

The remote entrypoints prefer a git checkout when available and fall back to verified release archives when git is unavailable. See [docs/codex-bootstrap.md](docs/codex-bootstrap.md) for options, manual fallback, uninstall flow, and devcontainer usage.

### Build Generated Views

After editing anything under `plugins/` or `marketplaces/catalog.json`, rebuild the generated views and marketplaces:

```bash
python3 scripts/build_marketplaces.py
python3 scripts/build_runtime_views.py
bin/check
```

### Skill Views

The repo emits two generated skill views:

- `skills/` for a flat, agent-agnostic standalone view
- `.agents/skills/` for standard in-repo agent discovery
- `.agents/plugins/marketplace.json` for the repo-local Codex marketplace manifest used by the installer's Codex marketplace registration command

If you're unsure where to start, use `37signals-implement`, `37signals-refactor`, or `37signals-review` for Rails work; use `37signals-product-design`, `37signals-shape-up`, `37signals-rework`, or `dhh-rails-judgment` for product, shaping, work, or architecture judgment.

For Fizzy specifically, install the CLI first with:

```bash
brew install joshyorko/tools/fizzy-cli-master
```

Or use the repo helper for the same tap-driven install:

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

That keeps the same plugin-owned source tree usable from both generic skill tooling and Claude-style plugin ecosystems.

## License

See the relevant upstream projects and individual skill directories for licensing context.
