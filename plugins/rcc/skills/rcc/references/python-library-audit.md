# Python Library Audit

Use this reference when improving RCC-family skill examples for Python libraries, package pins, or source-backed recipes. It captures the 2026-05-01 audit across official docs, Josh repositories, and upstream Robocorp/Sema4AI repositories.

Recheck sources before making "latest", version-current, or default-template claims. Treat Josh-owned RCC sources as current stack evidence, and upstream Robocorp/Sema4AI docs as package/API evidence unless the task explicitly targets their hosted product.

## Source Snapshot

Official docs and source repos checked:

- Sema4AI actions docs: `https://sema4.ai/docs/build-agents/develop-actions/action-structure`
- Sema4AI Python action/MCP source: `https://github.com/Sema4AI/actions` at `master` / `9d9479e`
- Robocorp Python library docs: `https://sema4.ai/docs/automation/python/robocorp`
- Robocorp Python library source: `https://github.com/robocorp/robocorp` at `master` / `64cc9a3`
- Josh Action Server fork: `https://github.com/joshyorko/actions` at `community` / `7e63577`
- Josh RCC fork: `https://github.com/joshyorko/rcc` at `main` / `2e0e309`
- Sema4AI gallery: `https://github.com/Sema4AI/gallery` at `main` / `d6afd61`

Useful org-level repos found during the scan:

- Sema4AI: `actions`, `gallery`, `cookbook`, `vscode-extension`.
- Robocorp: `robocorp`, `rpaframework`, `template-python`, `template-python-browser`, `template-python-workitems`, `template-python-assistant-ai`, `template-action`, `example-action-server-starter`, `example-advanced-python-template`, `python-producer-consumer-reporting`, `example-web-store-work-items`, `example-asset-storage`, `example-using-vault`, `example-encrypt-workitems`, `example-langchain-data-ingestion`.
- Josh: `actions`, `rcc`, `robot-templates`, `robocorp`, `gallery`, `robocorp_adapters_custom`, `fetch-repos-bot`, `fizzy-symphony`, `linkedin-easy-apply`, `yo-dawg`, `home-lab-actions`, `actions-robot-boostrapper`, `context-eng-copilot`, `rccremote-docker`, `prefect-setup`, `cook-with-gas-rpa-challenge`.

## Library Map

| Surface | Libraries | Use for | Example stance |
| --- | --- | --- | --- |
| Action packages | `sema4ai-actions`, `sema4ai-mcp`, `sema4ai-data` | `@action`, direct MCP tools, named data queries, OpenAPI/MCP exposure | Keep `package.yaml` v2, typed inputs, `Response[T]`, `ActionError`, `Secret`, `OAuth2Secret`, `SecretSpec`, `Request`, and `Table` examples current. |
| RCC robot projects | `robocorp`, `robocorp-tasks`, `robocorp-log`, `robocorp-browser`, `robocorp-workitems`, `robocorp-vault`, `robocorp-storage` | Contained automation run through `robot.yaml` and `conda.yaml` | Keep literal package/API names; RCC owns the environment boundary. |
| Browser automation | `robocorp-browser` | Playwright-backed browser tasks in RCC projects or action packages | Configure before `browser.page()`; use isolated install/post-install for CI; persistent contexts are single-run-sensitive. |
| Work item queues | `robocorp-workitems`, `actions-work-items`, `robocorp-adapters-custom` | Producer/consumer/reporter flows, file/SQLite/custom adapters | Classic robot examples use `robocorp.workitems`; action-package workflows can use `actions-work-items`; adapter-heavy design belongs in `$rcc-workitems`. |
| Secrets and assets | `robocorp-vault`, `robocorp-storage`, `robocorp-log` | Control Room secrets, assets, safe logging | Show mock vault only for local development; hide sensitive values with `robocorp.log`; never put real values in committed `devdata`. |
| Legacy/HITL | `rpaframework`, `rpaframework-assistant`, Robot Framework libraries | Assistant UI, Robot Framework maintenance, older examples | Keep separate from modern Python examples unless the repo actually uses these APIs. |

## Confirmed Gaps To Improve

- `robocorp-storage`: add asset API examples for `list_assets`, `get_text`, `get_json`, `get_file`, `set_text`, `set_json`, `set_file`, and `set_bytes` when a task needs shared runtime state beyond work item payloads.
- `robocorp-vault`: add local FileSecrets development guidance plus `robocorp.log.suppress_variables()` examples for secret rotation or credential generation tasks.
- `robocorp-log`: add `process_snapshot()` and suppression examples for debugging long-running robots without leaking secrets.
- `sema4ai.actions`: broaden examples beyond basic `@action` to include `Request`, `Table`, `SecretSpec`, `setup`, `teardown`, and explicit `ActionError` handling through `Response(error=...)`.
- `sema4ai.mcp`: keep annotation hints visible: `read_only_hint`, `destructive_hint`, `idempotent_hint`, and `open_world_hint`.
- `robocorp-browser`: add persistent-context examples and clarify `browser.configure(install=True, isolated=True)` versus `python -m robocorp.browser install ... --isolated`.
- `actions-work-items`: use Josh's `workflow-producer-consumer` template as community-branch evidence when documenting action-package producer/consumer flows.

## Reference Examples

### Action With Typed Result And Expected Error

```python
from sema4ai.actions import ActionError, Response, action


@action(is_consequential=False)
def normalize_order(order_id: str) -> Response[dict[str, str]]:
    if not order_id.strip():
        raise ActionError("order_id is required")
    return Response(result={"order_id": order_id.strip().upper()})
```

Use `ActionError` for expected user/data failures. Unexpected exceptions should remain real failures unless the action contract explicitly returns a typed error payload.

### Request-Aware Action

```python
from sema4ai.actions import Request, Response, action


@action
def caller_info(request: Request) -> Response[dict[str, str | None]]:
    return Response(result={"request_id": request.headers.get("x-request-id")})
```

Use `Request` only when action behavior needs invocation metadata. Keep normal business inputs as typed function parameters.

### Data Query Shape

```python
from sema4ai.actions import Response, Table
from sema4ai.data import get_connection, query


@query
def recent_orders() -> Response[Table]:
    result_set = get_connection().query("select id, status from orders limit 20")
    return Response(result=result_set.to_table())
```

Prefer `Response[Table]` for named data queries so tabular results stay structured instead of becoming large plain strings.

### Direct MCP Tool

```python
from sema4ai.mcp import tool


@tool(read_only_hint=True, open_world_hint=False)
def add(a: int, b: int) -> int:
    return a + b
```

Use direct `sema4ai.mcp` only when the package intentionally defines MCP tools/resources/prompts. Ordinary `@action` packages are exposed by Action Server through `/mcp`.

### Robot Task With Setup And Output Directory

```python
from pathlib import Path

from robocorp.tasks import get_output_dir, setup, task


@setup(scope="session")
def prepare_output(tasks):
    Path(get_output_dir()).mkdir(parents=True, exist_ok=True)


@task
def write_report() -> None:
    Path(get_output_dir(), "report.txt").write_text("ok", encoding="utf-8")
```

Use `get_output_dir()` instead of hardcoded `output/` when task code needs the RCC/runtime artifact directory.

### Browser With Isolated Install And Persistent Context

```python
from robocorp import browser
from robocorp.tasks import task


browser.configure(
    browser_engine="chromium",
    headless=True,
    install=True,
    isolated=True,
    persistent_context_directory="output/browser-context",
)


@task
def capture() -> None:
    page = browser.goto("https://example.com")
    page.screenshot(path="output/example.png")
```

Persistent contexts should not be shared by parallel runs. For CI, prefer fresh contexts unless session reuse is the feature under test.

### Work Items With Failure Semantics

```python
from robocorp import workitems
from robocorp.tasks import task


@task
def consume() -> None:
    for item in workitems.inputs:
        with item:
            if "id" not in item.payload:
                raise workitems.BusinessException(
                    code="MISSING_ID",
                    message="Input payload is missing id.",
                )
            workitems.outputs.create({"id": item.payload["id"], "status": "done"})
```

`BusinessException` marks non-retryable data/business failures. Use `ApplicationException` for retryable technical failures.

### Local Work Item File Adapter

```text
RC_WORKITEM_ADAPTER=FileAdapter
RC_WORKITEM_INPUT_PATH=devdata/work-items-in/test-input/work-items.json
RC_WORKITEM_OUTPUT_PATH=devdata/work-items-out/last-run/work-items.json
```

This is the modern Python `robocorp.workitems` file-adapter env family. Do not mix it with legacy `RPA_WORKITEMS_*` variables unless bridging older Robot Framework code.

### Vault Mock Plus Secret Suppression

```python
from robocorp import log, vault
from robocorp.tasks import task


@task
def rotate_token() -> None:
    with log.suppress_variables():
        secret = vault.get_secret("service-account")
        secret["token"] = "new-token-from-provider"
        vault.set_secret(secret)
```

For local mock vault only:

```text
RC_VAULT_SECRET_MANAGER=FileSecrets
RC_VAULT_SECRET_FILE=/absolute/path/to/dev-secrets.yaml
```

Mock vault files are development fixtures, not safe secret stores.

### Asset Storage

```python
from robocorp import storage
from robocorp.tasks import task


@task
def update_state() -> None:
    state = storage.get_json("workflow-state")
    state["last_status"] = "ok"
    storage.set_json("workflow-state", state)
```

Use asset storage for shared state or binary/text assets that are not a queue item. Use work item attachments when the data should follow a specific item through a process.

### Action Package Work Items

```python
from actions.work_items import inputs, outputs
from sema4ai.actions import Response, action


@action
def consume(max_items: int = 10) -> Response[dict[str, int]]:
    processed = 0
    for item in inputs:
        if processed >= max_items:
            break
        with item:
            outputs.create({"source": item.payload, "status": "done"})
            processed += 1
    return Response(result={"processed": processed})
```

Use `actions-work-items` for action-package-centered workflows. Use `robocorp.workitems` for classic RCC robot flows.

## Repo Scan Notes

- `joshyorko/actions` branch `community` adds `templates/workflow-producer-consumer/` and includes it in `templates/packaging/templates-prod.json`; upstream `Sema4AI/actions` at the checked commit lists only minimal/basic/advanced/data-access templates there.
- `joshyorko/actions` includes Action Server RCC utility code under `action_server/src/sema4ai/action_server/_rcc_robot_utils.py`, useful when documenting package/robot discovery and Action Server calling RCC.
- `Sema4AI/gallery` is better for real action package shape, auth patterns, models, and `package.yaml` layout than for low-level library API docs.
- `Sema4AI/cookbook` contains agent/action blueprints and invocation-context examples. Use it for higher-level patterns, not package API authority.
- `joshyorko/rcc` docs emphasize isolated Python automation packages, endpoint overrides, dependency export/freeze flow, `rcc task script`, uv-native mode, and holotree caching. Use these to keep Python-library guidance tied to the actual runtime boundary.
- Robocorp example/template repos still have useful recipes, but many are historical or Robot Framework-first. Prefer modern Python templates first, then legacy examples only when maintaining old code.

## Refresh Commands

Run from the Bluefin host or a repo devcontainer with `git` and authenticated `gh`:

```bash
audit_dir="/tmp/agent-skills-python-library-audit-$(date +%Y%m%d)"
mkdir -p "$audit_dir"
git clone --depth 1 --branch community https://github.com/joshyorko/actions.git "$audit_dir/joshyorko-actions-community"
git clone --depth 1 https://github.com/Sema4AI/actions.git "$audit_dir/sema4ai-actions"
git clone --depth 1 https://github.com/joshyorko/rcc.git "$audit_dir/joshyorko-rcc"
git clone --depth 1 https://github.com/robocorp/robocorp.git "$audit_dir/robocorp"
git clone --depth 1 https://github.com/Sema4AI/gallery.git "$audit_dir/sema4ai-gallery"
gh repo list Sema4AI --limit 100 --json name,description,isArchived,updatedAt,url,primaryLanguage
gh repo list robocorp --limit 100 --json name,description,isArchived,updatedAt,url,primaryLanguage
gh repo list joshyorko --limit 200 --json name,description,isArchived,updatedAt,url,primaryLanguage
```

After refreshing, update this file and `references/source-map.md` with new commit ids before changing examples or pin guidance.
