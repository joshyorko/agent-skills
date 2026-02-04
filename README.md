# Agent Skills

A collection of RCC (Repeatable, Contained Code) skills for AI coding agents. These skills enable Claude and Codex agents to create, manage, and distribute self-contained Python automation packages with isolated environments.

## Structure

```
agent-skills/
├── claude/rcc/          # RCC skill for Claude Code
│   ├── SKILL.md         # Skill definition with hooks
│   ├── robot.yaml       # RCC task configuration
│   ├── conda.yaml       # Environment specification
│   ├── hooks/           # Claude Code hook scripts
│   ├── scripts/         # Validation utilities
│   └── templates/       # Reference conda.yaml configs
│
├── copilot/rcc/         # RCC skill for GitHub Copilot agents
│   ├── SKILL.md         # Skill definition
│   ├── assets/          # Templates and starter files
│   ├── references/      # Documentation
│   └── scripts/         # Utilities
│
└── codex/rcc-skill/     # RCC skill for OpenAI Codex
    ├── SKILL.md         # Skill definition
    ├── agents/          # Agent configurations
    ├── assets/          # Templates and hook configs
    ├── references/      # Documentation
    └── scripts/         # Utilities and hooks
```

## Features

- **Isolated Environments**: Create Python environments without requiring Python on target machines
- **Holotree Caching**: Content-addressed storage for efficient environment deduplication
- **Work Items**: Producer-consumer patterns for batch processing
- **Self-Contained Bundles**: Single-file executables for distribution
- **Hook Integration**: Pre/post task hooks for validation and setup

## Prerequisites

- [RCC CLI](https://github.com/joshyorko/rcc) - Install via Homebrew:
  ```bash
  brew install --cask joshyorko/tools/rcc
  ```

## Quick Start

### Claude Code

1. Copy the `claude/rcc/` directory to your project's `.claude/skills/` folder
2. The skill will auto-initialize on session start via hooks
3. Use natural language to create and manage RCC robots

### GitHub Copilot

1. Copy `copilot/rcc/` to your project's `.github/skills/rcc/` folder
2. Commit the skill so Copilot agents can load it from the repository
3. Use natural language to plan and execute RCC workflows

### Codex

1. Reference the `codex/rcc-skill/` skill in your Codex agent configuration
2. Templates are available in `assets/templates/`
3. Documentation is in `references/`

## Common Commands

| Command | Purpose |
|---------|---------|
| `rcc robot init -t <template> -d <dir>` | Create new robot |
| `rcc ht vars -r robot.yaml` | Build/verify environment |
| `rcc run --task "Task Name" --silent` | Run specific task |
| `rcc task shell` | Interactive shell in environment |
| `rcc configure diagnostics` | System diagnostics |

## Templates Available

- `conda.yaml` - Minimal Python environment
- `conda-api.yaml` - API automation with requests
- `conda-browser.yaml` - Browser automation with Playwright
- `conda-data.yaml` - Data processing with pandas
- `conda-workitems.yaml` - Work item processing

## Documentation

- [Installation Guide](codex/rcc-skill/references/installation.md)
- [Command Reference](codex/rcc-skill/references/reference.md)
- [Examples & Recipes](codex/rcc-skill/references/examples.md)
- [Work Items](codex/rcc-skill/references/workitems.md)
- [Deployment Patterns](codex/rcc-skill/references/deployment.md)

## License

See individual skill directories for licensing information.
