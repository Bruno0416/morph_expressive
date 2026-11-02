# Morph Expressive 0.7.0 — release candidate checklist

**Do not push, tag or publish until every gate below is green.**

This release introduces frosted floating surfaces, opt-in frosted cards,
blur-safe native-derived geometric overscroll, and context menu interaction
fixes. The existing `doc/RELEASE.md` describes the historical 0.6.1 release
and should not be used as the 0.7.0 checklist.

## 1. Review the source changes

```bash
cd "$(git rev-parse --show-toplevel)"
git status --short
git diff --check
rg '^version:' pubspec.yaml
rg -A6 '  morph_expressive:' preview/pubspec.lock
```

Both the root `pubspec.yaml` and the *path* dependency in
`preview/pubspec.lock` should resolve to `0.7.0`. Leave the preview app's own
`version:` unchanged. Verify the new example's public imports, card glass
precedence, the native-derived stretch and its multi-ticker regression tests.

## 2. Run the new public example in a disposable app

From the repository root, with Flutter on `PATH`:

```bash
flutter create --platforms=android,ios,linux,macos,web,windows /tmp/morph-frosted-example
cd /tmp/morph-frosted-example
flutter pub add material_ui
# Point the example at this checkout (adjust the path if needed).
# Edit pubspec.yaml: morph_expressive: {path: /absolute/path/to/morph_ui}
# Then run flutter pub get and copy the example.
flutter pub get
cp /absolute/path/to/morph_ui/example/frosted_surfaces.dart lib/main.dart
flutter analyze
flutter run
```

Alternatively install a local path dependency manually in
`/tmp/morph-frosted-example/pubspec.yaml`. Check opaque cards, `frosted: true`,
custom glass, menu/dropdown/dialog/sheet, and repeated overscroll at both ends.
An opt-in card needs a visually non-uniform backdrop to demonstrate real blur.

## 3. Verify existing media assets (no new GIFs)

This release reuses the ten existing `doc/assets/gifs/*.gif` screenshots. No
new capture scenes, replacements or image files are needed for 0.7.0. Before
publication, verify that each path in `pubspec.yaml` exists, is below 4 MB,
and appears in the `dart pub publish --dry-run` package listing. Keep the
existing branding and asset integrity check:

```bash
python3 tool/check_gif_branding.py
```

## 4. Analyze, test and check dependency compatibility

```bash
cd "$(git rev-parse --show-toplevel)"
dart format --output=none --set-exit-if-changed lib test example preview/lib preview/test
flutter analyze
flutter test
(cd preview && flutter analyze && flutter test)
bash tool/check_dependency_matrix.sh all
```

The matrix creates disposable copies and checks `latest` and `lowest`,
including Web release build. Do not treat individual tests as a replacement.
Run the project's normal `tool/check.sh` and any project-specific consumer
smoke checks. Inspect and resolve the actual failures rather than suppressing
lints or test exceptions.

## 5. Pana and publishing dry-run

```bash
# From the repository root (does not publish or push):
bash tool/validate_release_0_7_0.sh
```

The script records the full Pana JSON report and publication dry-run output
outside the repository, and checks the dependency matrix (latest + lowest).
Install Pana if needed with `dart pub global activate pana`. It requires a
local Flutter SDK; do not substitute the pub.dev score for the already
published 0.6.1 version. Inspect the printed report directory after the run.

Confirm the dry-run includes the public examples and all listed screenshots
and excludes the preview's generated binaries. Record the Pana score actually
obtained; do not assume 160/160. Confirm that `0.7.0` does not already exist on
pub.dev and inspect all warnings before proceeding.

## 6. Push only after approval

Review `git status`, `git diff --cached --check`, the planned release files,
existing licensing and notices. Then commit, push, check CI at the intended
commit SHA and prepare tag `v0.7.0`. Publish the **exact tested version** only
after CI, consumer checks, the existing GIF assets, the dependency matrix,
Pana and the dry-run all pass.
