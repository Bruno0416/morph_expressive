"""Run the actual asset guard against README path, set and weight regressions."""
from pathlib import Path
import os
import re
import shutil
import subprocess
import sys
import tempfile
import unittest

ROOT = Path(__file__).resolve().parents[3]
PREFIX = 'https://raw.githubusercontent.com/Bruno0416/morph_expressive/'
RAW = PREFIX + 'main/'
REVIEW = 'review/v1.0.0-visual'
SHOWN = ['buttons', 'variants', 'dropdown', 'density', 'context_menu', 'async_button']
CI_VARIABLES = ('GITHUB_HEAD_REF', 'GITHUB_REF_NAME')


def readme_with(names, extra='', ref='main', banner_ref=None):
    base = f'{PREFIX}{ref}/'
    images = '\n'.join(f'<img src="{base}doc/assets/gifs/{n}.gif" width="480" alt="{n}">'
                       for n in names)
    banner = f'{PREFIX}{banner_ref or ref}/'
    return f'# Morph\n\n<img src="{banner}doc/assets/banner.png" alt="banner">\n\n{images}\n{extra}\n'


class ReadmeGifPathsTest(unittest.TestCase):
    def check(self, readme=None, pubspec=None, mutate_files=None, env=None):
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
            # Deterministic ref resolution: no inherited CI variables.
            environment = {k: v for k, v in os.environ.items() if k not in CI_VARIABLES}
            environment.update(env or {})
            return subprocess.run([sys.executable, str(root / 'tool/check_gif_branding.py')],
                                  cwd=root, capture_output=True, text=True, env=environment)

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

    def test_blob_or_query_urls_are_rejected(self):
        gif = f'{RAW}doc/assets/gifs/tabs.gif'
        for bad in [gif + '?raw=true',
                    gif.replace('raw.githubusercontent.com', 'github.com').replace(
                        '/main/', '/blob/main/')]:
            with self.subTest(bad=bad):
                result = self.check(readme_with(SHOWN, f'<img src="{bad}" alt="x">'))
                self.assertNotEqual(0, result.returncode)
                self.assertIn('absolute URL under', result.stderr)

    def test_main_ref_passes_on_any_branch(self):
        for env in [{}, {'GITHUB_REF_NAME': 'main'}, {'GITHUB_HEAD_REF': REVIEW}]:
            with self.subTest(env=env):
                result = self.check(readme_with(SHOWN, ref='main'), env=env)
                self.assertEqual(0, result.returncode, result.stderr)

    def test_current_branch_ref_passes_from_push_or_pull_request(self):
        readme = readme_with(SHOWN, ref=REVIEW)
        for env in [{'GITHUB_REF_NAME': REVIEW}, {'GITHUB_HEAD_REF': REVIEW},
                    {'GITHUB_HEAD_REF': REVIEW, 'GITHUB_REF_NAME': '12/merge'}]:
            with self.subTest(env=env):
                result = self.check(readme, env=env)
                self.assertEqual(0, result.returncode, result.stderr)

    def test_current_branch_ref_passes_from_git_fallback(self):
        def init_git(root):
            subprocess.run(['git', 'init', '-q', '-b', REVIEW, str(root)], check=True)
        result = self.check(readme_with(SHOWN, ref=REVIEW), mutate_files=init_git)
        self.assertEqual(0, result.returncode, result.stderr)
        # The same README is refused when git reports another branch.
        result = self.check(
            readme_with(SHOWN, ref=REVIEW),
            mutate_files=lambda root: subprocess.run(
                ['git', 'init', '-q', '-b', 'other', str(root)], check=True))
        self.assertNotEqual(0, result.returncode)

    def test_review_ref_is_rejected_when_current_branch_is_main(self):
        # What happens on main (push) and on a pull request targeting main.
        for env in [{'GITHUB_REF_NAME': 'main'}, {'GITHUB_HEAD_REF': 'main'}]:
            with self.subTest(env=env):
                result = self.check(readme_with(SHOWN, ref=REVIEW), env=env)
                self.assertNotEqual(0, result.returncode)
                self.assertIn(f"use ref '{REVIEW}'", result.stderr)
                self.assertIn('temporary', result.stderr)

    def test_other_branch_ref_is_rejected(self):
        result = self.check(readme_with(SHOWN, ref='develop'),
                            env={'GITHUB_REF_NAME': REVIEW})
        self.assertNotEqual(0, result.returncode)
        self.assertIn("use ref 'develop'", result.stderr)

    def test_mixed_refs_are_rejected(self):
        env = {'GITHUB_REF_NAME': REVIEW}
        for readme in [readme_with(SHOWN, ref=REVIEW, banner_ref='main'),
                       readme_with(SHOWN, extra=f'<img src="{PREFIX}{REVIEW}/doc/assets/gifs/tabs.gif" alt="x">')]:
            with self.subTest(readme=readme[:60]):
                result = self.check(readme, env=env)
                self.assertNotEqual(0, result.returncode)
                self.assertIn('mix refs', result.stderr)

    def test_frosted_scene_is_an_allowed_readme_scene(self):
        result = self.check(readme_with(SHOWN + ['frosted']))
        self.assertEqual(0, result.returncode, result.stderr)

    def test_missing_frosted_gif_is_rejected(self):
        result = self.check(
            readme_with(SHOWN + ['frosted']),
            mutate_files=lambda root: (root / 'doc/assets/gifs/frosted.gif').unlink())
        self.assertNotEqual(0, result.returncode)
        self.assertIn('frosted', result.stderr)

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
