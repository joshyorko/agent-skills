# Room Of Requirement Maintenance Pattern

Source: `https://github.com/joshyorko/room-of-requirement.git`, branch `main`, commit `a7e00e632865e0af434c78b7da809f2c07420fe7`.

Inspected files:

- `automation/maintenance-robot/README.md`
- `automation/maintenance-robot/robot.yaml`
- `automation/maintenance-robot/conda.yaml`
- `automation/maintenance-robot/src/maintenance_robot/tasks.py`
- `.github/workflows/rcc-maintenance.yml`

Use this as a pattern for RCC-powered scheduled maintenance robots, not as a generic service template.

## Local Commands

From the repository root:

```bash
rcc ht vars -r automation/maintenance-robot/robot.yaml --json
rcc run -r automation/maintenance-robot/robot.yaml --task maintenance --silent
```

Task-specific runs:

```bash
rcc run -r automation/maintenance-robot/robot.yaml --task update-workflows --silent
rcc run -r automation/maintenance-robot/robot.yaml --task update-downloads --silent
rcc run -r automation/maintenance-robot/robot.yaml --task update-lockfile --silent
rcc run -r automation/maintenance-robot/robot.yaml --task update-homebrew --silent
rcc run -r automation/maintenance-robot/robot.yaml --task validate-brewfiles --silent
rcc run -r automation/maintenance-robot/robot.yaml --task test-devcontainer --silent
```

## robot.yaml Structure

Pattern:

- `tasks` map user-facing task names to `python -m robocorp.tasks run ... -t <task_function>`.
- `environmentConfigs` prefers generated freeze files under `output/` before falling back to `conda.yaml`.
- `artifactsDir: output` keeps reports and freeze files in one ignored output tree.
- `PATH: [.]` and `PYTHONPATH: [src]` keep task imports repo-local.

Maintenance task set in the source repo:

- `maintenance`
- `update-workflows`
- `update-downloads`
- `update-lockfile`
- `update-homebrew`
- `validate-brewfiles`
- `test-devcontainer`

## conda.yaml Pattern

Execution environment pattern:

- `conda-forge` channel.
- Pinned Python, `uv`, and Node.js.
- Pip-installed task dependencies such as `robocorp`, `requests`, `ruamel.yaml`, `click`, `pre-commit`, `yamllint`, and wrapper tools.
- `rccPostInstall` installs CLI tools needed by maintenance tasks, for example `@devcontainers/cli` and `prettier`.
- `variables.PYTHONPATH` points at `${ROBOT_ROOT}/src`.

Before copying this pattern, verify current package versions from source or package indexes in the active run.

## Scheduled GitHub Actions Pattern

Workflow shape:

- Trigger with daily `schedule` plus `workflow_dispatch`.
- Set `ROBOCORP_HOME` inside `${{ github.workspace }}`.
- Pin `RCC_VERSION` as job env.
- Install RCC into a repo-local `.tools/rcc/<version>/` directory.
- Add the pinned RCC directory to `GITHUB_PATH`.
- Cache `ROBOCORP_HOME`.
- Disable telemetry with `rcc config identity -t`.
- Run `rcc run -r automation/maintenance-robot/robot.yaml -t maintenance --silent`.
- Detect changed files, configure bot git identity, create a timestamped maintenance branch, commit, push, and open a PR.

## Cache Key

Cache `ROBOCORP_HOME` with OS, RCC version, and robot environment config hashes:

```yaml
key: rcc-home-${{ runner.os }}-${{ env.RCC_VERSION }}-${{ hashFiles('automation/maintenance-robot/robot.yaml', 'automation/maintenance-robot/conda.yaml') }}
restore-keys: |
  rcc-home-${{ runner.os }}-${{ env.RCC_VERSION }}-
```

This invalidates cache when RCC version or robot environment config changes, while preserving useful holotree reuse.

## Safe Commit Hygiene

Use a pre-commit guard before `git add -A`:

```bash
if git status --porcelain | grep -q '\.rcc_home/'; then
  echo "ERROR: .rcc_home directory detected in changes. This should be in .gitignore!"
  exit 1
fi
```

Also:

- Configure bot identity before committing.
- Create a new branch only when changes exist.
- Gate push/PR creation behind a committed flag.
- Keep cache, output, and generated reports ignored unless the project intentionally stores artifacts.

## Allowlist Strategy

Maintenance stays bounded by allowlists:

- `github_actions.json`: allowed actions, source type, max major, prerelease policy.
- `downloads.json`: target files and regex patterns with named version groups.
- `homebrew.json`: informational version logging only in the source repo; it does not rewrite Brewfiles.

The source robot validates curated Brewfiles but does not auto-rewrite them. That catches missing taps or renamed formulae without unreviewed package churn.

## Maintenance Report

The source robot writes a JSON report to:

```text
automation/maintenance-robot/output/maintenance_report.json
```

Keep reports under `artifactsDir` or upload them as CI artifacts. Use the PR body for a human summary: changed categories, affected files, and any devcontainer-impact flag.
