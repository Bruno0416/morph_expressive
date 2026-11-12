# Morph Expressive — release automation

This directory contains tracked release guards and tests. CI uses `tool/ci/`
and never requires local agent instructions. The package version is read from
`pubspec.yaml`; it is not hardcoded in the workflow.

Optional local hooks: `bash tool/ci/install_git_hooks.sh`. Existing custom hooks
are never overwritten. Pre-commit checks the staged context; pre-push checks
the exact outgoing revision, independently of unstaged or staged corrections.

## Local validation

From the repository root:

```bash
python3 tool/ci/check_final_release_language.py --all
python3 tool/ci/check_final_release_language.py --staged
python3 tool/ci/check_final_release_language.py --revision HEAD
python3 -m unittest discover -s tool/ci/tests -p 'test_*.py'
python3 tool/ci/release_guard.py metadata
python3 tool/ci/check_markdown_links.py --include-local-context
python3 tool/ci/release_guard.py check-local-context
python3 tool/ci/release_guard.py check-local-context --revision HEAD
bash tool/check_dependency_matrix.sh all
dart pub publish --dry-run
```

`metadata` checks the stable package identity/version, first changelog entry and
root-package version in `preview/pubspec.lock`. The preview application's own
version is independent. `check-local-context` inspects the Git index: `.agents/`,
`.serena/` and any `AGENTS.md` must not be tracked or staged. Local excluded files
are allowed. Use `.git/info/exclude`; no `.gitignore` rule is required. A ZIP
cannot establish the original index, exclusions, branch or SHA.

Inspect the actual package archive separately, using a destination outside the
checkout (creating this archive does not upload or publish):

```bash
dart pub publish --to-archive=/tmp/package.tar.gz
python3 tool/ci/release_guard.py archive-files --archive /tmp/package.tar.gz
```

Recovery compares this archive's file names and bytes with pub.dev's archive,
after verifying its registry SHA-256. It does not approximate pub's ignore rules.
Tar timestamps and compression differences do not change package equality.
Never use `--skip-validation` or suppress warnings to make a gate pass.

## Modular workflows and release order

`.github/workflows/ci.yml` is a small coordinator: it validates
**all branch pushes** and pull requests targeting `main`, defines stage
ordering and the aggregate quality gate, and calls these reusable workflows
from the **same commit**. Each module declares only `workflow_call`; the
coordinator is the event entry point. Tag pushes and release events do not
trigger it.

| Order | Workflow file | Responsibility |
| --- | --- | --- |
| 1 | `tests.yml` | Automation tests, Dart formatting, Python guards, root and preview analysis/tests |
| 2 | `compatibility.yml` | Independent `latest` and `lowest` matrix jobs, each checking resolved dependencies, analysis, tests and Web build in a disposable copy |
| 3 | `documentation.yml` | Version/language/index guards, local Markdown file/asset links and pinned, checksum-verified actionlint 1.7.7 for every workflow |
| 4 | `package.yml` | Pub dry-run, actual archive inspection, pana 0.23.19 with `--exit-code-threshold=0`, and package/analysis evidence retained seven days |
| 5 | `ci.yml` → `quality` | Always evaluates results of all four stages; failure, cancellation or skip blocks publication |
| 6 | `publish.yml` | Main-only upload, exact archive confirmation, immutable tag and GitHub Release |

Stages run in that order. A failed stage skips later stages; the final gate
still runs and fails. Within compatibility, `latest` and `lowest` run with
`fail-fast: false`, so neither cancels its sibling. Pana still runs if an earlier
step fails **inside the package stage**; an unsuccessful preceding stage skips
the entire package stage.

The shared composite action `.github/actions/setup-flutter/action.yml` installs
the same pinned Flutter SDK (3.47.9) for every Dart/Flutter job, after checkout.
The small coordinator contains no SDK installation, dependency resolution,
package analysis or publication commands. Stage files can be maintained
independently. They share the coordinator's run/SHA and concurrency controls.

Configure branch protection/rulesets to require **All required quality checks**
before merging into `main`; this aggregate check name is preserved. Workflow
YAML cannot itself enforce repository rulesets. External SDK availability and
real runner execution must be checked in the branch run.

Run `python3 tool/ci/check_markdown_links.py` for local file/asset targets in
repository Markdown; add `--include-local-context` to inspect root `AGENTS.md`
and local `.agents/` as well. This does not check remote URLs or heading anchors.
CI requires no local instructions. Automation tests also execute the real final
gate for success, failure, cancellation and skipped stage results.

Only `push` to `main`, after `quality`, enters `release` in environment `pub.dev`.
The job prepares a real archive before requesting credentials, validates the
exact checkout/SHA, current remote `main`, immutable registry state and remote
tag/release state. It then:

1. Publishes a new version with a short-lived Google-federated ID token. Only
   this path requires publisher credentials. `pub` stores the token variable's
   name, so `PUB_DEV_TOKEN` stays defined through `dart pub publish --force`.
   The token registration is removed on success or failure. `--force` removes
   the interactive prompt; all validation gates still apply.
2. Confirms the immutable version **and exact archive file contents** on pub.dev.
3. Creates `vX.Y.Z` for the tested SHA, confirms the remote tag, and creates and
   verifies the GitHub Release with notes from that version's changelog entry.

`main` is checked again immediately before upload. If it advances after a
successful upload, finalization still tags the already published tested SHA;
it never tags the new head instead. Main runs are serialized and not cancelled.

If publication already succeeded, exact archive equality permits recovery of a
missing tag/release without re-uploading or obtaining publisher credentials.
An existing tag must point to the tested commit or an ancestor with the same
package version and identical package archive, regenerated by pub in a
disposable detached worktree; it is never moved. Complete matching releases are a successful
no-op. If package contents changed under an already published version, bump the
version instead of trying to replace the immutable archive. A stale preflight
skips publication. Unknown registry/GitHub/network state, conflicting tags,
archive differences and unconfirmed publication stop the release.

Rerun the failed original main workflow attempt to recover its exact SHA. If a
later main run has superseded it, inspect the published package and tag state
before deciding the next action. Do not manually create a tag to trigger
publication: there is no tag-triggered publication workflow.

## Required external configuration

An authorized administrator must independently verify:

- GitHub environment `pub.dev`, limited to `main` deployment. Configure its
  variables `WIF_PROVIDER` (full provider resource name) and
  `PUBLISH_SERVICE_ACCOUNT` (publisher service-account email).
- Google Cloud WIF provider, service account and IAM trust restricted to this
  repository and this pipeline on `refs/heads/main`. The caller `workflow_ref`
  identifies `Bruno0416/morph_expressive/.github/workflows/ci.yml@refs/heads/main`;
  the publisher `job_workflow_ref` now identifies
  `Bruno0416/morph_expressive/.github/workflows/publish.yml@refs/heads/main`. If the provider checks
  the latter claim, its allowlist must authorize the reusable publisher at
  `refs/heads/main`. Verify the real OIDC claims/trust before merging; do not
  assume the previous single-file allowlist authorizes this module. See
  [GitHub OIDC for reusable workflows](https://docs.github.com/en/actions/how-tos/secure-your-work/security-harden-deployments/oidc-with-reusable-workflows).
  Grant only required
  service-account impersonation/ID-token permissions. Keep `contents: write`
  and `id-token: write` limited to the release job.
- pub.dev automated publishing/service-account authorization for package
  `morph_expressive`, repository `Bruno0416/morph_expressive` and audience
  `https://pub.dev`. This flow uses Google federation, not a tag-triggered
  pub.dev/GitHub template. It does not use a GitHub App or a long-lived key/token.
- Repository rulesets: required quality gate, protection against tag overwrites,
  and permission for the workflow token to create the intended tag and release.

Missing or unverified settings are deployment blockers. Do not infer cloud
trust, pub.dev permissions, or CI success from this source tree. Never expose
credentials in logs or artifacts.

## Authorization and evidence

Preparing or validating this workflow is not authorization to push, publish,
create tags/releases or change external configuration from a local session.
Record implementation, local validation, CI for the target SHA, publication,
tag and GitHub Release as separate verified states. The next authorized branch
push validates only; merging into `main` can publish and must be intentional.


## Applying the workflow naming update

Workflow files and titles, local reusable calls, concurrency and artifact names,
and temporary package/analysis/release files now use unprefixed names. The
coordinator is `ci.yml`; modules are `tests.yml`, `compatibility.yml`,
`documentation.yml`, `package.yml` and `publish.yml`. The aggregate required
check remains **All required quality checks**.

Configure `WIF_PROVIDER` and `PUBLISH_SERVICE_ACCOUNT` in environment `pub.dev`
with the values previously held by the prefixed variables. There is no fallback
to the old names. Verify cloud trust for the new caller `ci.yml` and reusable
publisher `publish.yml` paths before a release-intended merge. This patch does
not change external variables or cloud settings. Package identity, publication
order and main-only gating are unchanged.


## Reproducing the tests job from a clean local copy

```bash
python3 -m unittest discover -s tool/ci/tests -p 'test_check_bootstrap.py'
python3 tool/ci/reproduce_tests.py
```

The first command runs four orchestration regressions using SDK command doubles.
It reproduces the logged root-only dependency setup failure, checks both package
resolutions before analysis, and ensures failed/missing preview configuration
stops analysis. This does not replace Flutter tests.

The second command requires the pinned Flutter/Dart SDK on PATH. It copies the
current source into a temporary directory excluding package configurations and
build caches, then runs the validation steps from `tests.yml`: automation tests,
root/preview dependency resolution, Dart format and `tool/check.sh`. It returns the first failure unchanged,
deletes only the temporary copy and leaves the original checkout untouched.
The SDK and global pub cache are reused; this does not emulate SDK installation
or the GitHub runner itself.

In the supplied logs for commit `b42f05ab5c27d5e071221fd5b8ac615a47fe546d`,
root analysis ran before `preview` dependency resolution and produced 71 issues.
The aggregate check correctly failed after tests failed; later stages were
skipped. The 18:34 snapshot already puts preview resolution before analysis.
This correction preserves that ordering, explicitly checks both generated
package configurations, adds regression coverage and prints aggregate results.
No analyzer exclusions, suppressed errors or relaxed release gates are added.


## README image sources

README GIF images use relative `doc/assets/gifs/*.gif` sources so repository
views use assets from their own branch or commit. `tool/check_gif_branding.py`
rejects absolute GIF sources in the HTML image grid, checks all 14 files and
keeps the ten-image pub.dev gallery contract. Integration tests exercise the
actual guard with the current README, a default-branch URL and a missing asset.
Apply a correction before running its tests: the old 4.5dp and whole-widget
label-center assertions are not the updated geometry tests. The combined
README/geometry correction replaces the earlier standalone geometry patch.
