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

- `robocorp-browser` for modern Python robots. It is separate from the base `robocorp` package.
- `browser.configure(...)` before browser APIs when changing screenshot, headless, or timeout behavior.
- Screenshot modes `on`, `off`, or `only-on-failure` depending on artifact policy.
- `python -m robocorp.browser install chromium --isolated` or `python -m robocorp.browser install chrome --isolated` in RCC/CI post-install flows.
- `rfbrowser init` only for Robot Framework Browser projects, not for `robocorp.browser`.

Linux headless behavior is auto-detected when no display is available. If RCC reports that no matching browser was found or browser launch fails before task logic starts, debug the environment/post-install layer first.

Validate browser projects with:

```bash
rcc ht vars -r robot.yaml
rcc run -r robot.yaml -t BrowserExample --silent
```

If browser install fails, treat it as environment/post-install first, not a selector or task-code bug.

## Assistant / HITL Robot

Assistant UI robots use `rpaframework-assistant`, not the base `rpaframework` package. They are desktop/HITL flows and should not be treated as headless CI smoke tests.

```yaml
dependencies:
  - python=3.12.11
  - uv=0.11.8
  - pip:
      - robocorp==3.1.1
      - rpaframework-assistant==5.0.0
```

Typical tasks block on dialog interaction:

```python
from RPA.Assistant import Assistant
from robocorp.tasks import task


@task
def ask_user() -> None:
    assistant = Assistant()
    assistant.add_heading("Review queued work")
    assistant.add_text_input("answer", label="Decision")
    result = assistant.run_dialog()
    if not result:
        raise RuntimeError("Assistant dialog closed without a result")
```

Keep producer/consumer/reporter task functions real `@task` entrypoints even when an Assistant task is present. Do not call `workitems.outputs.create(...)` from a HITL starter unless a seed/current input item is reserved.

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

## Diagnostic Dev Tasks

Production robots should expose diagnostics as `devTasks`, not just business tasks. Useful patterns from `fizzy-symphony`, `fetch-repos-bot`, and maintenance robots:

```yaml
tasks:
  Producer:
    shell: python -m robocorp.tasks run tasks.py -t producer
  Consumer:
    shell: python -m robocorp.tasks run tasks.py -t consumer
  Reporter:
    shell: python -m robocorp.tasks run tasks.py -t reporter

devTasks:
  Doctor:
    shell: python -m robocorp.tasks run tasks.py -t doctor
  PrintWorkitemsEnv:
    shell: python scripts/print_workitems_env.py
  SeedSQLiteDB:
    shell: python scripts/seed_sqlite_db.py
  CheckSQLiteDB:
    shell: python scripts/check_sqlite_db.py
  RecoverOrphanedItems:
    shell: python scripts/recover_orphaned_items.py
  DiagnoseReporter:
    shell: python scripts/diagnose_reporter_issue.py
```

Run diagnostics with `--dev`:

```bash
rcc run -r robot.yaml --dev -t Doctor --silent
rcc run -r robot.yaml --dev -t CheckSQLiteDB --silent
```

This separates environment and queue health from the main automation flow.

## Producer / Consumer / Reporter Shape

A durable flow usually has these layers:

- Producer validates one input, emits one output item per unit of work, then releases the source item after fan-out succeeds.
- Consumer reads exactly one queue, writes shard-aware artifacts, emits a result item, and cleans partial outputs on failure.
- Reporter reads result items, aggregates counts, writes a timestamped final report, and releases each input item.

For local CI, run a full SQLite or file-backed smoke:

```bash
rcc run -r robot.yaml -t Producer -e devdata/env-sqlite-producer.json --silent
rcc run -r robot.yaml -t Consumer -e devdata/env-sqlite-consumer.json --silent
rcc run -r robot.yaml -t Reporter -e devdata/env-sqlite-reporter.json --silent
rcc run -r robot.yaml --dev -t CheckSQLiteDB --silent
```

When consumers run in shards or matrix jobs, put shard ids in output filenames and result payloads so retries do not overwrite artifacts.

## Maintenance Robot

The `robot-templates` and `room-of-requirement` maintenance robots are a good pattern for repo automation:

- Keep package allowlists in source.
- Run refresh logic as an RCC task.
- Write a report artifact under `output/`.
- Use `PYTHONPATH` to include `src`.
- Run in scheduled CI with pinned RCC and a scoped `ROBOCORP_HOME`.

## UV-Native Pattern

The `06-python-uv-native` template intentionally removes conda-forge channels:

```yaml
dependencies:
  - python=3.12.11
  - uv=0.11.8
  - pip:
      - robocorp==3.1.1
```

Use uv-native mode for lighter Python environments when you do not need conda-forge binary packages. Current RCC uv-native mode expects exact `python=` and `uv=` top-level dependencies, no `channels`, and no other top-level conda dependencies beyond `python`, `uv`, and `pip`. Keep conda-forge channels for packages that require conda-managed native libraries.

## Template Release Behavior

The maintenance robot in `robot-templates` updates allowlisted package pins in template conda files. When changing template pins in this skill:

1. Verify the package source, usually PyPI JSON or the owning repo.
2. Update all matching RCC templates consistently.
3. Avoid "latest" language unless the source was checked in the current run.
4. Document the source in `references/source-map.md`.
