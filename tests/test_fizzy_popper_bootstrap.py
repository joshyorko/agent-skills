from __future__ import annotations

import json
import os
import subprocess
import tempfile
import unittest
from pathlib import Path


ROOT = Path(__file__).resolve().parents[1]
SCRIPT = ROOT / "plugins/fizzy/skills/fizzy/scripts/bootstrap-fizzy-popper-board.sh"


FAKE_FIZZY = r"""#!/usr/bin/env python3
from __future__ import annotations

import json
import os
import sys


state_path = os.environ["FIZZY_FAKE_STATE"]


def load():
    with open(state_path, "r", encoding="utf-8") as fh:
        return json.load(fh)


def save(state):
    with open(state_path, "w", encoding="utf-8") as fh:
        json.dump(state, fh, indent=2)


def out(data):
    print(json.dumps({"ok": True, "data": data}))


def flag(args, name):
    if name not in args:
        return None
    index = args.index(name)
    return args[index + 1]


def slug(value):
    return "".join(ch.lower() if ch.isalnum() else "-" for ch in value).strip("-")


args = sys.argv[1:]
state = load()
state.setdefault("commands", []).append(args)

if args[:2] == ["board", "show"]:
    board_id = args[2]
    board = state["boards"].get(board_id)
    if not board:
        print("missing board", file=sys.stderr)
        sys.exit(2)
    save(state)
    out(board)
elif args[:2] == ["column", "list"]:
    save(state)
    out(state.get("columns", []))
elif args[:2] == ["column", "create"]:
    name = flag(args, "--name")
    column = {"id": f"col-{slug(name)}", "name": name}
    state.setdefault("columns", []).append(column)
    save(state)
    out(column)
elif args[:2] == ["card", "list"]:
    save(state)
    out(state.get("cards", []))
elif args[:2] == ["card", "create"]:
    number = state.get("next_card_number", 100)
    state["next_card_number"] = number + 1
    card = {
        "id": f"card-{number}",
        "number": number,
        "title": flag(args, "--title"),
        "description": flag(args, "--description") or "",
        "tags": [],
        "steps": [],
        "column": None,
    }
    state.setdefault("cards", []).append(card)
    save(state)
    out(card)
elif args[:2] == ["card", "column"]:
    number = int(args[2])
    column_id = flag(args, "--column")
    column = next(col for col in state.get("columns", []) if col["id"] == column_id)
    for card in state.get("cards", []):
        if card["number"] == number:
            card["column"] = {"id": column["id"], "name": column["name"]}
            save(state)
            out(card)
            break
    else:
        print("missing card", file=sys.stderr)
        sys.exit(2)
elif args[:2] == ["card", "tag"]:
    number = int(args[2])
    tag = flag(args, "--tag")
    for card in state.get("cards", []):
        if card["number"] == number:
            if tag in card.setdefault("tags", []):
                card["tags"].remove(tag)
            else:
                card["tags"].append(tag)
            save(state)
            out(card)
            break
    else:
        print("missing card", file=sys.stderr)
        sys.exit(2)
elif args[:2] == ["step", "list"]:
    number = int(flag(args, "--card"))
    for card in state.get("cards", []):
        if card["number"] == number:
            save(state)
            out(card.get("steps", []))
            break
    else:
        print("missing card", file=sys.stderr)
        sys.exit(2)
elif args[:2] == ["step", "create"]:
    number = int(flag(args, "--card"))
    content = flag(args, "--content")
    for card in state.get("cards", []):
        if card["number"] == number:
            step = {"id": f"step-{len(card.setdefault('steps', [])) + 1}", "content": content}
            card["steps"].append(step)
            save(state)
            out(step)
            break
    else:
        print("missing card", file=sys.stderr)
        sys.exit(2)
else:
    print(f"unexpected command: {args}", file=sys.stderr)
    save(state)
    sys.exit(9)
"""


class FizzyPopperBootstrapTest(unittest.TestCase):
    def setUp(self) -> None:
        self.tmp = tempfile.TemporaryDirectory()
        self.root = Path(self.tmp.name)
        self.bin_dir = self.root / "bin"
        self.bin_dir.mkdir()
        fake = self.bin_dir / "fizzy"
        fake.write_text(FAKE_FIZZY, encoding="utf-8")
        fake.chmod(0o755)
        self.state_path = self.root / "state.json"
        self.write_state(
            {
                "boards": {"board-1": {"id": "board-1", "name": "Work AI"}},
                "columns": [],
                "cards": [],
                "next_card_number": 100,
            }
        )

    def tearDown(self) -> None:
        self.tmp.cleanup()

    def write_state(self, state: dict) -> None:
        self.state_path.write_text(json.dumps(state, indent=2), encoding="utf-8")

    def read_state(self) -> dict:
        return json.loads(self.state_path.read_text(encoding="utf-8"))

    def run_script(self, *args: str) -> subprocess.CompletedProcess[str]:
        env = os.environ.copy()
        env["PATH"] = f"{self.bin_dir}:{env['PATH']}"
        env["FIZZY_FAKE_STATE"] = str(self.state_path)
        return subprocess.run(
            ["bash", str(SCRIPT), *args],
            cwd=ROOT,
            env=env,
            text=True,
            stdout=subprocess.PIPE,
            stderr=subprocess.PIPE,
            check=False,
        )

    def test_creates_columns_golden_ticket_tags_and_steps(self) -> None:
        result = self.run_script("--board", "board-1")

        self.assertEqual(result.returncode, 0, result.stderr)
        state = self.read_state()
        self.assertEqual(
            [(column["id"], column["name"]) for column in state["columns"]],
            [("col-ready-for-agents", "Ready for Agents"), ("col-done", "Done")],
        )
        self.assertEqual(len(state["cards"]), 1)
        card = state["cards"][0]
        self.assertEqual(card["title"], "Repo Agent")
        self.assertEqual(card["column"]["id"], "col-ready-for-agents")
        self.assertEqual(card["tags"], ["agent-instructions", "codex", "move-to-done"])
        self.assertEqual(
            [step["content"] for step in card["steps"]],
            [
                "Inspect the repository and the card request",
                "Make the smallest safe change that satisfies the request",
                "Run the appropriate local checks",
                "Summarize what changed and any follow-up needed",
            ],
        )

    def test_reuses_existing_columns_and_valid_golden_ticket(self) -> None:
        self.write_state(
            {
                "boards": {"board-1": {"id": "board-1", "name": "Work AI"}},
                "columns": [
                    {"id": "col-ready", "name": "Ready for Agents"},
                    {"id": "col-done", "name": "Done"},
                ],
                "cards": [
                    {
                        "id": "card-77",
                        "number": 77,
                        "title": "Repo Agent",
                        "description": "Existing policy",
                        "tags": ["agent-instructions", "codex", "move-to-done"],
                        "steps": [
                            {"id": "step-1", "content": "Inspect the repository and the card request"},
                            {
                                "id": "step-2",
                                "content": "Make the smallest safe change that satisfies the request",
                            },
                            {"id": "step-3", "content": "Run the appropriate local checks"},
                            {"id": "step-4", "content": "Summarize what changed and any follow-up needed"},
                        ],
                        "column": {"id": "col-ready", "name": "Ready for Agents"},
                    }
                ],
                "next_card_number": 100,
            }
        )

        result = self.run_script("--board", "board-1")

        self.assertEqual(result.returncode, 0, result.stderr)
        state = self.read_state()
        self.assertEqual(len(state["columns"]), 2)
        self.assertEqual(len(state["cards"]), 1)
        mutating = [cmd[:2] for cmd in state["commands"] if cmd[:2] in (["column", "create"], ["card", "create"], ["card", "tag"], ["step", "create"])]
        self.assertEqual(mutating, [])

    def test_adds_only_missing_tags_and_steps_to_partial_ticket(self) -> None:
        self.write_state(
            {
                "boards": {"board-1": {"id": "board-1", "name": "Work AI"}},
                "columns": [{"id": "col-ready", "name": "Ready for Agents"}],
                "cards": [
                    {
                        "id": "card-77",
                        "number": 77,
                        "title": "Repo Agent",
                        "description": "Existing policy",
                        "tags": ["agent-instructions"],
                        "steps": [{"id": "step-1", "content": "Inspect the repository and the card request"}],
                        "column": {"id": "col-ready", "name": "Ready for Agents"},
                    }
                ],
                "next_card_number": 100,
            }
        )

        result = self.run_script("--board", "board-1")

        self.assertEqual(result.returncode, 0, result.stderr)
        card = self.read_state()["cards"][0]
        self.assertEqual(card["tags"], ["agent-instructions", "codex", "move-to-done"])
        self.assertEqual(len(card["steps"]), 4)

    def test_fails_on_multiple_golden_tickets_in_agent_column(self) -> None:
        self.write_state(
            {
                "boards": {"board-1": {"id": "board-1", "name": "Work AI"}},
                "columns": [{"id": "col-ready", "name": "Ready for Agents"}],
                "cards": [
                    {"id": "card-77", "number": 77, "title": "One", "tags": ["agent-instructions"], "steps": [], "column": {"id": "col-ready", "name": "Ready for Agents"}},
                    {"id": "card-78", "number": 78, "title": "Two", "tags": ["agent-instructions"], "steps": [], "column": {"id": "col-ready", "name": "Ready for Agents"}},
                ],
                "next_card_number": 100,
            }
        )

        result = self.run_script("--board", "board-1")

        self.assertNotEqual(result.returncode, 0)
        self.assertIn("Multiple golden-ticket cards", result.stderr)
        self.assertIn("77", result.stderr)
        self.assertIn("78", result.stderr)

    def test_fails_on_conflicting_tags_unless_forced(self) -> None:
        self.write_state(
            {
                "boards": {"board-1": {"id": "board-1", "name": "Work AI"}},
                "columns": [{"id": "col-ready", "name": "Ready for Agents"}],
                "cards": [
                    {
                        "id": "card-77",
                        "number": 77,
                        "title": "Repo Agent",
                        "description": "Existing policy",
                        "tags": ["agent-instructions", "claude", "close-on-complete"],
                        "steps": [],
                        "column": {"id": "col-ready", "name": "Ready for Agents"},
                    }
                ],
                "next_card_number": 100,
            }
        )

        result = self.run_script("--board", "board-1")
        self.assertNotEqual(result.returncode, 0)
        self.assertIn("--force-tags", result.stderr)

        result = self.run_script("--board", "board-1", "--force-tags")
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertEqual(self.read_state()["cards"][0]["tags"], ["agent-instructions", "codex", "move-to-done"])

    def test_smoke_card_is_opt_in(self) -> None:
        result = self.run_script("--board", "board-1")
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertEqual(len(self.read_state()["cards"]), 1)

        result = self.run_script("--board", "board-1", "--smoke-card")
        self.assertEqual(result.returncode, 0, result.stderr)
        cards = self.read_state()["cards"]
        self.assertEqual([card["title"] for card in cards], ["Repo Agent", "Smoke test the agent loop"])
        self.assertEqual(cards[1]["column"]["id"], cards[0]["column"]["id"])
        self.assertIn("may be picked up", result.stdout)

    def test_dry_run_does_not_mutate(self) -> None:
        result = self.run_script("--board", "board-1", "--dry-run")

        self.assertEqual(result.returncode, 0, result.stderr)
        state = self.read_state()
        self.assertEqual(state["columns"], [])
        self.assertEqual(state["cards"], [])
        self.assertIn("DRY RUN", result.stdout)

    def test_close_on_complete_does_not_create_done_column(self) -> None:
        result = self.run_script("--board", "board-1", "--completion", "close-on-complete")

        self.assertEqual(result.returncode, 0, result.stderr)
        state = self.read_state()
        self.assertEqual([column["name"] for column in state["columns"]], ["Ready for Agents"])
        self.assertEqual(state["cards"][0]["tags"], ["agent-instructions", "codex", "close-on-complete"])

    def test_custom_move_completion_column_slug(self) -> None:
        result = self.run_script("--board", "board-1", "--completion", "move-to:Ready for Review")

        self.assertEqual(result.returncode, 0, result.stderr)
        state = self.read_state()
        self.assertEqual([column["name"] for column in state["columns"]], ["Ready for Agents", "Ready for Review"])
        self.assertEqual(state["cards"][0]["tags"], ["agent-instructions", "codex", "move-to-ready-for-review"])


if __name__ == "__main__":
    unittest.main()
