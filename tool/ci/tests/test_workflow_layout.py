"""Validate stage ordering and execute the real final gate under failure states.

Actionlint independently checks YAML/schema, expressions and reusable calls.
These tests cover the repository's release policy, not a general YAML parser.
"""
from pathlib import Path
import os
import re
import subprocess
import textwrap
import unittest

ROOT = Path(__file__).resolve().parents[3]
WORKFLOWS = ROOT / '.github/workflows'


def job_blocks(text):
    jobs = text.split('\njobs:\n', 1)[1]
    return {m.group(1): m.group(2) for m in re.finditer(
        r'^  ([\w-]+):\n(.*?)(?=^  [\w-]+:\n|\Z)', jobs, re.M | re.S)}


class WorkflowLayoutTest(unittest.TestCase):
    def setUp(self):
        self.caller = (WORKFLOWS / 'ci.yml').read_text()
        self.jobs = job_blocks(self.caller)

    def test_only_coordinator_handles_events_and_every_module_uses_same_commit(self):
        expected = {'tests', 'compatibility', 'documentation', 'package', 'quality', 'release'}
        self.assertEqual(expected, set(self.jobs))
        self.assertLess(len(self.caller.splitlines()), 100)
        self.assertNotIn('dart pub', self.caller)
        called = []
        for name in expected - {'quality'}:
            match = re.search(r'^    uses: (\./\.github/workflows/[\w-]+\.yml)$', self.jobs[name], re.M)
            self.assertIsNotNone(match, name)
            module = ROOT / match.group(1)
            self.assertTrue(module.is_file(), module)
            text = module.read_text()
            self.assertIn('\non:\n  workflow_call:\n', text)
            events = text.split('\npermissions:\n', 1)[0]
            self.assertNotRegex(events, r'(?m)^  (push|pull_request|workflow_run|workflow_dispatch|release):')
            called.append(module.name)
        self.assertEqual(set(called) | {'ci.yml'}, {f.name for f in WORKFLOWS.glob('*.yml')})

    def test_workflow_names_and_identifiers_have_no_package_prefix(self):
        for file in [*WORKFLOWS.glob('*.yml'), ROOT / '.github/actions/setup-flutter/action.yml']:
            self.assertNotRegex(file.name, r'(?i)morph[-_]')
            self.assertNotRegex(file.read_text(), r'(?i)\bmorph(?:[-_ ]|$)')

    def test_stages_wait_for_previous_stage_and_gate_covers_all(self):
        for stage, dependency in [('compatibility', 'tests'), ('documentation', 'compatibility'),
                                  ('package', 'documentation'), ('release', 'quality')]:
            self.assertRegex(self.jobs[stage], rf'(?m)^    needs: {dependency}$')
        self.assertIn('needs: [tests, compatibility, documentation, package]', self.jobs['quality'])
        self.assertIn('if: ${{ always() }}', self.jobs['quality'])

    def test_real_gate_rejects_failed_cancelled_and_skipped_stages(self):
        script = textwrap.dedent(self.jobs['quality'].split('        run: |\n', 1)[1])
        names = ['TESTS_RESULT', 'COMPATIBILITY_RESULT', 'DOCUMENTATION_RESULT', 'PACKAGE_RESULT']
        cases = [(None, None)] + [(name, state) for name in names for state in ['failure', 'cancelled', 'skipped']]
        for name, state in cases:
            with self.subTest(stage=name, state=state):
                env = dict(os.environ, **{key: 'success' for key in names})
                if name:
                    env[name] = state
                result = subprocess.run(['bash', '--noprofile', '--norc', '-e', '-c', script],
                                        env=env, capture_output=True)
                self.assertEqual(name is None, result.returncode == 0)

    def test_write_and_oidc_permissions_are_confined_to_publication(self):
        for name, body in self.jobs.items():
            if name != 'release':
                self.assertNotIn('id-token: write', body)
                self.assertNotIn('contents: write', body)
        self.assertIn("if: github.event_name == 'push' && github.ref == 'refs/heads/main'", self.jobs['release'])
        for path in WORKFLOWS.glob('*.yml'):
            if path.name not in {'ci.yml', 'publish.yml'}:
                self.assertNotIn('id-token: write', path.read_text())
                self.assertNotIn('contents: write', path.read_text())

    def test_each_flutter_job_checks_out_before_shared_sdk_setup(self):
        action = ROOT / '.github/actions/setup-flutter/action.yml'
        self.assertTrue(action.is_file())
        self.assertIn("flutter-version: '3.47.9'", action.read_text())
        for name in ['tests', 'compatibility', 'package', 'publish']:
            text = (WORKFLOWS / f'{name}.yml').read_text()
            self.assertLess(text.index('uses: actions/checkout@'), text.index('uses: ./.github/actions/setup-flutter'))
            self.assertNotIn('flutter-version:', text)


if __name__ == '__main__':
    unittest.main()
