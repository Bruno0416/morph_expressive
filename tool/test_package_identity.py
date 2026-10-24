"""Regression tests for binary native lockfiles in the package identity scan."""

import shutil
import subprocess
import sys
import tempfile
import unittest
from pathlib import Path


CHECKER = Path(__file__).with_name("check_package_identity.py")


class PackageIdentityTests(unittest.TestCase):
    def setUp(self):
        self.temp = tempfile.TemporaryDirectory()
        self.addCleanup(self.temp.cleanup)
        self.root = Path(self.temp.name)
        (self.root / "tool").mkdir()
        shutil.copyfile(CHECKER, self.root / "tool/check_package_identity.py")
        self.write("pubspec.yaml", "name: morph_expressive\n")
        self.write("preview/pubspec.yaml", "name: morph_expressive_preview\n")
        self.write("lib/morph_expressive.dart", "// Public API\n")
        self.write("preview/lib/main.dart", "Text('Morph Expressive')\n")
        self.write("preview/lib/component_gif_capture.dart", "MORPH EXPRESSIVE\n")
        for name in ("README.md", "NOTICE", "CHANGELOG.md"):
            self.write(name, "Morph Expressive\n")

    def write(self, name, content):
        path = self.root / name
        path.parent.mkdir(parents=True, exist_ok=True)
        path.write_text(content, encoding="utf-8")

    def run_check(self):
        return subprocess.run(
            [sys.executable, str(self.root / "tool/check_package_identity.py")],
            capture_output=True, text=True, check=False,
        )

    def test_binary_native_lockfiles_do_not_break_branding_check(self):
        for name in (
            "preview/android/.gradle/8.0/fileHashes/fileHashes.lock",
            "preview/android/random_cache.lock",
        ):
            path = self.root / name
            path.parent.mkdir(parents=True, exist_ok=True)
            path.write_bytes(b"\x00\xbe\x80\x90")
        result = self.run_check()
        self.assertEqual(result.returncode, 0, result.stderr + result.stdout)
        self.assertIn("Package identity and branding OK", result.stdout)

    def test_legacy_branding_in_source_still_fails(self):
        self.write("lib/example.dart", "// Morph" + " UI is a previous name\n")
        result = self.run_check()
        self.assertNotEqual(result.returncode, 0)
        self.assertIn("outdated package name or branding: lib/example.dart", result.stderr)

    def test_invalid_encoding_of_real_source_reports_filename(self):
        source = self.root / "lib/invalid.dart"
        source.write_bytes(b"\x00\xbe")
        result = self.run_check()
        self.assertNotEqual(result.returncode, 0)
        self.assertIn("non-UTF-8 text file: lib/invalid.dart", result.stderr)
        self.assertNotIn("Traceback", result.stderr)


if __name__ == "__main__":
    unittest.main()
