"""Regression tests for the publish eligibility and exact-version metadata gate."""
from __future__ import annotations

import importlib.util
import hashlib
import io
import json
from pathlib import Path
import tarfile
import tempfile
import subprocess
import unittest
from unittest.mock import patch

SCRIPT = Path(__file__).resolve().parents[1] / 'release_guard.py'
spec = importlib.util.spec_from_file_location('release_guard', SCRIPT)
assert spec and spec.loader
release_guard = importlib.util.module_from_spec(spec)
spec.loader.exec_module(release_guard)


class ReleaseGuardTest(unittest.TestCase):
    def make_package(self, root: Path, version='0.8.0', lock=None, changelog=None):
        (root / 'pubspec.yaml').write_text(
            f'name: morph_expressive\nversion: {version}\n', encoding='utf-8')
        (root / 'preview').mkdir()
        (root / 'preview/pubspec.lock').write_text(
            lock or f'  morph_expressive:\n    version: "{version}"\n', encoding='utf-8')
        (root / 'CHANGELOG.md').write_text(
            changelog or f'# Changelog\n\n## {version} - 2026-11-10\n\n### Fixed\n\n- Correct behavior.\n\n## 0.7.0 - 2026-11-02\n- Historical.\n',
            encoding='utf-8')

    def test_good_metadata_and_notes(self):
        with tempfile.TemporaryDirectory() as temp:
            root = Path(temp)
            self.make_package(root)
            self.assertEqual('0.8.0', release_guard.read_metadata(root, 'v0.8.0')[0])
            self.assertIn('Correct behavior.', release_guard.read_metadata(root)[1])

    def test_wrong_tag_rejected(self):
        with tempfile.TemporaryDirectory() as temp:
            root = Path(temp)
            self.make_package(root)
            with self.assertRaisesRegex(ValueError, 'differs'):
                release_guard.read_metadata(root, 'v0.9.0')

    def test_suffix_not_allowed(self):
        with tempfile.TemporaryDirectory() as temp:
            root = Path(temp)
            self.make_package(root, version='0.8.0-dev.1')
            with self.assertRaisesRegex(ValueError, 'stable'):
                release_guard.read_metadata(root)

    def test_lock_mismatch_rejected(self):
        with tempfile.TemporaryDirectory() as temp:
            root = Path(temp)
            self.make_package(root, lock='  morph_expressive:\n    version: "0.7.0"\n')
            with self.assertRaisesRegex(ValueError, 'Preview'):
                release_guard.read_metadata(root)

    def test_changelog_must_start_with_version(self):
        with tempfile.TemporaryDirectory() as temp:
            root = Path(temp)
            self.make_package(root, changelog='# Changelog\n\n## 0.7.0 - 2026-11-02\n- Old\n')
            with self.assertRaisesRegex(ValueError, 'First CHANGELOG'):
                release_guard.read_metadata(root)

    def test_empty_notes_rejected(self):
        with tempfile.TemporaryDirectory() as temp:
            root = Path(temp)
            self.make_package(root, changelog='# Changelog\n\n## 0.8.0 - 2026-11-10\n\n## 0.7.0 - 2026-11-02\n- Old\n')
            with self.assertRaisesRegex(ValueError, 'no release notes'):
                release_guard.read_metadata(root)

    def test_published_version_detection(self):
        class FakeResponse:
            def __enter__(self): return self
            def __exit__(self, *args): return False
            def read(self): return b'{"versions": [{"version": "0.7.0"}, {"version": "0.8.0"}]}'
        with patch.object(release_guard, 'urlopen', return_value=FakeResponse()):
            self.assertTrue(release_guard.published_status('0.7.0'))
            self.assertFalse(release_guard.published_status('0.9.0'))

    def test_missing_response_field_fails_closed(self):
        class FakeResponse:
            def __enter__(self): return self
            def __exit__(self, *args): return False
            def read(self): return b'{"latest": {"version": "0.8.0"}}'
        with patch.object(release_guard, 'urlopen', return_value=FakeResponse()):
            with self.assertRaisesRegex(RuntimeError, 'Unexpected'):
                release_guard.published_status('0.8.0')

    def test_work_branch_and_pull_request_only_validate(self):
        for event, ref in (
            ('push', 'refs/heads/feature/release'),
            ('pull_request', 'refs/pull/17/merge'),
            ('push', 'refs/tags/v0.8.0'),
            ('release', 'refs/tags/v0.8.0'),
        ):
            with self.subTest(event=event, ref=ref):
                self.assertEqual(
                    'validate-only',
                    release_guard.release_decision(
                        event=event, ref=ref, gates_passed=True,
                        validated_sha='abc', main_sha='abc', published_state='absent'),
                )

    def test_main_requires_all_gates_and_current_sha(self):
        common = dict(event='push', ref='refs/heads/main', validated_sha='abc',
                      main_sha='abc', published_state='absent')
        self.assertEqual('blocked', release_guard.release_decision(
            **common, gates_passed=False))
        self.assertEqual('stale-skip', release_guard.release_decision(
            **{**common, 'main_sha': 'def'}, gates_passed=True))
        self.assertEqual('publish', release_guard.release_decision(
            **common, gates_passed=True))

    def test_existing_version_requires_matching_archive_before_recovery(self):
        common = dict(event='push', ref='refs/heads/main', gates_passed=True,
                      validated_sha='abc', main_sha='abc', published_state='published')
        self.assertEqual('existing-version-conflict', release_guard.release_decision(
            **common, archive_matches=False))
        self.assertEqual('recover', release_guard.release_decision(
            **common, archive_matches=True))

    def test_network_error_and_publish_failure_never_reach_tagging(self):
        common = dict(event='push', ref='refs/heads/main', gates_passed=True,
                      validated_sha='abc', main_sha='abc')
        self.assertEqual('blocked', release_guard.release_decision(
            **common, published_state='error'))
        self.assertEqual('publication-failed', release_guard.release_decision(
            **common, published_state='absent', publish_state='failed'))

    def test_existing_tag_on_another_sha_is_a_conflict(self):
        self.assertEqual('tag-conflict', release_guard.release_decision(
            event='push', ref='refs/heads/main', gates_passed=True,
            validated_sha='abc', main_sha='abc', published_state='published',
            archive_matches=True, existing_tag_sha='def'))

    def test_successful_publish_requires_pub_dev_confirmation(self):
        common = dict(event='push', ref='refs/heads/main', gates_passed=True,
                      validated_sha='abc', main_sha='abc', published_state='absent',
                      publish_state='succeeded')
        self.assertEqual('await-confirmation', release_guard.release_decision(
            **common, publication_confirmed=False))
        self.assertEqual('recover', release_guard.release_decision(
            **common, publication_confirmed=True))




class WorkflowPathTests(unittest.TestCase):
    """The published workflows may never require local agent-context files."""

    def make_package(self, root: Path):
        (root / 'pubspec.yaml').write_text(
            'name: morph_expressive\nversion: 0.8.0\n', encoding='utf-8')
        (root / 'preview').mkdir()
        (root / 'preview/pubspec.lock').write_text(
            '  morph_expressive:\n    version: "0.8.0"\n', encoding='utf-8')
        (root / 'CHANGELOG.md').write_text(
            '# Changelog\n\n## 0.8.0 - 2026-11-10\n\n### Fixed\n\n- Correct behavior.\n',
            encoding='utf-8')

    def test_workflows_reference_committed_tool_only(self):
        root = Path(__file__).resolve().parents[3]
        workflows = root / '.github/workflows'
        text = '\n'.join(file.read_text(encoding='utf-8') for file in workflows.glob('*.yml'))
        self.assertNotIn('.agents/', text)
        self.assertIn('tool/ci/', text)
        for filename in ('morph-auto-tag.yml', 'dependency-compatibility.yml'):
            with self.subTest(workflow=filename):
                self.assertFalse((workflows / filename).exists())
        for name in ('check_final_release_language.py', 'release_guard.py'):
            self.assertTrue((root / 'tool/ci' / name).is_file())

    def test_local_excluded_context_is_allowed_but_staged_context_is_rejected(self):
        with tempfile.TemporaryDirectory() as temp:
            root = Path(temp)
            self.make_package(root)
            subprocess.run(['git', 'init', '-q', str(root)], check=True)
            (root / '.git/info/exclude').write_text('/.agents/\n/AGENTS.md\n')
            (root / '.agents').mkdir()
            (root / '.agents/instructions.md').write_text('local')
            (root / 'AGENTS.md').write_text('local')
            subprocess.run(['git', '-C', str(root), 'add', '.'], check=True)
            release_guard.check_local_context_paths(root)
            subprocess.run(['git', '-C', str(root), 'add', '-f', 'AGENTS.md'], check=True)
            with self.assertRaisesRegex(ValueError, 'local agent context'):
                release_guard.check_local_context_paths(root)

    def test_zip_has_no_tracking_evidence(self):
        with tempfile.TemporaryDirectory() as temp:
            with self.assertRaisesRegex(ValueError, 'Git checkout'):
                release_guard.check_local_context_paths(Path(temp))

    def test_outgoing_revision_is_checked_even_after_index_is_corrected(self):
        with tempfile.TemporaryDirectory() as temp:
            root = Path(temp)
            subprocess.run(['git', 'init', '-q', str(root)], check=True)
            (root / 'AGENTS.md').write_text('local')
            subprocess.run(['git', '-C', str(root), 'add', 'AGENTS.md'], check=True)
            subprocess.run(['git', '-C', str(root), '-c', 'user.name=Guard test', '-c',
                            'user.email=test@localhost', 'commit', '-qm', 'fixture'], check=True)
            subprocess.run(['git', '-C', str(root), 'rm', '--cached', '-q', 'AGENTS.md'], check=True)
            release_guard.check_local_context_paths(root)
            with self.assertRaisesRegex(ValueError, 'local agent context'):
                release_guard.check_local_context_paths(root, 'HEAD')

    def archive(self, entries):
        buffer = io.BytesIO()
        with tarfile.open(fileobj=buffer, mode='w:gz') as archive:
            for name, content in entries.items():
                member = tarfile.TarInfo(name)
                member.size = len(content)
                archive.addfile(member, io.BytesIO(content))
        return buffer.getvalue()

    def test_archive_rejects_local_context_unsafe_and_duplicate_paths(self):
        for name in ('.agents/instructions.md', 'nested/AGENTS.md', '.serena/project.yml',
                     '../escape', '/absolute', 'a/../pubspec.yaml'):
            with self.subTest(name=name):
                data = self.archive({'pubspec.yaml': b'name: morph_expressive', name: b'local'})
                with self.assertRaises(ValueError):
                    release_guard.archive_files(data)

    def test_recovery_compares_actual_pub_archives_including_file_sets(self):
        entries = {'pubspec.yaml': b'name: morph_expressive\nversion: 0.8.0\n',
                   'README.md': b'source'}
        local_bytes = self.archive(entries)
        class Response:
            def __init__(self, content): self.content = content
            def __enter__(self): return self
            def __exit__(self, *args): return False
            def read(self): return self.content
        with tempfile.TemporaryDirectory() as temp:
            archive = Path(temp) / 'package.tar.gz'
            archive.write_bytes(local_bytes)
            for changed in (False, True):
                remote = self.archive({**entries, 'README.md': b'changed'}) if changed else local_bytes
                record = {'archive_url': 'https://pub.dev/api/archives/morph_expressive-0.8.0.tar.gz',
                          'archive_sha256': hashlib.sha256(remote).hexdigest()}
                with patch.object(release_guard, 'urlopen', side_effect=[
                    Response(json.dumps(record).encode()), Response(remote)]):
                    self.assertEqual(not changed, release_guard.published_archive_matches(archive, '0.8.0'))
            record['archive_sha256'] = '0' * 64
            with patch.object(release_guard, 'urlopen', side_effect=[
                Response(json.dumps(record).encode()), Response(remote)]):
                with self.assertRaisesRegex(RuntimeError, 'checksum'):
                    release_guard.published_archive_matches(archive, '0.8.0')

    def test_modular_workflows_publish_only_from_main_after_quality(self):
        workflows = Path(__file__).resolve().parents[3] / '.github/workflows'
        caller = (workflows / 'ci.yml').read_text(encoding='utf-8')
        publisher = (workflows / 'publish.yml').read_text(encoding='utf-8')
        compatibility = (workflows / 'compatibility.yml').read_text(encoding='utf-8')
        package = (workflows / 'package.yml').read_text(encoding='utf-8')
        for text in (caller, publisher):
            self.assertIn("if: github.event_name == 'push' && github.ref == 'refs/heads/main'", text)
        self.assertIn('pull_request:', caller)
        self.assertIn('branches: [main]', caller)
        self.assertIn("branches: ['**']", caller)
        self.assertIn('needs: quality', caller)
        self.assertIn('uses: ./.github/workflows/publish.yml', caller)
        self.assertIn('workload_identity_provider:', publisher)
        self.assertIn('id_token_audience: https://pub.dev', publisher)
        self.assertIn('environment: pub.dev', publisher)
        self.assertIn('bash tool/ci/publish.sh', publisher)
        self.assertIn('release.py finalize', publisher)
        self.assertIn('fail-fast: false', compatibility)
        self.assertIn('resolution: [latest, lowest]', compatibility)
        self.assertIn('needs: [tests, compatibility, documentation, package]', caller)
        self.assertIn('pana:pana --json --exit-code-threshold=0', package)
        self.assertFalse((workflows / 'morph-auto-tag.yml').exists())
        self.assertFalse((workflows / 'dependency-compatibility.yml').exists())

if __name__ == '__main__':
    unittest.main()
