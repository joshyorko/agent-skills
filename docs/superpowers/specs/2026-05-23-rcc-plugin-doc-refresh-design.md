# RCC Plugin Robocorp Documentation Refresh Design

## Goal

Improve the RCC plugin documentation for the current Robocorp/Sema4AI stack, with this phase focused on modern Python Robocorp libraries and RPA Framework guidance. The work should keep RCC positioned as the gateway for environment resolution, robot execution, Action Server packages, work-item queues, and Control Room-adjacent runtime patterns.

## Evidence Baseline

This refresh is based on a May 23, 2026 review of official docs, PyPI metadata, Josh-maintained forks, and public Robocorp/Sema4AI repositories. Version-current claims must be tied to source evidence and refreshed before future "latest" edits.

Primary source lanes:

- Official RPA Framework docs at `https://rpaframework.org/`, plus release notes and PyPI package metadata.
- `robocorp/robocorp` for modern Python packages: `robocorp.tasks`, `robocorp.browser`, `robocorp.workitems`, `robocorp.vault`, `robocorp.storage`, and `robocorp.log`.
- `robocorp/rpaframework` for `RPA.*` Robot Framework and Python-callable legacy/HITL libraries.
- `Sema4AI/actions` for current Action Server, `sema4ai-actions`, and `sema4ai-mcp`.
- `joshyorko/actions` branch `community` for `actions-work-items` and the Action Server workflow-producer-consumer template.
- `joshyorko/rcc` docs for RCC as the environment/runtime gateway, including holotree, dependency freeze/export, templates, bundles, and remote/prebuilt environment patterns.
- Public `robocorp/*` runtime/process examples, including on-demand runtime provisioners, work-item templates, producer/consumer/reporting examples, retry examples, asset storage, vault, and worker-log examples.

Private or unreleased Control Room backend details must not be presented as facts. Public clients/examples may support labeled inference, but docs must mark that material as "inferred from public examples" or "speculative architecture note."

## Recommended Approach

Use a docs-plus-stale-pin refresh. The primary deliverable is better RCC plugin documentation, but direct contradictions in examples, helper scripts, and template pins should be fixed when they would otherwise mislead users.

The alternative "docs only" approach leaves stale package pins and Python-version guidance in place. The broader plugin refactor approach is useful later, but too wide for this phase.

## Documentation Architecture

Keep canonical edits under `plugins/rcc/skills/...`. Do not edit generated `skills/`, `.agents/skills/`, or `.claude-plugin` views by hand.

Update these files:

- `plugins/rcc/skills/rcc/references/python-library-audit.md`
- `plugins/rcc/skills/rcc/references/source-map.md`
- `plugins/rcc/skills/rcc/references/agent-prompt-examples.md`
- `plugins/rcc/skills/rcc-core/references/rcc-source-recipes.md`
- `plugins/rcc/skills/rcc-robots/references/robot-project-recipes.md`
- `plugins/rcc/skills/rcc-robots/references/rcc-command-recipes.md`
- `plugins/rcc/skills/rcc-workitems/references/workitems-adapters.md`
- `plugins/rcc/skills/action-server/references/action-server-recipes.md`

Update stale hygiene surfaces if they contradict the refreshed docs:

- `plugins/rcc/skills/rcc-robots/assets/templates/package.yaml`
- `plugins/rcc/skills/rcc-robots/assets/templates/hitl-assistant/conda.yaml`
- `plugins/rcc/skills/rcc-robots/assets/templates/conda-browser.yaml`
- `plugins/rcc/skills/rcc-robots/scripts/env_check.py`

After edits, rebuild generated views with:

```bash
python3 scripts/build_marketplaces.py
python3 scripts/build_runtime_views.py
```

Then validate with:

```bash
bin/check
```

## Modern Python Robocorp Library Updates

Refresh `python-library-audit.md` so it is clearly dated May 23, 2026 and reflects current package facts:

- `robocorp` `3.1.1`
- `robocorp-browser` `2.4.0`
- `robocorp-workitems` `1.5.0`
- `robocorp-tasks` `4.1.1`
- `robocorp-log` `3.1.2` as the published PyPI version checked during this review; if the source tree shows newer unreleased metadata, record it separately as source evidence rather than a published-package claim
- `robocorp-vault` `1.4.0`
- `robocorp-storage` `1.1.0`

The audit should include short, copyable examples for:

- `robocorp.tasks`: `@task`, `@setup(scope="session")`, and `get_output_dir()` instead of hardcoded `output/`.
- `robocorp.browser`: isolated Playwright install, `browser.configure(...)`, `configure_context(...)`, persistent-context constraints, and the caveat that a persistent context changes normal context handling.
- `robocorp.workitems`: context-manager release, failure semantics, attachment staging with `outputs.create(..., save=False)`, `add_file(...)`, and `save()`.
- `robocorp.vault`: local `FileSecrets` development through `RC_VAULT_SECRET_MANAGER` and `RC_VAULT_SECRET_FILE`.
- `robocorp.log`: `suppress_variables()` for secret handling and `process_snapshot()` for debugging long-running robots.
- `robocorp.storage`: asset APIs including list, get, set, delete, JSON/text/file/bytes examples.

## RPA Framework Updates

Refresh RPA Framework guidance around current version and package split:

- `rpaframework` is `32.0.0` as of the May 2026 release batch.
- `rpaframework-assistant` is `6.0.0`.
- Current package metadata requires Python `>=3.10`; `rpaframework` currently caps below Python `3.14`.
- `rpaframework-assistant` is a separate dependency for `RPA.Assistant`; it is still useful for desktop/HITL Python workflows, but it should not be treated as part of the base `rpaframework` package.
- `rpaframework.org` can be partially stale. When hosted docs conflict with PyPI or checked source metadata, the RCC docs should say which source is being used for current package claims.

Split guidance into three lanes:

- Modern RCC Python: prefer `robocorp.workitems`, `robocorp.vault`, `robocorp.storage`, `robocorp.browser`, and `robocorp.tasks`.
- Legacy/Robot Framework-first: use `RPA.Robocorp.WorkItems`, `RPA.Robocorp.Vault`, `RPA.Robocorp.Storage`, `RPA.Browser.*`, Robot Framework keywords, and `RPA_*` environment variables when maintaining old robots.
- HITL/desktop Python: use `RPA.Assistant` through `rpaframework-assistant` when a desktop dialog is explicitly part of the workflow.

## Work Items And Adapter Updates

Do not flatten `robocorp-adapters-custom` and `actions-work-items`.

Document this lineage:

- `robocorp-adapters-custom` predates the generalized work-items package and remains the production-proven adapter layer for classic `robocorp.workitems` robot workflows, especially DocumentDB/MongoDB queue families, GridFS attachments, explicit output queues, retry/orphan recovery, and RCC producer/consumer/reporter robots.
- `actions-work-items` is the later generalized package for Action Server and non-robot workflows. It provides Robocorp-style aliases and its own adapter contract.

Refresh `actions-work-items` guidance to `0.2.4`:

- Import aliases: `from actions import workitems`, `from actions_work_items import workitems`, `import actions_work_items as workitems`, and direct `from actions.work_items import inputs, outputs`.
- Extras: `redis`, `docdb`, `documentdb`, and `all`.
- Adapter families: SQLite, File, Redis, and DocumentDB.
- Env vars: `RC_WORKITEM_ADAPTER`, `RC_WORKITEM_QUEUE_NAME`, `RC_WORKITEM_OUTPUT_QUEUE_NAME`, `RC_WORKITEM_FILES_DIR`, `RC_WORKITEM_DB_PATH`, `RC_WORKITEM_INPUT_PATH`, `RC_WORKITEM_OUTPUT_PATH`, `RC_REDIS_URL`, `DOCDB_*`, `RC_WORKITEM_AUTO_APPEND_OUTPUT_SUFFIX`, and `RC_WORKITEM_FILE_SIZE_THRESHOLD`.
- Action Server template behavior: `templates/workflow-producer-consumer`, `ACTION_SERVER_DATADIR` or `SEMA4AI_ACTION_SERVER_DATADIR`, SQLite-backed `RC_WORKITEM_DB_PATH`, `seed_input`, `queue_status`, and the `/api/work-items` UI/API limitation to the community branch's SQLite/datadir path.

Refresh process-pattern guidance:

- Producer reads seed input and creates child outputs.
- Consumer loops inputs and releases each item as done or failed.
- Reporter can consume prior outputs, use a sentinel item, or query prior step work items through a Process API pattern.
- Retry automation should target application/orchestrator/system failures, not business/data failures.
- Local file adapters simulate queue handoff but do not reproduce all hosted scheduling semantics.
- Legacy email flows rely on parsed Control Room email payload/files; raw email paths should be treated as deprecated example history.
- Terminal-marker patterns such as `_TERMINAL_` are examples for process termination flows, not a universal requirement.

## RCC Gateway And Runtime Updates

Expand RCC gateway docs using Josh RCC docs and public Robocorp runtime examples:

- RCC owns the local environment boundary: `robot.yaml`, `conda.yaml`, holotree, dependency export/freeze, bundles, templates, and command execution.
- Control Room-adjacent worker lifecycle is separate: public examples show provider webhooks and runtime linking, not RCC dependency resolution itself.
- Public K8S/Azure on-demand runtime examples expose a small webhook request shape: `start`, `stop`, `status`, `workspaceId`, `runtimeId`, `runtimeLinkToken`, and optional `maxLifetimeSeconds`.
- Public worker examples use env vars such as `RC_WORKER_NAME`, `RC_WORKER_LINK_TOKEN`, `ROBOCORP_HOME`, and `RC_AGENT_TERMINATE_AFTER_RUN_MS`.
- One-time link tokens affect retry semantics; infrastructure retries after token consumption may require a fresh Control Room request.
- Public example provisioners are not production hardening guides. If an example logs request/secret material, the RCC docs must call that out as a caution.

## Action Server And Sema4AI Updates

Refresh Action Server documentation around current packages:

- `sema4ai-action-server` `3.2.0`
- `sema4ai-actions` `1.6.6`
- `sema4ai-mcp` `0.0.3`

Keep examples for:

- `package.yaml` v2.
- `Response[T]`, `ActionError`, typed Pydantic payloads, `Secret`, `OAuth2Secret`, and `SecretSpec`.
- `Request`, `Table`, setup/teardown, and data-query surfaces where the source supports them.
- MCP direct decorators and annotation hints: `read_only_hint`, `destructive_hint`, `idempotent_hint`, and `open_world_hint`.
- Local endpoint checks for `/openapi.json`, `/docs`, `/mcp`, and run inspection.

Refresh the Action Server work-items section to use `actions-work-items>=0.2.4`, not `0.2.1`, and explain when to choose `actions-work-items` versus `robocorp.workitems`.

## Prompting And Routing Updates

Update prompt examples so future agents route requests correctly:

- Use the RCC router skill for gateway questions.
- Use `rcc-core` for RCC source, holotree, endpoint/profile, prebuilt/remote runtime, and public runtime-contract analysis.
- Use `rcc-robots` for `robot.yaml`, `conda.yaml`, Robocorp Python libraries, RPA Framework recipes, and local task debugging.
- Use `rcc-workitems` for producer/consumer/reporter queues, `robocorp-adapters-custom`, `actions-work-items`, custom adapters, and DocumentDB/Redis/local queue flows.
- Use `action-server` for `package.yaml` v2, `sema4ai-actions`, `sema4ai-mcp`, Action Server endpoints, and Action Server work-items templates.

## Validation

Implementation is complete only when:

- Canonical files under `plugins/rcc/skills/...` contain the refreshed guidance.
- Generated runtime views have been rebuilt.
- `bin/check` passes.
- Search checks no longer find stale first-party examples for `actions-work-items=0.2.1`, `rpaframework-assistant==5.0.0`, `rpaframework==31.2.0`, or Python 3.8 guidance unless explicitly preserved as historical context.
- The docs clearly distinguish fact from inference for unreleased Control Room backend behavior.
- No canonical content is manually authored under generated `skills/` or `.agents/skills/` directories.

## Out Of Scope

- Rewriting the whole RCC plugin structure.
- Implementing a Control Room backend.
- Treating private Control Room architecture as public fact.
- Replacing production `robocorp-adapters-custom` guidance with `actions-work-items`.
- Updating unrelated plugins or marketplace metadata unless validation requires generated-view updates.
