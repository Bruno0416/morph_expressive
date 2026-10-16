# Publishing checklist: 0.2.0

The source version is prepared as **0.2.0**, but changing `pubspec.yaml`,
committing to Git, and publishing on pub.dev are **three separate operations**.
A published version cannot be overwritten. Do not publish until each step
below has been reviewed.

## 1. Validate both Flutter packages

From the repository root:

```bash
bash tool/check.sh
```

This runs the source/API/branding/motion/coverage checks plus `flutter analyze`
and `flutter test` for both the library and `preview/`. A previous 725-test
success is valuable, but repeat the checks after applying the release patch.

## 2. Confirm GIF assets and examples

Review `doc/assets/gifs/chips.gif` and `textfields.gif` in the actual checkout.
They must show all three variants each and have been captured using the
updated release scenes. Confirm that the six other GIFs remain intact.

```bash
python3 tool/check_gif_branding.py
git status --short
git diff --check
```

The first pub.dev screenshot is the new chips scene; the second is the new
text-fields scene. Both are animated GIFs, which pub.dev supports as package
screenshots (up to 4 MB each). Do not stage Playwright caches, Web builds or
other temporary files.

Confirm that `example/main.dart`, the root `LICENSE`, `NOTICE`, and all
references in the README exist in the checkout. The README dependency
constraint `^0.2.0` is usable only **after** pub.dev publication.

## 3. Inspect the publishing archive

Use `.pubignore` to exclude generated builds, preview runtime, tests,
tooling, local caches and transient files. A `.gitignore` alone is not a
substitute for publication-specific exclusions. Keep `lib/`, `example/`,
README, CHANGELOG, LICENSE, NOTICE and maintained `doc/` sources and GIFs.

```bash
dart pub publish --dry-run
```

Inspect **all** warnings and listed archive files; ensure the package
metadata, SDK constraints, dependency ranges, version and screenshot paths
are correct. A dry-run checks the archive but does not upload it. The package
must not use `publish_to: none` in the root; that value belongs to the
unpublished `preview/` app only.

## 4. GitHub commit and publication (later step)

After verification, review the staged changes, including both refreshed
GIFs, and make a release commit. Push the reviewed branch and confirm the
README image URLs resolve on GitHub before publishing:

```bash
git status --short
git diff --check
# Review, stage and commit the release changes deliberately.
# Push to GitHub only after the full validation and asset review.
```

Then run `dart pub publish` interactively from the package root; read the
archive listing before confirming. Do not use `--force` or bypass validation.
Publication is not complete until pub.dev confirms version 0.2.0 is live.

## 5. Hosting caveat

Older source snapshots included a built Web app in `docs/`. If GitHub Pages
still deploys from the `/docs` branch directory, change its deployment
source before removing generated files. Deploy future Web previews through
a CI artifact or dedicated deployment branch rather than adding compiled
Flutter output to maintained reference documentation.
