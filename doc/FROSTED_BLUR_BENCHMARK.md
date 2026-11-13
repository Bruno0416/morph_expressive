# Morph frosted blur experiment — Impeller native lab

Production frosted surfaces are unchanged. This is an **opt-in**, native-only
performance experiment. It does **not** implement Zenith's multipass/downsampled
Dual Kawase pipeline: `frosted_kawase_single_pass.frag` samples the backdrop in
one pass. It should not be assumed faster or perceptually equivalent to Gaussian.

## Run the native benchmark

Start from the existing `preview/` Flutter app (it needs the native platform
folder for the target OS):

```sh
cd preview
flutter run -d macos --profile --dart-define=MORPH_FROSTED_BENCHMARK=true
```

For Linux, replace `-d macos` with `-d linux`. The Kawase option is enabled
**only when** `ImageFilter.isShaderFilterSupported` is true and the shader asset
loads. Otherwise it is visibly disabled, never silently replaced with Gaussian.
`ImageFilter.shader` requires Impeller; this experiment does not target Chrome.

## Workload and metrics

- Compare `Sin blur` (baseline), `Gaussian`, `Bounded`, and `Kawase 1x`.
- Select **1, 4, 8, 12, or 16** distinct clipped backdrop surfaces. Each is a
  real `BackdropFilter` for blurred modes, not one shared filter replicated
  visually. No automatic `BackdropGroup` is used (overlap/key semantics vary).
- `Auto-scroll` is enabled by default, continuously moving the content behind
  the surfaces at a controllable pixel speed. You can pause and drag manually.
- **FPS renderizados (1 s)** uses a rolling one-second window of native
  `FrameTiming` vsync timestamps, not the accumulated sample count. The FPS
  reading is estimated rendered-frame throughput, **not** GPU frame time or
  display refresh rate; it falls to zero when updates stop.
- **Raster p50/p95 and UI p95** use up to 600 recently reported frame timings.
  The sample window resets when changing a test variable. Allow warmup before
  recording results. The dashboard itself updates twice per second and adds
  a small measurement overhead.
  Enable **Gráficas Flutter** to show the built-in UI/raster performance
  overlay as an additional diagnostic. The overlay adds its own overhead.

Measure each mode in `--profile` with the same **window size, panel count,
scroll speed, and representative perceived blur**. The last requirement is
crucial: Kawase step and Gaussian sigma are not equivalent. Run repeated
trials, include the no-blur baseline, and observe CPU/GPU using DevTools.

## Production status

`MorphSurfaceGlass(boundedBlur: true)` and
`MorphNavigationGlass(boundedBlur: true)` are optional native blur paths.
The default remains Gaussian. Do not enable Kawase in production or claim a
speedup until repeated native measurements justify it. Bounded sampling can
change the edge appearance and is not a guaranteed GPU win.
