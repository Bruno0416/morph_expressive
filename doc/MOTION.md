# Morph Motion

Motion tokens and behavior shared by every component. Reduced-motion handling
is summarized in [Accessibility](ACCESSIBILITY.md#reduced-motion).

## Motion added in 0.8.0

* Buttons: 90 / 160 ms press and release (below).
* Reactive button groups: critically damped local width compensation; pressed
  expansion 0.15 and selected expansion 0.08 by default, neighbours give way
  without re-routing slack to distant items ([OPERATION_LOADING.md](OPERATION_LOADING.md)).
* Tabs: slide (default) or bounded elastic indicator, duration and curve from
  the tab theme, or the pages' own progress when a `MorphTabsView` is linked;
  elasticity is removed with reduced motion ([TABS.md](TABS.md)).
* FAB menu: one surface interpolated by one controller in both directions,
  starting from the visible value when interrupted ([R3_VISUAL_FIXES.md](R3_VISUAL_FIXES.md)).
* Operation and skeleton transitions have independent durations and honour
  reduced motion ([OPERATION_LOADING.md](OPERATION_LOADING.md)).

## Button press and release geometry

`MorphButtonTheme.pressDuration` / `releaseDuration` default to **90 / 160 ms**.
Precedence is local decoration, decoration scope, theme, defaults; merging keeps
the most specific non-null value. `Duration.zero` jumps to the target and
negative values are rejected with an `ArgumentError`. These fields do not
replace the Material style's `animationDuration`. Split buttons propagate the
overrides; icon buttons keep their previous 165 / 380 ms profile.

The temporal geometry captures the visible value when it retargets; velocity
continuity is not guaranteed. `MorphButtonMotion`, `shapeSpring` and the
`motion` argument remain for compatibility and other spring effects: the
radius/padding animator uses its temporal curve and does not simulate that
spring. Reduced motion resolves the current target through the existing Morph
mechanisms.

The 0.2.0 motion vocabulary adds expressive reusable curves and composable
tweens while keeping per-component motion overrides available.

`MorphMotion` centralizes the motion vocabulary of the fork. Components use
these tokens directly; they are not wrappers around upstream widgets.

## Motion families

- **Spatial motion:** shape, scale, width, and position can use moderate
  overshoot (`expressiveSpatialDefault`, `spatialFast`, etc.).
- **Effects:** opacity, color, and scrim animation stay within valid bounds
  (`effectsFast`, `effectsDefault`, `effectsSlow`, and bounded curves).
- **Component choreography:** `connectedSelection` controls connected groups;
  `navigationSelection` and `navigationEffects` coordinate navigation pills;
  `dialogSpatial` and `dialogEffects` control faster dialog transitions.
- **Timing:** `short1`–`short4`, `medium1`–`medium4`, and other duration tokens
  replace scattered timing literals where applicable.

`MorphMotion.springMotion(MorphSpring)` adapts a configured spring to Motor.
Existing component-level theme overrides take precedence over defaults.

Avoid applying overshooting curves to opacity, color interpolation, or values
that must stay in [0, 1]. Preserve delays needed for focus management,
accessibility, and gesture sequencing.

## Expressive choreography and tweens

The shared `MorphMotion` curves now differentiate spatial travel from effects:
`spatial` permits a measured overshoot, while `standard`, `enter`, `exit`,
`emphasized`, and effect curves stay bounded for opacity and color. Expressive
spatial spring defaults have slightly lower damping; effects springs remain
critically damped. Existing widget/theme overrides are still respected. These helpers are
available to components but do not imply that every family has had their
individual controllers replaced by tweens.

Compose motion with `MorphMotion.spatialTween(begin:, end:)` for position and
size, `MorphMotion.effectsTween(begin:, end:)` for bounded scalar effects, and
`MorphMotion.staggeredTween(begin:, end:, delayFraction:)` when an edge must
wait before catching up. The last helper uses `TweenSequence`, not a separate
`Timer`, so the delay participates in the same animation timeline.

`MorphChipToggle` defaults to 289 ms (15% below 340 ms) and an adjusted
77 ms trailing-edge delay. Its 4 px circular growth/shrink is **only** for an
empty selection becoming the first selected chip or the last chip being
deselected. The circle grows uniformly before filling out the pill; intermediate
selections never use that circular boundary animation.
Adding a second/third selection duplicates from the nearest active pill and
stretches with staggered tweens; removing a non-last selection merges into the
nearest survivor. Explicit widget durations and curves remain customizable.

## Testing

Run the library and preview checks from the repository root:

```bash
bash tool/check.sh
```

Use a release-mode preview for visual performance judgments:

```bash
cd preview
flutter build web --release
```

Animations may look slower in debug Web than in release builds.

## Reduced motion

Every Morph theme follows the platform's `disableAnimations` and `reduceMotion`
preferences. Set `MorphThemeData.light().copyWith(reduceMotion: true)` to opt the
application into reduced motion, or wrap a component/subtree in
`MorphMotionScope(reduceMotion: true, child: ...)`. False means follow the system
and ancestor scopes; it never forces animations against an accessibility request.

Selections and decorative springs reach their final state, textfield labels stop
at their current target, and ornamental waves/automatic loading morphs become
static. Progress semantics and direct user gestures remain available. Normal mode
keeps configured durations, curves and springs.

See [the accessibility motion guide](REDUCED_MOTION_ACCESSIBILITY.md) for scope
inheritance, overlays and reproducible checks.


## Shared harmonic stretch (navigation and segmented selectors)

The selected capsule uses the same organic stretch as MorphChip. The existing
spring and trailing-edge delay remain unchanged; only the cross-axis surface
slightly contracts while the indicator is moving. Horizontal movement pinches
height; vertical movement pinches width. The indicator is identical to the
original geometry at rest.

`organicStretchIntensity: 0.40` is the shared starting preset for
`MorphNavigationBar`, `MorphNavigationRail`, `MorphNavigationDrawer`,
`MorphPageIndicator`, `MorphSegmentedToggle`, and single-select
`MorphSegmentedButton`. Set `organicStretchIntensity: 0` to paint the original
indicator exactly. The reduced-motion setting also bypasses this effect.
Multi-select `MorphSegmentedButton` retains its independent selected fills.
Gradients and decorative outlines retain their existing painting instead of
being flattened by the effect. The same cached chip shader is used; platforms
without shader support use a conventional Canvas path.

## Disabling the organic effects

For every organic selector that exposes `organicStretchIntensity`, set
`organicStretchIntensity: 0` to restore the plain indicator appearance and
motion (no organic shape deformation). For `MorphChipToggle`, bloom and stretch
can be disabled independently with `organicBloomIntensity: 0` and
`organicStretchIntensity: 0`.
