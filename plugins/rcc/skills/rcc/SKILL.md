---
name: rcc
description: Router for RCC-family work. Use when a task mentions RCC, Robocorp robots, robot.yaml, conda.yaml, holotree, work items, Sema4AI Action Server packages, sema4ai-actions, sema4ai-mcp, RCC CI/cache, or maintenance robots and Codex needs to choose the focused RCC specialist skill.
---

# RCC Router

Use this skill to triage RCC-family tasks. Load the specialist skill that matches the actual work, then continue there.

## Route By Task

- Use `$rcc-robots` for RCC CLI, `robot.yaml`, `conda.yaml`, holotree, freeze files, bundles, robot templates, environment validation, and robot runtime debugging.
- Use `$rcc-workitems` for classic `robocorp.workitems`, `actions-work-items`, producer/consumer/reporter flows, local SQLite/file queues, custom adapters, Redis, DocumentDB, and Yorko Control Room adapters.
- Use `$sema4ai-action-server` for ordinary Sema4AI Action Server packages, `package.yaml` v2, `sema4ai-actions`, `sema4ai-mcp`, OpenAPI/MCP exposure, secrets, dev tasks, action tests, and typed responses.
- Use `$rcc-ci-maintenance` for RCC in GitHub Actions, `ROBOCORP_HOME` cache, pinned RCC install, scheduled maintenance robots, allowlist dependency maintenance, bot PR flows, and CI cache hygiene.

## Router Rules

- Do not keep detailed command recipes in this router. Load one specialist skill and its references.
- If a task crosses boundaries, start with the skill that owns the failing surface. Example: `rcc ht vars` fails before work item code runs, so start with `$rcc-robots`.
- Keep canonical edits under `plugins/rcc/skills/<skill>/`. Treat top-level `skills/` and `.agents/skills/` as generated views.
- Do not prototype marketplace servers, MCP servers, web services, daemons, or new runtime products from this plugin. `sema4ai-action-server` covers normal action-package work only.

## Shared References

- `references/source-map.md`: source evidence for RCC plugin refreshes.
- `references/agent-prompt-examples.md`: short prompts that point future agents at the right specialist skill.
