---
name: rcc
description: Use when asked to create, run, debug, package, or review RCC robots, Robocorp automation, Action Server/Sema4AI action packages, MCP tools, work items, adapters, templates, or validation workflows.
---

# RCC

Use this skill when a task touches:
- RCC commands, holotree environments, `robot.yaml`, `conda.yaml`, freezes, bundles, or RCC remote caches.
- Robocorp Python robots using `robocorp.tasks`, `robocorp.browser`, `robocorp.workitems`, vault, storage, or RPA Framework Assistant.
- Sema4AI Action Server packages using `package.yaml`, `sema4ai-actions`, `sema4ai-mcp`, OpenAPI, MCP, secrets, or dev tasks.
- Producer/consumer work item flows, `actions-work-items`, custom adapters, SQLite/file/local queues, Redis, DocumentDB, or Yorko Control Room adapters.

## First Inspection

1. Locate the robot or action package root. Prefer the directory containing `robot.yaml`, `conda.yaml`, `package.yaml`, or `pyproject.toml`.
2. Inspect config before code: `robot.yaml`, `conda.yaml`, `package.yaml`, `devdata/*.json`, `.gitignore`, and any `environment_*_freeze.yaml` files.
3. Inspect task/action entry points next: `tasks.py`, `actions.py`, `src/**`, `scripts/**`, work item producer/consumer/reporter files, and adapter setup.
4. Check available validation scripts: this skill ships `scripts/env_check.py`, `scripts/validate_robot.py`, and hook helpers under `scripts/hooks/`.

## Operating Rules

- Prebuild or inspect environments with `rcc ht vars -r robot.yaml` before assuming a Python/package bug.
- Separate RCC environment failures from Python runtime failures: RCC/holotree problems happen before the task command starts; Python failures happen inside the command listed in `robot.yaml`.
- Prefer `environmentConfigs` with platform freeze files before `conda.yaml` when reproducibility matters.
- Use `ROBOT_ROOT` and `ROBOT_ARTIFACTS` for raw path resolution; in `robocorp.tasks`, prefer `get_output_dir()` and `get_current_task()`.
- For package pins, verify PyPI or the owning source before bumping. If you update shared template pins such as `uv`, update all RCC templates consistently.
- Treat `skills/` and `.agents/skills/` as generated views; edit the canonical plugin files only.

## References

- `references/source-map.md`: inspected repos/docs and what each source supports.
- `references/rcc-command-recipes.md`: RCC commands, `robot.yaml`, `conda.yaml`, holotree, `ROBOCORP_HOME`, `RCC_REMOTE_ORIGIN`, CI cache hygiene.
- `references/robot-project-recipes.md`: Josh robot template names, Python/browser/work item/UV-native patterns, template index/release behavior.
- `references/action-server-sema4ai-recipes.md`: Josh `actions` fork, `package.yaml` v2, OpenAPI/MCP, secrets, tests, dev tasks.
- `references/workitems-adapters.md`: classic `robocorp.workitems`, `actions-work-items`, adapter contracts, SQLite/file/local queue semantics.
- `references/troubleshooting-validation.md`: playbooks for env/package failures, locks/cache/network, and pre-commit verification.
- `references/agent-prompt-examples.md`: short prompts future Codex agents can reuse.

## Templates And Scripts

- Robot templates live in `assets/templates/`.
- HITL Assistant + work item starter lives in `assets/templates/hitl-assistant/`.
- Optional Claude hook assets live in `assets/claude-hooks/`; use only when mirroring Claude Code hook behavior.
- Run `python3 scripts/validate_robot.py path/to/robot.yaml` for static robot config validation when PyYAML is available.
- Run `python3 scripts/env_check.py --skip-network` for a quick local RCC/project health check.
