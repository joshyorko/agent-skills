---
name: rcc-core
description: "RCC CLI/source specialist. Use for RCC itself: command selection, installation, source tree orientation, holotree/cache internals, endpoint/profile configuration, templates, bundles, remote cache/client behavior, and diagnosing RCC before robot task code runs."
---

# RCC Core

Use this skill when the task is about RCC itself rather than a specific robot, work item adapter, Action Server package, or CI wrapper.

## First Inspection

1. Identify the active context: installed `rcc` binary, Josh's fork at `github.com/joshyorko/rcc`, upstream `github.com/robocorp/rcc`, or a robot project merely using RCC.
2. Run read-only CLI checks first when a binary is available: `rcc version`, `rcc diagnostics --quick`, `rcc docs recipes`, and `rcc docs changelog`.
3. For source work, inspect `README.md`, `developer/toolkit.yaml`, `docs/recipes.md`, `docs/holotree.md`, `docs/troubleshooting.md`, `cmd/rcc`, `robot/`, `conda/`, `htfs/`, `remotree/`, `settings/`, and `templates/`.
4. If a failure reaches Python task code, switch to `$rcc-robots`; if it reaches queue behavior, switch to `$rcc-workitems`.

## Operating Rules

- On Josh's Bluefin host, prefer repo-native/devcontainer paths or Homebrew for host `rcc`; do not suggest host package layering unless there is a clear reason.
- Treat `ROBOCORP_HOME` as the primary RCC home/cache boundary. Older notes may mention `RCC_HOME`; verify current source/config behavior before relying on it.
- Use `rcc ht vars` and `rcc task script` to prove environment resolution before debugging task imports.
- Delete holotree spaces surgically. Avoid broad cache cleanup on a shared workstation.
- For Josh's fork, remember telemetry is intentionally disabled and endpoint overrides are first-class.

## References

- `references/rcc-source-recipes.md`: RCC command map, source tree orientation, holotree/cache, endpoints, remote cache, and fork development recipes.
- `../rcc-robots/references/rcc-command-recipes.md`: robot-facing commands and environment recipes.
- `../rcc-robots/references/troubleshooting-validation.md`: failure-splitting playbook.
- `../rcc/references/source-map.md`: evidence map for inspected RCC, Robocorp, Sema4AI, and Josh repositories.
