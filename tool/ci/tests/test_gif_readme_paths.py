"""Run the actual asset guard against README branch/path regressions."""
from pathlib import Path
import shutil
import subprocess
import sys
import tempfile
import unittest

ROOT = Path(__file__).resolve().parents[3]


class ReadmeGifPathsTest(unittest.TestCase):
    def check(self, change):
        with tempfile.TemporaryDirectory() as temp:
            root = Path(temp)
            for relative in ['tool/check_gif_branding.py', 'tool/gif_capture/capture.mjs',
                             'pubspec.yaml', 'README.md']:
                target = root / relative
                target.parent.mkdir(parents=True, exist_ok=True)
                shutil.copyfile(ROOT / relative, target)
            shutil.copytree(ROOT / 'doc/assets/gifs', root / 'doc/assets/gifs')
            file = root / 'README.md'
            file.write_text(change(file.read_text()))
            return subprocess.run([sys.executable, str(root / 'tool/check_gif_branding.py')],
                                  cwd=root, capture_output=True, text=True)

    def test_current_readme_and_all_local_assets_pass(self):
        result = self.check(lambda text: text)
        self.assertEqual(0, result.returncode, result.stderr)

    def test_default_branch_source_is_rejected(self):
        result = self.check(lambda text: text.replace(
            'src="doc/assets/gifs/async_button.gif"',
            'src="https://raw.githubusercontent.com/owner/repo/main/doc/assets/gifs/async_button.gif"'))
        self.assertNotEqual(0, result.returncode)
        self.assertIn('branch-relative local path', result.stderr)

    def test_missing_local_asset_is_rejected(self):
        result = self.check(lambda text: text.replace('doc/assets/gifs/async_button.gif',
                                                     'doc/assets/gifs/not_present.gif'))
        self.assertNotEqual(0, result.returncode)
        self.assertIn('missing GIF', result.stderr)


if __name__ == '__main__':
    unittest.main()
