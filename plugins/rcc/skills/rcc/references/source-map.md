# Source Map

This file records the sources inspected for the 2026-04-27 RCC skill refresh and what each source supports. Recheck sources before making new "latest" or version-current claims.

## Josh Repositories

- `https://github.com/joshyorko/agent-skills`
  - Branch/commit inspected: `main` / `d9c6289`
  - Supports RCC plugin/skill layout, generated runtime symlink views, marketplace metadata flow, and repository validation rules.

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

- `https://github.com/joshyorko/fetch-repos-bot.git`
  - Research checkout: `/tmp/rcc-public-examples/fetch-repos-bot`
  - Branch/commit inspected: `main` / `1531c178`
  - Supports full producer/consumer/reporter robot shape, role-specific adapter env files, Assistant task, sharded consumers, SQLite/Redis/DocumentDB/Yorko queue recipes, and operational recovery scripts.

- `https://github.com/joshyorko/fizzy-symphony.git`
  - Research checkout: `/tmp/rcc-public-examples/fizzy-symphony`
  - Branch/commit inspected: `main` / `6685376e`
  - Supports RCC diagnostic dev task patterns such as `Doctor`, work item env printing, SQLite smoke runs, contract/parity robot tests, and hosted-smoke style validation.

- `https://github.com/joshyorko/robocorp_adapters_custom.git`
  - Research checkout: `/tmp/agent-skills-rcc-research/robocorp_adapters_custom`
  - Branch/commit inspected: `main` / `1bfb81c`
  - Supports custom adapter class names, env variables, SQLite/Redis/DocumentDB/Yorko Control Room behavior, Fizzy orchestration helpers, and adapter tests.

- `https://github.com/joshyorko/rccremote-docker.git`
  - Research checkout: `/tmp/agent-skills-rcc-research/rccremote-docker`
  - Branch/commit inspected: `self-hosted` / `b265fbc`
  - Supports RCC remote deployment/client orientation and `RCC_REMOTE_ORIGIN` usage.

- `https://github.com/joshyorko/actions-robot-boostrapper.git`
  - Research checkout: `/tmp/rcc-public-examples/actions-robot-boostrapper`
  - Branch/commit inspected: `main` / `2769fb7a`
  - Supports Action Server packages that wrap `action-server` and `rcc` subprocess operations.

- `https://github.com/joshyorko/home-lab-actions.git`
  - Research checkout: `/tmp/rcc-public-examples/home-lab-actions`
  - Branch/commit inspected: `main` / `88d0786d`
  - Supports typed response models, Kubernetes client actions, and `@action(is_consequential=False)` examples.

- `https://github.com/joshyorko/linkedin-easy-apply.git`
  - Research checkout: `/tmp/rcc-public-examples/linkedin-easy-apply`
  - Branch/commit inspected: `main` / `1c620080`
  - Supports modern `package.yaml` v2 fields: `external-endpoints`, `post-install`, `dev-dependencies`, multi-line `dev-tasks`, database/browser dependencies, and packaging excludes.

- `https://github.com/joshyorko/yo-dawg.git`
  - Research checkout: `/tmp/rcc-public-examples/yo-dawg`
  - Branch/commit inspected: `main` / `fdaf7422`
  - Supports browser/action packages with `ActionError`, `Response`, dotenv/env development handling, and packaging excludes.

- `https://github.com/joshyorko/robocorp-action-server041.git`
  - Research checkout: `/tmp/agent-skills-rcc-research/robocorp-action-server041`
  - Branch/commit inspected: `main` / `2c860cc`
  - Optional probe result: available during this run.
  - Supports historical Robocorp/Action Server 0.4.1 source orientation only; do not use it for current-version claims.

- `https://github.com/joshyorko/room-of-requirement.git`
  - Research checkout: `/tmp/agent-skills-room-of-requirement`
  - Branch/commit inspected: `main` / `a7e00e632865e0af434c78b7da809f2c07420fe7`
  - Supports RCC maintenance robot structure, scheduled GitHub Actions pattern, pinned RCC install, `ROBOCORP_HOME` cache key, telemetry disable, no-cache commit guard, allowlist strategy, and maintenance report artifact behavior.

- `https://github.com/joshyorko/homebrew-tools.git`
  - Research checkout: `/tmp/rcc-public-examples/homebrew-tools`
  - Branch/commit inspected: `main` / `f3d5a44`
  - Supports maintenance robot reuse in a real repository and Josh Homebrew tap context for Linux-friendly RCC/Action Server installation.

- `https://github.com/joshyorko/dudleys-second-bedroom.git`
  - Branch/commit inspected: `main` / `e06ec20`
  - Supports Bluefin/Homebrew-oriented install context for RCC and Action Server on Josh's Linux workstation.

- `https://github.com/joshyorko/dsb-common.git`
  - Branch/commit inspected: `main` / `4f6eeeb`
  - Supports shared Bluefin/Homebrew helper context for repeatable workstation CLI setup.

- `https://github.com/joshyorko/hermetic_coding_eniveronments_dags.git`
  - Branch/commit inspected: `main` / `5a82aef`
  - Supports architectural research for RCC inside Dagger/container execution, `ROBOCORP_HOME` cache volumes, `rccremote` sidecars, preflight network builds, and no-network run phases. Treat as design evidence, not canonical RCC docs.

- `https://github.com/joshyorko/rcc-selfextracting-assistant.git`
  - Branch/commit inspected: `main` / `9089c01`
  - Supports offline/air-gapped delivery patterns: bundled `rcc`, local `.rcc_home`/Holotree assets, single-file launchers, and GitHub Actions packaging guidance.

- `https://github.com/joshyorko/04-python-assistant-ai.git`
  - Branch/commit inspected: `main` / `136aa1e`
  - Supports Assistant UI examples with `rpaframework-assistant`, `robocorp.tasks`, key validation tasks, and AI/HITL robot shape.

- `https://github.com/joshyorko/order-bot.git`
  - Branch/commit inspected: `main` / `0b0ef5d`
  - Supports older robot freeze-file ordering and Assistant/browser dependency examples.

- `https://github.com/joshyorko/cook-with-gas-rpa-challenge.git`
  - Branch/commit inspected: `main` / `09efd11`
  - Supports browser/Excel RPA examples and Prefect orchestration that shells out to `rcc run -t ...`.

- `https://github.com/joshyorko/prefect-setup.git`
  - Branch/commit inspected: `main` / `e591f19`
  - Supports containerized RCC examples that install Playwright/RCC, copy robot files, and prebuild environments with `rcc holotree vars`.

- `https://github.com/joshyorko/context-eng-copilot.git`
  - Branch/commit inspected: `main` / `d1d44df`
  - Supports Action Server as LangChain/LangGraph tools via `ActionServerToolkit(...).get_tools()` and `ToolNode`.

## Local-Only Josh Repositories

- `git@github.com:yorko-io/control-room.git`
  - Local branch/commit inspected: `main` / `57c29f0`
  - Supports private Control Room parity notes, robot test structure, Helm holotree init context, and custom adapter env patterns.

- `git@github.com:yorko-io/assistant.git`
  - Local branch/commit inspected: `main` / `3b9d509`
  - Supports Electron-hosted RCC usage, bundled RCC binary versioning, and UI exposure of run/holotree/tasks operations.

## Robocorp / Sema4AI Source

- `https://github.com/robocorp/rcc`
  - Branch/commit inspected: `master` / `f70394b`
  - Supports upstream RCC docs, command behavior orientation, holotree/cache terminology, robot templates, dependency freeze flow, diagnostics, and troubleshooting commands. The current checkout is docs-focused; use Josh's `joshyorko/rcc` fork for source-tree internals.

- `https://github.com/Sema4AI/actions`
  - Branch/commit inspected: `master` / `9d9479e`
  - Supports current Action Server 3.2.0, `package.yaml` v2, dev tasks, external endpoints, OAuth2, `SecretSpec`, MCP endpoint behavior, `Response[T]`, and deployment commands.

- `https://github.com/robocorp/robocorp`
  - Branch/commit inspected: `master` / `64cc9a3`
  - Supports `robocorp.tasks`, `robocorp.workitems`, and `robocorp.browser` package behavior.

- `https://github.com/robocorp/rpaframework`
  - Branch/commit inspected: `master` / `74d554d`
  - Supports legacy Robot Framework/RPA work item env names, `RPA.Robocorp.WorkItems`, Robot Framework browser usage, and Assistant package context.

- `https://github.com/robocorp/template-python`
  - Branch/commit inspected: `master` / `294d020`
  - Supports minimal modern Python robot structure.

- `https://github.com/robocorp/template-python-browser`
  - Branch/commit inspected: `master` / `f33eb62`
  - Supports browser robot structure with `robocorp.browser`.

- `https://github.com/robocorp/template-python-workitems`
  - Branch/commit inspected: `master` / `fb0942c`
  - Supports modern Python work item producer/consumer local dev env files.

- `https://github.com/robocorp/example-advanced-python-template`
  - Branch/commit inspected: `main` / `b17d743`
  - Supports advanced producer/consumer/reporter Python flow and CI examples.

- `https://github.com/robocorp/template-producer-consumer`
  - Branch/commit inspected: `master` / `655360f`
  - Supports Robot Framework producer/consumer work item flow.

- `https://github.com/robocorp/template-extended-producer-consumer`
  - Branch/commit inspected: `master` / `96df1e0`
  - Supports Robot Framework producer/consumer/reporter flow, `preRunScripts`, and local devdata.

- `https://github.com/robocorp/example-python-workitem-files`
  - Branch/commit inspected: `master` / `8e8ea40`
  - Supports work item attachment patterns.

## Optional Repository Probe

- No optional Josh repositories were private/unavailable during this run. Probe status is recorded in `/tmp/agent-skills-rcc-research/OPTIONAL-UNAVAILABLE.txt`.

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

Fetched JSON files are under `/tmp/agent-skills-rcc-research/official-docs/pypi-*.json`. The versions below are the fetched `info.version` values used for package availability/version context; they are not automatic template pin recommendations.

- `actions-work-items`: `0.2.1`
- `black`: `26.3.1`
- `fastapi`: `0.136.1`
- `httpx`: `0.28.1`
- `joblib`: `1.5.3`
- `openpyxl`: `3.1.5`
- `pydantic`: `2.13.3`
- `pytest`: `9.0.3`
- `pytest-asyncio`: `1.3.0`
- `python-multipart`: `0.0.27`
- `requests`: `2.33.1`
- `robocorp`: `3.1.1`
- `robocorp-adapters-custom`: `0.1.5`
- `robocorp-browser`: `2.4.0`
- `robocorp-tasks`: `4.1.1`
- `robocorp-truststore`: `0.9.1`
- `robocorp-workitems`: `1.5.0`
- `robotframework`: `7.4.2`
- `robotframework-browser`: `19.14.2`
- `rpaframework`: `31.2.0`
- `rpaframework-assistant`: `5.0.0`
- `ruff`: `0.15.12`
- `sema4ai-action-server`: `3.2.0`
- `sema4ai-actions`: `1.6.6`
- `sema4ai-mcp`: `0.0.3`
- `uv`: `0.11.8`
- `uvicorn`: `0.46.0`
