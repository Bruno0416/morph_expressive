# Morph Expressive examples

Four runnable programs. All use only `package:morph_expressive/morph_expressive.dart`
and an explicit `show` import of `package:material_ui/material_ui.dart`.

| File | Shows | Run |
| --- | --- | --- |
| [`v1_tour.dart`](v1_tour.dart) | The 1.0 API: visual types as named constructors, every `MorphVariant` role, `surface: MorphSurface.frosted` over a colorful backdrop, density and light/dark switching with `MorphMaterialApp` and `MorphThemeController`, a controlled `MorphAsyncButton`, text field validation, chips and a desktop `MorphContextMenuRegion` | `flutter run -t example/v1_tour.dart` |
| [`main.dart`](main.dart) | An interactive component tour: `MorphButton` selection states, `MorphDialog`, `MorphSegmentedToggle`, multi-select `MorphChipToggle`, filled and outlined `MorphTextField` with validation icons, swipeable `MorphList` rows | `flutter run -t example/main.dart` |
| [`frosted_surfaces.dart`](frosted_surfaces.dart) | Opaque card, `surface: MorphSurface.frosted` (inherited theme glass) and a custom `glass:` card, then a menu, dropdown, dialog and bottom sheet over a colorful backdrop with blur-safe `MorphScrollBehavior` | `flutter run -t example/frosted_surfaces.dart` |
| [`whats_new_0_8_0.dart`](whats_new_0_8_0.dart) | The 0.8.0 additions: `MorphAsyncButton`, `MorphSkeletonGroup`, `MorphReactiveButtonGroup`, `MorphShapeButton`, linked `MorphTabs`, menus and `MorphFabMenu` | `flutter run -t example/whats_new_0_8_0.dart` |

The examples keep state locally and need no extra packages. They are a public
API sample, **not** the Widgetbook preview application in `preview/`, which
covers every exported widget ([Preview](../doc/PREVIEW.md)).

`v1_tour.dart` and `whats_new_0_8_0.dart` are built and exercised by
`test/doc_examples_test.dart` and `test/example_whats_new_test.dart`, so they stay
in step with the package.

## Try it in a new Flutter app

Create a Flutter app (Flutter >= 3.47, Dart >= 3.13), add the dependencies and
copy a file from this directory into the app's `lib/`:

```bash
flutter pub add morph_expressive material_ui
```

Version 1.0.0 is prepared in this repository and its publication is pending; the
latest published version is 0.8.0, which does not contain the v1 API used by
`v1_tour.dart`. To try the v1 API before it is published, use a Git or `path:`
dependency on a checkout of this repository.

For the complete catalog see [Components](../doc/COMPONENTS.md); for the API
model see [Component API](../doc/API_V1.md); for theming see
[Theming](../doc/THEMING.md).
