# Publishing checklist: 0.3.1

`0.3.0` is already published on pub.dev and must remain unchanged. This
repository targets the **next patch release, 0.3.1**. Publishing requires a clean
repository, a successful dry-run, and explicit confirmation; neither a Git
commit nor a Git tag publishes a package automatically by itself.

## 1. Verify package and example

From the package root:

```bash
flutter analyze
bash tool/check.sh
```

The previous full validation passed 731 library tests and 30 preview tests.
Repeat it after applying this patch. The existing interactive
`example/main.dart` remains the public API reference; recheck it with the
current Flutter SDK before publishing. The example imports `material_ui` and `morph_expressive` only; for
standalone app setup see [`../example/README.md`](../example/README.md).

## 2. Review media and tracked files

The repository contains ten generated GIFs in `doc/assets/gifs/`, and the
package metadata selects eight for the pub.dev screenshots. Check the newest
`sliders.gif` and `loading.gif` (along with lists/dialogs GIFs),
including the smooth 90–98% wavy flattening and absence of a trailing
overflow icon on swipeable rows.

```bash
python3 tool/check_gif_branding.py
git status --short
git diff --check
```

Do **not** stage backups such as `test/carousel_widget_states_test.dart.bak`,
IDE files, caches, compiled Web output, or capture tool downloads. Confirm
`example/main.dart`, `LICENSE`, `NOTICE` and the declared GIF files exist.

## 3. Commit and push the reviewed changes

Stage only intended release files, including the new source and GIFs. Inspect
what Git will record before committing:

```bash
git diff --cached --check
git diff --cached --stat
git status --short
# Commit and push after reviewing the staged paths.
```

`git add -A` indiscriminately can include temporary `.bak` files. Prefer
explicit staging. Do not create a `v0.3.1` tag before the release commit.

## 4. Inspect the package archive

With a clean Git worktree:

```bash
dart pub publish --dry-run
```

Confirm the command reports **Publishing morph_expressive 0.3.1** and includes
only the intended source, example, docs, metadata and media. Review every
warning. The `.pubignore` must exclude generated output, tests and preview
runtime, while retaining the maintained documentation, screenshots and
`example/` source.

## 5. Publish and tag

Confirm `0.3.1` is not already listed at
<https://pub.dev/packages/morph_expressive/versions>, then run:

```bash
dart pub publish
```

Approve only after reviewing the package summary. Do not use `--force`.
When pub.dev confirms the new version and the matching release commit is
pushed, tag that commit:

```bash
git tag -a v0.3.1 -m "Morph Expressive v0.3.1"
git push origin v0.3.1
```

If the repository has workflows triggered by tags, inspect them before pushing
the tag to avoid an unintended second release attempt.

## Hosting note

Older snapshots placed compiled Web output under `docs/`. If GitHub Pages still
points there, update the deployment configuration before deleting build
artifacts. Use a dedicated deployment branch or CI artifact for future Web
previews; maintained reference docs are under `doc/`.
