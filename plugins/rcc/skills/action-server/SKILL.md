---
name: action-server
description: Action Server action-package specialist. Use for ordinary Action Server packages, Josh's actions community branch, package.yaml v2, sema4ai-actions, sema4ai-mcp, typed action responses, secrets, dev-tasks, tests, and local OpenAPI/MCP endpoint validation.
---

# Action Server

Use this skill for normal Action Server package authoring and debugging across Josh's `actions` community branch and Sema4AI-compatible package APIs.

## Scope

- Build or repair action packages using `package.yaml` spec-version v2.
- Work with `sema4ai-actions`, `sema4ai-mcp`, typed responses, `Secret`, `OAuth2Secret`, tests, lint dev tasks, OpenAPI, and local MCP endpoint validation.
- Use `actions-work-items` only when the action package itself needs producer/consumer work item behavior; switch to `$rcc-workitems` for adapter-heavy queue design.

## Non-Goals

- Do not prototype an agent-skills marketplace server.
- Do not create a new MCP server, action server, daemon, web service, or marketplace runtime product for this repo.
- Do not make plugin distribution sound hosted; this skill is for ordinary Action Server action packages.

## First Inspection

1. Locate `package.yaml`, `actions.py`, `src/**`, `tests/**`, and `.action-server/` or datadir settings if present.
2. Inspect dependencies, `pythonpath`, `dev-dependencies`, and `dev-tasks` before changing action code.
3. Check secrets and typed inputs/outputs before writing sample payloads.
4. Validate local endpoints only when Action Server is installed and intended for the project.

## References

- `references/action-server-recipes.md`: package v2 patterns, actions, MCP decorators, secrets, dev tasks, endpoint validation, and work-item-in-actions examples.
- `../rcc-workitems/references/workitems-adapters.md`: queue/adapters details when action packages use `actions-work-items`.
- `../rcc-robots/references/troubleshooting-validation.md`: shared failure triage and validation commands.
- `../rcc-robots/assets/templates/package.yaml`: starter package template.
- `../rcc/references/source-map.md`: source evidence for Action Server and Sema4AI recipes.
