# Agent Skills

A collection of skills for AI coding agents. Includes RCC (Repeatable, Contained Code) automation skills and Fizzy project management support for the hosted instance at `https://fizzy.joshyorko.com`. Fizzy operations use the direct HTTP API as the primary path; the optional [Fizzy CLI](https://github.com/basecamp/fizzy-cli) is a convenience layer when the binary is confirmed installed.

## Structure

```
agent-skills/
├── claude/
│   ├── fizzy/           # Fizzy CLI skill for Claude Code
│   │   ├── SKILL.md     # Skill definition (Basecamp fizzy CLI)
│   │   └── scripts/     # install.sh
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
    │   ├── SKILL.md     # Skill definition (Basecamp fizzy CLI)
    │   ├── agents/      # Agent configuration
    │   └── scripts/     # install.sh
    └── rcc-skill/       # RCC skill for OpenAI Codex
        ├── SKILL.md     # Skill definition
        ├── agents/      # Agent configurations
        ├── assets/      # Templates and hook configs
        ├── references/  # Documentation
        └── scripts/     # Utilities and hooks
```

## Skills

### Fizzy

Manage Fizzy boards, cards, columns, comments, and steps on the hosted instance at `https://fizzy.joshyorko.com`.

**Primary path — direct HTTP API (validated):**
```bash
export FIZZY_TOKEN="your_token"
export FIZZY_BASE="https://fizzy.joshyorko.com"
# Identity
curl -s -H "Authorization: Bearer $FIZZY_TOKEN" "$FIZZY_BASE/my/identity" | jq .
# List boards
curl -s -H "Authorization: Bearer $FIZZY_TOKEN" "$FIZZY_BASE/boards.json" | jq '[.[] | {id, name}]'
```

**Optional CLI (use only when binary is confirmed installed):**
```bash
bash claude/fizzy/scripts/install.sh   # Claude Code
bash codex/fizzy/scripts/install.sh   # Codex
fizzy setup                            # Interactive token setup
fizzy board list
fizzy card list --board BOARD_ID
```

See the [Fizzy skill](codex/fizzy/SKILL.md) for the full validation matrix and API reference.

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
- [Fizzy Skill & Validation Matrix](codex/fizzy/SKILL.md)
- [Fizzy CLI Repository](https://github.com/basecamp/fizzy-cli) (optional binary)

## License

See individual skill directories for licensing information.
