"""Regression tests for accidental candidate labels in release-facing sources."""
from __future__ import annotations

import importlib.util
from pathlib import Path
import subprocess
import sys
import tempfile
import unittest

SCRIPT = Path(__file__).resolve().parents[1] / 'check_final_release_language.py'
spec = importlib.util.spec_from_file_location('final_language_guard', SCRIPT)
assert spec is not None and spec.loader is not None
checker = importlib.util.module_from_spec(spec)
sys.modules[spec.name] = checker
spec.loader.exec_module(checker)


class WordingTests(unittest.TestCase):
    def test_rejects_prohibited_labels(self):
        phrases = [
            'Release Candidate 0.8.0', 'release-candidate', 'release_candidate',
            'Candidato a lanzamiento', 'candidata de publicación',
            'versión candidata', '0.8.0-rc1', '0.8.0-rc.1',
            'v0.8.0_rc1', 'RC1 0.8.0', 'release RC1', 'Pre-release',
            'RC', 'rc1',
        ]
        for phrase in phrases:
            with self.subTest(phrase=phrase):
                self.assertTrue(checker.scan_content('CHANGELOG.md', phrase.encode()))

    def test_accepts_final_implementation_wording(self):
        phrases = [
            'Implementación final del parche 0.8.0',
            'Validación pendiente; publicación pendiente',
            'Checklist de publicación v0.8.0',
            'Final implementation report',
            'A candidate object represents a scroll gesture.',
        ]
        for phrase in phrases:
            with self.subTest(phrase=phrase):
                self.assertFalse(checker.scan_content('doc/RELEASE.md', phrase.encode()))

    def test_checks_filenames(self):
        self.assertTrue(checker.scan_content('doc/0.8.0-release-candidate.md', b'clean text'))

    def test_exempts_only_policy_and_tests(self):
        self.assertFalse(checker.should_scan('.agents/FINAL_RELEASE_POLICY.md'))
        self.assertFalse(checker.should_scan('tool/ci/check_final_release_language.py'))
        self.assertFalse(checker.should_scan('tool/ci/tests/test_final_release_language.py'))
        self.assertTrue(checker.should_scan('.agents/OTHER.md'))
        self.assertTrue(checker.should_scan('CHANGELOG.md'))


class GitModesTests(unittest.TestCase):
    def setUp(self):
        self.temp = tempfile.TemporaryDirectory()
        self.addCleanup(self.temp.cleanup)
        self.root = Path(self.temp.name)
        self.git('init', '-q')
        self.git('config', 'user.name', 'Agent Guard Test')
        self.git('config', 'user.email', 'guard@example.invalid')
        (self.root / 'doc').mkdir()
        (self.root / 'doc' / 'release.md').write_text('Implementación final 0.8.0\n')
        self.git('add', '.')
        self.git('commit', '-qm', 'baseline')

    def git(self, *args):
        return subprocess.run(['git', '-C', str(self.root), *args],
                              check=True, capture_output=True)

    def scan(self, mode, *args):
        return subprocess.run([sys.executable, str(SCRIPT), mode, *args,
                               '--root', str(self.root)], capture_output=True, text=True)

    def test_staged_checks_exact_index_not_unstaged_changes(self):
        p = self.root / 'doc' / 'release.md'
        p.write_text('0.8.0-rc.1\n')
        self.assertEqual(self.scan('--staged').returncode, 0)
        self.assertEqual(self.scan('--all').returncode, 1)
        self.git('add', '.')
        self.assertEqual(self.scan('--staged').returncode, 1)

    def test_revision_scans_exact_commit(self):
        p = self.root / 'doc' / 'release.md'
        p.write_text('release candidate\n')
        self.git('add', '.')
        self.git('commit', '-qm', 'candidate test revision')
        self.assertEqual(self.scan('--revision', 'HEAD').returncode, 1)
        p.write_text('Implementación final\n')
        self.assertEqual(self.scan('--all').returncode, 0)
        self.assertEqual(self.scan('--revision', 'HEAD').returncode, 1)

    def test_revision_checks_commit_message(self):
        self.git('commit', '--allow-empty', '-qm', 'Release Candidate 0.8.0')
        self.assertEqual(self.scan('--revision', 'HEAD').returncode, 1)

    def test_ref_name_is_blocked(self):
        self.assertEqual(self.scan('--revision', 'HEAD', '--ref', 'refs/tags/v0.8.0-rc.1').returncode, 1)
        self.assertEqual(self.scan('--revision', 'HEAD', '--ref', 'refs/tags/v0.8.0').returncode, 0)

    def test_policy_file_exemption_is_exact(self):
        (self.root / '.agents').mkdir()
        (self.root / '.agents' / 'FINAL_RELEASE_POLICY.md').write_text('release candidate\n')
        (self.root / '.agents' / 'random.md').write_text('clean\n')
        self.assertEqual(self.scan('--all').returncode, 0)
        (self.root / '.agents' / 'random.md').write_text('release candidate\n')
        self.assertEqual(self.scan('--all').returncode, 1)


if __name__ == '__main__':
    unittest.main()
