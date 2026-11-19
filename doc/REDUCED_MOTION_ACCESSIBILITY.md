# Reduced motion

Morph keeps its curves, durations and springs in normal motion. When the system
requests `disableAnimations` **or** `reduceMotion`, decorative transitions take
their final state and automatic waves stop moving. No per-widget configuration
is needed. See also [Accessibility](ACCESSIBILITY.md#reduced-motion).

## App configuration

```dart
final theme = MorphThemeData.light().copyWith(reduceMotion: true);

MorphMaterialApp(data: theme, home: const MyHome());
```

`reduceMotion: false` is the default and follows the system preference. It never
forces animations against a user's request. `copyWith`, nested themes and the
derived dark theme preserve the property.

To limit the option to one widget or section:

```dart
MorphMotionScope(
  reduceMotion: true,
  child: MorphSegmentedToggle<String>(
    options: const [
      MorphSegmentedToggleOption(value: 'a', label: 'One'),
      MorphSegmentedToggleOption(value: 'b', label: 'Two'),
    ],
    selected: selected,
    onChanged: onChanged,
  ),
);
```

A child scope with `false` does not override a parent with `true`. Overlays that
capture inherited themes keep this preference. For your own overlays that do not
capture themes, use `InheritedTheme.captureAll(context, child)` or apply the
scope explicitly to the overlay content.

For your own components:

```dart
final reduced = MorphMotion.reduceMotionOf(context);
final duration = MorphMotion.durationOf(context, myDuration);
```

## Behavior

| Family or mechanism | With reduced motion |
| --- | --- |
| Selection, buttons, navigation, tabs and Morph springs | Final state without spatial transfer |
| Animated chip and segmented toggle | No stretch, bloom or trailing-edge delay |
| Text fields | Label, shape and effects reach their target; also when the preference changes mid-transition |
| Determinate progress | The real value stays visible; the decorative wave is static |
| Indeterminate progress and loading | A recognizable static frame; progress semantics are kept |
| Sliders and range sliders | Static wave; value, keyboard and drag remain available |
| Carousel | Consistent reduced layout; programmatic navigation jumps without an animated trip |
| Overlays, list selection and implicit effects | Reduced transitions, keeping interaction and focus |

Spring controllers complete their `Future` and notify their state when they
reach the target. `TickerMode(false)` is not used to freeze widgets in
intermediate states. Functional durations, such as how long a snackbar stays on
screen, are not turned into zero.

## Tests

```bash
flutter pub get
(cd preview && flutter pub get)
python3 tool/audit_reduced_motion.py --profiles full reduced reduce-only
```

Profiles:

- `full`: both preferences off.
- `reduced`: both on.
- `reduce-only`: only `AccessibilityFeatures.reduceMotion` on.

The report is written to `.dart_tool/motion_audit/REPORT.md`, with structured
results and traces. The command exits with an error if a test fails. The ordinary
suite runs with `flutter test` without enabling the instrumentation.

The contracts compare pixels, geometry, final states and preference changes. The
catalog tests mount the public classes of every component family; mounting a
class does not cover all its variants and interactions, and the absence of
motion in passive sampling does not by itself prove compliance. See
[Reduced motion tests](REDUCED_MOTION_TESTS.md) for the audit details.

The matrix runs as widget tests on Linux. Visual evaluation in Firefox/Chromium
and on physical devices remains a separate check; this suite does not certify
the accessibility of the whole product.
