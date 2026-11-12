# Morph Expressive 0.8.0 — final implementation report and publication checklist

**Version:** 0.8.0 (`pubspec.yaml`). Preview application: 0.2.0+1, `publish_to: none`.
**Base:** the published 0.7.0 (`v0.7.0`). **Scope:** implementation final for this
update; documentation and assets prepared for review.

| Status | State |
| --- | --- |
| Implementation | Final for the scope below |
| Local validation | Executed; results below, historical failures identified |
| User visual review | Pending |
| CI for the target SHA | Pending (no commit exists for this work) |
| Publication to pub.dev | Pending. pub.dev lists 0.7.0 as the latest version; 0.8.0 does not exist there |

No commit, push, tag or publication was made.

## Scope

Implemented in this update (details: [upgrade guide](UPGRADE_0_8_0.md),
[CHANGELOG](../CHANGELOG.md)):

* Shape engine, catalog, Canvas reference renderer and restricted ellipse Shader;
  `MorphShapeButton` (rotation, press response); loaders on the engine.
* 90 / 160 ms button press response; connected groups with automatic width and
  a configurable gap; `MorphReactiveButtonGroup`.
* FAB menu with one morphing surface; hover submenus; menu semantics.
* Edge antialiasing, clipping, splash and exact 360° rotation fixes.
* `MorphAsyncButton`; `MorphSkeleton` / `MorphSkeletonGroup` with a tiltable shimmer.
* Tabs with a continuous indicator, page-linked progress and refined geometry.
* Organic stretch options on navigation selectors, chips and dropdown motion styles.

Not implemented (pending): the general migration of defaults, refresh indicator
changes, and a continuous page indicator. The code was checked: refresh is
unchanged from 0.7.0 and the page indicator only gained `organicStretchIntensity`.

### Renderers (what really uses a Shader)

* Shader: the procedural ellipse (shape view, loaders, shape button), the
  rounded-rectangle program (`MorphRoundedSurface`: FAB menu surface, tabs
  indicator, async button surface) and the skeleton shimmer.
* Canvas: everything else, and every fallback (while loading, on failure,
  gradients, asymmetric radii, unsupported shapes), with sampled edge coverage.
* Offscreen mitigation: `MorphSmoothEdges` rasterizes sliders, progress
  indicators, button cores (including splash) and list swipe actions into a
  texture on desktop Linux, because Impeller OpenGLES has binary edge coverage
  for direct paths there. Cost per frame was not measured.

## Earlier local validation (2026-11-12, Linux, Flutter 3.47.9)

| Check | Result |
| --- | --- |
| `dart format --output=none --set-exit-if-changed lib test example preview/lib preview/test` | Clean |
| `flutter analyze` (root, preview) | No issues |
| Root `flutter test` | 1171 passed, 3 failed (historical, below) |
| Preview `flutter test` | 79 passed |
| `tool/check_api.py`, `check_package_identity.py`, `check_gif_branding.py`, `check_icons.py`, `check_motion.py`, `check_morph_names.py`, `check_preview_coverage.py`, `check_third_party_notices.py`, `check_dependency_imports.py` | All passed |
| `python3 -m unittest discover -s tool` | Passed |
| `python3 -m unittest discover -s tool/ci/tests -p 'test_*.py'` | 28 passed |
| `bash tool/check.sh` | Failed in the root Flutter suite: 1171 passed, 3 failed (the same historical failures below); the global gate is not green. |
| `python3 tool/ci/check_final_release_language.py --all` | Passed |
| `python3 tool/ci/release_guard.py metadata` | 0.8.0; first CHANGELOG entry and the preview lock match |
| `flutter build web --release` (preview) | Built |
| `flutter build linux --release` (preview, earlier in this update) | Built; Impeller OpenGLESSDF |
| Reduced-motion audit (`full`, `reduced`, `reduce-only`) | Contracts, preview and catalog: 0 failures. Library: 3 / 27 / 28 failures, all in tests that assert motion in families outside this update (see below) |
| `dart pub publish --dry-run` | 6 MB compressed; exit 65 with package-validation warnings. It reports ignored-but-tracked `dependency-compatibility.yml` and `navigation_morph.gif`, plus 104 modified tracked files. Re-run on the clean, authorized release commit; this dirty-checkout result is not a clean archive gate. |
| `bash tool/check_dependency_matrix.sh all` | **Failed** in `latest`: 1171 passed, 3 failed (the two expandable-list radius tests and the text-field label-centering test); the `lowest` resolution was not reached. |
| CI on the target SHA | **Not run** |
| GitHub workflow schema/lint validation | YAML parsers/lint tools unavailable in this environment; PyYAML, Ruby, `actionlint`, `yamllint`, `action-validator` and `zizmor` were not available. No schema validation is claimed. |

### Historical failures (not regressions of this update)

* `test/list_expandable_test.dart` — *expandable nested last row closes bottom
  radii* and *sublist last row rounds its bottom unless opted out*: the last row
  paints a bottom radius of 9.0 where 4.5 is expected.
* `test/text_field_test.dart` — *MorphTextField centers the label until it
  floats*: label offset 312.7 where 300 is expected.
* An earlier `tool/ci/tests` test required `/.agents/` in `.gitignore`. That
  obsolete requirement was removed; it is not a current blocker. Context is
  kept local through `.git/info/exclude`, and the Git index is checked instead.
* Reduced-motion audit, library scope: tests that assert animation fail when the
  platform preference is forced (for example the dropdown, chip bloom, press
  profile and operation tests). The `contracts` scope, which inspects intermediate
  geometry under reduced motion, passes with 0 failures. The new tabs tests skip
  the two motion-dependent cases under the forced profiles and pass otherwise.

The global gate is therefore **not** declared green.

## Visual and platform validation

Executed by the agent (not a substitute for the user's review): Web (Chromium
headless) with real touch and pointer events and the 14 GIF captures reviewed
frame by frame (first frame, intermediate states, open/expanded states, close and
loop join); Linux native (Impeller OpenGLESSDF) for the tabs lab and earlier labs.
Not measured: GPU cost, frame rates on any device, other backends, DPRs and
platforms, haptics on hardware.

## Animated assets

README: 14 GIFs grouped by family (`doc/assets/gifs/`). pub.dev gallery
(`pubspec.yaml` → `screenshots`, ten images, each well under the 4 MB limit):
async_button, skeleton, fab_menu, buttons, segmented, tabs, loading, navigation,
dropdown, lists. `navigation_rail_drawer.gif` is kept only for the navigation
guide; `navigation_morph.gif` was retired (its content is now `navigation.gif`).

| GIF | Canvas | Duration | Frames | GIF fps | Size | Status |
| --- | --- | --- | --- | --- | --- | --- |
| async_button | 640×260 | 10.60 s | 530 | 50.0 | 159 KB | New |
| skeleton | 640×340 | 8.30 s | 415 | 50.0 | 1121 KB | New — 48 colors, no dither |
| fab_menu | 640×400 | 7.70 s | 385 | 50.0 | 268 KB | Regenerated — FAB sizes, extended FAB and the menu |
| buttons | 640×370 | 7.20 s | 360 | 50.0 | 993 KB | Regenerated — Five styles and four ShapeButtons; 96 colors, no dither |
| segmented | 640×350 | 7.20 s | 360 | 50.0 | 207 KB | Regenerated — Segmented toggle, connected group and reactive group |
| tabs | 640×380 | 7.50 s | 375 | 50.0 | 252 KB | New |
| loading | 640×310 | 8.00 s | 400 | 50.0 | 676 KB | Regenerated — Adds linear wavy; all variants visible |
| navigation | 640×350 | 7.20 s | 360 | 50.0 | 371 KB | Regenerated — Morph variants only |
| dropdown | 640×320 | 4.80 s | 240 | 50.0 | 220 KB | Regenerated |
| lists | 640×340 | 5.80 s | 290 | 50.0 | 489 KB | Regenerated |
| dialogs | 640×360 | 6.48 s | 162 | 25.0 | 270 KB | Regenerated — Page renders ~14 real fps (backdrop blur) |
| chips | 640×340 | 8.68 s | 217 | 25.0 | 113 KB | Regenerated — Page renders ~40 real fps |
| textfields | 640×420 | 8.16 s | 204 | 25.0 | 64 KB | Regenerated — Page renders ~25 real fps |
| sliders | 640×360 | 6.80 s | 340 | 50.0 | 330 KB | Regenerated |
| navigation_rail_drawer | 640×380 | 7.60 s | 380 | 50.0 | 352 KB | Regenerated — Guide only; organic stretch verified on Shader |

Total 5.7 MB of GIFs; the largest screenshots declared for pub.dev are skeleton (1.1 MB) and buttons (1.0 MB), far below the 4 MB limit.

Capture: frames come from the compositor screencast (about 60 per second with real
timestamps) sampled on a uniform grid without generating intermediate frames.
Motion scenes use 50 fps (20 ms per frame); `chips`, `textfields` and `dialogs`
use 25 fps because their pages produce fewer frames. Sampling or a still screen
can repeat the last real frame; the GIF timing does not certify live GPU fps. Scene source and settings:
[PREVIEW.md](PREVIEW.md). All GIFs are 640 px wide; the height follows the
content (260–420 px). Headers are compact (title and short description on one
line). `tool/check_gif_branding.py` checks dimensions and frame interval against
the capture settings. Loop joins were checked: identical first and last frame in
async_button, dialogs, segmented and tabs; the rest differ only by continuous
motion (rotation, shimmer, loaders) or by the unchanged chips, lists, text field and
slider sequences, which end in a different state than they start.

## Publication checklist (pending; do not run without authorization)

1. Review the GIFs, README and guides; correct directly on this documentation.
2. Before a release-intended push, an authorized repository/cloud administrator
   must configure GitHub environment `pub.dev`, `WIF_PROVIDER`,
   `PUBLISH_SERVICE_ACCOUNT`, Google WIF/IAM trust, and pub.dev automated
   publishing authorization. See the [tracked automation guide](https://github.com/Bruno0416/morph_expressive/blob/main/tool/ci/README.md).
3. After explicit release authorization and a clean reviewed commit, run
   `bash tool/check.sh`, `bash tool/check_dependency_matrix.sh all`, the staged
   and revision language scans, and `dart pub publish --dry-run`. Resolve all
   failures and warnings; verify CI for the exact release SHA.
4. Confirm `pubspec.yaml`, the preview lock and the first CHANGELOG entry agree
   (`python3 tool/ci/release_guard.py metadata`) and check the pub.dev version
   state. Do not infer publication status from local files.
5. The modular pipeline publishes to pub.dev first, waits for confirmation,
   then creates `v0.8.0` for the validated SHA and creates the GitHub Release.
   Verify each external result. No local tag, push or publication is performed
   by this report. Do not use `tool/validate_release_0_7_0.sh`.


## Final automation audit of the supplied snapshot (2026-11-12)

The ZIP has no Git metadata. An incremental correction was prepared against its
exact contents; no UI, GIF, version or dependency was changed in this audit.
The historical Flutter results above were reported by the earlier local agent,
not re-executed in this environment.

Corrected the release runner's missing Flutter/Dart installation, token lifetime,
branch validation triggers and pana executable invocation. Latest/lowest are
independent matrix jobs; an aggregate gate requires all validation jobs. Pana
now has an explicit zero-point-loss gate and retained evidence. Pinned
checksum-verified actionlint validates workflow schema and expressions in CI.

Recovery compares actual pub-generated archives, including the package of any
older existing tag, before accepting its identity. An already complete matching
release is a no-op. Registry confirmation and file equality precede tag/release
creation; an advance of main after upload does not strand a successful
publication. Tags are never overwritten. Index/revision guards allow excluded
local instructions while preventing them from being committed or published.
Local agent guides were synchronized with the tracked automation.

Fresh validation: 44 automation tests, 14 general Python tests, all nine Python
guards, actionlint 1.7.7, Bash syntax, metadata and final-language scans passed.
Hook integration preserved custom hooks and upgraded known unmodified hooks
with a backup. The patch is checked in a separate extraction of the input ZIP;
synthetic Git checks do not establish the author's real index, branch or SHA.

**Publication remains blocked:** this audit environment has no Flutter/Dart SDK,
so Flutter tests/builds, dependency resolutions, pub dry-run and pana were not
re-executed. The three previously reported Flutter failures and dirty-checkout
dry-run need resolution and fresh clean-commit evidence. Google WIF/IAM,
pub.dev authorization, environment/rulesets/token permissions and a real branch
CI run remain unconfirmed. A read-only registry query during this audit listed
0.7.0 as latest and no 0.8.0. No push, publication, tag or GitHub Release was made.
See the [tracked automation guide](https://github.com/Bruno0416/morph_expressive/blob/main/tool/ci/README.md)
for the branch-validation and main-publication sequence.


## Modular workflow refinement (2026-11-12)

The pipeline is now split into five reusable stage workflows and the 57-line
`ci.yml` coordinator. Stages run in order: tests/analysis, dependency
compatibility, documentation, package checks, aggregate quality, and main-only
publication. Each local reusable call uses the coordinator's commit. A shared
composite action installs the pinned Flutter SDK after checkout in each job.

The quality gate keeps the name **All required quality checks**. It always
evaluates all four validation results; failures, cancellations and skipped
stages block publication. Latest/lowest remain independent matrix jobs within
the compatibility stage. Package/archive confirmation, token handling and
immutable tag/release recovery retain the previous audit's protections.

Fresh local evidence: 52 automation tests, 14 general Python tests, nine Python
guards, actionlint for all six workflows, metadata and final-language scans
passed. Markdown local file/asset targets pass, including local agent guides;
remote URLs and heading anchors are outside that check. The incremental patch
is checked against the previous audit's corrected snapshot. Real Flutter/CI,
dry-run, dependency resolution, pana and external authorization are still
pending as described above. Review WIF trust for the reusable publisher's
`job_workflow_ref` before merging into main. No push or publication was made.
