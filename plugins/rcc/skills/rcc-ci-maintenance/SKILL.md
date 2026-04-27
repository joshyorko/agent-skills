---
name: rcc-ci-maintenance
description: RCC CI and maintenance specialist. Use for RCC in GitHub Actions, ROBOCORP_HOME cache setup, pinned RCC installs, scheduled maintenance robots, allowlist-based dependency maintenance, bot PR workflows, maintenance artifacts, and safe cache/commit hygiene.
---

# RCC CI Maintenance

Use this skill for RCC-powered CI and repository maintenance robots.

## First Inspection

1. Inspect workflow files before robot code: `.github/workflows/*.yml`, RCC install step, `ROBOCORP_HOME`, cache key, token permissions, commit/PR steps, and artifact upload.
2. Inspect the maintenance robot root next: `automation/**/robot.yaml`, `conda.yaml`, allowlists, task entry points, and generated report path.
3. Confirm commit hygiene: cache dirs ignored, bot identity configured, branch naming explicit, and PR creation gated by detected changes.
4. If environment creation fails, use `$rcc-robots` for holotree and `conda.yaml` diagnostics.

## Operating Rules

- Pin RCC install versions in CI and include the RCC version plus robot/env config hashes in `ROBOCORP_HOME` cache keys.
- Disable telemetry in CI when the workflow pattern supports it.
- Add a safety guard that fails if RCC cache paths appear in `git status --porcelain`.
- Keep dependency maintenance allowlist-driven. Update only files and version families the allowlists name.
- Write maintenance reports as artifacts or ignored output files, then include useful summaries in bot PR bodies.
- Prefer branch + PR flow over direct pushes to the protected target branch.

## References

- `references/room-of-requirement-maintenance.md`: sourced pattern from `joshyorko/room-of-requirement` maintenance robot and GitHub Actions workflow.
- `../rcc-robots/references/rcc-command-recipes.md`: RCC command and cache background.
- `../rcc-robots/references/troubleshooting-validation.md`: CI and environment failure triage.
- `../rcc/references/source-map.md`: source evidence and inspected commit IDs.
