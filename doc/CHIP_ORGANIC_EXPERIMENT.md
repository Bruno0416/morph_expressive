# MorphChip — Organic ink: bloom and harmonic stretch

The MorphChip experiment keeps the original selection behavior and adds two
small, independent visual refinements. No special canvas is required to link
multiple chips: each selected chip uses the existing delayed-edge transfer.

```dart
MorphChipToggle<String>(
  options: options,
  multiSelection: true,
  selectedValues: selected,
  onSelectionChanged: (next) => setState(() => selected = next),
  organicBloomIntensity: 0.25,
  organicStretchIntensity: 0.40,
)
```

- **First selection bloom (0.25):** temporary low-frequency displacement of the
  growing circular outline. It affects the perimeter only, not the texture.
- **Stretch (0.40):** delayed-edge movement inherited from the original Morph
  selector. The shader adds a small, symmetric central-height deformation
  without changing the rounded end caps.
- **Resting state:** both effects return to the exact normal capsule. At
  intensity `0` the original rendering path is retained. A reduced-motion
  setting disables shader animation.

The `organicIntensity` constructor argument remains available as a shared
value for both effects. The two optional properties above override it
independently; `null` means inherit `organicIntensity`.

The dedicated Web preview shows single and multiple selection, independent
sliders (0–1), and a reference rendering with no organic shader.

Only `shaders/chip_organic.frag` is required for these effects. The existing
Canvas fallback is used when the fragment program is unavailable.
