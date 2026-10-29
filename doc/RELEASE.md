# Publishing checklist — Morph Expressive 0.6.0

**Release candidate; do not publish or tag until the gates below pass.**

The previous commit/tag is `b6a6c31` / `v0.5.0` (2026-10-23). This release is
`0.6.0`, not a republish of 0.5.0, because bottom-navigation destination
`Widget` icons changed to `IconData` and the two named constructors now map
consistently to their intended designs. Keep `preview/pubspec.yaml` at its
independent unpublished app version; its *tracked lockfile* must resolve the
local package to `0.6.0`.

## 1. Verify the release content from the repository root

```bash
cd "$(git rev-parse --show-toplevel)"
git status --short
grep '^version:' pubspec.yaml
rg -n 'morph_expressive:|version: "0.6.0"' preview/pubspec.lock
python3 tool/check_gif_branding.py
```

Inspect `README.md`, `CHANGELOG.md`, `doc/GETTING_STARTED.md`,
`doc/NAVIGATION_MORPH.md`, `doc/PREVIEW.md`, `example/README.md` and
`doc/COMPONENTS.md`. The `doc/PUB_DEV_COMPATIBILITY.md` report deliberately
retains historic results from 0.4.1; they are **not** new 0.6.0 test evidence.
The 0.6.0 changelog must sit above the preserved 0.5.0 entry.

## 2. Regenerate and inspect changed GIFs

`navigation_morph.gif` was rendered for the older 0.5.0 capture scene and
must be regenerated for the corrected `.morph()` / `.expressive()` layout,
76dp Morph bar and icon-data API. The original MD3E `navigation.gif` and the
unchanged rail/drawer GIF should not be rewritten without a scene change.
**Run only after any capture-source changes are final, with no concurrent
Flutter Web server/build running for `preview/`:**

```bash
bash tool/generate_component_gifs.sh --only navigation_morph
python3 tool/check_gif_branding.py
(cd preview && flutter test test/gif_capture_test.dart)
git status --short doc/assets/gifs/
git diff --numstat -- doc/assets/gifs/
# Must fail if the navigation GIF has NOT changed since v0.5.0:
if git diff --quiet v0.5.0 -- doc/assets/gifs/navigation_morph.gif; then
  echo 'ERROR: regenerate navigation_morph.gif for 0.6.0' >&2
  exit 1
fi
```

Visually inspect the new `doc/assets/gifs/navigation_morph.gif` at 640×520:
Expressive pill vs Morph sliding dash, active/unselected icons, clear top-dash
gap, and both page indicator effects. The file must differ from `v0.5.0`.
The GIF branding audit checks file presence and old branding; **it does not
prove an asset is fresh or visually correct**.

## 3. Full validation (both dependency lanes)

```bash
# After release-source edits, format once, then validate.
dart format lib test example preview/lib preview/test
set -o pipefail
bash tool/check_dependency_matrix.sh all 2>&1 | tee /tmp/morph-0.6.0-matrix.log
```

Both `latest` and `lowest` must complete with clean analysis, all package and
preview tests, and the Web release build. The matrix runs in temporary copies
and does not mutate the active lockfiles. Flutter Web's font/wasm notices do
not independently imply a test failure, but examine new diagnostics. For
visual/performance assurance, run the native preview on a real Android/iOS
device (`cd preview && flutter run -t lib/main_mobile.dart`); Web rendering
cannot prove mobile blur performance.

## 4. Archive, documentation and Pana

```bash
cd "$(git rev-parse --show-toplevel)"
flutter pub get
(cd preview && flutter pub get)  # update tracked local path lock entry
python3 tool/check_gif_branding.py
git diff --check
dart pub publish --dry-run
dart pub global run pana .
```

Review the `dry-run`'s archive list, `.pubignore`, metadata, ten pub.dev
screenshots, README, changelog, attribution (`NOTICE` / `LICENSE`) and no
unexpected generated files. Record Pana's **actual** score; a previous
160/160 report for 0.5.0 is not evidence for 0.6.0.
Check <https://pub.dev/packages/morph_expressive/versions> and confirm
`0.6.0` is still unused before proceeding. The dry-run does not reserve it.

## 5. Commit, push, wait for CI, then publish manually

The only repository workflow in this snapshot is
`.github/workflows/dependency-compatibility.yml`: its `push` and PR events
run latest/lowest analysis/tests/builds. It **does not publish to pub.dev**.
Do not trigger an extra automated publisher or duplicate a release tag.

```bash
cd "$(git rev-parse --show-toplevel)"
git add -A
git diff --cached --check
git diff --cached --stat
git diff --cached -- pubspec.yaml CHANGELOG.md README.md
# Inspect staged changes, especially the new navigation_morph.gif.
git commit -m "release: morph_expressive 0.6.0"
git push origin main
```

In GitHub Actions, wait for **both** `Dependency compatibility` jobs
(`latest`, `lowest`) for this exact pushed commit to succeed. Do not publish
merely because an older green workflow exists. Using GitHub CLI:

```bash
SHA=$(git rev-parse HEAD)
gh run list --workflow dependency-compatibility.yml --commit "$SHA" --limit 5
# Locate the push run for this SHA, then:
gh run watch RUN_ID --exit-status
```

Only after green CI and checking `0.6.0` is still unpublished:

```bash
dart pub publish --dry-run
dart pub publish
git tag -a v0.6.0 -m "Morph Expressive v0.6.0"
git push origin v0.6.0
gh release create v0.6.0 --title "Morph Expressive v0.6.0" --generate-notes
```

`dart pub publish` is an irreversible upload for that exact version. Stop on
any unexpected output. Confirm the Git tag points at the published commit;
never create it on a different tree. No commands above are executed by this
document.
