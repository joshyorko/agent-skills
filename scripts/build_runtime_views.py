#!/usr/bin/env python3
from __future__ import annotations

import argparse
import json
import os
import shutil
import sys
from pathlib import Path


ROOT = Path(__file__).resolve().parents[1]
CATALOG_PATH = ROOT / "marketplaces" / "catalog.json"


def load_catalog() -> dict:
    return json.loads(CATALOG_PATH.read_text())


def remove_path(path: Path) -> None:
    if path.is_symlink() or path.is_file():
        path.unlink()
    elif path.is_dir():
        shutil.rmtree(path)


def rel_symlink(target: Path, link_path: Path, check: bool) -> bool:
    relative = Path(os.path.relpath(target, link_path.parent))
    if link_path.is_symlink() and Path(link_path.readlink()) == relative:
        return False
    if check:
        print(f"stale: {link_path.relative_to(ROOT)}")
        return True
    if link_path.exists() or link_path.is_symlink():
        remove_path(link_path)
    link_path.parent.mkdir(parents=True, exist_ok=True)
    link_path.symlink_to(relative)
    print(f"linked {link_path.relative_to(ROOT)} -> {relative}")
    return True


def collect_skills(catalog: dict) -> tuple[dict[str, Path], dict[str, Path]]:
    canonical = {}
    standalone_entries = {}
    for plugin in catalog["plugins"]:
        skills_root = ROOT / "plugins" / plugin["name"] / "skills"
        for skill_dir in sorted(p for p in skills_root.iterdir() if p.is_dir()):
            if skill_dir.name in canonical:
                raise SystemExit(f"duplicate skill name: {skill_dir.name}")
            canonical[skill_dir.name] = skill_dir
            standalone_entries[skill_dir.name] = skill_dir
    return canonical, standalone_entries


def sync_dir(target_dir: Path, entries: dict[str, Path], check: bool) -> bool:
    changed = False
    if target_dir.exists():
        existing = {child.name: child for child in target_dir.iterdir()}
    else:
        existing = {}
    expected = set(entries)

    for name, path in existing.items():
        if name not in expected:
            if check:
                print(f"stale: {path.relative_to(ROOT)}")
                changed = True
            else:
                remove_path(path)
                print(f"removed {path.relative_to(ROOT)}")
                changed = True

    if not target_dir.exists() and not check:
        target_dir.mkdir(parents=True, exist_ok=True)

    for name, target in entries.items():
        changed |= rel_symlink(target, target_dir / name, check)

    return changed


def main() -> int:
    parser = argparse.ArgumentParser(description="Build generated skill runtime views.")
    parser.add_argument("--check", action="store_true", help="Fail if generated views are out of date.")
    args = parser.parse_args()

    catalog = load_catalog()
    canonical, standalone_entries = collect_skills(catalog)

    changed = False
    changed |= sync_dir(ROOT / ".agents" / "skills", canonical, args.check)
    changed |= sync_dir(ROOT / "skills", standalone_entries, args.check)

    codex_dir = ROOT / "codex"
    if codex_dir.exists() or codex_dir.is_symlink():
        if args.check:
            print("stale: codex")
            changed = True
        else:
            remove_path(codex_dir)
            print("removed codex")
            changed = True

    if args.check and changed:
        return 1
    return 0


if __name__ == "__main__":
    sys.exit(main())
