"""Fail early with actionable diagnostics instead of losing screenshot points."""
from pathlib import Path
import os
import shutil
import subprocess
import tempfile
import unittest

ROOT = Path(__file__).resolve().parents[3]
TOOLS = ('webpinfo', 'cwebp', 'dwebp', 'gif2webp', 'webpmux')


class PanaToolsTest(unittest.TestCase):
    def probe(self, absent=()):
        with tempfile.TemporaryDirectory() as temp:
            for tool in TOOLS:
                if tool not in absent:
                    path = Path(temp) / tool
                    path.write_text('#!/bin/sh\nexit 0\n')
                    path.chmod(0o755)
            return subprocess.run([shutil.which('bash'), str(ROOT / 'tool/ci/check_pana_tools.sh')],
                                  env=dict(os.environ, PATH=temp), capture_output=True, text=True)

    def test_missing_converter_fails_with_its_name_and_install_package(self):
        result = self.probe(('gif2webp',))
        self.assertEqual(1, result.returncode)
        self.assertIn('gif2webp', result.stderr)
        self.assertIn('package: webp', result.stderr)

    def test_all_missing_tools_are_reported(self):
        result = self.probe(TOOLS)
        self.assertEqual(1, result.returncode)
        for tool in TOOLS:
            self.assertIn(tool, result.stderr)

    def test_available_tools_pass(self):
        self.assertEqual(0, self.probe().returncode)

    def test_package_workflow_installs_tools_before_strict_pana(self):
        workflow = (ROOT / '.github/workflows/package.yml').read_text()
        self.assertLess(workflow.index('apt-get install --yes --no-install-recommends webp'),
                        workflow.index('dart pub global run pana:pana'))
        self.assertIn('bash tool/ci/check_pana_tools.sh', workflow)
        self.assertIn('--exit-code-threshold=0', workflow)


if __name__ == '__main__':
    unittest.main()
