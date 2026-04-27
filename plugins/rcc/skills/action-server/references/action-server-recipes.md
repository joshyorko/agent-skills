# Action Server Recipes

Use this guide for Action Server packages, MCP tools, secrets, Sema4AI-compatible package APIs, and Josh's `actions` community fork.

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

dependencies:
  conda-forge:
    - python=3.12.11
    - uv=0.11.8
  pypi:
    - sema4ai-actions=1.6.6
    - sema4ai-mcp=0.0.3
    - requests>=2.32.0
    - pydantic>=2.11.7

pythonpath:
  - src
  - tests

dev-dependencies:
  pypi:
    - pytest=8.3.3
    - ruff=0.8.6

dev-tasks:
  test: pytest tests -v
  lint: ruff check src tests
```

`package.yaml` v2 is the documented package format shown in the official Action Server docs fetched for this refresh.

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
from sema4ai.actions import Response, Secret, action


class LookupResponse(Response):
    status: str
    value: str


@action(is_consequential=False)
def lookup(customer_id: str, token: Secret) -> LookupResponse:
    """Return customer data for the given id."""
    return LookupResponse(status="ok", value=customer_id)
```

Use typed `Response` subclasses for structured outputs. Mark side-effecting actions with `is_consequential=True`.

## MCP

```python
from sema4ai.mcp import prompt, resource, tool


@tool
def add(a: int, b: int) -> int:
    return a + b


@resource("tickets://{ticket_id}")
def ticket_resource(ticket_id: str) -> dict[str, str]:
    return {"ticket_id": ticket_id}


@prompt
def triage_prompt(summary: str) -> str:
    return f"Triage this ticket: {summary}"
```

Action Server exposes MCP through the local `/mcp` endpoint when MCP packages are present.

## Secrets

Use official `Secret` and `OAuth2Secret` parameter types. Do not pass secrets as plain strings in action signatures or sample payloads.

```python
from sema4ai.actions import OAuth2Secret, Secret, action


@action
def call_api(api_token: Secret) -> str:
    return "ok"


@action
def call_oauth(account: OAuth2Secret) -> str:
    return "ok"
```

## Tests And Dev Tasks

- Put tests under `tests/`.
- Keep `dev-dependencies` and `dev-tasks` in `package.yaml`.
- Run `action-server start` for endpoint/manual validation.
- Run dev tasks for local checks, for example `pytest tests -v` and `ruff check src tests`.

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
