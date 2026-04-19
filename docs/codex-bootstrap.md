# Codex Bootstrap

This repository can be installed once per machine and reused across projects without copying skills into each repo. The bootstrap scripts set up a user-level marketplace and global skills so Codex can discover everything from this repo no matter which project you are working in.

## Concepts

- **Plugins** package skills plus metadata. A user-level marketplace entry points Codex at each plugin in `plugins/`.
- **Skills** live under each plugin’s `skills/` directory. The installer exposes them globally via `~/.codex/skills` so they are available in any repo.
- **Repo-local vs global**: keep `agent-skills` cloned in a stable path (default `~/src/agent-skills`) and let the installer wire it into your user directories. Your active project stays clean.

## Install

Run from anywhere. The public entrypoints acquire the repo into a stable local path and then delegate to the repo-local installer.

**macOS/Linux (bash):**

```bash
curl -fsSL https://raw.githubusercontent.com/joshyorko/agent-skills/main/install.sh | bash
```

Pinned install:

```bash
curl -fsSL https://raw.githubusercontent.com/joshyorko/agent-skills/main/install.sh | bash -s -- --ref v1.2.3
```

**Windows (PowerShell):**

```powershell
irm https://raw.githubusercontent.com/joshyorko/agent-skills/main/install.ps1 | iex
```

Pinned install:

```powershell
$env:AGENT_SKILLS_REF = "v1.2.3"
irm https://raw.githubusercontent.com/joshyorko/agent-skills/main/install.ps1 | iex
```

The remote entrypoints prefer git when it is available and fall back to release archives when it is not. On Windows, `SkillMode=auto` will transparently fall back from symlink to copy if symlinks are blocked.

### Manual fallback

If you prefer to manage the checkout yourself, clone the repo and run the local installer directly:

```bash
if [ ! -d ~/src/agent-skills/.git ]; then git clone https://github.com/joshyorko/agent-skills.git ~/src/agent-skills; fi && bash ~/src/agent-skills/scripts/install-codex-assets.sh --repo-path ~/src/agent-skills
```

```powershell
if (-not (Test-Path "$HOME/src/agent-skills/.git")) { git clone https://github.com/joshyorko/agent-skills.git "$HOME/src/agent-skills" } ; pwsh -File "$HOME/src/agent-skills/scripts/install-codex-assets.ps1" -RepoPath "$HOME/src/agent-skills"
```

What it does:

- Materializes `agent-skills` at `~/src/agent-skills` by cloning with git or downloading a release archive.
- Defaults to the latest release. Use `--ref` or `AGENT_SKILLS_REF` to pin a release tag.
- Registers this repo as a local Codex marketplace via `codex marketplace add "$REPO_PATH"`, keeping plugin paths relative to the repo root.
- Installs all skills into `~/.codex/skills` using `auto`, `link`, or `copy` mode. In `auto`, the installer prefers symlinks and falls back to copies when needed.
- Writes install state to `~/.codex/state/agent-skills.json` so uninstall can target only the managed marketplace and skill entries.
- Prints whether marketplace registration actually succeeded, was skipped, or failed, along with the manual `codex marketplace add` command when needed.

Common options:

- `--repo-path ~/code/agent-skills` — change clone location.
- `--codex-home ~/.codex-custom` — change the Codex user directory.
- `--marketplace-name my-agent-skills` — customize the marketplace entry name.
- `--install-method archive` — force archive mode even if git is installed.
- `--skill-mode copy` — copy skills instead of symlinking.
- `--force` — replace conflicting skill entries.

After install, restart Codex and run `/plugins` to confirm the marketplace is visible.

## Uninstall

Remove the Codex marketplace registration plus any symlinks (and matching copy-mode installs when `--force` is provided). Legacy `~/.agents/plugins/marketplace.json` entries are also cleaned up:

```bash
bash ~/src/agent-skills/scripts/uninstall-codex-assets.sh --repo-path ~/src/agent-skills
```

## Devcontainer example

To bootstrap automatically inside a devcontainer, add a `postCreateCommand`:

```jsonc
{
  "postCreateCommand": "curl -fsSL https://raw.githubusercontent.com/joshyorko/agent-skills/main/install.sh | bash"
}
```

This keeps the devcontainer workspace clean while exposing the full plugin catalog globally.
