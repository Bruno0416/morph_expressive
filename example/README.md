# Morph Expressive example

[`main.dart`](main.dart) is an interactive single-screen tour of the public
Morph APIs, including:

- `MorphButton` with selection states and a floating `MorphDialog`.
- `MorphSegmentedToggle` and controlled multi-selection `MorphChipToggle`.
- Filled/outlined `MorphTextField` with opt-in validation icons.
- `MorphList` rows with `MorphListItemSwipe` reveal actions.

The example intentionally keeps state locally and uses only Morph Expressive
and its `material_ui` host import. It is a public API example, **not** the
separate 39-family preview application.

## Try it in a new Flutter app

Create a Flutter app with Flutter >= 3.47 and Dart >= 3.13, then run:

```bash
flutter pub add morph_expressive material_ui
```

Copy [`main.dart`](main.dart) into your application's `lib/main.dart` and
run `flutter run`. The published `0.3.0` version already supports this example. To try the
unreleased `0.3.1` fixes, point `morph_expressive` at your local cloned package
using a `path:` dependency in the app's `pubspec.yaml`.

For all available components and advanced APIs see
[`../doc/COMPONENTS.md`](../doc/COMPONENTS.md). For the complete Web
showcase and reproducible animated GIFs, see
[`../doc/PREVIEW.md`](../doc/PREVIEW.md).
