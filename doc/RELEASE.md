# Publishing checklist: Morph Expressive 0.4.1

`0.4.1` is the patch release following `0.4.0`. It fixes dependency namespace
collisions with Material UI 1.8.0, completes the slider test correction, and
adds import-policy/CI regression coverage. Public polygon types, widget APIs,
rendering, runtime dependency constraints and the 0.4.0 feature set are preserved.

The release metadata patch assumes the namespace-isolation hotfix has already
been applied and validated. It updates only the root version and maintained
documentation. `preview/` remains a separate, non-published app with its own
version. Published package versions cannot be overwritten: check the
[pub.dev version list](https://pub.dev/packages/morph_expressive/versions)
immediately before publishing and confirm that `0.4.1` is still unused.

## 1. Confirm the validated release contents

The maintainer's 2026-10-21 reproduction completed both dependency lanes:

| Check | `material_ui 1.8.0` (latest compatible) | `material_ui 1.6.0` (lower bounds) |
| --- | --- | --- |
| Root / preview analysis | No issues | No issues |
| Library tests | 759 passed | 759 passed |
| Preview tests | 31 passed | 31 passed |
| Import-policy tests | 11 passed | 11 passed |
| Formatting | 720 files, 0 changed | 720 files, 0 changed |
| Web release build | Passed | Passed |
| Branding, icons, motion, attribution, preview coverage | Passed | Passed |

The full implementation matrix was also run during hotfix preparation on
Flutter 3.47.7 / Dart 3.13.5. See
[Dependency compatibility](PUB_DEV_COMPATIBILITY.md) for the underlying cause,
public type guarantees and consumer import guidance.

The log contains two non-blocking notices: the previous patch expected a
non-executable `tool/check.sh` while the maintainer's file was executable,
and the preview Web build reports missing Material/Cupertino host font
families. The script ran successfully, both Fluent font assets were bundled,
and all tests/builds completed. This metadata patch changes no file modes or
font configuration. Native builds and a standalone Wasm runtime build were
not executed; the Web compiler's Wasm dry run is not a runtime test.

From the package root, review:

```bash
git status --short
git diff --check
git diff --stat
```

Confirm `version: 0.4.1` in the root `pubspec.yaml`, installation examples using
`^0.4.1`, and the first changelog entry `## 0.4.1 - 2026-10-21`. Preserve the
historical `0.4.0`, `0.3.1` and older entries. Review the implementation hotfix
as well as the metadata patch if they have not yet been committed.

No Dart source or dependency constraint changes are introduced by this release
metadata patch, so the completed matrix remains evidence for the implementation.
If either changes after validation, rerun:

```bash
bash tool/check_dependency_matrix.sh
```

This tests root and preview with fresh independent latest/lowest resolutions,
without rewriting the working lockfiles. A pana score does not replace it:
the published archive excludes the tests, tools and preview app.

## 2. Review the package and commit the release

Keep `LICENSE`, `NOTICE`, attribution headers and the eight declared screenshot
GIFs. The hotfix does not change the visuals, so it does not require regenerating
GIFs. Preserve the existing `.pubignore` exclusions, including `.github/`,
preview/test/tool sources, build output, caches and local archives.

Stage only reviewed release changes, including newly added hotfix files:

```bash
git add .pubignore .github/workflows/dependency-compatibility.yml \
  pubspec.yaml README.md CHANGELOG.md doc/ example/ lib/ test/ \
  preview/lib/ preview/test/ tool/
git diff --cached --check
git diff --cached --stat
git status --short
git commit -m "release: morph_expressive 0.4.1"
```

Do not stage local patches, ZIPs, IDE files, signing assets or unrelated work.
Review any other previously tracked changes before committing them.

From the **package root**, run the publication preflight:

```bash
dart pub publish --dry-run
```

The package summary must say **morph_expressive 0.4.1**. Resolve publication
errors and relevant warnings. Run this on the committed release tree: otherwise
Pub warns that the working tree contains modified files. A clean temporary copy
can also validate the package archive without that Git-state warning.

Use the existing pana installation for an optional local scoring comparison:

```bash
dart pub global run pana .
```

Install pana first only if needed (`dart pub global activate pana`). The earlier
160/160 report belongs to the 0.4.0 hotfix preparation; a new 0.4.1 score is not
implied by test success or the metadata bump.

## 3. Publish once and tag the exact release

Inspect the repository's workflows before publishing. The dependency
compatibility workflow only validates; if another workflow publishes on tags,
use that flow instead of also publishing manually.

Push the release commit to the verified release branch. For `main`:

```bash
git push origin main
```

Confirm `0.4.1` is still unused, then publish interactively from the root:

```bash
dart pub publish
```

After Pub confirms successful publication, tag the **same release commit**:

```bash
git tag -a v0.4.1 -m "Morph Expressive v0.4.1"
git push origin v0.4.1
```

Do not replace an existing published version or move an existing release tag.
This preparation patch does not publish, push or create tags automatically.
