"""The real cold-copy command sequence must resolve lint packages before format."""
from contextlib import redirect_stdout
import io
from pathlib import Path
import subprocess
import sys
import unittest
from unittest.mock import patch

sys.path.insert(0, str(Path(__file__).resolve().parents[1]))
import reproduce_tests


class ReproducerPreparationTest(unittest.TestCase):
    def run_sequence(self, fail_prepare=False):
        calls = []

        def run(command, **kwargs):
            calls.append(command)
            failed = fail_prepare and command[:2] == ['bash', '-c']
            return subprocess.CompletedProcess(command, 42 if failed else 0)

        with patch.object(reproduce_tests.shutil, 'which', return_value='/fake/sdk'), \
             patch.object(reproduce_tests.shutil, 'copytree'), \
             patch.object(reproduce_tests.subprocess, 'run', side_effect=run), \
             redirect_stdout(io.StringIO()):
            status = reproduce_tests.main()
        return status, calls

    def test_dependencies_precede_format_in_both_workflow_and_reproducer(self):
        status, calls = self.run_sequence()
        self.assertEqual(0, status)
        prepare = ['bash', '-c', 'flutter pub get && (cd preview && flutter pub get)']
        self.assertLess(calls.index(prepare), next(i for i, c in enumerate(calls) if c[:2] == ['dart', 'format']))
        workflow = (Path(__file__).resolve().parents[3] / '.github/workflows/tests.yml').read_text()
        self.assertLess(workflow.index('run: ' + prepare[2]), workflow.index('run: dart format'))

    def test_resolution_failure_stops_before_format_or_flutter_tests(self):
        status, calls = self.run_sequence(fail_prepare=True)
        self.assertEqual(42, status)
        self.assertEqual(2, len(calls))
        self.assertFalse(any(c[0] == 'dart' for c in calls))
        self.assertFalse(any(c == ['bash', 'tool/check.sh'] for c in calls))


if __name__ == '__main__':
    unittest.main()
