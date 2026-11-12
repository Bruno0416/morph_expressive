"""Operational release regressions; no network or real publication is performed."""
from __future__ import annotations

import importlib.util
import json
import os
from pathlib import Path
import subprocess
import sys
import tempfile
import unittest
from unittest.mock import patch

TOOL = Path(__file__).resolve().parents[1]
sys.path.insert(0, str(TOOL))
spec = importlib.util.spec_from_file_location('morph_release', TOOL / 'release.py')
release = importlib.util.module_from_spec(spec)
spec.loader.exec_module(release)
SHA = 'a' * 40
OLD = 'b' * 40


class ReleaseOperationsTest(unittest.TestCase):
    def test_registry_error_prevents_tag_and_release(self):
        with patch.object(release, 'require_main_push', return_value=SHA), \
             patch.object(release.guard, 'read_metadata', return_value=('0.8.0', 'notes')), \
             patch.object(release.guard, 'published_status', side_effect=RuntimeError('offline')), \
             patch.object(release, 'run') as run:
            with self.assertRaisesRegex(RuntimeError, 'offline'):
                release.finalize(Path('.'), Path('archive'), SHA)
            run.assert_not_called()

    def test_wrong_archive_prevents_tag(self):
        with patch.object(release.guard, 'published_status', return_value=True), \
             patch.object(release.guard, 'published_archive_matches', return_value=False), \
             patch.object(release, 'run') as run:
            with self.assertRaisesRegex(ValueError, 'differs'):
                release.confirm(Path('archive'), '0.8.0')
            run.assert_not_called()

    def test_confirm_retries_absence_but_not_registry_errors(self):
        with patch.object(release.guard, 'published_status', side_effect=[False, True]), \
             patch.object(release.guard, 'published_archive_matches', return_value=True) as compare, \
             patch.object(release.time, 'sleep') as sleep:
            release.confirm(Path('archive'), '0.8.0')
            sleep.assert_called_once_with(5)
            compare.assert_called_once()

    def test_finalize_confirms_then_tags_tested_sha_even_if_main_advanced(self):
        events = []
        def run(*args, **kwargs):
            events.append(args)
            return subprocess.CompletedProcess(args, 0, '', '')
        with tempfile.TemporaryDirectory() as temp, \
             patch.dict(os.environ, {'RUNNER_TEMP': temp}), \
             patch.object(release, 'require_main_push', return_value=SHA), \
             patch.object(release.guard, 'read_metadata', return_value=('0.8.0', 'notes')), \
             patch.object(release, 'confirm', side_effect=lambda *a: events.append(('confirmed',))), \
             patch.object(release, 'remote_tag_sha', side_effect=[None, SHA]), \
             patch.object(release, 'github_release_exists', side_effect=[False, True]), \
             patch.object(release, 'run', side_effect=run), \
             patch.object(release, 'current_main', return_value=OLD) as main:
            release.finalize(Path('.'), Path('archive'), SHA)
            self.assertEqual(('confirmed',), events[0])
            self.assertIn(('git', 'tag', 'v0.8.0', SHA), events)
            self.assertLess(events.index(('git', 'push', 'origin', 'refs/tags/v0.8.0')),
                            next(i for i, e in enumerate(events) if e[:3] == ('gh', 'release', 'create')))
            main.assert_not_called()

    def test_tag_conflict_never_overwrites_remote(self):
        with patch.object(release, 'require_main_push', return_value=SHA), \
             patch.object(release.guard, 'read_metadata', return_value=('0.8.0', 'notes')), \
             patch.object(release, 'confirm'), \
             patch.object(release, 'remote_tag_sha', return_value=OLD), \
             patch.object(release, 'run') as run:
            with self.assertRaisesRegex(ValueError, 'conflicts'):
                release.finalize(Path('.'), Path('archive'), SHA)
            run.assert_not_called()

    def test_complete_release_is_noop_and_recovery_reuses_an_ancestor_tag(self):
        for exists, expected in [(True, 'complete'), (False, 'recover')]:
            with self.subTest(exists=exists), \
                 patch.object(release, 'require_main_push', return_value=SHA), \
                 patch.object(release, 'current_main', return_value=SHA), \
                 patch.object(release.guard, 'check_local_context_paths'), \
                 patch.object(release.guard, 'read_metadata', return_value=('0.8.0', 'notes')), \
                 patch.object(release.guard, 'published_status', return_value=True), \
                 patch.object(release.guard, 'published_archive_matches', return_value=True), \
                 patch.object(release, 'remote_tag_sha', return_value=OLD), \
                 patch.object(release, 'verify_tagged_archive'), \
                 patch.object(release, 'github_release_exists', return_value=exists), \
                 patch.object(release, 'run', side_effect=[
                     subprocess.CompletedProcess([], 0, '', ''),
                     subprocess.CompletedProcess([], 0, 'version: 0.8.0\n', '')]):
                result = release.plan(Path('.'), Path('archive'))
                self.assertEqual(expected, result['decision'])
                self.assertEqual(OLD, result['release_sha'])

    def test_recovery_rejects_a_tag_with_same_version_but_different_package(self):
        with patch.object(release, 'require_main_push', return_value=SHA), \
             patch.object(release, 'current_main', return_value=SHA), \
             patch.object(release.guard, 'check_local_context_paths'), \
             patch.object(release.guard, 'read_metadata', return_value=('0.8.0', 'notes')), \
             patch.object(release.guard, 'published_status', return_value=True), \
             patch.object(release.guard, 'published_archive_matches', return_value=True), \
             patch.object(release, 'remote_tag_sha', return_value=OLD), \
             patch.object(release, 'verify_tagged_archive', side_effect=ValueError('tag package differs')), \
             patch.object(release, 'run', side_effect=[
                 subprocess.CompletedProcess([], 0, '', ''),
                 subprocess.CompletedProcess([], 0, 'version: 0.8.0\n', '')]):
            with self.assertRaisesRegex(ValueError, 'tag package differs'):
                release.plan(Path('.'), Path('archive'))

    def test_tag_cannot_justify_publication_of_missing_registry_version(self):
        self.assertEqual('tag-conflict', release.guard.release_decision(
            event='push', ref='refs/heads/main', gates_passed=True,
            validated_sha=SHA, main_sha=SHA, published_state='absent', existing_tag_sha=SHA))

    def test_preflight_stale_push_has_no_registry_or_tag_side_effect(self):
        with patch.object(release, 'require_main_push', return_value=SHA), \
             patch.object(release, 'current_main', return_value=OLD), \
             patch.object(release.guard, 'check_local_context_paths'), \
             patch.object(release.guard, 'read_metadata', return_value=('0.8.0', 'notes')), \
             patch.object(release.guard, 'published_status') as registry, \
             patch.object(release, 'remote_tag_sha') as tag:
            self.assertEqual('stale-skip', release.plan(Path('.'), Path('archive'))['decision'])
            registry.assert_not_called()
            tag.assert_not_called()

    def test_github_404_is_absence_but_auth_failure_is_not(self):
        with patch.dict(os.environ, {'GH_REPO': 'owner/repository'}):
            for status in (404, 401, 403, 500):
                result = subprocess.CompletedProcess([], 1, f'HTTP/2.0 {status} Error\n\n{{}}', '')
                with self.subTest(status=status), patch.object(release, 'run', return_value=result):
                    if status == 404:
                        self.assertFalse(release.github_release_exists('v0.8.0'))
                    else:
                        with self.assertRaises(RuntimeError):
                            release.github_release_exists('v0.8.0')

    def test_lightweight_and_annotated_tags_resolve_to_commit(self):
        for peeled in (False, True):
            refs = f'{OLD if peeled else SHA}\trefs/tags/v0.8.0\n'
            if peeled:
                refs += f'{SHA}\trefs/tags/v0.8.0^{{}}\n'
            with self.subTest(peeled=peeled), patch.object(release, 'run', return_value=
                    subprocess.CompletedProcess([], 0, refs, '')):
                self.assertEqual(SHA, release.remote_tag_sha('v0.8.0'))

    def test_existing_github_release_must_be_public_and_stable(self):
        with patch.dict(os.environ, {'GH_REPO': 'owner/repository'}):
            for draft, unstable in [(False, False), (True, False), (False, True)]:
                body = json.dumps(dict(tagName='v0.8.0', isDraft=draft, isPrerelease=unstable))
                with self.subTest(draft=draft, unstable=unstable), patch.object(release, 'run', side_effect=[
                    subprocess.CompletedProcess([], 0, 'HTTP/2.0 200 OK\n\n{}', ''),
                    subprocess.CompletedProcess([], 0, body, '')]):
                    if draft or unstable:
                        with self.assertRaisesRegex(ValueError, 'metadata'):
                            release.github_release_exists('v0.8.0')
                    else:
                        self.assertTrue(release.github_release_exists('v0.8.0'))

    def test_entry_points_reject_non_main_and_wrong_checkout(self):
        with patch.dict(os.environ, {'GITHUB_EVENT_NAME': 'push', 'GITHUB_REF': 'refs/heads/work',
                                     'GITHUB_SHA': SHA}):
            with self.assertRaisesRegex(ValueError, 'main'):
                release.require_main_push()
        with patch.dict(os.environ, {'GITHUB_EVENT_NAME': 'push', 'GITHUB_REF': 'refs/heads/main',
                                     'GITHUB_SHA': SHA}), \
             patch.object(release, 'run', return_value=subprocess.CompletedProcess([], 0, OLD, '')):
            with self.assertRaisesRegex(ValueError, 'Checkout'):
                release.require_main_push()

    def test_publish_keeps_env_token_and_cleans_up_even_on_failure(self):
        for publish_status in (0, 65):
            with self.subTest(publish_status=publish_status), tempfile.TemporaryDirectory() as temp:
                root = Path(temp)
                (root / 'python3').write_text('#!/bin/sh\nexit 0\n')
                (root / 'dart').write_text('''#!/bin/sh
printf '%s\\n' "$*" >> "$MOCK_LOG"
test -n "$PUB_DEV_TOKEN" || exit 98
if [ "$1 $2 $3" = 'pub publish --force' ]; then exit "$MOCK_STATUS"; fi
''')
                for file in root.iterdir():
                    file.chmod(0o755)
                log = root / 'calls'
                env = dict(os.environ, PATH=f'{root}:{os.environ["PATH"]}', PUB_DEV_TOKEN='mock',
                           MOCK_LOG=str(log), MOCK_STATUS=str(publish_status))
                result = subprocess.run(['bash', str(TOOL / 'publish.sh')], env=env, capture_output=True)
                self.assertEqual(publish_status, result.returncode)
                self.assertEqual(['pub token add https://pub.dev --env-var=PUB_DEV_TOKEN',
                                  'pub publish --force', 'pub token remove https://pub.dev'], log.read_text().splitlines())


if __name__ == '__main__':
    unittest.main()
