"""Check the generator's directory boundary and repository launchers offline."""

from pathlib import Path
import hashlib
import os
import shutil
import subprocess
import tempfile
import unittest


ROOT = Path(__file__).resolve().parents[1]


class LayoutTests(unittest.TestCase):
    def setUp(self):
        temporary = tempfile.TemporaryDirectory(prefix="new checker layout ")
        self.addCleanup(temporary.cleanup)
        self.work = Path(temporary.name)
        self.tool = self.work / "standalone tool"
        shutil.copytree(
            ROOT / "new_checker", self.tool,
            ignore=shutil.ignore_patterns("checkers", "__pycache__"),
        )

    def invoke(self, command, *args, cwd=None):
        return subprocess.run(
            [str(command), *args], cwd=cwd or self.work,
            text=True, capture_output=True,
        )

    def test_standalone_defaults_and_output_from_another_directory(self):
        config = self.tool / "config.sh"
        config.write_text(config.read_text().replace('CHECKER="MyChecker"', 'CHECKER="Local"'))
        result = self.invoke(self.tool / "new-checker.sh", "--dummy-rule")
        self.assertEqual(result.returncode, 0, result.stderr)
        project = self.tool / "checkers/Local"
        self.assertTrue((project / "lakefile.toml").is_file())
        self.assertTrue((project / "install/defs/MyCalculus.eo").is_file())
        self.assertIn("standalone tool/checkers/Local", result.stdout)
        self.assertFalse((self.work / "checkers").exists())

    def test_standalone_spec_from_tool_directory(self):
        result = self.invoke(
            self.tool / "new-checker.sh", "--checker", "Demo", "--calculus", "Hello",
            "--spec", "examples/hello", cwd=self.tool,
        )
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertEqual(
            (self.tool / "examples/hello/Hello.eo").read_bytes(),
            (self.tool / "checkers/Demo/install/defs/Hello.eo").read_bytes(),
        )
        listed = self.invoke(self.tool / "run-ci.sh", "--list")
        self.assertEqual(listed.returncode, 0, listed.stderr)
        self.assertIn("Basic:Hello:examples/hello:", listed.stdout)

    def test_launcher_preserves_relative_paths_and_exit_status(self):
        shutil.copytree(self.tool / "examples/hello", self.work / "input spec")
        launcher = ROOT / "scripts/new-checker.sh"
        result = self.invoke(
            launcher, "--checker", "Demo", "--calculus", "Hello",
            "--spec", "input spec", "--out", "output projects",
        )
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertEqual(
            (self.work / "input spec/Hello.eo").read_bytes(),
            (self.work / "output projects/Demo/install/defs/Hello.eo").read_bytes(),
        )
        rejected = self.invoke(launcher, "--unknown-option")
        self.assertEqual(rejected.returncode, 2)
        self.assertIn("unrecognized option", rejected.stderr)

    def test_maintenance_launchers_forward_arguments(self):
        for name, option in (("run-ci.sh", "--list"), ("bump-eoc.sh", "--help")):
            with self.subTest(command=name):
                direct = self.invoke(self.tool / name, option)
                wrapped = self.invoke(ROOT / "scripts" / name, option)
                self.assertEqual(direct.returncode, 0, direct.stderr)
                self.assertEqual(wrapped.returncode, 0, wrapped.stderr)
                self.assertEqual(wrapped.stdout, direct.stdout)

    def test_standalone_bump_updates_its_own_inputs(self):
        # Supply a local download fixture so this exercises the updater's real
        # file writes without changing a compiler pin or requiring the network.
        fixtures = self.work / "downloads"
        fixtures.mkdir()
        smt = (self.tool / "examples/hello/smt.eos").read_bytes() + b"\n; fixture\n"
        (fixtures / "smt.eos").write_bytes(smt)
        shutil.copyfile(self.tool / "examples/cpc/Cpc.eos", fixtures / "development-cpc.eos")
        commands = self.work / "bin"
        commands.mkdir()
        curl = commands / "curl"
        curl.write_text(
            '#!/usr/bin/env python3\n'
            'from pathlib import Path\n'
            'import os, shutil, sys\n'
            'shutil.copyfile(Path(os.environ["LAYOUT_DOWNLOADS"]) / '
            'sys.argv[2].rsplit("/", 1)[-1], sys.argv[4])\n'
        )
        curl.chmod(0o755)
        commit = "a" * 40
        result = subprocess.run(
            [str(self.tool / "bump-eoc.sh"), "--commit", commit],
            cwd=self.work, text=True, capture_output=True,
            env={**os.environ, "PATH": str(commands) + os.pathsep + os.environ["PATH"],
                 "LAYOUT_DOWNLOADS": str(fixtures)},
        )
        self.assertEqual(result.returncode, 0, result.stdout + result.stderr)
        for spec in ("hello", "scoped", "cpc"):
            self.assertEqual((self.tool / "examples" / spec / "smt.eos").read_bytes(), smt)
        digest = hashlib.md5(smt).hexdigest()
        self.assertIn(digest, (self.tool / "new-checker.sh").read_text())
        self.assertIn(digest, (self.tool / "templates/install/install-sig.sh.in").read_text())
        self.assertIn(commit, (self.tool / "templates/install/get-eo-compiler.sh.in").read_text())
        self.assertFalse((self.work / "templates").exists())
        self.assertFalse((self.work / "examples").exists())


if __name__ == "__main__":
    unittest.main()
