# Morph Motion

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
available to components but do not imply that all 39 families have had their
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
