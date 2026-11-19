# Release process

How a Morph Expressive version moves from a branch to pub.dev, a Git tag and a
GitHub Release. This document describes the **process defined by the
repository's workflows**; it does not state that any step has run for a given
version. For the version in `pubspec.yaml`, check the workflow runs for the exact
commit and <https://pub.dev/packages/morph_expressive/versions>.

Operational detail for the automation lives in
[`tool/ci/README.md`](../tool/ci/README.md); the workflows are in
`.github/workflows/`. The previous manual 0.6.1 checklist is replaced by this
page and survives only in Git history.

## Principles

- The package version comes from `pubspec.yaml`; workflows never hardcode it.
- Validation runs on **every push to any branch** and on pull requests targeting
  `main`. Tag pushes and release events do not trigger anything.
- Publication happens **only** from a push to `main` that passed every
  validation stage, in the protected GitHub environment `pub.dev`, with a
  short-lived Google workload-identity ID token. No long-lived pub.dev token is
  stored.
- Publication is irreversible for a version number. The archive is inspected
  before upload, confirmed (file names and bytes) after upload, and only then
  tagged.
- Never use `--skip-validation` or suppress warnings, and never publish, tag,
  push or create releases from a workstation.

## Stages

`.github/workflows/ci.yml` coordinates reusable workflows from the same commit,
in this order. A failed stage skips the later ones; the aggregate gate always
runs and fails.

| # | Workflow | What it checks |
| --- | --- | --- |
| 1 | `tests.yml` | Automation unit tests, `dart format --set-exit-if-changed` (lib, test, example, preview), `bash tool/check.sh` (package and preview analysis and tests) |
| 2 | `compatibility.yml` | `latest` and `lowest` dependency resolutions as independent jobs (`fail-fast: false`): resolved versions, analysis, tests and Web build in a disposable copy |
| 3 | `documentation.yml` | Release-language guard, version and changelog metadata, local Markdown links and assets, absence of local agent context from the index, pinned and checksum-verified `actionlint` for every workflow |
| 4 | `package.yml` | `dart pub publish --dry-run`, a real archive from `dart pub publish --to-archive`, archive file inspection, pana 0.23.19 with `--exit-code-threshold=0` (the full 160/160 score is required; no points may be lost), evidence kept for seven days |
| 5 | `ci.yml` job `quality` ("All required quality checks") | Succeeds only if stages 1-4 all succeeded; skipped or cancelled stages block publication |
| 6 | `publish.yml` | Main-only upload, exact archive confirmation, immutable tag and GitHub Release |

Every Dart or Flutter job installs the same pinned SDK (Flutter 3.47.9) through
the shared composite action `.github/actions/setup-flutter`. The pana job
installs the `webp` tools it needs for screenshots
(`tool/ci/check_pana_tools.sh`).

## Preparing a version

1. Set `version:` in `pubspec.yaml` and add the matching first entry to
   `CHANGELOG.md` (`## X.Y.Z - YYYY-MM-DD`). The preview application's own
   version is independent, but the root-package entry in
   `preview/pubspec.lock` must resolve to the same version.
2. Update README, `doc/`, example and migration guides for the scope of the
   version. Documentation is written when the implementation is complete and
   describes what exists; mark unpublished work as "publication pending". Follow
   the wording rules of the release-language guard.
3. Regenerate GIFs and screenshots only when their capture scenes changed
   ([Preview](PREVIEW.md)). README images use absolute
   `raw.githubusercontent.com` URLs; they resolve only after the assets reach
   `main`.
4. Run the local gates (below), review the complete diff and the Git index, and
   open a pull request.

## Local validation

From the repository root:

```bash
python3 tool/ci/check_final_release_language.py --all
python3 -m unittest discover -s tool/ci/tests -p 'test_*.py'
python3 tool/ci/release_guard.py metadata
python3 tool/ci/check_markdown_links.py
python3 tool/ci/release_guard.py check-local-context
python3 tool/check_gif_branding.py

dart format --output=none --set-exit-if-changed lib test example preview/lib preview/test
flutter pub get && (cd preview && flutter pub get)
bash tool/check.sh
bash tool/check_dependency_matrix.sh all

dart pub publish --dry-run
dart pub publish --to-archive=/tmp/morph_expressive_package.tar.gz   # outside the checkout
python3 tool/ci/release_guard.py archive-files --archive /tmp/morph_expressive_package.tar.gz
dart pub global activate pana 0.23.19
dart pub global run pana:pana --exit-code-threshold=0 .
```

`--to-archive` and `--dry-run` do not upload anything. Record the real results
of the commands you ran; a dry-run does not reserve a version number, and a
local pana run does not replace the one in CI. The agent-context guards
(`check-local-context`) require `AGENTS.md`, `.agents/` and `.serena/` to stay
out of the Git index; keep them local through `.git/info/exclude`.

Optional hooks (`bash tool/ci/install_git_hooks.sh`) run the release-language
guard before commit and push.

## Publication

Merging to `main` is the publication trigger:

1. Validation stages 1-5 pass for the pushed commit.
2. The `release` job (environment `pub.dev`) checks out the tested SHA, builds
   the real archive and runs the preflight **before** requesting credentials. It
   verifies metadata, a clean tested SHA, that the SHA is still the head of
   remote `main`, the registry state of the version and the remote tag and
   release state.
3. If the version is new, it authenticates with GitHub OIDC federation
   (`WIF_PROVIDER`, `PUBLISH_SERVICE_ACCOUNT` repository variables), registers
   the ID token for `dart pub publish --force` (all pub validations still apply)
   and removes the registration afterwards.
4. It confirms on pub.dev that the version exists **and that the archive files
   match exactly** (after verifying the registry SHA-256).
5. Only then it creates the immutable tag `vX.Y.Z` on the tested SHA, confirms
   the remote tag, and creates and verifies the GitHub Release with the notes of
   that version's changelog entry.

If `main` advances after a successful upload, finalization still tags the
already published, tested SHA. Runs on `main` are serialized and never cancelled.

## Recovery

- Rerun the failed workflow attempt of the original `main` push to recover its
  exact SHA. If a later `main` run superseded it, inspect the published package
  and tag first.
- If publication succeeded but the tag or Release is missing, the exact archive
  comparison allows finalizing without credentials or a new upload. An existing
  tag must point at the tested commit or an ancestor with the same package
  version and an identical archive; it is never moved.
- If package contents change under an already published version, bump the
  version; pub.dev archives are immutable.
- Unknown registry, GitHub or network state, conflicting tags, archive
  differences or unconfirmed publication stop the process. Do not create tags by
  hand to trigger publication; no workflow is tag-triggered.

## External prerequisites

These live outside the repository and must be verified independently of the
workflow files: the protected `pub.dev` environment (deployments limited to
`main`) with the two variables above; the Google workload-identity pool and
service account trusting only this repository, `refs/heads/main`, the `ci.yml`
caller and the `publish.yml` reusable workflow; automated publishing enabled for
`morph_expressive` on pub.dev with audience `https://pub.dev`; and branch
protection requiring the "All required quality checks" status. Until each is
confirmed, treat publication as unverified.

## Historical release records

[Documentation index](README.md#historical-records) lists the earlier release
reports and checklists (0.6.1, 0.7.0, 0.8.0). They describe those versions as
they were and are not instructions for the current process.
