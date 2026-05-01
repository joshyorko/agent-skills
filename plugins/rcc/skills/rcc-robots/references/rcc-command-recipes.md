# RCC Command Recipes

Use this guide for RCC command selection, robot configuration, environment prebuilds, and cache hygiene.

For RCC source, endpoint, holotree internals, or cache behavior not tied to a specific robot, switch to `$rcc-core`.

For cross-source Python library evidence, current example gaps, and package/source refresh commands, see `../../rcc/references/python-library-audit.md`.

## Create Or Locate A Robot

```bash
rcc robot init --json
rcc robot init -t python -d my-robot
rcc create
rcc pull github.com/joshyorko/template-python-browser
```

Before editing task code, inspect:
- `robot.yaml`: tasks, `devTasks`, `environmentConfigs`, `artifactsDir`, `PATH`, `PYTHONPATH`.
- `conda.yaml`: channels, Python, `uv`, pip dependencies, `rccPostInstall`.
- `devdata/*.json`: env files passed with `rcc run -e`.
- freeze files: `environment_linux_amd64_freeze.yaml`, `environment_windows_amd64_freeze.yaml`, `environment_darwin_amd64_freeze.yaml`.

## robot.yaml Pattern

```yaml
tasks:
  Main:
    shell: python -m robocorp.tasks run tasks.py -t main

devTasks:
  Test:
    shell: pytest tests -v

environmentConfigs:
  - environment_linux_amd64_freeze.yaml
  - environment_windows_amd64_freeze.yaml
  - environment_darwin_amd64_freeze.yaml
  - conda.yaml

artifactsDir: output
PATH:
  - .
PYTHONPATH:
  - .
  - src
ignoreFiles:
  - .gitignore
```

Use `environmentConfigs` when production repeatability matters. Use single `condaConfigFile: conda.yaml` only for simple local projects.

## conda.yaml Pattern

```yaml
channels:
  - conda-forge

dependencies:
  - python=3.12.11
  - uv=0.11.8
  - pip:
      - robocorp==3.1.1
      - requests==2.32.5

# robocorp.browser projects often need:
# rccPostInstall:
#   - python -m robocorp.browser install chromium --isolated
#
# Robot Framework Browser projects often need:
# rccPostInstall:
#   - rfbrowser init
```

RCC templates in this skill use `uv` for faster pip dependency installation. Package metadata was fetched from PyPI during the 2026-04-27 skill refresh; recheck exact pins before bumping.

## Prebuild And Inspect Holotree

```bash
rcc ht vars -r robot.yaml
rcc ht vars -r robot.yaml --json
rcc ht vars -r robot.yaml --space dev
rcc diagnostics --robot robot.yaml --json
rcc robot diagnostics -r robot.yaml --json
rcc task shell -r robot.yaml
rcc task script -r robot.yaml --silent -- python -m pip list
```

`rcc ht vars` is the first diagnostic when a robot fails before Python starts. It proves whether RCC can resolve the environment and exposes `ROBOT_ROOT`, `ROBOT_ARTIFACTS`, Python path, and other runtime variables.

## Run Tasks

```bash
rcc run -r robot.yaml -t Main
rcc run -r robot.yaml -t Main --silent
rcc run -r robot.yaml --dev -t Test
rcc run -r robot.yaml -t Consumer -e devdata/env-sqlite-consumer.json
```

Use `--silent` for agent-readable output. Add `--debug`, `--trace`, or `--timeline` when diagnosing RCC behavior.

## Bundles

```bash
rcc robot bundle --robot robot.yaml --output my-robot.py
rcc robot run-from-bundle my-robot.py --task Main
```

Bundle after the robot validates locally. Do not commit `output/`, transient bundle outputs, or generated freeze files unless the project intentionally tracks them.

## Freeze Files And Dependency Exports

RCC writes platform freeze files during a real run. Copy the freeze file from `output/` only when the project intentionally tracks reproducible environment locks:

```bash
rcc run -r robot.yaml -t Main --silent
cp output/environment_linux_amd64_freeze.yaml .
rcc robot dependencies -r robot.yaml --space user --export
```

`rcc robot dependencies --export` writes dependency export data such as `dependencies.yaml`; it does not create the platform freeze file. Keep freeze-first fallback order in `environmentConfigs`:

```yaml
environmentConfigs:
  - environment_linux_amd64_freeze.yaml
  - environment_windows_amd64_freeze.yaml
  - environment_darwin_amd64_freeze.yaml
  - conda.yaml
```

## Cache And Home Directories

Set `ROBOCORP_HOME` in CI or experiments to keep RCC state isolated:

```bash
export ROBOCORP_HOME="$PWD/.cache/robocorp"
rcc ht vars -r robot.yaml
```

Common cache commands:

```bash
rcc holotree list
rcc holotree delete --space <space>
rcc holotree check --retries 5
rcc holotree shared --enable
rcc diagnostics --quick --json
```

Use targeted deletes by space. Avoid broad cache deletion in shared developer machines or CI caches unless the cache is known corrupt.

## RCC Remote

Josh's `rccremote-docker` repo uses `RCC_REMOTE_ORIGIN` for clients:

```bash
export RCC_REMOTE_ORIGIN=https://rccremote.example.com
rcc holotree pull -r robot.yaml
rcc holotree pull -r robot.yaml --origin https://rccremote.example.com
```

For self-hosted remote caches, validate server bootstrapping from the deployment repo first, then validate client connectivity with catalog/list/pull commands before changing robot dependencies.

## CI Cache Hygiene

- Pin `ROBOCORP_HOME` to a job cache directory.
- Cache holotree data by OS, architecture, Python version, and dependency hash.
- Run `rcc ht vars -r robot.yaml` before task execution so cache/environment failures are isolated.
- Keep `output/`, logs, and work item files as artifacts, not source changes.
- When dependency resolution changes, invalidate cache keys rather than deleting caches ad hoc.
