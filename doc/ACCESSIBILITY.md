# Accessibility

What Morph Expressive does for you, what you have to provide, and how to turn
each behavior off or tune it. The snippets are compiled by
`test/doc_examples_test.dart`. Passing the package's widget tests does not
replace testing your own screens with a screen reader, a keyboard and large
text.

## Semantics and labels

Interactive Morph widgets expose button, toggle, slider, tab or text-field
semantics through Flutter's `Semantics` tree (about seventy components build
their own nodes), including enabled, selected and focused state.

You provide the *meaning*:

- **Icon-only controls need a label.** `MorphIconButton` uses `semanticLabel`,
  falling back to `tooltip`, and `tooltip` also shows the text on hover and
  long press. `MorphButton`, `MorphButtonGroupAction` and
  `MorphShapeButton` accept `semanticLabel` and `tooltip` too.
- `MorphTextField` announces `errorText` as the error message; add an
  `errorIcon` only as a visual aid.
- `MorphProgressIndicator` and `MorphRefreshIndicator` take `semanticsLabel` /
  `semanticsValue`; `MorphSkeletonGroup` takes `semanticLabel` for the loading
  state; `MorphAsyncButton` takes `semanticLabel` and `semanticValue` and keeps
  its state readable while loading.
- `MorphMenu` rows and `MorphContextMenuRegion` expose menu and menu-item
  semantics; destructive rows keep their label.

```dart
Widget accessibleActions({
  required VoidCallback onDelete,
  required VoidCallback onShare,
}) {
  return Row(
    spacing: 8,
    children: [
      // Icon-only controls need a label for assistive technology. `tooltip`
      // is also used as the semantic label when `semanticLabel` is absent.
      MorphIconButton.filled(
        onPressed: onShare,
        tooltip: 'Share',
        icon: Icon(FluentIcons.line.share),
      ),
      MorphIconButton.outlined(
        variant: .danger,
        onPressed: onDelete,
        tooltip: 'Delete',
        semanticLabel: 'Delete conversation',
        icon: Icon(FluentIcons.line.delete),
      ),
    ],
  );
}
```

## Keyboard and focus ring

- Tab and Shift+Tab traverse controls; Enter, numpad Enter and Space activate a
  focused `MorphButton`, `MorphIconButton`, `MorphCard` and other tappables.
- Menus: arrows move the highlight (skipping disabled rows and dividers),
  Home/End jump, Enter/Space activate, Right opens a submenu, Left closes it and
  Escape closes the innermost menu. Context menus also open with Shift+F10 or
  the Menu key from a focused `MorphContextMenuRegion`. Focus returns to the
  previously focused widget when a menu closes.
- Dialogs, dropdowns and the FAB menu manage focus on open and close;
  `MorphDialog.show(autofocusFirst: true)` focuses the first interactive element.
- The focus ring is shown for **keyboard** focus and hidden after pointer
  interaction, so mouse users do not see stale rings. Style it with
  `MorphThemeData.focusRingTheme` (`MorphFocusRingTheme(color:, width:, gap:)`,
  defaults: primary color, 2 dp width, 2 dp gap). `keyboardFocusIndicators:
  false` removes rings and focus fills; traversal and activation keep working,
  so only disable it if you draw your own indicator.
- Tabs do not scroll the enclosing viewport on focus unless
  `autoScrollToFocusedTab: true`.

## Hit targets and density

Density changes the *visual* size of controls, never the accessible target:
buttons and icon buttons keep a 48 dp padded tap target even in
`MorphDensity.compact`, and checkbox, radio and switch targets are
density-invariant. Density never changes fonts or colors. See
[Density](DENSITY_AND_CONTEXT_MENUS.md). Desktop context-menu rows (28 / 32 /
40 dp) are pointer- and keyboard-oriented; touch long press uses the standard
48 dp presentation.

## Text scaling

Morph text follows the ambient `MediaQuery.textScaler`; density and component
sizes are independent from it. Labels wrap or ellipsize according to each
component's documented behavior, so check dense screens (button groups, tabs,
navigation bars) at 1.5x and 2.0x. The Widgetbook preview has a text-scale
addon (0.8x to 2.0x) for this.

## Contrast and high contrast

- Seed schemes follow Material 3 tone rules. Request more contrast with
  `contrastLevel` (-1 to 1) on `MorphThemeData.light` / `.dark`.
- Frosted cards raise their tint until supporting text reaches 4.5:1 over both
  a white and a black backdrop, and frosted surfaces become opaque under the
  system high-contrast setting. See [Frosted surfaces](FROSTED_SURFACES.md).
- Badge colors (`error` / `onError`) measure 6.5:1 in light and 7.7:1 in dark.
- `MorphMaterialApp` forwards `highContrastTheme` and `highContrastDarkTheme`
  (Material `ThemeData`) if you want a dedicated high-contrast palette.
- A color role never carries meaning alone: pair `variant: .danger` with a label
  or icon.

## Reduced motion

Every Morph theme follows the platform's `disableAnimations` and
`reduceMotion` preferences without configuration: decorative transitions jump
to their end state, springs and organic stretch are skipped, automatic waves and
loading morphs become static, while progress values, gestures, keyboard input
and semantics stay available. `reduceMotion: false` follows the system; it never
forces animation against the user's request.

```dart
MorphThemeData accessibleTheme(Color seed) {
  return MorphThemeData.light(seedColor: seed, contrastLevel: 0.5).copyWith(
    reduceMotion: true, // opt in; the system setting is always honored
    hapticsEnabled: false, // no Morph-managed haptics
    keyboardFocusIndicators: true, // default: focus rings for Tab navigation
  );
}
```

Limit the opt-in to a subtree with `MorphMotionScope` (a child scope with
`false` does not override a parent with `true`):

```dart
Widget calmSelector(String selected, ValueChanged<String> onChanged) {
  return MorphMotionScope(
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
}
```

For your own animations:

```dart
Duration customDuration(BuildContext context) {
  final bool reduced = MorphMotion.reduceMotionOf(context);
  return reduced
      ? Duration.zero
      : MorphMotion.durationOf(context, const Duration(milliseconds: 300));
}
```

The per-family behavior table is in
[Reduced motion](REDUCED_MOTION_ACCESSIBILITY.md), the audit in
[Reduced motion tests](REDUCED_MOTION_TESTS.md); see also [Motion](MOTION.md).

## Haptics opt-out

`hapticsEnabled: false` silences all Morph-managed feedback; per-widget `haptic`
parameters accept `inherit`, `none` or an explicit level
([Theming](THEMING.md#haptics)). Provide a setting in your app for users who
prefer no vibration.

## Checklist for your screens

1. Every icon-only control has `tooltip` or `semanticLabel`.
2. Forms expose `errorText` and `supportingText`, not color alone.
3. Tab through the screen: order, visible focus ring, no traps in overlays.
4. Enable the system screen reader, 2.0x text, reduced motion and high contrast.
5. Check contrast of any custom colors, tints and explicit `glass.tint` values.
6. Keep targets at least 48 dp when you build custom controls around Morph.
