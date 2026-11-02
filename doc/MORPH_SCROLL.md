# MorphScrollBehavior — Flutter-like stretch without an image filter

> **0.7.0 release candidate.** This guide describes the source-tree
> implementation, pending final release checks and publication.

On Flutter versions that support shader filters, the default Material
`StretchingOverscrollIndicator` can place an `ImageFiltered` ancestor above
scroll content. A `BackdropFilter` inside that scrollable may then sample a
captured image instead of the intended underlying scene. This is especially
noticeable with frosted cards over textured backgrounds.

`MorphScrollBehavior` retains the standard Flutter scrollable widgets but
substitutes a **geometric transform** for the visual stretch. It doesn't add
`ImageFiltered`. Its pull response, impact handling, and spring model follow
the framework's `StretchingOverscrollIndicator` / `_StretchController` source,
while the rendering is the geometric matrix-style fallback rather than the
Impeller fragment shader. Thus the physics can be closely matched but the
pixel-by-pixel distortion will not be identical to the shader version.

## Basic integration

```dart
import 'package:flutter/material.dart';
import 'package:morph_expressive/morph_expressive.dart';

ScrollConfiguration(
  behavior: const MorphScrollBehavior(),
  child: ListView.builder(
    itemCount: items.length,
    itemBuilder: (context, index) => MorphCard(
      frosted: true, // Opt into the theme's glass for this card.
      headline: items[index].title,
    ),
  ),
)
```

This works with `ListView`, `GridView`, `SingleChildScrollView`, and
`CustomScrollView`; no custom list implementation or replacement widget is
required. `ScrollConfiguration` affects **only its descendant scrollables**.
You can wrap a whole subtree, but an inner `ScrollConfiguration` or a
scrollable's explicit `physics:` may override the intended behavior.

### Preserve custom scroll policies

To retain an ancestor's custom scrollbars, pointer-device configuration,
keyboard gestures, and other delegated policies, capture the ancestor behavior
**outside** the new `ScrollConfiguration`:

```dart
Builder(
  builder: (context) => ScrollConfiguration(
    behavior: MorphScrollBehavior(
      delegate: ScrollConfiguration.of(context),
    ),
    child: existingScrollView,
  ),
)
```

A broader opt-in can use `MaterialApp.scrollBehavior` or
`MorphMaterialApp.scrollBehavior`, but applying the behavior only where
backdrop blur is needed avoids unrelated scrolling changes.

## Parameters and default response

```dart
const MorphScrollBehavior(
  maxStretch: 1.0,
  stretchGain: 1.0,
  releaseDuration: Duration(milliseconds: 330),
)
```

| Parameter | Meaning |
| --- | --- |
| `maxStretch` | Safety cap on stretch **strength**, range `(0, 1]`. The default is not an instruction to stretch by 100%. |
| `stretchGain` | Multiplier of the native-derived drag/impact response; `1.0` keeps the framework-model intensity. |
| `releaseDuration` | Reference time scale for the spring (`330 ms` matches the native-derived constants); this is **not** a fixed tween duration. Must be positive. |
| `physics` | Optional override of the scroll physics used by the subtree. |
| `delegate` | Existing `ScrollBehavior` used for non-overscroll policies. |

The drag equation, for normalized overscroll distance `d` clamped to `[-1, 1]`,
is, before applying `stretchGain` and `maxStretch`:

```text
strength = sign(d) * 0.016 * (abs(d) + 1 - exp(-abs(d) * e / 0.33))
```

For example, a one-viewport pull (`abs(d) == 1`) produces a geometric stretch
strength of approximately **0.032 (3.2%)**, not 100%. The source uses
Flutter's spring constants (natural frequency 24.657, damping ratio 0.98,
time correction 0.8) with scaled fling/impact velocity, including interrupted
releases. `releaseDuration` and `stretchGain` let consumers vary the response
without making the default exaggerated.

The transform scales the **entire content** along the scrolling axis, anchored
to the edge being pulled (including horizontal and reversed directions). Text
and icons can therefore stretch slightly. Flutter's shader variant has a
nonuniform distortion and will not look pixel-identical.

### Scroll physics caveat

By default this behavior uses `ClampingScrollPhysics` with
`AlwaysScrollableScrollPhysics` for its subtree, **including on iOS**. This is
intentional: it produces the `OverscrollNotification` values used by the
geometric effect, including for short lists. It changes the platform's
normal bouncing behavior within the subtree. Explicit `physics:` on a
`ScrollView` takes precedence; `BouncingScrollPhysics` may prevent the
indicator from receiving the required notifications.

Nested scrolling, custom physics, and competing gesture recognizers should be
validated in their actual composition. The indicator listens to depth-zero
scroll notifications for its axis, honors
`OverscrollIndicatorNotification.disallowIndicator()`, and supports repeated
pull/release cycles.

## Validation and visual limitations

```bash
flutter analyze
flutter test test/morph_scroll_behavior_test.dart
flutter test test/morph_scroll_native_parity_test.dart
flutter test test/morph_scroll_repeated_spring_test.dart
flutter test
cd preview
flutter analyze
flutter test
flutter run -t lib/main_mobile.dart
```

Use **Frosted Surfaces → Scroll Blur Compatibility Lab** to compare
*Original Stretch* and *Geometric*. Check both ends of the list, repeated
flings, light/dark colors, high/low tint, and glass disabled. Flutter widget
tests can check transforms, notification handling, and the absence of added
`ImageFiltered`; **they cannot verify that a `BackdropFilter` samples the
correct pixels on a GPU**. Inspect on a real device or a representative
hardware-accelerated emulator.

See [Frosted surfaces](FROSTED_SURFACES.md) for configuring theme glass and
opt-in cards. The interaction implementation follows Flutter's BSD-licensed
stretch controller model; see the attribution header in the source and the
repository's `LICENSE` / `NOTICE`.
