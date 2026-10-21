# Dependency namespace compatibility — Morph Expressive 0.4.1

Updated 2026-10-21 for the `0.4.1` release. The implementation was prepared
against `morph_ui(6).zip` (`0.4.0`) with its earlier indicator/platform hotfix,
then completed by the namespace-isolation patch. The maintainer subsequently
applied that patch and reproduced the complete passing dependency matrix.
The release metadata update changes no Dart implementation or dependencies.

## Confirmed failure and why the first patch was incomplete

The supplied log upgrades `material_ui` from `1.6.0` to `1.8.0`. The latter's
public library newly exports its own `RoundedPolygon` and `CornerRounding`.
Morph deliberately exposes the distinct geometry from `material_new_shapes`.
These types cannot be substituted simply because they have the same names.

The first hotfix qualified geometry inside loading/refresh indicators, but
left `test/slider_test.dart` importing both public barrels without restrictions.
Its custom dot painter's `RoundedPolygon` field therefore remained ambiguous.
The log shows a **test compilation failure**, not a slider rendering failure.
The baseline was also reproduced locally with Flutter 3.47.7/Dart 3.13.5 and
`material_ui 1.8.0` before changing the imports.

The same supplied log already ends with **pana 160/160**, including 20/20 for
platforms and 50/50 for static analysis. That does not contradict the failing
suite: `.pubignore` excludes `/test/`, `/tool/`, and `/preview/` from the published
archive. Scoring the publishable package does not replace testing the repository.

## Correction and prevention

- Restrict existing `material_ui` imports to explicit `show` lists across
  `lib/`, `test/`, `example/`, `preview/lib/`, and `preview/test/`. Import only
  names used by the library, including its `part` files. Additions to a future
  dependency barrel can no longer silently introduce unrelated names here.
- Apply the same explicit namespace policy to direct `material_new_shapes`
  imports. Keep the bridge's original public export list intact.
- Keep `RoundedPolygon`, `CornerRounding`, `Morph`, their path extensions,
  `MorphShapeKind.polygon`, loading/refresh `polygons`, and the complete shape
  catalog backed by **material_new_shapes**, preserving existing type identity.
- Keep the existing `material_ui: ^1.6.0` constraint. Do not pin an old version,
  replace the polygon implementation, use `dynamic`, or remove shape exports.
- Add `tool/check_dependency_imports.py` and its negative regression cases to
  `tool/check.sh`. The guard requires `show`, rejects `hide`/prefix-only imports
  (a prefix alone does not limit implicit extensions), checks re-exports and
  dependency-private paths, and prevents unprefixed Material UI geometry from
  silently replacing Morph's geometry.
- Add a public consumer test covering entrypoint type identity, shape paths,
  every catalog clipper, and loading/refresh/slider coexistence with Material UI.
  The existing slider painter test now compiles with the restricted import.

No geometry algorithm, widget layout, animation, haptic behavior, platform
manifest, runtime dependency, or public widget signature is intentionally changed.

## Reproducible checks

From the package root:

```bash
flutter pub get
bash tool/check.sh
```

For fresh dependency resolutions, including the gallery and a Web release build:

```bash
bash tool/check_dependency_matrix.sh
# Or select one lane:
bash tool/check_dependency_matrix.sh latest
bash tool/check_dependency_matrix.sh lowest
```

The matrix works on disposable copies, removes copied lockfiles/caches, and
runs `flutter pub upgrade` or `flutter pub downgrade` **independently in both
the package and preview**. It then checks formatting, all source guards, root
and preview analysis/tests, and `flutter build web --release` for the preview.
The original working tree and its two lockfiles are not rewritten. The GitHub
Actions workflow runs these two lanes on pushes, pull requests, or manual runs.
It tests on Flutter 3.47.7; it is not an exhaustive SDK/version matrix.

The latest lane covers the newest versions allowed by the manifest, while the
lowest lane exercises declared dependency lower bounds. These checks prevent
this namespace failure and expose future dependency changes; they do not promise
compatibility with arbitrary upstream API removals or every intermediate version.

Before publishing, also run:

```bash
dart pub publish --dry-run
dart pub global run pana .
```

If pana is not installed, activate it first with `dart pub global activate pana`.
The root manifest now targets `0.4.1`. Confirm that this version is still unused
on pub.dev before publication and follow [Release](RELEASE.md). Preparing this
version does not publish it or change the separate preview app's version.

## Observed validation of this follow-up

Executed on Linux with Flutter 3.47.7 / Dart 3.13.5. Both lanes used fresh,
independently resolved root and preview lockfiles:

| Check | Latest compatible (`material_ui 1.8.0`) | Lower bounds (`material_ui 1.6.0`) |
| --- | --- | --- |
| Root analysis | No issues | No issues |
| Root tests | 759 passed | 759 passed |
| Preview analysis | No issues | No issues |
| Preview tests | 31 passed | 31 passed |
| Preview Web release build | Passed | Passed |
| Namespace policy and its 11 negative/positive cases | Passed | Passed |
| Formatting, branding, Fluent icons, motion, licenses, 39-family coverage | Passed | Passed |

The two-lane script completed with exit status 0. The focused slider/geometry
run also passed all 17 tests. `dart pub publish --dry-run` on a clean copy of
the patched ZIP completed with **0 warnings**; nothing was published.
`git apply --check`, actual application and reverse-check were verified
against the supplied ZIP. Existing Dart changes consist of imports and
formatter output; runtime implementations and public geometry exports remain
unchanged. The additional consumer regression test covers all 35 catalog shapes.

The maintainer's subsequent 2026-10-21 run independently confirms the same
759 library tests, 31 preview tests, 11 import-policy cases, clean root/preview
analysis, unchanged formatting and successful Web builds in both lanes. These
runs validate the implementation carried into 0.4.1; the version/documentation
patch does not claim that the full suites were rerun after a metadata-only bump.
Git's `tool/check.sh` mode notice during application of the earlier patch was
non-blocking: the executable script ran and both lanes reached completion.

The Web builds emit a font-family notice for Material/Cupertino host fonts
absent from the current preview manifest; both Fluent font assets are bundled.
This patch does not change that font configuration, and these build notices
are separate from static analysis or polygon compatibility. A standalone Wasm
runtime build and native platform builds were not executed. The 160/160 pana
score discussed above is the **supplied report**, not a new scoring run.

## Consumer imports

Applications importing both public libraries should also limit their imports.
Morph cannot rewrite another application's import namespace:

```dart
import 'package:material_ui/material_ui.dart' show MaterialApp, Scaffold;
import 'package:morph_expressive/morph_expressive.dart'
    show MorphLoadingIndicator, MorphMaterialNewShapes, RoundedPolygon;

final List<RoundedPolygon> polygons = [
  MorphMaterialNewShapes.circle,
  MorphMaterialNewShapes.square,
];
final indicator = MorphLoadingIndicator(polygons: polygons);
```

If using Material UI's independent geometry deliberately, give that import a
prefix **and** an explicit `show` list. Do not pass those polygons to Morph's
`material_new_shapes` APIs.

## Platform report

The earlier six-platform declaration remains unchanged. The supplied pana log
attributes its advisory iOS/Web messages to `dynamic_color`'s declared native
platforms, while awarding the package 20/20 for platforms. Dynamic color is an
optional capability with fallback; these messages alone do not demonstrate that
Morph widgets fail on iOS/Web. Web compilation and existing fallback tests are
useful evidence, but Android, iOS, Linux, macOS and Windows consumer builds still
require their corresponding host toolchains. Do not report those native builds
as executed merely because a manifest or score lists them.

References:

- [Material UI 1.8.0 changelog](https://pub.dev/packages/material_ui/changelog)
- [Dart imports, prefixes and show/hide](https://dart.dev/language/libraries)
- [Dart ambiguous_import diagnostic](https://dart.dev/tools/diagnostics/ambiguous_import)
- [pub.dev scoring](https://pub.dev/help/scoring)
