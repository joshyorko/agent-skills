# Robot Project Recipes

Use this guide when creating or reviewing Robocorp robot projects from Josh's RCC and robot template repos.

## Josh Template Index

The inspected `joshyorko/robot-templates` repo contains:

- `01-python`: minimal `robocorp.tasks` robot.
- `02-python-browser`: browser automation with Playwright/Robocorp browser dependencies.
- `03-python-work-items`: producer, consumer, reporter, Assistant UI, and custom adapter examples.
- `04-python-assistant-ai`: Assistant UI with an AI chat task and key-test dev task.
- `05-python-action-server-work-items`: work item flow aligned with `actions-work-items`.
- `06-python-uv-native`: RCC uv-native mode with no conda-forge channels.
- `maintenance-robot`: template pin maintenance robot with allowlists.

Prefer these names when prompting RCC or future agents. If a template has freeze files, keep `environmentConfigs` ordering intact.

## Minimal Python Robot

`robot.yaml`:

```yaml
tasks:
  RunTask:
    shell: python -m robocorp.tasks run tasks.py

environmentConfigs:
  - environment_windows_amd64_freeze.yaml
  - environment_linux_amd64_freeze.yaml
  - environment_darwin_amd64_freeze.yaml
  - conda.yaml

artifactsDir: output
PATH:
  - .
PYTHONPATH:
  - .
ignoreFiles:
  - .gitignore
```

`conda.yaml`:

```yaml
channels:
  - conda-forge

dependencies:
  - python=3.12.11
  - uv=0.11.8
  - pip:
      - robocorp==3.1.1
      - robocorp-browser==2.4.0
```

## Browser Robot

Browser projects usually need:
- Node.js or browser tooling dependency in `conda.yaml`.
- `robocorp-browser` or Robot Framework Browser packages.
- `rccPostInstall: rfbrowser init` when using Robot Framework Browser.

Validate browser projects with:

```bash
rcc ht vars -r robot.yaml
rcc run -r robot.yaml -t BrowserExample --silent
```

If browser install fails, treat it as environment/post-install first, not a selector or task-code bug.

## Work Item Robot

Use explicit producer/consumer/reporter tasks:

```yaml
tasks:
  Producer:
    shell: python -m robocorp.tasks run tasks.py -t producer
  Consumer:
    shell: python -m robocorp.tasks run tasks.py -t consumer
  Reporter:
    shell: python -m robocorp.tasks run tasks.py -t reporter

devTasks:
  SeedSQLiteDB:
    shell: python scripts/seed_sqlite_db.py
  CheckSQLiteDB:
    shell: python scripts/check_sqlite_db.py
```

Run with role-specific env files:

```bash
rcc run -t Producer -e devdata/env-sqlite-producer.json
rcc run -t Consumer -e devdata/env-sqlite-consumer.json
rcc run -t Reporter -e devdata/env-sqlite-for-reporter.json
```

Keep work item files and SQLite databases under `devdata/` or `output/`; commit only sample inputs that are intended fixtures.

## UV-Native Pattern

The `06-python-uv-native` template intentionally removes conda-forge channels:

```yaml
dependencies:
  - python=3.12.11
  - uv=0.11.8
  - pip:
      - robocorp==3.1.1
```

Use uv-native mode for lighter Python environments when you do not need conda-forge binary packages. Keep conda-forge channels for packages that require conda-managed native libraries.

## Template Release Behavior

The maintenance robot in `robot-templates` updates allowlisted package pins in template conda files. When changing template pins in this skill:

1. Verify the package source, usually PyPI JSON or the owning repo.
2. Update all matching RCC templates consistently.
3. Avoid "latest" language unless the source was checked in the current run.
4. Document the source in `references/source-map.md`.
