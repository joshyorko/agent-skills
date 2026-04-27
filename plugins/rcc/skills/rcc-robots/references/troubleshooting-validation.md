# Troubleshooting And Validation Playbooks

Use this guide when RCC, Python dependencies, Action Server, or work item flows fail.

If the failure is in RCC install, source, endpoint configuration, or holotree/cache behavior before a project is involved, use `$rcc-core`.

## Split The Failure

Run these in order:

```bash
rcc ht vars -r robot.yaml
rcc task script -r robot.yaml --silent -- python -V
rcc task script -r robot.yaml --silent -- python -m pip list
rcc run -r robot.yaml -t <Task> --silent
```

Interpretation:

- `rcc ht vars` fails: RCC, conda/uv resolution, network, cache, lock, or `conda.yaml` problem.
- `python -V` fails inside `rcc task script`: environment activation or Python install problem.
- `pip list` works but task fails: package import, code, secrets/env, or task command problem.
- Task works locally but not CI: cache key, `ROBOCORP_HOME`, OS-specific freeze, env file, or missing service.

## RCC Environment Failures

Useful commands:

```bash
rcc configuration diagnostics
rcc diagnostics --quick --json
rcc diagnostics --robot robot.yaml --json
rcc configuration diagnostics --quick --json
rcc ht vars -r robot.yaml --debug
rcc ht vars -r robot.yaml --trace
rcc ht vars -r robot.yaml --timeline
rcc holotree list
rcc holotree delete --space <space>
```

Check:
- Does `robot.yaml` point to the expected `conda.yaml`?
- Does `environmentConfigs` fall back to `conda.yaml`?
- Is `uv` available from the configured channel/mode?
- Is a freeze file stale for the current OS/architecture?
- Is `ROBOCORP_HOME` pointing at a writable directory?
- Is a prior RCC process holding a lock?
- Does the network allow package index access?

## Python/Package Failures

Use the RCC environment, not the system Python:

```bash
rcc task script -r robot.yaml --silent -- python -c "import robocorp; print(robocorp.__file__)"
rcc task script -r robot.yaml --silent -- python -m pip check
rcc task script -r robot.yaml --silent -- pytest tests -v
```

Common fixes:
- Add missing packages to `conda.yaml` or `package.yaml`.
- Keep packages under `pip:` unless they require conda native dependencies.
- Rebuild after changing dependencies: `rcc ht vars -r robot.yaml`.
- For `robocorp.browser`, verify post-install steps such as `python -m robocorp.browser install chromium --isolated`. Use `rfbrowser init` only for Robot Framework Browser projects.

## Work Item Failures

Check env files first:

```bash
python3 -m json.tool devdata/env-sqlite-consumer.json
rcc run -t Producer -e devdata/env-sqlite-producer.json --silent
rcc run -t Consumer -e devdata/env-sqlite-consumer.json --silent
```

Confirm:
- Producer and consumer use the same backend and compatible queue names.
- SQLite paths are relative to the project root or are absolute.
- File attachments live under the configured files directory.
- Consumers release items with `with item:` or explicit `done()`/`fail()`.

## Action Server Failures

```bash
action-server start
curl -fsS http://localhost:8080/openapi.json >/tmp/openapi.json
curl -fsS http://localhost:8080/mcp >/tmp/mcp.txt
python -m sema4ai.actions run . -t <action_name> --json-input input.json
```

If startup fails, inspect `package.yaml` and dev dependencies. If endpoints fail, check server logs and whether actions import successfully.

## Validate Before Committing

From the repo root:

```bash
python3 scripts/build_marketplaces.py --check
python3 scripts/build_runtime_views.py --check
python3 scripts/validate_repo.py
bin/check
```

For edited JSON:

```bash
python3 -m json.tool path/to/file.json
```

For edited robot configs:

```bash
python3 plugins/rcc/skills/rcc-robots/scripts/validate_robot.py path/to/robot.yaml
```

If PyYAML or RCC is unavailable, record the skipped validation plainly with the missing dependency.
