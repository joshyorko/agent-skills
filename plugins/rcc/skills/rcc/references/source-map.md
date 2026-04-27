# Source Map

This file records the sources inspected for the 2026-04-27 RCC skill refresh and what each source supports. Recheck sources before making new "latest" or version-current claims.

## Josh Repositories

- `https://github.com/joshyorko/rcc.git`
  - Research checkout: `/tmp/agent-skills-rcc-research/rcc`
  - Branch/commit inspected: `main` / `2e0e309`
  - Supports RCC command names, `robot.yaml`/`conda.yaml` recipes, holotree commands, bundles, diagnostics, uv-native examples, and RCC remote client commands.

- `https://github.com/joshyorko/actions.git`
  - Research checkout: `/tmp/agent-skills-rcc-research/actions`
  - Branch/commit inspected: `community` / `7e63577`
  - Supports Action Server community source build commands, `package.yaml` v2 examples, Sema4AI action/MCP docs, `actions-work-items`, workflow producer/consumer templates, and frontend community build notes.

- `https://github.com/joshyorko/robot-templates.git`
  - Research checkout: `/tmp/agent-skills-rcc-research/robot-templates`
  - Branch/commit inspected: `main` / `487cdfc`
  - Supports template names and patterns for minimal Python, browser, work items, Assistant AI, Action Server work items, uv-native, and maintenance robot workflows.

- `https://github.com/joshyorko/robocorp_adapters_custom.git`
  - Research checkout: `/tmp/agent-skills-rcc-research/robocorp_adapters_custom`
  - Branch/commit inspected: `main` / `1bfb81c`
  - Supports custom adapter class names, env variables, SQLite/Redis/DocumentDB/Yorko Control Room behavior, Fizzy orchestration helpers, and adapter tests.

- `https://github.com/joshyorko/rccremote-docker.git`
  - Research checkout: `/tmp/agent-skills-rcc-research/rccremote-docker`
  - Branch/commit inspected: `self-hosted` / `b265fbc`
  - Supports RCC remote deployment/client orientation and `RCC_REMOTE_ORIGIN` usage.

## Optional Repository Probe

- `https://github.com/joshyorko/robocorp-action-server041.git`
  - Probe result: unavailable/private during this run.
  - Recorded at: `/tmp/agent-skills-rcc-research/OPTIONAL-UNAVAILABLE.txt`.
  - Not used as a blocking source.

## Official Docs Fetched

Fetched into `/tmp/agent-skills-rcc-research/official-docs/`.

- `https://raw.githubusercontent.com/Sema4AI/actions/master/action_server/docs/guides/00-startup-command-line.md`
  - Supports Action Server startup/import/start behavior.
- `https://raw.githubusercontent.com/Sema4AI/actions/master/action_server/docs/guides/01-package-yaml.md`
  - Supports `package.yaml` v2 structure.
- `https://raw.githubusercontent.com/Sema4AI/actions/master/action_server/docs/guides/07-secrets.md`
  - Supports Action Server/Sema4AI secret handling.
- `https://raw.githubusercontent.com/Sema4AI/actions/master/action_server/docs/guides/14-dev-tasks.md`
  - Supports package dev task examples.
- `https://raw.githubusercontent.com/Sema4AI/actions/master/actions/docs/api/sema4ai.actions.md`
  - Supports `@action`, `Response`, `Secret`, `OAuth2Secret`, and action runtime API usage.
- `https://raw.githubusercontent.com/Sema4AI/actions/master/mcp/docs/api/sema4ai.mcp.md`
  - Supports `@tool`, `@resource`, and `@prompt`.
- `https://raw.githubusercontent.com/robocorp/robocorp/master/tasks/README.md`
  - Supports `robocorp.tasks` usage and task runtime positioning.
- `https://raw.githubusercontent.com/robocorp/robocorp/master/workitems/README.md`
  - Supports classic `robocorp.workitems` usage.
- `https://raw.githubusercontent.com/robocorp/robocorp/master/browser/README.md`
  - Supports `robocorp.browser` package positioning.

The RPA Framework Assistant raw docs URL tried during the run returned 404. Assistant guidance therefore uses Josh template/repo evidence and PyPI package metadata, not a fetched Assistant docs page.

## PyPI Metadata Fetched

Fetched JSON files are under `/tmp/agent-skills-rcc-research/official-docs/pypi-*.json`.

- `uv`: `0.11.8`
- `robocorp`: `3.1.1`
- `robocorp-tasks`: `4.1.1`
- `robocorp-workitems`: `1.5.0`
- `robocorp-browser`: `2.4.0`
- `rpaframework`: `31.2.0`
- `rpaframework-assistant`: `5.0.0`
- `sema4ai-actions`: `1.6.6`
- `sema4ai-action-server`: `3.2.0`
- `sema4ai-mcp`: `0.0.3`
- `actions-work-items`: `0.2.1`
- `robocorp-adapters-custom`: `0.1.5`
