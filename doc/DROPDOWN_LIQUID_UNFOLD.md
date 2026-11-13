# Liquid Unfold — Dropdowns and menu popups

`MorphDropdownMenu` retains the shader-driven Liquid Unfold: its full-sized
surface is revealed from the activating point, with lateral tension and a
bounded highlight; text and icons are not scaled. The shader has a Canvas
fallback, and `organicStretchIntensity: 0` disables its deformation while
keeping the reveal. `motionStyle: MorphDropdownMotionStyle.legacy` preserves
its former clipped height-reveal.

## MorphMenuPopup: centered fade and scale

`MorphMenu` / `showMorphMenu` use a separate default transition in **liquid**
mode (not the dropdown's shader): the entire popup fades 0–100% and scales
**90–100% from Alignment.center** on both opening and closing. The placement
(up/down/side), pointer position and keyboard activation never affect that
scale origin. Opening takes **300 ms** (`MorphMotion.medium2`) and closing
**250 ms** (`MorphMotion.medium1`), with `MorphMotion.enter` / `exit` easing.

Content (rows, labels and icons) has its own fade, confined to the **first
35% of the popup timeline**: 105 ms on opening and 87.5 ms on closing. It
therefore becomes fully transparent well before the panel finishes exiting.
The opaque or frosted panel and its shadow retain the longer outer fade.
Text layout and sizing do not change. Background tapping, keyboard Escape,
item selection and submenus keep their native behavior; dismissed popups stop
intercepting pointer input immediately, but remain mounted through the exit.

`motionStyle: MorphDropdownMotionStyle.legacy` still selects the old spring
scale from the placement edge for callers who explicitly opt into it. For
popup `liquid`, `originFromTap` / `tapPosition` and
`organicStretchIntensity` are intentionally ignored in the visual transition;
they remain useful for `MorphDropdownMenu` and for API compatibility.

`openInstantly: true` and reduced motion skip the decorative transition.
No animated blur is introduced for glass surfaces.
