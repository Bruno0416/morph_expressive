"""Operational release regressions; no network or real publication is performed."""
from __future__ import annotations

import contextlib
import importlib.util
import json
import os
import re
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
DONE = subprocess.CompletedProcess([], 0, '', '')


class FakeClock:
    """Monotonic clock whose sleep advances time instantly and records waits."""

    def __init__(self):
        self.now = 0.0
        self.sleeps: list[float] = []

    def monotonic(self) -> float:
        return self.now

    def sleep(self, seconds: float) -> None:
        self.sleeps.append(seconds)
        self.now += seconds

    @contextlib.contextmanager
    def installed(self):
        with patch.object(release.time, 'monotonic', self.monotonic), \
             patch.object(release.time, 'sleep', self.sleep), \
             patch('builtins.print'):
            yield self


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
        clock = FakeClock()
        with patch.object(release.guard, 'published_status', side_effect=[False, True]), \
             patch.object(release.guard, 'published_archive_matches', return_value=True) as compare, \
             clock.installed():
            release.confirm(Path('archive'), '0.8.0')
            self.assertEqual([release.FIRST_CONFIRM_INTERVAL], clock.sleeps)
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

    def test_absent_registry_version_prevents_tag_and_release_after_all_retries(self):
        with patch.object(release, 'require_main_push', return_value=SHA), \
             patch.object(release.guard, 'read_metadata', return_value=('0.8.0', 'notes')), \
             patch.object(release.guard, 'published_status', return_value=False) as status, \
             FakeClock().installed() as clock, \
             patch.object(release, 'run') as run:
            with self.assertRaisesRegex(ValueError, 'has not confirmed'):
                release.finalize(Path('.'), Path('archive'), SHA)
            self.assertEqual(release.DEFAULT_CONFIRM_TIMEOUT, clock.now)
            self.assertEqual(len(clock.sleeps) + 1, status.call_count)
            run.assert_not_called()

    def test_wrong_published_archive_prevents_finalization_side_effects(self):
        with patch.object(release, 'require_main_push', return_value=SHA), \
             patch.object(release.guard, 'read_metadata', return_value=('0.8.0', 'notes')), \
             patch.object(release.guard, 'published_status', return_value=True), \
             patch.object(release.guard, 'published_archive_matches', return_value=False), \
             patch.object(release, 'run') as run:
            with self.assertRaisesRegex(ValueError, 'differs'):
                release.finalize(Path('.'), Path('archive'), SHA)
            run.assert_not_called()

    def test_workflow_cannot_finalize_before_successful_upload(self):
        workflow = (TOOL.parents[1] / '.github/workflows/publish.yml').read_text()
        self.assertLess(workflow.index('run: bash tool/ci/publish.sh'),
                        workflow.index('run: python3 tool/ci/release.py finalize'))
        self.assertNotIn('continue-on-error: true', workflow)
        final_step = workflow.split('- name: Confirm archive, then create immutable tag and GitHub Release', 1)[1]
        self.assertNotIn('always()', final_step)
        self.assertNotIn('failure()', final_step)

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


def appears_after(clock: FakeClock, seconds: float):
    return lambda version: clock.now >= seconds


class ConfirmationPolicyTest(unittest.TestCase):
    """Bounded pub.dev propagation wait; a fake clock replaces real time."""

    def confirm(self, clock, status, matches=True, timeout=None, env=None):
        compare = matches if callable(matches) else (lambda *a: matches)
        with patch.dict(os.environ, env or {}, clear=False), \
             patch.object(release.guard, 'published_status', side_effect=status), \
             patch.object(release.guard, 'published_archive_matches', side_effect=compare), \
             clock.installed():
            release.confirm(Path('archive'), '1.0.0', timeout=timeout)

    def test_immediate_confirmation_never_sleeps(self):
        clock = FakeClock()
        self.confirm(clock, lambda version: True)
        self.assertEqual([], clock.sleeps)

    def test_slow_propagation_beyond_the_old_20_second_window_confirms(self):
        clock = FakeClock()
        self.confirm(clock, appears_after(clock, 75))
        self.assertGreater(clock.now, 20)
        self.assertEqual([10, 15, 22.5, 33.75], clock.sleeps)

    def test_backoff_is_capped_and_ten_minute_propagation_confirms(self):
        clock = FakeClock()
        self.confirm(clock, appears_after(clock, 600))
        self.assertLessEqual(max(clock.sleeps), release.MAX_CONFIRM_INTERVAL)
        self.assertLess(clock.now, release.DEFAULT_CONFIRM_TIMEOUT)

    def test_appearance_at_the_deadline_still_confirms(self):
        clock = FakeClock()
        self.confirm(clock, appears_after(clock, 100), timeout=100)
        self.assertEqual(100, clock.now)
        self.assertEqual(18.75, clock.sleeps[-1])

    def test_definitive_timeout_is_bounded_and_descriptive(self):
        clock = FakeClock()
        with self.assertRaisesRegex(ValueError, r'has not confirmed .*1\.0\.0 within 100s'):
            self.confirm(clock, lambda version: False, timeout=100)
        self.assertEqual(100, clock.now)

    def test_different_archive_fails_without_retry(self):
        clock = FakeClock()
        with self.assertRaisesRegex(ValueError, 'differs'):
            self.confirm(clock, lambda version: True, matches=False)
        self.assertEqual([], clock.sleeps)

    def test_checksum_and_auth_errors_fail_closed_without_retry(self):
        for error in ('Published archive checksum does not match pub.dev metadata',
                      'Cannot verify published archive: HTTP 403'):
            def compare(*args, error=error):
                raise RuntimeError(error)
            with self.subTest(error=error):
                clock = FakeClock()
                with self.assertRaisesRegex(RuntimeError, error):
                    self.confirm(clock, lambda version: True, matches=compare)
                self.assertEqual([], clock.sleeps)

    def test_pending_version_resources_are_retried_then_fully_verified(self):
        clock = FakeClock()
        calls = []
        def compare(*args):
            calls.append(clock.now)
            if len(calls) < 3:
                raise release.guard.RegistryPendingError('HTTP 404, not propagated yet')
            return True
        self.confirm(clock, lambda version: True, matches=compare)
        self.assertEqual(3, len(calls))

    def test_transient_errors_get_bounded_consecutive_retries(self):
        def flaky(failures):
            state = {'count': 0}
            def status(version):
                state['count'] += 1
                if state['count'] <= failures:
                    raise release.guard.RegistryTransientError('HTTP 503')
                return True
            return status
        clock = FakeClock()
        self.confirm(clock, flaky(release.MAX_CONSECUTIVE_TRANSIENT_ERRORS - 1))
        clock = FakeClock()
        with self.assertRaisesRegex(RuntimeError, 'consecutive'):
            self.confirm(clock, flaky(release.MAX_CONSECUTIVE_TRANSIENT_ERRORS))
        self.assertEqual(release.MAX_CONSECUTIVE_TRANSIENT_ERRORS - 1, len(clock.sleeps))

    def test_unclassified_registry_error_is_never_treated_as_pending(self):
        def status(version):
            raise RuntimeError('Cannot verify package versions on pub.dev: HTTP 401')
        clock = FakeClock()
        with self.assertRaisesRegex(RuntimeError, '401'):
            self.confirm(clock, status)
        self.assertEqual([], clock.sleeps)

    def test_timeout_is_configurable_but_bounded(self):
        self.assertEqual(720, release.DEFAULT_CONFIRM_TIMEOUT)
        for raw, expected in (('', 720), ('60', 60), ('900', 900)):
            with self.subTest(raw=raw), patch.dict(os.environ, {release.CONFIRM_TIMEOUT_ENV: raw}):
                self.assertEqual(expected, release.confirm_timeout())
        for raw in ('0', '59', '901', '-5', '1e3', 'forever'):
            with self.subTest(raw=raw), patch.dict(os.environ, {release.CONFIRM_TIMEOUT_ENV: raw}):
                with self.assertRaisesRegex(ValueError, 'between'):
                    release.confirm_timeout()

    def test_job_timeout_covers_the_maximum_confirmation_budget(self):
        workflow = (TOOL.parents[1] / '.github/workflows/publish.yml').read_text()
        minutes = int(re.search(r'timeout-minutes: (\d+)', workflow).group(1))
        # Setup, archive, preflight, upload and per-request timeouts need about 10 minutes.
        self.assertGreaterEqual(minutes * 60, release.MAX_CONFIRM_TIMEOUT + 600)


class RecoveryScenarioTest(unittest.TestCase):
    """plan/finalize decisions for partially and fully completed releases."""

    def plan(self, tag_sha, release_exists, main_sha=SHA, published=True, matches=True):
        tagged = [DONE, subprocess.CompletedProcess([], 0, 'version: 1.0.0\n', '')] if tag_sha else []
        with patch.object(release, 'require_main_push', return_value=SHA), \
             patch.object(release, 'current_main', return_value=main_sha), \
             patch.object(release.guard, 'check_local_context_paths'), \
             patch.object(release.guard, 'read_metadata', return_value=('1.0.0', 'notes')), \
             patch.object(release.guard, 'published_status', return_value=published) as registry, \
             patch.object(release.guard, 'published_archive_matches', return_value=matches), \
             patch.object(release, 'remote_tag_sha', return_value=tag_sha), \
             patch.object(release, 'verify_tagged_archive'), \
             patch.object(release, 'github_release_exists', return_value=release_exists), \
             patch.object(release, 'run', side_effect=tagged) as run:
            return release.plan(Path('.'), Path('archive')), registry, run

    def finalize(self, tag_states, release_states):
        events = []
        def run(*args, **kwargs):
            events.append(args)
            return DONE
        with tempfile.TemporaryDirectory() as temp, \
             patch.dict(os.environ, {'RUNNER_TEMP': temp}), \
             patch.object(release, 'require_main_push', return_value=SHA), \
             patch.object(release.guard, 'read_metadata', return_value=('1.0.0', 'notes')), \
             patch.object(release.guard, 'published_status', return_value=True), \
             patch.object(release.guard, 'published_archive_matches', return_value=True), \
             patch.object(release, 'remote_tag_sha', side_effect=tag_states), \
             patch.object(release, 'github_release_exists', side_effect=release_states), \
             patch.object(release, 'run', side_effect=run), \
             FakeClock().installed() as clock:
            release.finalize(Path('.'), Path('archive'), SHA)
        self.assertEqual([], clock.sleeps)
        return events

    def test_published_without_tag_or_release_recovers_without_upload(self):
        result, _, _ = self.plan(tag_sha=None, release_exists=False)
        self.assertEqual('recover', result['decision'])
        self.assertEqual(SHA, result['release_sha'])
        workflow = (TOOL.parents[1] / '.github/workflows/publish.yml').read_text()
        for step in ('Require configured short-lived publisher identity',
                     'Authenticate using GitHub OIDC federation',
                     'Publish the validated version to pub.dev'):
            body = workflow.split(f'- name: {step}', 1)[1].split('- name:', 1)[0]
            self.assertIn("if: steps.preflight.outputs.decision == 'publish'\n", body)
        events = self.finalize([None, SHA], [False, True])
        self.assertIn(('git', 'tag', 'v1.0.0', SHA), events)
        self.assertIn(('git', 'push', 'origin', 'refs/tags/v1.0.0'), events)
        self.assertEqual(1, sum(e[:3] == ('gh', 'release', 'create') for e in events))
        self.assertFalse(any('publish' in e for e in events))

    def test_partial_recovery_with_correct_tag_creates_only_the_release(self):
        result, _, _ = self.plan(tag_sha=SHA, release_exists=False)
        self.assertEqual('recover', result['decision'])
        events = self.finalize([SHA], [False, True])
        self.assertFalse(any(e[:2] in {('git', 'tag'), ('git', 'push')} for e in events))
        self.assertEqual(1, sum(e[:3] == ('gh', 'release', 'create') for e in events))

    def test_complete_release_is_idempotent_across_repeated_runs(self):
        for attempt in (1, 2):
            with self.subTest(attempt=attempt):
                result, _, _ = self.plan(tag_sha=SHA, release_exists=True)
                self.assertEqual('complete', result['decision'])
        workflow = (TOOL.parents[1] / '.github/workflows/publish.yml').read_text()
        final = workflow.split('- name: Confirm archive, then create immutable tag', 1)[1]
        self.assertNotIn("== 'complete'", final)
        events = self.finalize([SHA], [True])
        self.assertEqual([], events)

    def test_conflicting_tag_aborts_without_touching_it(self):
        with patch.object(release, 'require_main_push', return_value=SHA), \
             patch.object(release, 'current_main', return_value=SHA), \
             patch.object(release.guard, 'check_local_context_paths'), \
             patch.object(release.guard, 'read_metadata', return_value=('1.0.0', 'notes')), \
             patch.object(release, 'remote_tag_sha', return_value=OLD), \
             patch.object(release, 'run', side_effect=[
                 subprocess.CompletedProcess([], 1, '', ''),
                 subprocess.CompletedProcess([], 0, 'version: 1.0.0\n', '')]) as run:
            with self.assertRaisesRegex(ValueError, 'conflicts'):
                release.plan(Path('.'), Path('archive'))
            self.assertFalse(any(c.args[:2] in {('git', 'tag'), ('git', 'push')}
                                 for c in run.call_args_list))

    def test_published_archive_mismatch_blocks_recovery(self):
        with self.assertRaisesRegex(ValueError, 'existing-version-conflict'):
            self.plan(tag_sha=None, release_exists=False, matches=False)

    def test_advanced_main_skips_without_registry_access(self):
        result, registry, _ = self.plan(tag_sha=None, release_exists=False, main_sha=OLD)
        self.assertEqual('stale-skip', result['decision'])
        registry.assert_not_called()

    def test_unauthorized_branches_never_publish(self):
        for event, ref in (('push', 'refs/heads/review/v1.0.0-visual'),
                           ('pull_request', 'refs/pull/2/merge'),
                           ('workflow_dispatch', 'refs/heads/main')):
            with self.subTest(ref=ref), patch.dict(os.environ, {
                    'GITHUB_EVENT_NAME': event, 'GITHUB_REF': ref, 'GITHUB_SHA': SHA}):
                with self.assertRaisesRegex(ValueError, 'push to main'):
                    release.require_main_push()
                self.assertEqual('validate-only', release.guard.release_decision(
                    event=event, ref=ref, gates_passed=True, validated_sha=SHA,
                    main_sha=SHA, published_state='absent'))


if __name__ == '__main__':
    unittest.main()
