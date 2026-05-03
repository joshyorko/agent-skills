from __future__ import annotations

import tempfile
import unittest
from pathlib import Path

from scripts import validate_repo


class SkillFrontmatterTest(unittest.TestCase):
    def make_skill(self, directory_name: str, frontmatter: str) -> Path:
        root = Path(tempfile.mkdtemp())
        skill_dir = root / directory_name
        skill_dir.mkdir()
        (skill_dir / "SKILL.md").write_text(
            f"---\n{frontmatter}\n---\n# Test Skill\n",
            encoding="utf-8",
        )
        return skill_dir

    def test_rejects_unquoted_colon_in_scalar_value(self) -> None:
        skill_dir = self.make_skill(
            "bad-skill",
            "name: bad-skill\n"
            "description: Use for RCC itself: command selection",
        )

        with self.assertRaises(SystemExit) as error:
            validate_repo.validate_skill_frontmatter(skill_dir)

        self.assertIn("quote frontmatter values", str(error.exception))

    def test_accepts_quoted_colon_in_scalar_value(self) -> None:
        skill_dir = self.make_skill(
            "good-skill",
            "name: good-skill\n"
            'description: "Use for RCC itself: command selection"',
        )

        validate_repo.validate_skill_frontmatter(skill_dir)

    def test_accepts_folded_description_with_colon(self) -> None:
        skill_dir = self.make_skill(
            "folded-skill",
            "name: folded-skill\n"
            "description: >-\n"
            "  Use when a long description contains: a colon",
        )

        validate_repo.validate_skill_frontmatter(skill_dir)

    def test_rejects_directory_name_mismatch(self) -> None:
        skill_dir = self.make_skill(
            "actual-name",
            "name: other-name\n"
            "description: Valid short description",
        )

        with self.assertRaises(SystemExit) as error:
            validate_repo.validate_skill_frontmatter(skill_dir)

        self.assertIn("skill name must match directory", str(error.exception))

    def test_rejects_missing_frontmatter_close(self) -> None:
        root = Path(tempfile.mkdtemp())
        skill_dir = root / "broken-skill"
        skill_dir.mkdir()
        (skill_dir / "SKILL.md").write_text(
            "---\nname: broken-skill\ndescription: Broken\n# Missing close\n",
            encoding="utf-8",
        )

        with self.assertRaises(SystemExit) as error:
            validate_repo.validate_skill_frontmatter(skill_dir)

        self.assertIn("missing YAML frontmatter close", str(error.exception))

    def test_rejects_rails_37signals_non_trigger_description(self) -> None:
        skill_dir = self.make_skill(
            "rails-skill",
            "name: rails-skill\n"
            "description: Builds Rails things",
        )

        with self.assertRaises(SystemExit) as error:
            validate_repo.validate_rails_37signals_skill(skill_dir)

        self.assertIn("must start with 'Use when'", str(error.exception))

    def test_rejects_rails_37signals_long_skill_body(self) -> None:
        root = Path(tempfile.mkdtemp())
        skill_dir = root / "rails-skill"
        skill_dir.mkdir()
        long_body = " ".join(["word"] * (validate_repo.RAILS_37SIGNALS_MAX_WORDS + 1))
        (skill_dir / "SKILL.md").write_text(
            "---\n"
            "name: rails-skill\n"
            "description: Use when testing length\n"
            "---\n"
            f"{long_body}\n",
            encoding="utf-8",
        )

        with self.assertRaises(SystemExit) as error:
            validate_repo.validate_rails_37signals_skill(skill_dir)

        self.assertIn("exceeds", str(error.exception))

    def test_rejects_rails_37signals_per_skill_references(self) -> None:
        skill_dir = self.make_skill(
            "rails-skill",
            "name: rails-skill\n"
            "description: Use when testing references",
        )
        (skill_dir / "references").mkdir()

        with self.assertRaises(SystemExit) as error:
            validate_repo.validate_rails_37signals_skill(skill_dir)

        self.assertIn("per-skill references", str(error.exception))


if __name__ == "__main__":
    unittest.main()
