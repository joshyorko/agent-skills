# Codex Bootstrap

This repository can be installed once per machine and reused across projects without copying skills into each repo. The bootstrap scripts set up a user-level marketplace and global skills so Codex can discover everything from this repo no matter which project you are working in.

## Concepts

- **Plugins** package skills plus metadata. A user-level marketplace entry points Codex at each plugin in `plugins/`.
- **Skills** live under each plugin’s `skills/` directory. The installer exposes them globally via `~/.codex/skills` so they are available in any repo.
- **Repo-local vs global**: keep `agent-skills` cloned in a stable path (default `~/src/agent-skills`) and let the installer wire it into your user directories. Your active project stays clean.

## Install

Run from anywhere. On a fresh machine, clone into the stable path first and then run the installer from that checkout:

```bash
if [ ! -d ~/src/agent-skills/.git ]; then git clone https://github.com/joshyorko/agent-skills.git ~/src/agent-skills; fi && bash ~/src/agent-skills/scripts/install-codex-assets.sh --repo-path ~/src/agent-skills
```

After the repo exists at `~/src/agent-skills`, the installer is idempotent and safe to re-run:

```bash
bash ~/src/agent-skills/scripts/install-codex-assets.sh --repo-path ~/src/agent-skills
```

What it does:

- Clones or updates `agent-skills` to `~/src/agent-skills` (override with `--repo-path`).
- Registers a user-level marketplace entry in `~/.agents/plugins/marketplace.json` that points at this repo’s plugins.
- Symlinks all skills into `~/.codex/skills` (use `--copy` if you prefer copies). Conflicting entries are left untouched unless you pass `--force`.

Common options:

- `--repo-path ~/code/agent-skills` — change clone location.
- `--codex-home ~/.codex-custom` — change the Codex user directory.
- `--marketplace-name my-agent-skills` — customize the marketplace entry name.
- `--copy` — copy skills instead of symlinking (requires `--force` to replace existing copies).

After install, restart Codex and run `/plugins` to confirm the marketplace is visible.

## Uninstall

Remove marketplace entries and any symlinks (and matching copy-mode installs when `--force` is provided):

```bash
bash ~/src/agent-skills/scripts/uninstall-codex-assets.sh --repo-path ~/src/agent-skills
```

## Devcontainer example

To bootstrap automatically inside a devcontainer, add a `postCreateCommand`:

```jsonc
{
  "postCreateCommand": "if [ ! -d ~/src/agent-skills/.git ]; then git clone https://github.com/joshyorko/agent-skills.git ~/src/agent-skills; fi && bash ~/src/agent-skills/scripts/install-codex-assets.sh --repo-path ~/src/agent-skills"
}
```

This keeps the devcontainer workspace clean while exposing the full plugin catalog globally.
