# Agent Prompt Examples

Use these short prompts when handing RCC-family work to future Codex agents.

## Inspect A Robot

```text
Use $rcc-robots. Inspect this robot root before editing: robot.yaml, conda.yaml, devdata env files, freeze files, and task entry points. Run rcc ht vars first if RCC is available, then separate environment failures from Python/task failures.
```

## Fix A Dependency Failure

```text
Use $rcc-robots. The robot fails during environment creation. Reproduce with rcc ht vars -r robot.yaml, inspect conda.yaml and environmentConfigs, then change the smallest dependency/config surface. Do not edit generated output or freeze files unless the project intentionally tracks them.
```

## Add A Work Item Consumer

```text
Use $rcc-workitems. Add a consumer task that uses the project's existing work item API and adapter env files. Preserve producer/consumer/reporter queue names, use item context managers for release, and validate with the SQLite/file local backend before distributed services.
```

## Create An Action Package

```text
Use $action-server. Create or update an Action Server package with package.yaml spec-version v2, typed sema4ai.actions responses, Secret/OAuth2Secret for sensitive inputs, and dev-tasks for tests/lint. Validate action-server start and OpenAPI/MCP endpoints when the dependency is available.
```

## Review Template Pins

```text
Use $rcc-robots. Before changing package pins, fetch PyPI or the owning repo metadata in this run. If uv or shared Robocorp pins change, update all RCC templates consistently and record sources in references/source-map.md.
```

## Diagnose CI Cache Issues

```text
Use $rcc-ci-maintenance. Check ROBOCORP_HOME, holotree cache keys, OS/architecture freeze files, and rcc ht vars output. Prefer cache-key invalidation over broad cache deletion, and keep output/work item runtime files as artifacts.
```
