# Robocorp Python Libraries (robocorp.*)

Use this when documenting or building robots with the Robocorp Python stack (not the RPA Framework `RPA.*` libraries). These packages are maintained in the `robocorp` repository and documented in the Robocorp/Sema4 docs.

**Core packages (metapackage)**
- `robocorp` metapackage bundles `robocorp.tasks`, `robocorp.log`, `robocorp.workitems`, `robocorp.vault`, and `robocorp.storage`.
- Install as a single dependency when you want the default Robocorp Python stack.

**Key libraries**
- `robocorp.tasks`: task entry points and discovery for Python robots.
- `robocorp.log`: structured logging and HTML log generation controls.
- `robocorp.workitems`: input/output work items for Control Room queues.
- `robocorp.vault`: secrets management in Control Room.
- `robocorp.storage`: assets management in Control Room.
- `robocorp.browser`: Playwright-based browser automation.
- `robocorp.windows`: Windows desktop automation.
- `robocorp.excel`: Excel file read/write for `.xlsx` and `.xls`.

**Minimal example (tasks + log + workitems)**
```python
from robocorp.tasks import task
from robocorp import log, workitems

@task
def process_items():
    log.info("Starting processing")
    for item in workitems.inputs:
        try:
            payload = item.payload
            log.info("Processing payload")
            item.done()
        except Exception as exc:
            item.fail(exception_type="APPLICATION", message=str(exc))
```

**Dependency placement**
Add `robocorp` (or individual packages) to your `conda.yaml` pip section. Libraries not in the metapackage (`robocorp.browser`, `robocorp.windows`, `robocorp.excel`) should be added explicitly.

```yaml
dependencies:
  - python=3.12.11
  - uv=0.9.28
  - pip:
      - robocorp
```

**RPA Framework vs Robocorp**
- `RPA.*` libraries live in the RPA Framework and are used with Robot Framework and Python.
- `robocorp.*` libraries are the Python-native automation stack.
- You can use both in the same robot when needed, but keep dependencies explicit.

**References**
- RPA Framework site: https://rpaframework.org/
- Robocorp Python stack repo: https://github.com/robocorp/robocorp
