# Agent Skills

A focused set of Codex skills for three jobs:
- `codex/fizzy/` for self-hosted Fizzy workflows via the upstream CLI
- `codex/frontend-skill/` for 37signals-influenced frontend direction with GPT-5.x/Codex
- `codex/rcc-skill/` for RCC automation, isolated environments, and robot scaffolding

## Structure

```text
agent-skills/
├── README.md
└── codex/
    ├── fizzy/
    │   ├── SKILL.md
    │   ├── agents/
    │   └── scripts/
    ├── frontend-skill/
    │   ├── SKILL.md
    │   ├── agents/
    │   └── assets/
    └── rcc-skill/
        ├── SKILL.md
        ├── agents/
        ├── assets/
        ├── references/
        └── scripts/
```

## Skills

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

### Frontend Skill

The frontend skill is for visually led landing pages, app surfaces, dashboards, and prototypes where composition, hierarchy, copy, imagery, and motion matter more than component count.

Its current direction is:
- OpenAI GPT-5.4 frontend guidance first: low/medium reasoning, constraints, mood boards, narrative structure, and browser verification
- 37signals taste as the second layer: interface first, epicenter design, real words, less chrome, fewer cards
- Codex-specific execution: use provided images first, generate multiple mood directions when needed, inspect real layouts, and avoid generic SaaS fallback composition

Primary docs:
- [Frontend skill](codex/frontend-skill/SKILL.md)
- [Frontend agent prompt](codex/frontend-skill/agents/openai.yaml)
- [Frontend mood assets](codex/frontend-skill/assets/)

The bundled reference set now includes four interface-led fallback boards:
- Basecamp alpine calm
- HEY letterpress color pop
- Campfire warmth at night
- Fizzy editorial kanban

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

Point Codex at one or more of these skill folders:
- `codex/fizzy/`
- `codex/frontend-skill/`
- `codex/rcc-skill/`

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
