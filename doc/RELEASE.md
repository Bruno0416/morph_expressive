# Publishing checklist

Validate each version before publishing to pub.dev. Published versions cannot
be overwritten.

## 1. Verification

From the package root:

```bash
bash tool/check.sh
```

This runs the catalog coverage check plus `flutter analyze` and `flutter test`
for the package and `preview/`. Confirm the command exits successfully.

## 2. Package contents

Use `.pubignore` to exclude `build/` (including the large test cache), preview
builds, tooling, and transient files from the pub.dev archive. A local
`.gitignore` **does not replace** `.pubignore` for publication validation.

```bash
dart pub publish --dry-run
```

Inspect every entry listed. The archive should contain license, notice,
README, changelog, package sources, and maintained reference documentation.
There should be no compiled Web builds, native test caches, developer archives,
or local path dependencies.

Check that `pubspec.yaml` has the intended SDK constraints, repository
metadata, dependency bounds, and publishing destination. Check that the
screenshots referenced in `pubspec.yaml` exist and meet pub.dev size limits.
Do not publish with `publish_to: none`.

## 3. GitHub Pages, if applicable

Older snapshots included an approximately 59 MB compiled Flutter Web output in
`docs/`. This is generated application code, not reference documentation.
The cleanup script deletes only those known generated files. **If your GitHub
Pages source is `/docs` on a branch, change its deployment first**, or the
previous live site will stop working. Publish future showcase builds from a
CI artifact or a dedicated deployment branch rather than committing output
inside reference docs.

## 4. Final release

Review README, CHANGELOG, NOTICE, LICENSE, version, and generated API surface.
Make sure the GitHub branch referenced by README images and documentation links
contains the release contents before publishing. Then run `dart pub publish`
interactively. A successful dry run is necessary but not proof of license or
user-experience readiness.
