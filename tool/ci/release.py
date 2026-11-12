#!/usr/bin/env python3
"""Main-only release orchestration. CI gates run before these entry points.

No credentials are handled here. Remote errors fail closed; tags are immutable.
"""
from __future__ import annotations

import argparse
import json
import os
from pathlib import Path
import re
import subprocess
import sys
import tempfile
import time

import release_guard as guard


def run(*args: str, check: bool = True, cwd: Path | None = None) -> subprocess.CompletedProcess:
    result = subprocess.run(args, cwd=cwd, capture_output=True, text=True, check=False)
    if check and result.returncode:
        raise RuntimeError(f'{args[0]} failed ({result.returncode}): {result.stderr.strip()}')
    return result


def require_main_push() -> str:
    if os.environ.get('GITHUB_EVENT_NAME') != 'push' or os.environ.get('GITHUB_REF') != 'refs/heads/main':
        raise ValueError('Release commands require a push to main')
    sha = os.environ.get('GITHUB_SHA', '')
    if not re.fullmatch(r'[0-9a-f]{40}', sha):
        raise ValueError('GITHUB_SHA must be the exact validated commit')
    if run('git', 'rev-parse', 'HEAD').stdout.strip() != sha:
        raise ValueError('Checkout differs from the validated SHA')
    run('git', 'diff', '--exit-code')
    run('git', 'diff', '--cached', '--exit-code')
    return sha


def current_main() -> str:
    run('git', 'fetch', '--no-tags', 'origin', '+refs/heads/main:refs/remotes/origin/main')
    return run('git', 'rev-parse', 'refs/remotes/origin/main').stdout.strip()


def remote_tag_sha(tag: str) -> str | None:
    result = run('git', 'ls-remote', '--exit-code', '--tags', 'origin',
                 f'refs/tags/{tag}', f'refs/tags/{tag}^{{}}', check=False)
    if result.returncode == 2:
        return None
    if result.returncode:
        raise RuntimeError(f'Cannot verify remote tag: {result.stderr.strip()}')
    refs = {}
    for line in result.stdout.splitlines():
        fields = line.split()
        if len(fields) != 2 or not re.fullmatch(r'[0-9a-f]{40}', fields[0]):
            raise ValueError('Malformed remote tag response')
        if fields[1] not in {f'refs/tags/{tag}', f'refs/tags/{tag}^{{}}'} or fields[1] in refs:
            raise ValueError('Unexpected remote tag reference')
        refs[fields[1]] = fields[0]
    if f'refs/tags/{tag}' not in refs:
        raise ValueError('Remote tag response has no tag')
    return refs.get(f'refs/tags/{tag}^{{}}', refs[f'refs/tags/{tag}'])


def github_release_exists(tag: str) -> bool:
    repo = os.environ.get('GH_REPO', '')
    if not re.fullmatch(r'[\w.-]+/[\w.-]+', repo):
        raise ValueError('GH_REPO must identify the repository')
    result = run('gh', 'api', '--include', f'repos/{repo}/releases/tags/{tag}', check=False)
    response = result.stdout.replace('\r\n', '\n')
    status = re.match(r'HTTP/[\d.]+ (\d{3})\b', response)
    if not status:
        raise RuntimeError('Cannot verify GitHub Release state')
    if status.group(1) == '404':
        return False
    if result.returncode or status.group(1) != '200':
        raise RuntimeError(f'GitHub Release lookup failed: HTTP {status.group(1)}')
    record = json.loads(run('gh', 'release', 'view', tag, '--json',
                            'tagName,isDraft,isPrerelease').stdout)
    if record.get('tagName') != tag or record.get('isDraft') is not False or record.get('isPrerelease') is not False:
        raise ValueError('Existing GitHub Release has unexpected metadata')
    return True


def verify_tagged_archive(tag_sha: str, archive: Path) -> None:
    """Prove an older tag actually contains this package, not just its version.

    Pub generates both file sets; no hand-maintained ignore approximation is
    safe here. All generated files stay in a disposable detached worktree.
    """
    with tempfile.TemporaryDirectory(prefix='release-tag-', dir=os.environ['RUNNER_TEMP']) as temp:
        worktree = Path(temp) / 'source'
        tagged_archive = Path(temp) / 'package.tar.gz'
        run('git', 'worktree', 'add', '--detach', str(worktree), tag_sha)
        try:
            run('dart', 'pub', 'publish', f'--to-archive={tagged_archive}', cwd=worktree)
            if guard.archive_files(tagged_archive.read_bytes()) != guard.archive_files(archive.read_bytes()):
                raise ValueError('Existing tag package differs from the published package')
        finally:
            run('git', 'worktree', 'remove', '--force', str(worktree))


def plan(root: Path, archive: Path) -> dict[str, str]:
    sha = require_main_push()
    guard.check_local_context_paths(root)
    version, _ = guard.read_metadata(root)
    main_sha = current_main()
    result = dict(version=version, tag=f'v{version}', release_sha=sha)
    if sha != main_sha:
        return dict(result, decision='stale-skip')
    tag_sha = remote_tag_sha(result['tag'])
    ancestor = False
    if tag_sha:
        ancestry = run('git', 'merge-base', '--is-ancestor', tag_sha, sha, check=False)
        if ancestry.returncode not in (0, 1):
            raise RuntimeError('Cannot verify tag ancestry')
        ancestor = ancestry.returncode == 0
        tagged_spec = run('git', 'show', f'{tag_sha}:pubspec.yaml').stdout
        tagged_version = guard.PUBSPEC_VERSION.search(tagged_spec)
        if not ancestor or not tagged_version or tagged_version.group(1) != version:
            raise ValueError('Existing tag identity/version conflicts with this release')
        result['release_sha'] = tag_sha
    published = guard.published_status(version)
    matches = guard.published_archive_matches(archive, version) if published else False
    if published and matches and tag_sha and tag_sha != sha:
        verify_tagged_archive(tag_sha, archive)
    exists = github_release_exists(result['tag'])
    if exists and tag_sha is None:
        raise ValueError('GitHub Release exists without its remote tag')
    decision = guard.release_decision(
        event='push', ref='refs/heads/main', gates_passed=True,
        validated_sha=sha, main_sha=main_sha,
        published_state='published' if published else 'absent', archive_matches=matches,
        existing_tag_sha=tag_sha, tag_is_ancestor=ancestor, release_exists=exists)
    if decision not in {'publish', 'recover', 'complete'}:
        raise ValueError(f'Release blocked: {decision}')
    return dict(result, decision=decision)


def confirm(archive: Path, version: str) -> None:
    for attempt in range(5):
        if guard.published_status(version):
            if not guard.published_archive_matches(archive, version):
                raise ValueError('Published package differs from the validated package archive')
            return
        if attempt < 4:
            time.sleep(5)
    raise ValueError('pub.dev has not confirmed the immutable version')


def finalize(root: Path, archive: Path, release_sha: str) -> None:
    sha = require_main_push()
    version, notes = guard.read_metadata(root)
    if not re.fullmatch(r'[0-9a-f]{40}', release_sha):
        raise ValueError('Invalid release SHA')
    if release_sha != sha:
        run('git', 'merge-base', '--is-ancestor', release_sha, sha)
    confirm(archive, version)  # No tag/release side effects before exact archive confirmation.
    tag = f'v{version}'
    tag_sha = remote_tag_sha(tag)
    if tag_sha is None:
        if release_sha != sha:
            raise ValueError('Recovery tag disappeared; refusing to recreate it on an older SHA')
        run('git', 'tag', tag, sha)
        run('git', 'push', 'origin', f'refs/tags/{tag}')
        if remote_tag_sha(tag) != sha:
            raise ValueError('Remote tag confirmation failed')
    elif tag_sha != release_sha:
        raise ValueError('Remote tag moved or conflicts; never overwrite it')
    # main may advance after the upload. Tag the already published tested SHA.
    if not github_release_exists(tag):
        notes_file = Path(os.environ['RUNNER_TEMP']) / 'release-notes.md'
        notes_file.write_text(notes + '\n', encoding='utf-8')
        run('gh', 'release', 'create', tag, '--verify-tag', '--title',
            f'Morph Expressive {version}', '--notes-file', str(notes_file), '--latest')
        if not github_release_exists(tag):
            raise ValueError('GitHub Release creation was not confirmed')


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('command', choices=['plan', 'assert-current-main', 'finalize'])
    parser.add_argument('--archive', type=Path)
    parser.add_argument('--release-sha')
    args = parser.parse_args()
    try:
        if args.command == 'assert-current-main':
            if require_main_push() != current_main():
                raise ValueError('main advanced before publication; refusing upload')
        elif args.command == 'plan':
            if not args.archive:
                parser.error('--archive is required')
            result = plan(guard.ROOT, args.archive)
            with Path(os.environ['GITHUB_OUTPUT']).open('a', encoding='utf-8') as output:
                for key, value in result.items():
                    output.write(f'{key}={value}\n')
            print(f'Release decision: {result["decision"]} ({result["version"]})')
        else:
            if not args.archive or not args.release_sha:
                parser.error('--archive and --release-sha are required')
            finalize(guard.ROOT, args.archive, args.release_sha)
        return 0
    except (OSError, RuntimeError, ValueError, KeyError, IndexError, subprocess.CalledProcessError) as exc:
        print(f'Release FAILED: {exc}', file=sys.stderr)
        return 1


if __name__ == '__main__':
    raise SystemExit(main())
