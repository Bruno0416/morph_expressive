# Morph Expressive example

[`main.dart`](main.dart) is an interactive single-screen tour of the public
Morph APIs, including:

- `MorphButton` with selection states and a floating `MorphDialog`.
- `MorphSegmentedToggle` and controlled multi-selection `MorphChipToggle`.
- Filled/outlined `MorphTextField` with opt-in validation icons.
- `MorphList` rows with `MorphListItemSwipe` reveal actions.

The **0.7.0 Frosted Surfaces walkthrough** is in
[`frosted_surfaces.dart`](frosted_surfaces.dart). It compares opaque cards,
`frosted: true` (inherited theme glass) and a custom `glass:` configuration,
then opens a menu, dropdown, dialog and bottom sheet. Its colorful backdrop
and `MorphScrollBehavior` make the blur-safe overscroll visually testable.
Use its `main()` as a standalone sample, or open it from the button at the top
of the original component tour.

The example intentionally keeps state locally and uses only Morph Expressive
and its `material_ui` host import. It is a public API example, **not** the
separate 40-family preview application.

## Try it in a new Flutter app

Create a Flutter app with Flutter >= 3.47 and Dart >= 3.13, then run:

```bash
# After 0.8.0 has been published:
flutter pub add 'morph_expressive:^0.8.0' material_ui
```

Copy [`main.dart`](main.dart) and [`frosted_surfaces.dart`](frosted_surfaces.dart)
into the same application's `lib/` directory and run `flutter run`. To try
the **unpublished** 0.8.0 source, use a
`path:` dependency pointed at your local checkout instead of the hosted
version. Alternatively copy `frosted_surfaces.dart` to `lib/main.dart` for
the standalone glass showcase. These examples do not cover every navigation
API; see the navigation guide for those.

[`whats_new_0_8_0.dart`](whats_new_0_8_0.dart) is a standalone tour of the 0.8.0
additions (`flutter run -t example/whats_new_0_8_0.dart`).

For all available components and advanced APIs see
[`../doc/COMPONENTS.md`](../doc/COMPONENTS.md). For the complete Web
showcase and reproducible animated GIFs, see
[`../doc/PREVIEW.md`](../doc/PREVIEW.md).
