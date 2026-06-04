# RCC Dagger MCP Bridge

Use this when an agent needs access to Josh's existing RCC Dagger runner through MCP.

The bridge does not embed RCC source code. It starts Dagger from the agent host and points Dagger at a local RCC checkout through `RCC_DAGGER_REPO`.

## Runtime Boundary

- Host: the MCP client starts `plugins/rcc/skills/rcc/scripts/rcc-dagger-mcp`.
- Dagger: runs the RCC module from `RCC_DAGGER_REPO`.
- RCC function work: runs in Dagger containers defined by the RCC checkout's `.dagger/` module.

Do not hide the RCC checkout path. If the path is wrong or absent, fix the MCP registration rather than guessing.

## Codex Registration

On Josh's Bluefin host, with the usual RCC checkout:

```bash
codex mcp add rcc-dagger \
  --env RCC_DAGGER_REPO=/var/home/kdlocpanda/second_brain/Projects/automation-control-plane/rcc \
  -- /var/home/kdlocpanda/src/agent-skills/plugins/rcc/skills/rcc/scripts/rcc-dagger-mcp
```

For another machine, change `RCC_DAGGER_REPO` and the script path to local absolute paths.

Codex loads MCP server definitions when a session starts, so start a new Codex session after adding or changing this server.

Verify registration:

```bash
codex mcp get rcc-dagger
```

Verify the Dagger module itself from the RCC checkout:

```bash
dagger functions
dagger call rcc --source . --c "version"
```

## Dagger MCP Surface

Dagger's MCP server exposes a generic method interface:

- `ListMethods`
- `SelectMethods`
- `CallMethod`
- `ChainMethods`
- `ReadLogs`

Agents should call `ListMethods` first, then select and call the RCC module methods they need. In the current RCC Dagger module, the useful methods are:

| Method | Use |
|--------|-----|
| `rcc` | Run an RCC command in the Dagger container and return stdout. |
| `rcc-with-output` | Run an RCC command and return a directory from the container. |
| `run-robot-tests` | Run the RCC Robot Framework acceptance suite through the Dagger test container. |

The Dagger docs note that externally exposed MCP currently supports modules with no required constructor arguments. The RCC module fits that shape.
