# Publishing checklist: Morph Expressive 0.4.0

The package's local release baseline is `0.3.1`, and the changes accumulated
since that release are packaged as **0.4.0** (new interactive behavior and
public options, not only defect fixes). Published versions cannot be
replaced. Before proceeding, check the
[pub.dev version list](https://pub.dev/packages/morph_expressive/versions)
and ensure `0.4.0` is not already published.

Only the root `pubspec.yaml` version is bumped. `preview/` is a separate,
non-published app (`publish_to: none`) and keeps its independent version.

## 1. Review the release diff

From the repository root:

```bash
git status --short
git diff --check
git diff --stat
```

Confirm that `pubspec.yaml` says `version: 0.4.0`, README/Getting started
install `^0.4.0`, and `CHANGELOG.md` begins with `## 0.4.0`. Keep the
existing `0.3.1` changelog entry intact. Review any untracked generated files
or IDE artifacts before staging.

Verify that the final runtime dependency set does **not** include
`core_haptics`, FFI bindings or manual Swift Package Manager installation;
the package uses Flutter `HapticFeedback` through `MorphHaptics`.

## 2. Format once, then validate

Do not format between incremental patches. At final release validation only,
run the formatter once on the maintained Dart sources, then inspect the diff:

```bash
dart format lib test preview/lib preview/test example
# If this checkout has no example/ directory, omit that last path.
git diff --check
```

Run the project's complete checks. `tool/check.sh` invokes static checks,
root `flutter analyze` / `flutter test`, plus the nested preview's analysis
and tests:

```bash
bash tool/check.sh
```

Also verify the native-specific regression tests and render on a real device
if available:

```bash
flutter test test/morph_global_haptics_test.dart test/morph_continuous_slider_haptics_test.dart test/list_dismissible_swipe_actions_test.dart test/refresh_indicator_test.dart test/progress_indicator_spec_test.dart
cd preview
flutter test test/mobile_haptics_lab_test.dart
flutter run -t lib/main_mobile.dart
cd ..
```

The physical-device run is an acceptance check, not an automated haptic
measurement. Confirm Light/Medium/Heavy/Off and that smooth sliders do not
emit continuous ticks. No `CoreHapticsFFI` integration should be necessary.

## 3. Review screenshots and package inventory

The package declares eight GIFs under `doc/assets/gifs/` in `pubspec.yaml`.
Review whether the recorded animations still represent the release. Rebuild
changed scenes if necessary and inspect the binaries before staging:

```bash
python3 tool/check_gif_branding.py
```

Preserve `LICENSE`, `NOTICE`, maintained `doc/`, `example/`, README and
CHANGELOG. The `.pubignore` excludes caches, IDE files, the preview app, test
sources, build artifacts and local archives. Do not stage private signing
assets, provisioning profiles, `.dart_tool`, build output, or old `.patch`
files.

## 4. Dry-run and release commit

Run the publishing validator from the **package root**, not `preview/`:

```bash
dart pub publish --dry-run
```

Inspect the complete archive inventory and resolve errors and relevant
warnings. The dry-run must report `morph_expressive 0.4.0`; a successful
`flutter test` does not replace the publication dry-run.

When the final diff is approved, stage only intended tracked/new release
files, inspect the staged changes, commit, and push the branch:

```bash
git add pubspec.yaml README.md CHANGELOG.md doc/ lib/ test/ preview/lib/ preview/test/ preview/doc/ tool/
git diff --cached --check
git diff --cached --stat
git status --short
git commit -m "release: morph_expressive 0.4.0"
git push origin main
```

Add other reviewed files (such as `example/`, capture scripts or GIFs) only
if changed. If the working branch is not `main`, verify the remote branch
before pushing rather than blindly substituting another name. Do not commit
private generated files.

## 5. Publish and tag

After verifying the pushed release commit and confirming that `0.4.0` is
still unused on pub.dev, publish **once**:

```bash
dart pub publish
```

Review and approve the published package summary interactively. Do not use
`--force`. After pub.dev confirms that 0.4.0 is visible, tag the **exact
release commit** and push the tag:

```bash
git tag -a v0.4.0 -m "Morph Expressive v0.4.0"
git push origin v0.4.0
```

If CI publishes automatically on version tags, inspect workflows before
pushing a tag, to prevent duplicate publish attempts. Neither pushing Git
nor creating a tag publishes to pub.dev unless such CI is configured.

## Hosting note

Older snapshots placed compiled Web output under `docs/`. If GitHub Pages
still points there, migrate deployment to a dedicated branch or CI artifact
before deleting existing hosting output. Maintained Markdown lives in `doc/`.
