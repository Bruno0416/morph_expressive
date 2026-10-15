# Morph Motion

`MorphMotion` centralizes the motion vocabulary of the fork. Components use
these tokens directly; they are not wrappers around upstream widgets.

## Motion families

- **Spatial motion:** shape, scale, width, and position can use restrained
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
