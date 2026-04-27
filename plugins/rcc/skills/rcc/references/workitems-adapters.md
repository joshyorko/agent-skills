# Work Items And Adapters

Use this guide for producer/consumer queues, classic Robocorp work items, `actions-work-items`, and custom adapters.

## Classic robocorp.workitems

```python
from robocorp import workitems
from robocorp.tasks import task


@task
def producer() -> None:
    workitems.outputs.create({"id": "one", "status": "new"})


@task
def consumer() -> None:
    for item in workitems.inputs:
        with item:
            payload = item.payload
            workitems.outputs.create({"processed": True, "source": payload})
```

Use `with item:` so input items are released consistently. Raise business errors for non-retryable data problems and application errors for retryable technical failures.

## actions-work-items

Josh's `actions` community branch includes `actions-work-items`, a drop-in style package for producer/consumer workflows outside classic robots.

```python
from actions.work_items import BusinessException, inputs, outputs

for item in inputs:
    with item:
        if "id" not in item.payload:
            raise BusinessException("Missing id")
        outputs.create({"id": item.payload["id"], "processed": True})
```

Default local SQLite adapter:

```python
from actions.work_items import SQLiteAdapter, init

adapter = SQLiteAdapter(
    db_path="./workitems.db",
    queue_name="default",
    files_dir="./work_item_files",
)
init(adapter)
```

Environment variables used by the SQLite/file local adapters:

```text
RC_WORKITEM_DB_PATH
RC_WORKITEM_QUEUE_NAME
RC_WORKITEM_OUTPUT_QUEUE_NAME
RC_WORKITEM_FILES_DIR
RC_WORKITEM_INPUT_PATH
RC_WORKITEM_OUTPUT_PATH
```

## Custom Adapter Contract

Custom adapters follow the Robocorp work item adapter shape:

- `reserve_input() -> str`
- `release_input(item_id, state, exception=None)`
- `create_output(parent_id, payload=None) -> str`
- `load_payload(item_id)`
- `save_payload(item_id, payload)`
- `list_files(item_id)`
- `get_file(item_id, name)`
- `add_file(item_id, name, path_or_content)`
- `remove_file(item_id, name)`

Adapter implementations should make reservation, release, payload, and file behavior testable independently. Use local SQLite or file adapters in CI before testing distributed backends.

## robocorp-adapters-custom

Josh's `robocorp_adapters_custom` repo provides these adapters:

- SQLite: `robocorp_adapters_custom._sqlite.SQLiteAdapter`
- Redis: `robocorp_adapters_custom._redis.RedisAdapter`
- DocumentDB/MongoDB: `robocorp_adapters_custom._docdb.DocumentDBAdapter`
- Yorko Control Room: `robocorp_adapters_custom._yorko_control_room.YorkoControlRoomAdapter`

Common SQLite env file:

```json
{
  "RC_WORKITEM_ADAPTER": "robocorp_adapters_custom._sqlite.SQLiteAdapter",
  "RC_WORKITEM_DB_PATH": "devdata/work_items.db",
  "RC_WORKITEM_FILES_DIR": "devdata/work_item_files",
  "RC_WORKITEM_QUEUE_NAME": "default",
  "RC_WORKITEM_OUTPUT_QUEUE_NAME": "default_output"
}
```

Common Redis env file:

```json
{
  "RC_WORKITEM_ADAPTER": "robocorp_adapters_custom._redis.RedisAdapter",
  "REDIS_HOST": "localhost",
  "REDIS_PORT": "6379",
  "RC_WORKITEM_QUEUE_NAME": "default"
}
```

Common DocumentDB/MongoDB env file:

```json
{
  "RC_WORKITEM_ADAPTER": "robocorp_adapters_custom._docdb.DocumentDBAdapter",
  "DOCDB_HOSTNAME": "localhost",
  "DOCDB_PORT": "27017",
  "DOCDB_DATABASE": "workitems",
  "DOCDB_USERNAME": "user",
  "DOCDB_PASSWORD": "password"
}
```

## Local Queue Semantics

- SQLite is persistent and good for local/CI producer-consumer tests.
- File adapters are closest to Control Room JSON input/output fixtures and are best for tiny deterministic tests.
- Redis and DocumentDB support distributed workers but add service availability and locking/failure modes.
- Keep queue name and output queue name explicit in env files when multiple roles share one database.

## Validation Commands

```bash
rcc run -t Producer -e devdata/env-sqlite-producer.json
rcc run -t Consumer -e devdata/env-sqlite-consumer.json
rcc run -t Reporter -e devdata/env-sqlite-for-reporter.json
rcc run --dev -t CheckSQLiteDB
```

When a consumer sees no work, inspect the adapter env file, queue names, database path, and whether the producer released output items into the same backend.
