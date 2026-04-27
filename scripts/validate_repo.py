#!/usr/bin/env python3
from __future__ import annotations

import json
import re
import sys
from pathlib import Path


ROOT = Path(__file__).resolve().parents[1]
CATALOG_PATH = ROOT / "marketplaces" / "catalog.json"
SKILL_NAME_RE = re.compile(r"^[a-z0-9]+(?:-[a-z0-9]+)*$")


def fail(message: str) -> None:
    raise SystemExit(message)


def load_json(path: Path) -> dict:
    return json.loads(path.read_text())


def parse_skill_frontmatter(path: Path) -> dict[str, str]:
    text = path.read_text()
    if not text.startswith("---\n"):
        fail(f"missing YAML frontmatter start: {path}")
    parts = text.split("---\n", 2)
    if len(parts) < 3:
        fail(f"missing YAML frontmatter close: {path}")
    frontmatter = parts[1]

    data: dict[str, str] = {}
    lines = frontmatter.splitlines()
    index = 0
    while index < len(lines):
        line = lines[index]
        if not line.strip():
            index += 1
            continue
        if line.startswith((" ", "\t")):
            index += 1
            continue
        match = re.match(r"^([A-Za-z0-9_-]+):(?:\s*(.*))?$", line)
        if not match:
            fail(f"invalid frontmatter line in {path}: {line}")
        key, value = match.groups()
        value = value or ""
        if value.startswith(("|", ">")):
            block_lines = []
            index += 1
            while index < len(lines) and (
                not lines[index].strip()
                or lines[index].startswith((" ", "\t"))
            ):
                block_lines.append(lines[index].strip())
                index += 1
            data[key] = "\n".join(block_lines).strip()
            continue
        if not value.strip():
            index += 1
            while index < len(lines) and (
                not lines[index].strip()
                or lines[index].startswith((" ", "\t"))
            ):
                index += 1
            data[key] = ""
            continue
        stripped = value.strip()
        if (
            ": " in stripped
            and not stripped.startswith(("'", '"', "{", "["))
        ):
            fail(f"quote frontmatter values containing ': ' in {path}: {line}")
        data[key] = stripped.strip("'\"")
        index += 1

    return data


def validate_skill_frontmatter(skill_dir: Path) -> None:
    path = skill_dir / "SKILL.md"
    data = parse_skill_frontmatter(path)
    name = data.get("name", "")
    description = data.get("description", "")
    if not name:
        fail(f"missing skill name in {path}")
    if name != skill_dir.name:
        fail(f"skill name must match directory for {path}: {name} != {skill_dir.name}")
    if not SKILL_NAME_RE.match(name):
        fail(f"invalid skill name in {path}: {name}")
    if not description:
        fail(f"missing skill description in {path}")
    if len(description) > 1024:
        fail(f"skill description exceeds 1024 characters in {path}")


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
            validate_skill_frontmatter(skill_dir)

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
