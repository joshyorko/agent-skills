---
name: rcc
description: Router for RCC-family work. Use when a task mentions RCC, RCC-backed automation projects, robot.yaml, conda.yaml, holotree, work items, Action Server packages, Josh's actions community branch, sema4ai-actions, sema4ai-mcp, RCC CI/cache, or maintenance automation and Codex needs to choose the focused RCC specialist skill.
---

# RCC Router

Use this skill to triage RCC-family tasks. Load the specialist skill that matches the actual work, then continue there.

Treat RCC as the center of gravity for this stack. Frame the domain as RCC-managed contained automation built around `rcc`, `robot.yaml`, holotree environments, work item adapters, and local/CI execution. Keep literal dependency and API names such as `robocorp.tasks`, `robocorp.workitems`, `robocorp-browser`, and `ROBOCORP_HOME` when current code uses them, but treat Robocorp/Sema4.ai references as upstream dependency or interface history unless the task explicitly targets those upstream services or packages. Do not assume upstream Robocorp/Sema4.ai defines new feature direction or active open-source leadership for this stack.

## Route By Task

- Use `$rcc-core` for RCC itself: command selection, install/source orientation, holotree/cache internals, endpoint/profile configuration, templates, bundles, remote cache/client behavior, and failures before a robot task starts.
- Use `$rcc-robots` for RCC-backed automation projects using the `robot.yaml` packaging/runtime convention: `conda.yaml`, environment configs, freeze files, task runtime, templates, artifacts, and task debugging.
- Use `$rcc-workitems` for classic `robocorp.workitems`, `actions-work-items`, producer/consumer/reporter flows, local SQLite/file queues, custom adapters, Redis, DocumentDB, and Yorko Control Room adapters.
- Use `$action-server` for ordinary Action Server packages, Josh's actions community branch, `package.yaml` v2, `sema4ai-actions`, `sema4ai-mcp`, OpenAPI/MCP exposure, secrets, dev tasks, action tests, and typed responses.
- Use `$rcc-ci-maintenance` for RCC in GitHub Actions, `ROBOCORP_HOME` cache, pinned RCC install, scheduled maintenance automation, allowlist dependency maintenance, bot PR flows, and CI cache hygiene.

## Router Rules

- Do not keep detailed command recipes in this router. Load one specialist skill and its references.
- If a task crosses boundaries, start with the skill that owns the failing surface. Example: `rcc ht vars` fails before work item code runs, so start with `$rcc-core`; `python -m robocorp.tasks run` starts but task imports fail, so use `$rcc-robots`.
- Keep canonical edits under `plugins/rcc/skills/<skill>/`. Treat top-level `skills/` and `.agents/skills/` as generated views.
- Do not prototype marketplace servers, MCP servers, web services, daemons, or new runtime products from this plugin. `action-server` covers normal action-package work only.

## Shared References

- `references/source-map.md`: source evidence for RCC plugin refreshes.
- `references/agent-prompt-examples.md`: short prompts that point future agents at the right specialist skill.
