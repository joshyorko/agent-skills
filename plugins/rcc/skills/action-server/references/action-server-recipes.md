# Action Server Recipes

Use this guide for Action Server packages, MCP tools, secrets, Sema4AI-compatible package APIs, and Josh's `actions` community fork.

For cross-source Python library evidence, current example gaps, and refresh commands, see `../../rcc/references/python-library-audit.md`.

## Source Build From Josh's Fork

The inspected `joshyorko/actions` checkout is on branch `community`. It keeps Sema4AI action/MCP packages and adds a community `actions-work-items` package.

Common build commands from the repo:

```bash
rcc run -r action_server/developer/toolkit.yaml -t community
cd action_server/frontend
inv build-frontend --tier=community
```

Use source builds when you need the community fork behavior. For ordinary action-package authoring, a PyPI Action Server install is usually enough.

## package.yaml v2

```yaml
spec-version: v2

name: my-actions
description: Custom AI actions and MCP tools
version: 0.0.1

external-endpoints:
  - name: "Public API"
    description: "Calls an external HTTPS API."
    additional-info-link: "https://docs.example.com/api"
    rules:
      - host: "api.example.com"
        port: 443

dependencies:
  conda-forge:
    - python=3.12.11
    - uv=0.11.8
  pypi:
    - sema4ai-actions=1.6.6
    - sema4ai-mcp=0.0.3
    - requests=2.32.5
    - pydantic=2.11.7

post-install:
  - python -m robocorp.browser install chrome --isolated

pythonpath:
  - src
  - tests

dev-dependencies:
  pypi:
    - pytest=8.3.3
    - ruff=0.8.6
    - mypy=1.16.0

dev-tasks:
  test: pytest tests -v
  lint: |
    ruff check src tests
    ruff format --check src tests
  typecheck: mypy --strict src tests

packaging:
  exclude:
    - ./.git/**
    - ./.vscode/**
    - ./devdata/**
    - ./output/**
    - ./.venv/**
    - ./**/*.pyc
    - ./**/.env
```

`package.yaml` v2 is the documented package format shown in the official Action Server docs fetched for this refresh.
The official package guide marks `version` as required and documents exact dependency pins with `=`.
For `external-endpoints`, `name` and `description` are required. `rules`, `host`, and `port` are deployment policy details; `port` must be an integer from `0` to `65535`.

## Run And Inspect

```bash
action-server new
action-server start
action-server start --actions-sync=false --datadir ./.action-server
python -m sema4ai.actions run actions.py
python -m sema4ai.actions run . -t my_action --json-input input.json
```

Default local endpoints:

```text
http://localhost:8080/openapi.json
http://localhost:8080/docs
http://localhost:8080/mcp
http://localhost:8080/runs
```

When serving multiple action directories, import them into one datadir and start with sync disabled:

```bash
action-server import --dir=./actions-a --datadir=./.action-server
action-server import --dir=./actions-b --datadir=./.action-server
action-server start --actions-sync=false --datadir=./.action-server
```

## Actions

```python
from typing import Annotated

from pydantic import BaseModel, Field
from sema4ai.actions import ActionError, Response, Secret, action


CustomerId = Annotated[str, Field(description="Customer identifier")]


class LookupResult(BaseModel):
    status: str
    value: str


@action(is_consequential=False)
def lookup(customer_id: CustomerId, token: Secret) -> Response[LookupResult]:
    """Return customer data for the given id."""
    if not customer_id:
        raise ActionError("Missing customer_id")
    return Response(result=LookupResult(status="ok", value=customer_id))
```

Use Pydantic models for payloads and return `Response[T]`. Mark side-effecting actions with `is_consequential=True`. Use `Annotated`, `Field`, and `Literal` when they make tool schemas clearer.

## API Client Pattern

Keep request/session logic outside the action function, and turn remote failures into `ActionError` or typed response errors.

```python
import os

import requests
from sema4ai.actions import ActionError, Response, Secret, action


def _token_value(token: Secret | None) -> str:
    value = token.value if token else os.getenv("API_TOKEN", "")
    if not value:
        raise ActionError("Missing API token")
    return value


@action(is_consequential=False)
def fetch_record(record_id: str, api_token: Secret | None = None) -> Response[dict]:
    response = requests.get(
        f"https://api.example.com/records/{record_id}",
        headers={"Authorization": f"Bearer {_token_value(api_token)}"},
        timeout=30,
    )
    if response.status_code >= 400:
        raise ActionError(f"API request failed: {response.status_code}")
    return Response(result=response.json())
```

For paginated APIs, keep the cursor/ETag/next URL in a typed response model so callers can continue safely.

## MCP

Two MCP modes matter:

- Ordinary `@action` packages are exposed by Action Server through `/mcp`.
- Direct `sema4ai.mcp` decorators define MCP tools/resources/prompts in code.
- `@action` and `@tool` are reciprocally exposed by Action Server. Current Action Server versions expose action MCP tool names as the action name.
- `/mcp` is the primary streamable HTTP MCP endpoint; older `/sse` references are historical compatibility.

```python
from sema4ai.mcp import prompt, resource, tool


@tool(read_only_hint=True, open_world_hint=False)
def add(a: int, b: int) -> int:
    return a + b


@resource("tickets://{ticket_id}", mime_type="application/json")
def ticket_resource(ticket_id: str) -> dict[str, str]:
    return {"ticket_id": ticket_id}


@prompt
def triage_prompt(summary: str) -> str:
    return f"Triage this ticket: {summary}"
```

Action Server exposes MCP through the local `/mcp` endpoint when MCP packages are present.
Tool annotations can include `read_only_hint`, `destructive_hint`, `idempotent_hint`, and `open_world_hint`.

## Secrets

Use official `Secret` and `OAuth2Secret` parameter types. Do not pass secrets as plain strings in action signatures or sample payloads.

```python
from typing import Literal

from sema4ai.actions import OAuth2Secret, Secret, SecretSpec, action


class DocumentIntelligenceSecret(SecretSpec):
    token: Secret
    endpoint: Secret


@action
def call_api(api_token: Secret) -> str:
    return "ok"


@action
def call_oauth(account: OAuth2Secret) -> str:
    return "ok"


@action
def call_google(
    account: OAuth2Secret[
        Literal["google"],
        list[Literal["https://www.googleapis.com/auth/calendar.readonly"]],
    ],
) -> str:
    return account.access_token[:4]
```

Local examples may read `.env` values for development, but new package guidance should prefer `Secret`/`OAuth2Secret` and exclude `.env` from packaging.
MCP-style clients can pass secrets by environment variable or header, for example `MY_SECRET` or `X-My-Secret`. OAuth setup commands worth knowing:

```bash
action-server start --oauth2-settings oauth2-settings.json
action-server oauth2 sema4ai-config
action-server oauth2 user-config-path
```

## Tests And Dev Tasks

- Put tests under `tests/`.
- Keep `dev-dependencies` and `dev-tasks` in `package.yaml`.
- Run `action-server start` for endpoint/manual validation.
- Prefer Action Server's environment for checks:

```bash
action-server devenv task test
action-server devenv task lint
action-server devenv task typecheck
```

Raw `pytest` or `ruff` is fine inside the project environment, but do not accidentally use host Python when the package depends on Action Server/RCC environment resolution.
Dev tasks are split with `shlex`, not run through a shell. Avoid `cd`, `&&`, pipes, redirection, and shell env expansion inside `dev-tasks`; put shell-heavy flows in scripts.

## Browser, Database, And Large Packages

Browser action packages usually need either `robocorp-browser` or direct Playwright/browser-use dependencies plus a `post-install` browser install. Prefer `python -m robocorp.browser install chrome --isolated` for `robocorp-browser`; use direct Playwright install commands only for direct Playwright packages. Keep browser outputs under `output/` and exclude generated files from packaging.

Large packages often combine API clients, browser automation, database drivers, and AI SDKs. Add focused dev tasks for the risky surfaces:

```yaml
dev-tasks:
  test: pytest tests -v
  test-db: pytest tests/test_db_sqlite.py -v
  lint: |
    ruff check src tests
    ruff format --check src tests
  typecheck: mypy --follow-imports=silent --strict src tests
```

For SQLite tests, isolate the database path with an env var and clean `-wal`/`-shm` files between cases.

## Deployment

Docker images commonly import actions at build time, then run with sync disabled:

```dockerfile
RUN action-server import --dir /app/actions --datadir /app/.action-server
CMD ["action-server", "start", "--expose", "--address", "0.0.0.0", "--datadir", "/app/.action-server", "--actions-sync=false"]
```

Persist the datadir in compose/Kubernetes when runs, auth, or imported package state must survive container restarts. Keep API keys and secrets in the platform secret store, not image layers.
Use `--api-key` in exposed deployments; `--api-key None` is only for controlled local/no-auth contexts. Use `--full-openapi-spec` when validating internal run/artifact endpoints. Current Action Server writes `server-info.json` under the datadir, and container builds can set `SEMA4AI_OPTIMIZE_FOR_CONTAINER=1`.

## Wrapping RCC Robots As Actions

When an action package launches RCC robots or other local processes:

- Validate `robot.yaml` exists before spawning.
- Set `cwd` to the robot root.
- Build an explicit env and mask secret-looking keys in logs.
- Use timeouts and capture stdout/stderr.
- Return a structured execution report with command, task, return code, elapsed time, and artifact paths.
- Cross-reference robot `devTasks` so callers can run diagnostics separately from business tasks.

## Work Items In Actions

For Josh's community workflow template:

```yaml
dependencies:
  conda-forge:
    - python=3.12.11
    - uv=0.11.8
  pypi:
    - sema4ai-actions=1.6.6
    - actions-work-items=0.2.1
```

```python
from actions.work_items import inputs, outputs

for item in inputs:
    with item:
        outputs.create({"processed": True, "source": item.payload})
```

Use `actions-work-items` for action-server-centered producer/consumer flows. Use `robocorp.workitems` for classic Robocorp robot flows.
