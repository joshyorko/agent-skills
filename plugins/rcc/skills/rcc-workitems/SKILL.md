---
name: rcc-workitems
description: RCC work item specialist. Use for classic robocorp.workitems, actions-work-items, producer/consumer/reporter flows, queue env files, local SQLite/file queues, custom adapters, Redis, DocumentDB, and Yorko Control Room adapters.
---

# RCC Work Items

Use this skill for work item queues, adapters, and producer/consumer/reporter automation.

## First Inspection

1. Find the role split: producer, consumer, reporter, queue setup, and any local database/files directory.
2. Inspect env files before code: `devdata/*.json`, adapter import path, queue names, output queue names, database/file paths, and service credentials.
3. Inspect task/action code next: classic `robocorp.workitems`, `actions-work-items`, adapter initialization, item release behavior, and attachment handling.
4. If RCC environment setup fails before code runs, switch to `$rcc-robots` and validate `robot.yaml`/`conda.yaml` first.

## Operating Rules

- Preserve producer/consumer/reporter queue names and output queue wiring.
- Prefer local SQLite/file adapters for deterministic local and CI validation before Redis, DocumentDB, or Yorko Control Room.
- Release input items consistently with context managers or explicit done/fail APIs.
- Keep adapter contracts testable: reserve, release, payload load/save, file list/get/add/remove.
- Do not hardcode live board, queue, or service IDs into committed sample env files.

## References

- `references/workitems-adapters.md`: classic Robocorp work items, `actions-work-items`, adapter contracts, local queues, and validation commands.
- `../rcc-robots/references/troubleshooting-validation.md`: work item failure triage and repo validation.
- `../rcc-robots/assets/templates/conda-workitems.yaml`: work item environment template.
- `../rcc-robots/assets/templates/hitl-assistant/`: starter robot with Assistant/work item structure.
- `../rcc/references/source-map.md`: source evidence for adapters and work item recipes.
