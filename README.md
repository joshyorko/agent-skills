# Agent Skills

A collection of skills for AI coding agents. Includes RCC (Repeatable, Contained Code) automation skills and a Fizzy HTTP API skill for managing boards, cards, and more on the self-hosted Fizzy instance at `https://fizzy.joshyorko.com`.

## Structure

```
agent-skills/
├── claude/
│   ├── fizzy/           # Fizzy HTTP API skill for Claude Code
│   │   ├── SKILL.md     # Skill definition (direct HTTP API)
│   │   └── scripts/     # install.sh (token setup + connectivity check)
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
    ├── fizzy/           # Fizzy HTTP API skill for OpenAI Codex
    │   ├── SKILL.md     # Skill definition (direct HTTP API)
    │   ├── agents/      # Agent configuration
    │   └── scripts/     # install.sh (token setup + connectivity check)
    └── rcc-skill/       # RCC skill for OpenAI Codex
        ├── SKILL.md     # Skill definition
        ├── agents/      # Agent configurations
        ├── assets/      # Templates and hook configs
        ├── references/  # Documentation
        └── scripts/     # Utilities and hooks
```

## Skills

### Fizzy HTTP API

Manage Fizzy boards, cards, columns, comments, steps, and more via the [Fizzy HTTP API](https://fizzy.joshyorko.com). The supported method for this self-hosted instance is direct HTTP calls with a Bearer token — no CLI binary is required or validated for self-hosted use.

> **Note:** The `basecamp/fizzy-cli` binary hardcodes `https://app.fizzy.do` and does not work with `https://fizzy.joshyorko.com`. The `@raw-works/fizzy-cli` npm package requires `bun` and is not validated here. **Use the HTTP API directly.**

Configure your token:
```bash
export FIZZY_TOKEN=fizzy_your_token_here
export FIZZY_API_URL=https://fizzy.joshyorko.com
```

Verify authentication:
```bash
curl -s -H "Authorization: Bearer $FIZZY_TOKEN" $FIZZY_API_URL/my/identity | jq .
```

Or use the bundled setup script (verifies connectivity):
```bash
export FIZZY_TOKEN=fizzy_your_token_here
bash claude/fizzy/scripts/install.sh   # Claude Code
bash codex/fizzy/scripts/install.sh   # Codex
```

**Validated endpoints:**

| Method | Path | Description |
|--------|------|-------------|
| `GET`  | `/my/identity` | Authenticate / identity discovery |
| `GET`  | `/1/boards` | List boards |
| `POST` | `/1/boards` | Create a board |
| `POST` | `/1/boards/:board_id/columns` | Create a column |
| `POST` | `/1/boards/:board_id/cards` | Create a card |
| `POST` | `/1/cards/:card_number/triage` | Move card to triage |

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

1. Reference `codex/fizzy/` or `codex/rcc-skill/` in your Codex agent configuration
2. RCC templates are available in `codex/rcc-skill/assets/templates/`

## RCC Common Commands

| Command | Purpose |
|---------|---------|
| `rcc robot init -t <template> -d <dir>` | Create new robot |
| `rcc ht vars -r robot.yaml` | Build/verify environment |
| `rcc run --task "Task Name" --silent` | Run specific task |
| `rcc task shell` | Interactive shell in environment |
| `rcc configure diagnostics` | System diagnostics |

## Documentation

- [RCC Installation Guide](codex/rcc-skill/references/installation.md)
- [RCC Command Reference](codex/rcc-skill/references/reference.md)
- [RCC Examples & Recipes](codex/rcc-skill/references/examples.md)
- [RCC Work Items](codex/rcc-skill/references/workitems.md)
- [RCC Deployment Patterns](codex/rcc-skill/references/deployment.md)
- [Fizzy HTTP API Skill (Codex)](codex/fizzy/SKILL.md)
- [Fizzy HTTP API Skill (Claude)](claude/fizzy/SKILL.md)

## License

See individual skill directories for licensing information.
