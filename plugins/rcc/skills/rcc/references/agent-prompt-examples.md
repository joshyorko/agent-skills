# Agent Prompt Examples

Use these short prompts when handing RCC work to future Codex agents.

## Inspect A Robot

```text
Use the RCC skill. Inspect this robot root before editing: robot.yaml, conda.yaml, devdata env files, freeze files, and task entry points. Run rcc ht vars first if RCC is available, then separate environment failures from Python/task failures.
```

## Fix A Dependency Failure

```text
Use the RCC skill. The robot fails during environment creation. Reproduce with rcc ht vars -r robot.yaml, inspect conda.yaml and environmentConfigs, then change the smallest dependency/config surface. Do not edit generated output or freeze files unless the project intentionally tracks them.
```

## Add A Work Item Consumer

```text
Use the RCC skill. Add a consumer task that uses the project's existing work item API and adapter env files. Preserve producer/consumer/reporter queue names, use item context managers for release, and validate with the SQLite/file local backend before distributed services.
```

## Create An Action Package

```text
Use the RCC skill. Create or update a Sema4AI Action Server package with package.yaml spec-version v2, typed sema4ai.actions responses, Secret/OAuth2Secret for sensitive inputs, and dev-tasks for tests/lint. Validate action-server start and OpenAPI/MCP endpoints when the dependency is available.
```

## Review Template Pins

```text
Use the RCC skill. Before changing package pins, fetch PyPI or the owning repo metadata in this run. If uv or shared Robocorp pins change, update all RCC templates consistently and record sources in references/source-map.md.
```

## Diagnose CI Cache Issues

```text
Use the RCC skill. Check ROBOCORP_HOME, holotree cache keys, OS/architecture freeze files, and rcc ht vars output. Prefer cache-key invalidation over broad cache deletion, and keep output/work item runtime files as artifacts.
```
