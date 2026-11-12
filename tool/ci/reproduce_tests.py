#!/usr/bin/env python3
"""Run tests.yml's validation steps in a disposable checkout without local caches.

Requires the workflow's Flutter/Dart SDK on PATH. This runs real analysis/tests,
not SDK installation, remote GitHub orchestration or publishing.
"""
import shutil
import subprocess
import tempfile
from pathlib import Path


def main():
    for executable in ('flutter', 'dart'):
        if shutil.which(executable) is None:
            raise SystemExit(f'{executable} must be on PATH; use the SDK pinned in setup-flutter/action.yml')
    source = Path(__file__).resolve().parents[2]
    with tempfile.TemporaryDirectory(prefix='ci-tests-') as temp:
        target = Path(temp) / 'source'
        shutil.copytree(source, target, ignore=shutil.ignore_patterns(
            '.git', '.dart_tool', 'build', 'coverage', '__pycache__', '.agents',
            '.serena', 'AGENTS.md', '.plugin_symlinks', '.flutter-plugins-dependencies',
            '*.patch', '*.zip'))
        commands = [
            ['python3', '-m', 'unittest', 'discover', '-s', 'tool/ci/tests', '-p', 'test_*.py'],
            ['bash', '-c', 'flutter pub get && (cd preview && flutter pub get)'],
            ['dart', 'format', '--output=none', '--set-exit-if-changed',
             'lib', 'test', 'example', 'preview/lib', 'preview/test'],
            ['bash', 'tool/check.sh'],
        ]
        for command in commands:
            print('Running:', ' '.join(command), flush=True)
            result = subprocess.run(command, cwd=target, check=False)
            if result.returncode:
                return result.returncode
    return 0


if __name__ == '__main__':
    raise SystemExit(main())
