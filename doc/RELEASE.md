# Publishing checklist — Morph Expressive 0.6.1

**Release preparation only. Do not publish, tag or push until validation passes.**

`0.6.1` is a backward-compatible patch over the published `v0.6.0` release:
`MorphNavigationBarHost` recognizes pull-to-refresh from nested vertical
scrollables and hides/reveals its floating bar during diagonally initiated
vertical scroll. Neither change requires new public parameters. Keep the
`0.6.0` changelog and `v0.6.0` tag unchanged.

## 1. Inspect release content and version

From the Morph repository root:

```bash
cd "$(git rev-parse --show-toplevel)"
git status --short
grep '^version:' pubspec.yaml
rg -n 'morph_expressive:|version: "0.6.1"' preview/pubspec.lock
python3 tool/check_gif_branding.py
```

Confirm `pubspec.yaml` and the **path dependency entry** in the tracked
`preview/pubspec.lock` resolve to `0.6.1`. Do not bump the independent preview
app's own version. Review README, CHANGELOG, `doc/NAVIGATION_MORPH.md`,
`doc/GETTING_STARTED.md`, example and public doc index. This patch changes
no navigation rendering or GIF capture scenes: **reuse the existing GIFs**.
Only regenerate images when their capture code or presentation changes. The
historical `doc/PUB_DEV_COMPATIBILITY.md` refers to release 0.4.1.

## 2. Format and run both dependency lanes

```bash
# Format only if files actually need it, before running CI-equivalent checks.
dart format lib test example preview/lib preview/test
set -o pipefail
bash tool/check_dependency_matrix.sh all 2>&1 | tee /tmp/morph-0.6.1-matrix.log
```

Require both `latest` and `lowest` to complete successfully: import/name/GIF
checks, strict `dart format --set-exit-if-changed`, static analysis, library
and preview widget tests, and the Web release build. Do not substitute a
single-test pass for the matrix. The nested integration tests must exercise
real pull gestures over the active child list, horizontal-only swipes,
collapsed outer headers, callback deduplication, diagonal hide/reveal and
scroll reversals. Independently check that `onRefresh: null` creates no
indicator and the three bar variants remain supported.

## 3. Validate against a real consumer using local path

In WatchNext (or an equivalent nested-scroll consumer), temporarily set:

```yaml
dependencies:
  morph_expressive:
    path: ../morph_ui
```

Then run `flutter pub get`, `flutter analyze`, and the app **after a full
restart**. Verify Movies and TV vertical pull-to-refresh, no refresh on
horizontal tab swipes, normal scrolling when the outer header is collapsed,
navbar hide/reveal on diagonal vertical scroll, and back-to-top. Check short
lists with `AlwaysScrollableScrollPhysics` as appropriate. Restore a hosted
constraint when `0.6.1` is published; never commit an unintended local path
to the consumer app.

## 4. Inspect the publish archive and Pana

```bash
cd "$(git rev-parse --show-toplevel)"
flutter pub get
(cd preview && flutter pub get)
git diff --check
dart pub publish --dry-run
dart pub global run pana:pana .
```

Inspect `.pubignore`, the dry-run file list and warnings, attribution, declared
platforms, and all ten screenshot assets. Require the release to have no
blocking warnings and record the actual Pana score (target 160/160; do not
reuse the previous version's score). Check
<https://pub.dev/packages/morph_expressive/versions> and confirm `0.6.1`
has not been published. A dry-run does not reserve the version number.

## 5. Commit and push; inspect the workflow for the exact SHA

```bash
cd "$(git rev-parse --show-toplevel)"
git add pubspec.yaml preview/pubspec.lock README.md CHANGELOG.md \
  doc/NAVIGATION_MORPH.md doc/GETTING_STARTED.md doc/README.md \
  doc/PUB_DEV_COMPATIBILITY.md doc/PREVIEW.md doc/RELEASE.md \
  example/README.md lib/components/navigation_bar/morph_navigation_bar_host.dart \
  test/navigation_nested_refresh_test.dart
git status --short
git diff --cached --check
git diff --cached --stat
git diff --cached -- pubspec.yaml CHANGELOG.md README.md
# Review the complete staged diff before committing.
git commit -m "fix: support nested navigation scrolling (0.6.1)"
git push origin main
```

The `.github/workflows/dependency-compatibility.yml` workflow runs both
`latest` and `lowest` on push, but does **not** publish to pub.dev. Verify the
successful runs correspond to the exact pushed commit, not an older SHA.

```bash
SHA=$(git rev-parse HEAD)
gh run list --workflow dependency-compatibility.yml --commit "$SHA" --limit 5
# For the run corresponding to $SHA:
gh run watch RUN_ID --exit-status
```

## 6. Publish manually after green CI

Once CI, the consumer test, Pana and the dry-run are green and `0.6.1` remains
available:

```bash
dart pub publish --dry-run
dart pub publish
git tag -a v0.6.1 -m "Morph Expressive v0.6.1"
git push origin v0.6.1
gh release create v0.6.1 --title "Morph Expressive v0.6.1" --generate-notes
```

Do not use `--force` or `--skip-validation` for pub.dev. Confirm that the tag
points to the published source commit and that the package appears under
`0.6.1` on pub.dev. A release upload is irreversible for that version.
