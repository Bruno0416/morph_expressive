# Dropdown centered fade + scale + vertical unfold (2026-11-10)

The default for both `MorphDropdownMenu` (including `.future`) and
`MorphMenu` / `MorphMenuPopup` is now
`motionStyle: MorphDropdownMotionStyle.centered`.

- Surface: fades from 0% to 100% and scales from **80% to 100%**, always
  around `Alignment.center`, whether opened by pointer, keyboard or controller.
- Independent vertical `ClipRect` + `Align(heightFactor)` reveal grows from the
  anchor-side edge (top when opening down, bottom when opening up), with no
  vertical text scaling. It lasts **240 ms** on entry and **200 ms** on exit,
  around 20% faster than the centered fade + scale. It can reverse mid-flight
  without snapping, because it has its own controller.
- Search spacing: with default styles the top/side panel inset and the gap
  between the search field and the first row are all **8dp**. Explicit search
  margins remain configurable.
- Entry lasts **300 ms**; exit lasts **250 ms**.
- Content opacity is independent of the surface: it finishes the entry fade
  in the first 35% (105 ms) and disappears during the first 35% of exit
  (87.5 ms). The empty surface is therefore visible briefly during closing.
- Reopening while the panel is closing reverses its existing timeline without
  destroying the overlay. The popup retains its own legacy route semantics.
- Reduced-motion settings display the final panel directly.

For the previous tap-origin shader effect in `MorphDropdownMenu`:

```dart
MorphDropdownMenu<String>(
  motionStyle: MorphDropdownMotionStyle.liquid,
  organicStretchIntensity: 0.35,
  originFromTap: true,
  items: items,
)
```

`MorphDropdownMotionStyle.legacy` still uses the original vertical clip
transition, and the popup's legacy anchored spring remains unchanged. `organicStretchIntensity: 0` disables deformation in liquid mode;
it is not a switch for centered fade + scale.

The prior centered fade + scale changes in `MorphMenuPopup` alone did not alter
`MorphDropdownMenu`, whose default had remained `liquid`. This patch corrects
that discrepancy rather than changing the shader itself.
