"""Execute the real workflow check script with isolated SDK command doubles.

These tests validate orchestration only. reproduce_tests.py runs the real SDK.
"""
import json
import os
from pathlib import Path
import subprocess
import sys
import tempfile
import unittest

ROOT = Path(__file__).resolve().parents[3]


class CheckBootstrapTest(unittest.TestCase):
    def execute(self, *, legacy=False, fail_preview=False, missing_config=False):
        with tempfile.TemporaryDirectory() as temp:
            root = Path(temp)
            (root / 'preview').mkdir()
            bin_dir = root / 'bin'
            bin_dir.mkdir()
            # Unrelated Python guards are covered by their own suites.
            (bin_dir / 'python3').write_text('#!/bin/sh\nexit 0\n')
            (bin_dir / 'python3').chmod(0o755)
            fake = bin_dir / 'flutter'
            fake.write_text('#!' + sys.executable + '\n' + '''
import json, os, pathlib, sys
root = pathlib.Path(os.environ['FIXTURE_ROOT'])
package = 'preview' if pathlib.Path.cwd() == root / 'preview' else 'root'
args = sys.argv[1:]
with (root / 'calls').open('a') as log:
    log.write(json.dumps([package, *args]) + '\\n')
if args == ['pub', 'get']:
    if package == 'preview' and os.environ['FAIL_PREVIEW'] == '1': sys.exit(42)
    if package == 'preview' and os.environ['MISSING_CONFIG'] == '1': sys.exit(0)
    folder = pathlib.Path.cwd() / '.dart_tool'
    folder.mkdir(exist_ok=True)
    (folder / 'package_config.json').write_text('{"configVersion": 2, "packages": []}')
elif args and args[0] in ['analyze', 'test']:
    if not all((p / '.dart_tool/package_config.json').is_file() for p in [root, root / 'preview']):
        print('uri_does_not_exist: package:morph_expressive_preview/component_catalog.dart', file=sys.stderr)
        sys.exit(1)
''')
            fake.chmod(0o755)
            script = (ROOT / 'tool/check.sh').read_text()
            if legacy:
                # Recreate the logged commit: root get -> root analyze, no preview get.
                script = script[:script.index('flutter pub get')] + 'flutter pub get\nflutter analyze\n'
            (root / 'check.sh').write_text(script.replace(
                'ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"', 'ROOT="$FIXTURE_ROOT"'))
            env = dict(os.environ, PATH=f'{bin_dir}:{os.environ["PATH"]}', FIXTURE_ROOT=str(root),
                       FAIL_PREVIEW=str(int(fail_preview)), MISSING_CONFIG=str(int(missing_config)))
            result = subprocess.run(['bash', str(root / 'check.sh')], cwd=root,
                                    env=env, capture_output=True, text=True)
            calls = [json.loads(line) for line in (root / 'calls').read_text().splitlines()]
            return result, calls

    def test_logged_order_reproduces_missing_preview_imports(self):
        result, calls = self.execute(legacy=True)
        self.assertEqual(1, result.returncode)
        self.assertIn('uri_does_not_exist', result.stderr)
        self.assertEqual([['root', 'pub', 'get'], ['root', 'analyze']], calls)

    def test_clean_workflow_resolves_both_packages_before_analysis(self):
        result, calls = self.execute()
        self.assertEqual(0, result.returncode, result.stderr)
        self.assertEqual([['root', 'pub', 'get'], ['preview', 'pub', 'get'],
                          ['root', 'analyze'], ['root', 'test'],
                          ['preview', 'analyze'], ['preview', 'test']], calls)

    def test_resolution_failure_stops_before_any_analysis(self):
        result, calls = self.execute(fail_preview=True)
        self.assertEqual(42, result.returncode)
        self.assertEqual([['root', 'pub', 'get'], ['preview', 'pub', 'get']], calls)

    def test_success_exit_without_package_config_is_rejected(self):
        result, calls = self.execute(missing_config=True)
        self.assertEqual(1, result.returncode)
        self.assertIn('Missing package configuration', result.stderr)
        self.assertEqual([['root', 'pub', 'get'], ['preview', 'pub', 'get']], calls)


if __name__ == '__main__':
    unittest.main()
