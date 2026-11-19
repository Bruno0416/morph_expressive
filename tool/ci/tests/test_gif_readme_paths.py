"""Run the actual asset guard against README path, set and weight regressions."""
from pathlib import Path
import re
import shutil
import subprocess
import sys
import tempfile
import unittest

ROOT = Path(__file__).resolve().parents[3]
RAW = 'https://raw.githubusercontent.com/Bruno0416/morph_expressive/main/'
SHOWN = ['buttons', 'variants', 'frosted', 'density', 'context_menu', 'async_button']


def readme_with(names, extra=''):
    images = '\n'.join(f'<img src="{RAW}doc/assets/gifs/{n}.gif" width="480" alt="{n}">'
                       for n in names)
    return f'# Morph\n\n<img src="{RAW}doc/assets/banner.png" alt="banner">\n\n{images}\n{extra}\n'


class ReadmeGifPathsTest(unittest.TestCase):
    def check(self, readme=None, pubspec=None, mutate_files=None):
        with tempfile.TemporaryDirectory() as temp:
            root = Path(temp)
            for relative in ['tool/check_gif_branding.py', 'tool/gif_capture/capture.mjs',
                             'pubspec.yaml']:
                target = root / relative
                target.parent.mkdir(parents=True, exist_ok=True)
                shutil.copyfile(ROOT / relative, target)
            shutil.copytree(ROOT / 'doc/assets/gifs', root / 'doc/assets/gifs')
            (root / 'doc/assets/banner.png').write_bytes(b'\x89PNG\r\n')
            (root / 'README.md').write_text(readme if readme is not None else readme_with(SHOWN))
            if pubspec is not None:
                (root / 'pubspec.yaml').write_text(pubspec(
                    (root / 'pubspec.yaml').read_text()))
            if mutate_files:
                mutate_files(root)
            return subprocess.run([sys.executable, str(root / 'tool/check_gif_branding.py')],
                                  cwd=root, capture_output=True, text=True)

    def test_absolute_urls_with_local_assets_pass(self):
        result = self.check()
        self.assertEqual(0, result.returncode, result.stderr)

    def test_readme_may_show_a_subset_but_not_too_few(self):
        self.assertEqual(0, self.check(readme_with(SHOWN[:6])).returncode)
        result = self.check(readme_with(SHOWN[:3]))
        self.assertNotEqual(0, result.returncode)
        self.assertIn('expected at least', result.stderr)

    def test_relative_gif_path_is_rejected(self):
        result = self.check(readme_with(SHOWN, '<img src="doc/assets/gifs/tabs.gif" alt="x">'))
        self.assertNotEqual(0, result.returncode)
        self.assertIn('never a relative path', result.stderr)

    def test_relative_markdown_image_is_rejected(self):
        result = self.check(readme_with(SHOWN, '![tabs](doc/assets/gifs/tabs.gif)'))
        self.assertNotEqual(0, result.returncode)
        self.assertIn('never a relative path', result.stderr)

    def test_other_branch_blob_or_query_urls_are_rejected(self):
        gif = f'{RAW}doc/assets/gifs/tabs.gif'
        for bad in [gif.replace('/main/', '/develop/'),
                    gif + '?raw=true',
                    gif.replace('raw.githubusercontent.com', 'github.com').replace(
                        '/main/', '/blob/main/')]:
            with self.subTest(bad=bad):
                result = self.check(readme_with(SHOWN, f'<img src="{bad}" alt="x">'))
                self.assertNotEqual(0, result.returncode)
                self.assertIn('absolute URL under', result.stderr)

    def test_svg_banner_source_is_rejected(self):
        result = self.check(readme_with(
            SHOWN, f'<img src="{RAW}doc/assets/banner.svg" alt="banner">'))
        self.assertNotEqual(0, result.returncode)

    def test_third_party_badges_are_not_checked(self):
        result = self.check(readme_with(
            SHOWN, '![pub](https://img.shields.io/pub/v/morph_expressive.svg)'))
        self.assertEqual(0, result.returncode, result.stderr)

    def test_missing_local_asset_is_rejected(self):
        result = self.check(mutate_files=lambda root: (root / 'doc/assets/gifs/tabs.gif').unlink(),
                            readme=readme_with(SHOWN + ['tabs']))
        self.assertNotEqual(0, result.returncode)
        self.assertIn('Missing GIF', result.stderr)

    def test_unknown_scene_in_readme_is_rejected(self):
        result = self.check(readme_with(SHOWN + ['not_present']))
        self.assertNotEqual(0, result.returncode)
        self.assertIn('not an allowed scene', result.stderr)

    def test_missing_banner_file_is_rejected(self):
        result = self.check(mutate_files=lambda root: (root / 'doc/assets/banner.png').unlink())
        self.assertNotEqual(0, result.returncode)
        self.assertIn('banner.png is missing', result.stderr)

    def test_stray_gif_is_rejected(self):
        result = self.check(mutate_files=lambda root: shutil.copyfile(
            root / 'doc/assets/gifs/tabs.gif', root / 'doc/assets/gifs/stray.gif'))
        self.assertNotEqual(0, result.returncode)
        self.assertIn('not a known scene', result.stderr)

    def test_oversized_readme_gif_is_rejected(self):
        def pad(root):
            path = root / 'doc/assets/gifs/buttons.gif'
            path.write_bytes(path.read_bytes() + b'\x00' * (2 * 1024 * 1024))
        result = self.check(mutate_files=pad)
        self.assertNotEqual(0, result.returncode)
        self.assertIn('README GIFs stay under', result.stderr)

    def test_more_than_ten_screenshots_are_rejected(self):
        def extra(text):
            entry = ('  - description: Extra\n    path: doc/assets/gifs/tabs.gif\n')
            return re.sub(r'(?m)^(screenshots:\n)', r'\1' + entry * 11, text, count=1)
        result = self.check(pubspec=extra)
        self.assertNotEqual(0, result.returncode)
        self.assertIn('pub.dev allows', result.stderr)

    def test_long_screenshot_description_is_rejected(self):
        def long(text):
            return re.sub(r'(?m)^(  - description: )(.+)$', r'\1' + 'x' * 170, text, count=1)
        result = self.check(pubspec=long)
        self.assertNotEqual(0, result.returncode)
        self.assertIn('description longer than', result.stderr)


if __name__ == '__main__':
    unittest.main()
