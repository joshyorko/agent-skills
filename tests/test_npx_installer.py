from __future__ import annotations

import json
import shutil
import subprocess
import unittest
from pathlib import Path


ROOT = Path(__file__).resolve().parents[1]
PACKAGE_JSON = ROOT / "package.json"


class NpxInstallerTest(unittest.TestCase):
    def test_package_exposes_agent_skills_bin(self) -> None:
        package = json.loads(PACKAGE_JSON.read_text(encoding="utf-8"))

        self.assertEqual(package["name"], "agent-skills")
        self.assertEqual(package["bin"], {"agent-skills": "bin/agent-skills.js"})
        self.assertIn("install.sh", package["files"])
        self.assertIn("install.ps1", package["files"])

    @unittest.skipUnless(shutil.which("node"), "node is required for the NPX installer")
    def test_cli_help_delegates_to_linux_installer(self) -> None:
        result = subprocess.run(
            ["node", "bin/agent-skills.js", "--help"],
            cwd=ROOT,
            text=True,
            stdout=subprocess.PIPE,
            stderr=subprocess.PIPE,
            check=False,
        )

        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertIn("Usage: install.sh [options]", result.stdout)

    @unittest.skipUnless(shutil.which("node"), "node is required for the NPX installer")
    def test_windows_arguments_are_translated_to_powershell_parameters(self) -> None:
        script = """
          const cli = require('./bin/agent-skills.js');
          const command = cli.commandForPlatform('win32', ['--ref', 'v1.2.3', '--link', '--force']);
          console.log(JSON.stringify(command.args));
        """
        result = subprocess.run(
            ["node", "-e", script],
            cwd=ROOT,
            text=True,
            stdout=subprocess.PIPE,
            stderr=subprocess.PIPE,
            check=False,
        )

        self.assertEqual(result.returncode, 0, result.stderr)
        args = json.loads(result.stdout)
        self.assertIn("install.ps1", args[args.index("-File") + 1])
        self.assertIn("-Ref", args)
        self.assertIn("v1.2.3", args)
        self.assertIn("-SkillMode", args)
        self.assertIn("link", args)
        self.assertIn("-Force", args)


if __name__ == "__main__":
    unittest.main()
