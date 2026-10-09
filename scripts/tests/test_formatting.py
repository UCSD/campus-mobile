import os
from pathlib import Path
import shutil
import subprocess
import sys
import tempfile
import unittest


REPO_ROOT = Path(__file__).resolve().parents[2]
BASH = shutil.which("bash")
if os.name == "nt":
    git_bash = Path(os.environ.get("ProgramFiles", "C:/Program Files")) / "Git/bin/bash.exe"
    if git_bash.is_file():
        BASH = str(git_bash)
DART = shutil.which("dart")

PROGRAM = """void main() {
  const enabled = false;
  if (enabled) {
    print('first'); print('second');
  }
  print('//server/share');
  print('// TODO: example');
  print(r'\\d+'); //Comment
  print('''
int example() {
  return 1;
}
''');
}
"""


class FormattingTests(unittest.TestCase):
    def setUp(self):
        self.assertIsNotNone(BASH, "Bash is required for the formatting helper tests")
        self.assertIsNotNone(DART, "The pinned Flutter SDK must be on PATH")
        self.directory = tempfile.TemporaryDirectory(prefix="campus-mobile-format-test-")
        self.addCleanup(self.directory.cleanup)
        self.root = Path(self.directory.name)
        for folder in ("lib", "test", "scripts", "bin"):
            (self.root / folder).mkdir()
        self.source = self.root / "lib/main.dart"
        self.source.write_text(PROGRAM, encoding="utf-8", newline="\n")
        shutil.copyfile(REPO_ROOT / "scripts/auto_fix_all.sh", self.root / "scripts/auto_fix_all.sh")
        shutil.copyfile(REPO_ROOT / ".pre-commit-config.yaml", self.root / ".pre-commit-config.yaml")

    def run_command(self, command, **kwargs):
        return subprocess.run(command, cwd=self.root, capture_output=True, text=True, **kwargs)

    def initialize_git(self):
        for arguments in (("init", "--quiet"), ("add", ".")):
            result = self.run_command(["git", *arguments])
            self.assertEqual(result.returncode, 0, result.stdout + result.stderr)

    def run_hook(self):
        return self.run_command([sys.executable, "-m", "pre_commit", "run", "--all-files"])

    def test_hook_preserves_behavior_and_only_formats_dart_sources(self):
        untouched = self.root / "outside.dart"
        untouched.write_text("void main(){print('outside');}\n", encoding="utf-8")
        original_untouched = untouched.read_bytes()
        test_source = self.root / "test/example_test.dart"
        test_source.write_text("void main(){print('test');}\n", encoding="utf-8")
        original_test = test_source.read_bytes()
        self.initialize_git()
        before = self.run_command([DART, str(self.source)])
        self.assertEqual(before.returncode, 0, before.stderr)
        first = self.run_hook()
        self.assertEqual(first.returncode, 1, first.stdout + first.stderr)
        self.assertIn("files were modified by this hook", first.stdout)
        after = self.run_command([DART, str(self.source)])
        self.assertEqual(after.returncode, 0, after.stderr)
        self.assertEqual(after.stdout, before.stdout)
        self.assertEqual(untouched.read_bytes(), original_untouched)
        self.assertNotEqual(test_source.read_bytes(), original_test)
        second = self.run_hook()
        self.assertEqual(second.returncode, 0, second.stdout + second.stderr)

    def test_hook_rejects_invalid_dart(self):
        self.source.write_text("void main( {\n", encoding="utf-8")
        self.initialize_git()
        result = self.run_hook()
        self.assertNotEqual(result.returncode, 0, result.stdout + result.stderr)
        self.assertIn("Could not format", result.stdout + result.stderr)

    def test_dry_run_reports_changes_without_writing(self):
        before = self.source.read_bytes()
        result = self.run_command([BASH, "scripts/auto_fix_all.sh", "--dry-run"])
        self.assertEqual(result.returncode, 1, result.stdout + result.stderr)
        self.assertEqual(self.source.read_bytes(), before)
        formatted = self.run_command([BASH, "scripts/auto_fix_all.sh"])
        self.assertEqual(formatted.returncode, 0, formatted.stdout + formatted.stderr)
        checked = self.run_command([BASH, "scripts/auto_fix_all.sh", "--dry-run"])
        self.assertEqual(checked.returncode, 0, checked.stdout + checked.stderr)

    def test_missing_dart_is_an_error(self):
        result = self.run_command([
            BASH, "-c", 'export PATH="$PWD/bin"; exec "$BASH" scripts/auto_fix_all.sh',
        ])
        self.assertEqual(result.returncode, 127, result.stdout + result.stderr)
        self.assertIn("dart is required", result.stderr)

    def test_formatter_exit_code_is_propagated(self):
        formatter = self.root / "bin/dart"
        formatter.write_text("#!/bin/sh\nexit 23\n", encoding="utf-8", newline="\n")
        formatter.chmod(0o755)
        result = self.run_command([
            BASH, "-c", 'export PATH="$PWD/bin:/usr/bin:/bin"; exec "$BASH" scripts/auto_fix_all.sh',
        ])
        self.assertEqual(result.returncode, 23, result.stdout + result.stderr)

    def test_unknown_arguments_are_rejected(self):
        for arguments in (("--fix",), ("--dry-run", "unexpected")):
            with self.subTest(arguments=arguments):
                result = self.run_command([BASH, "scripts/auto_fix_all.sh", *arguments])
                self.assertEqual(result.returncode, 2, result.stdout + result.stderr)
                self.assertIn("Usage:", result.stderr)


if __name__ == "__main__":
    unittest.main()
