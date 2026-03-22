# Agent Skills

A collection of skills for AI coding agents. Includes RCC (Repeatable, Contained Code) automation skills and a Fizzy CLI skill for managing boards, cards, and more on the self-hosted Fizzy instance at `https://fizzy.joshyorko.com`.

## Structure

```
agent-skills/
├── claude/
│   ├── fizzy/           # Fizzy CLI skill for Claude Code
│   │   ├── SKILL.md     # Skill definition (CLI-only workflow)
│   │   └── scripts/     # install.sh (CLI install + setup verification)
│   └── rcc/             # RCC skill for Claude Code
│       ├── SKILL.md     # Skill definition with hooks
│       ├── robot.yaml   # RCC task configuration
│       ├── conda.yaml   # Environment specification
│       ├── hooks/       # Claude Code hook scripts
│       ├── scripts/     # Validation utilities
│       └── templates/   # Reference conda.yaml configs
│
├── copilot/rcc/         # RCC skill for GitHub Copilot agents
│   ├── SKILL.md         # Skill definition
│   ├── assets/          # Templates and starter files
│   ├── references/      # Documentation
│   └── scripts/         # Utilities
│
└── codex/
    ├── fizzy/           # Fizzy CLI skill for OpenAI Codex
    │   ├── SKILL.md     # Skill definition (CLI-only workflow)
    │   ├── agents/      # Agent configuration
    │   └── scripts/     # install.sh (CLI install + setup verification)
    ├── frontend-skill/  # Frontend design skill for Codex
    │   ├── SKILL.md     # Design guidance and guardrails
    │   └── agents/      # Agent configuration
    └── rcc-skill/       # RCC skill for OpenAI Codex
        ├── SKILL.md     # Skill definition
        ├── agents/      # Agent configurations
        ├── assets/      # Templates and hook configs
        ├── references/  # Documentation
        └── scripts/     # Utilities and hooks
```

## Skills

### Fizzy CLI

Manage Fizzy boards, cards, columns, comments, steps, and more via the upstream [`fizzy` CLI](https://github.com/basecamp/fizzy-cli). This repo standardizes on a **CLI-only** workflow for the self-hosted instance at `https://fizzy.joshyorko.com`.

> **Rule:** Agents must use the `fizzy` CLI only. Do **not** call the HTTP API directly, inspect raw endpoints, or scrape the app HTML as a fallback.

The bundled setup scripts install the official upstream binary from GitHub releases using the current asset names (`fizzy-linux-amd64`, `fizzy-darwin-arm64`, and so on), then walk you through self-hosted CLI setup.

Bootstrap the CLI:

```bash
export FIZZY_API_URL=https://fizzy.joshyorko.com
bash claude/fizzy/scripts/install.sh   # Claude Code
bash codex/fizzy/scripts/install.sh    # Codex / global agents
```

Authenticate and verify access:

```bash
export FIZZY_TOKEN=fizzy_your_token_here
fizzy auth login "$FIZZY_TOKEN" --api-url "$FIZZY_API_URL"
fizzy identity show --api-url "$FIZZY_API_URL" --json | jq .
fizzy board list --api-url "$FIZZY_API_URL" --limit 5
```

Or use the interactive wizard:

```bash
fizzy setup --api-url "$FIZZY_API_URL"
```

### RCC

Create and run self-contained Python automation robots with isolated environments and holotree caching.

- **Isolated Environments**: Create Python environments without requiring Python on target machines
- **Holotree Caching**: Content-addressed storage for efficient environment deduplication
- **Work Items**: Producer-consumer patterns for batch processing
- **Self-Contained Bundles**: Single-file executables for distribution
- **Hook Integration**: Pre/post task hooks for validation and setup

Prerequisites — [RCC CLI](https://github.com/joshyorko/rcc):

```bash
brew install --cask joshyorko/tools/rcc
```

## Quick Start

### Claude Code

1. Copy `claude/fizzy/` to your project's `.claude/skills/fizzy/` folder for Fizzy support
2. Copy `claude/rcc/` to your project's `.claude/skills/rcc/` folder for RCC support
3. The RCC skill will auto-initialize on session start via hooks

### GitHub Copilot

1. Copy `copilot/rcc/` to your project's `.github/skills/rcc/` folder
2. Commit the skill so Copilot agents can load it from the repository

### Codex

1. Reference `codex/fizzy/`, `codex/frontend-skill/`, or `codex/rcc-skill/` in your Codex agent configuration
2. Use `codex/frontend-skill/` for 37signals-inspired frontend guidance, `codex/fizzy/` for Fizzy CLI workflows, and `codex/rcc-skill/` for RCC automation.
3. RCC templates are available in `codex/rcc-skill/assets/templates/`

## RCC Common Commands

| Command                                 | Purpose                          |
| --------------------------------------- | -------------------------------- |
| `rcc robot init -t <template> -d <dir>` | Create new robot                 |
| `rcc ht vars -r robot.yaml`             | Build/verify environment         |
| `rcc run --task "Task Name" --silent`   | Run specific task                |
| `rcc task shell`                        | Interactive shell in environment |
| `rcc configure diagnostics`             | System diagnostics               |

## Documentation

- [RCC Installation Guide](codex/rcc-skill/references/installation.md)
- [RCC Command Reference](codex/rcc-skill/references/reference.md)
- [RCC Examples & Recipes](codex/rcc-skill/references/examples.md)
- [RCC Work Items](codex/rcc-skill/references/workitems.md)
- [RCC Deployment Patterns](codex/rcc-skill/references/deployment.md)
- [Fizzy CLI Skill (Codex)](codex/fizzy/SKILL.md)
- [Frontend Skill (Codex)](codex/frontend-skill/SKILL.md)
- [Fizzy CLI Skill (Claude)](claude/fizzy/SKILL.md)

## License

See individual skill directories for licensing information.
