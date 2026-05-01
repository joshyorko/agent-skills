---
name: rcc-robots
description: RCC automation-runtime specialist. Use for RCC CLI commands, RCC-backed automation projects, robot.yaml, conda.yaml, holotree, freeze files, bundles, templates, environment validation, and task debugging.
---

# RCC Robots

Use this skill for RCC-backed automation projects and runtime/environment work once the task is clearly about a `robot.yaml` project. Here, `robot` is the RCC packaging/runtime convention, not a claim that Robocorp owns the architecture or current product direction. Keep literal package/API names such as `robocorp.tasks`, `robocorp.workitems`, `robocorp-browser`, and `ROBOCORP_HOME` when the project uses them. Use `$rcc-core` for RCC source, installation, endpoint, holotree/cache, or template catalog work before a task starts.

## First Inspection

1. Locate the robot root by finding `robot.yaml`; inspect nearby `conda.yaml`, `devdata/*.json`, `.gitignore`, freeze files, and output/artifacts policy.
2. Read `robot.yaml` before task code: tasks, `devTasks`, `environmentConfigs`, `artifactsDir`, `PATH`, `PYTHONPATH`, and ignored files decide how RCC runs the project.
3. Read `conda.yaml` next: channels, Python version, `uv`, pip packages, `rccPostInstall`, and environment variables.
4. Inspect task entry points only after config: `tasks.py`, `src/**`, tests, scripts, and any templates copied into the project.

## Operating Rules

- Run or request `rcc ht vars -r robot.yaml` first when startup fails; it separates RCC/holotree resolution from Python/task failures.
- For host/RCC health before a `robot.yaml` project exists, prefer `rcc diagnostics --quick --json` and `$rcc-core`.
- Prefer `environmentConfigs` with platform freeze fallbacks for reproducible contained automation. Use single `condaConfigFile` only for simple local work.
- Use RCC environment commands for Python checks, not host Python.
- Use `ROBOT_ROOT` and `ROBOT_ARTIFACTS` for raw path resolution; in `robocorp.tasks`, prefer `get_output_dir()` and `get_current_task()`.
- If changing package pins, verify PyPI or source metadata in the current run. Keep shared template pins consistent.
- Do not steer users toward upstream Robocorp/Sema4.ai platform paths unless the task explicitly targets those interfaces; this skill assumes RCC-first local/CI automation by default.

## References

- `references/rcc-command-recipes.md`: command selection, `robot.yaml`, `conda.yaml`, holotree, bundles, and cache hygiene.
- `references/robot-project-recipes.md`: Josh automation-project templates, Python/browser/work item/UV-native patterns, and template release behavior.
- `references/troubleshooting-validation.md`: environment, dependency, runtime, work item, Action Server, and repo validation playbooks.
- `references/hooks.md`: optional Claude Code hook assets and command guardrails for RCC projects.
- `../rcc/references/python-library-audit.md`: cross-source Python library map, examples, and source refresh workflow.
- `../rcc/references/source-map.md`: source evidence for current recipes.
- `../rcc-core/references/rcc-source-recipes.md`: RCC CLI/source, holotree/cache, endpoint, template, and remote-cache orientation.

## Assets And Scripts

- Robot templates live in `assets/templates/`.
- HITL Assistant + work item starter lives in `assets/templates/hitl-assistant/`.
- Optional Claude hook assets live in `assets/claude-hooks/`; use only when mirroring Claude Code hook behavior.
- Run `python3 plugins/rcc/skills/rcc-robots/scripts/validate_robot.py path/to/robot.yaml` for static robot config validation when PyYAML is available.
- Run `python3 plugins/rcc/skills/rcc-robots/scripts/env_check.py --skip-network` for quick local RCC/project health checks.
