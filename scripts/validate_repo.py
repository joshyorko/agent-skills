#!/usr/bin/env python3
from __future__ import annotations

import json
import sys
from pathlib import Path


ROOT = Path(__file__).resolve().parents[1]
CATALOG_PATH = ROOT / "marketplaces" / "catalog.json"


def fail(message: str) -> None:
    raise SystemExit(message)


def load_json(path: Path) -> dict:
    return json.loads(path.read_text())


def main() -> int:
    catalog = load_json(CATALOG_PATH)
    plugins = catalog["plugins"]
    seen_skills: dict[str, str] = {}
    expected_standalone_entries: dict[str, Path] = {}
    expected_agent_entries: dict[str, Path] = {}

    for plugin in plugins:
        plugin_root = ROOT / "plugins" / plugin["name"]
        codex_manifest_path = plugin_root / ".codex-plugin" / "plugin.json"
        claude_manifest_path = plugin_root / ".claude-plugin" / "plugin.json"
        if not codex_manifest_path.exists():
            fail(f"missing codex manifest: {codex_manifest_path}")
        if not claude_manifest_path.exists():
            fail(f"missing claude manifest: {claude_manifest_path}")

        codex_manifest = load_json(codex_manifest_path)
        if codex_manifest["name"] != plugin["name"]:
            fail(f"plugin manifest name mismatch for {plugin['name']}")

        skills_root = plugin_root / codex_manifest["skills"].removeprefix("./")
        if not skills_root.exists():
            fail(f"missing skills path for {plugin['name']}: {skills_root}")

        for skill_dir in sorted(p for p in skills_root.iterdir() if p.is_dir()):
            if skill_dir.name in seen_skills:
                fail(f"duplicate skill name {skill_dir.name} in {plugin['name']} and {seen_skills[skill_dir.name]}")
            seen_skills[skill_dir.name] = plugin["name"]
            expected_agent_entries[skill_dir.name] = skill_dir
            expected_standalone_entries[skill_dir.name] = skill_dir
            if not (skill_dir / "SKILL.md").exists():
                fail(f"missing SKILL.md in {skill_dir}")

    for name, target in expected_agent_entries.items():
        link_path = ROOT / ".agents" / "skills" / name
        if not link_path.is_symlink():
            fail(f"missing skill symlink: {link_path}")
        if link_path.resolve() != target.resolve():
            fail(f"incorrect skill symlink: {link_path}")
    actual_agent_entries = {path.name for path in (ROOT / ".agents" / "skills").iterdir()}
    if actual_agent_entries != set(expected_agent_entries):
        fail("unexpected entries found in .agents/skills")

    for name, target in expected_standalone_entries.items():
        link_path = ROOT / "skills" / name
        if not link_path.is_symlink():
            fail(f"missing standalone skill symlink: {link_path}")
        if link_path.resolve() != target.resolve():
            fail(f"incorrect standalone skill symlink: {link_path}")
    actual_standalone_entries = {path.name for path in (ROOT / "skills").iterdir()}
    if actual_standalone_entries != set(expected_standalone_entries):
        fail("unexpected entries found in top-level skills view")

    if (ROOT / "codex").exists() or (ROOT / "codex").is_symlink():
        fail("legacy codex compatibility view should not exist")

    codex_marketplace = load_json(ROOT / ".agents" / "plugins" / "marketplace.json")
    claude_marketplace = load_json(ROOT / ".claude-plugin" / "marketplace.json")
    ordered_names = [plugin["name"] for plugin in plugins]
    if [entry["name"] for entry in codex_marketplace["plugins"]] != ordered_names:
        fail("Codex marketplace plugin order does not match catalog")
    if [entry["name"] for entry in claude_marketplace["plugins"]] != ordered_names:
        fail("Claude marketplace plugin order does not match catalog")

    print("repo structure validated")
    return 0


if __name__ == "__main__":
    sys.exit(main())
