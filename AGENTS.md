# Repo Structure

Author canonical skills only under `plugins/<plugin>/skills/<skill>/`.

Do not manually author skill content under `skills/` or `.agents/skills/`. Those directories are generated views and should only contain symlinks into `plugins/`.

## Required Files

- Every plugin must include `plugins/<plugin>/.codex-plugin/plugin.json`.
- Claude compatibility manifests are generated to `plugins/<plugin>/.claude-plugin/plugin.json`.
- Marketplace metadata is authored in `marketplaces/catalog.json` and generated to:
  - `.agents/plugins/marketplace.json`
  - `.claude-plugin/marketplace.json`

## Workflow

1. Add or edit skills under the owning plugin in `plugins/`.
2. Update `marketplaces/catalog.json` when plugin metadata, ordering, or categories change.
3. Rebuild generated views:

```bash
python3 scripts/build_marketplaces.py
python3 scripts/build_runtime_views.py
```

4. Validate the repo:

```bash
bin/check
```

## Invariants

- A skill may belong to exactly one plugin.
- `skills/` must contain symlinks only.
- `.agents/skills/` must contain symlinks only.
- `codex/` must not exist.
