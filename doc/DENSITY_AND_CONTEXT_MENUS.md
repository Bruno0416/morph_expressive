# Density and desktop context menus

Technical reference for the global density system and the desktop
presentation of context menus. The snippets are compiled by
`test/doc_examples_test.dart`.

## Global density

```dart
MorphThemeData densityThemes(Color seed) {
  final MorphThemeData compact = MorphThemeData.light(seedColor: seed).copyWith(
    density: .compact, // compact | standard | comfortable
  );
  // or
  final MorphThemeData comfortable = MorphThemeData.light(
    seedColor: seed,
    density: .comfortable,
  );
  return compact.density == comfortable.density ? compact : comfortable;
}
```

`MorphDensity.standard` is the default and keeps the approved Morph geometry.
Density is independent from component sizes: a `MorphButtonSize.sm` button stays
`sm` in every density, and only its layout metrics change.

Density is resolved from additive deltas (`MorphDensityMetrics`), never from a
transform or a multiplier:

| Metric | Compact | Standard | Comfortable |
| --- | --- | --- | --- |
| Control height, per size step (smallest → largest) | −4, −4, −8, −8, −8 | 0 | +4, +4, +4, +8, +8 |
| Row height | −8 | 0 | +8 |
| Horizontal / vertical padding (per side) | −2 | 0 | +2 |
| Gap | −2 | 0 | +2 |
| Layout icon size | −2 | 0 | 0 |

`MorphThemeData.densityMetrics` exposes the active deltas and
`MorphThemeData.densitySpacing` the spacing scale with the gap delta applied.
Components that need their own table (for example desktop menus) define it in
their theme, keyed by `MorphDensity`, with the standard entry equal to the
historical value. All metrics are monotonic: compact ≤ standard ≤ comfortable.

Density never changes font sizes, font weights, colors, variants, visual types
or surfaces, and it is independent from `MediaQuery.textScaler`. Compact
reduces the visual box, not the accessible target: buttons and icon buttons
keep the 48 dp padded tap target.

### Resolution order

1. An explicit widget parameter (for example `MorphSegmentedButton.density`,
   `MorphButtonGroup.density`, `MorphNavigationBar.density`,
   `MorphAppBar.density`, `MorphTextField.density`).
2. The component theme.
3. `MorphThemeData.density`.
4. Standard.

The per-component density parameters are nullable; `null` follows the theme.
Passing an enum value keeps working as before.

Changing `density` at runtime (`MorphTheme`, `MorphThemeScope`,
`MorphMaterialApp`) rebuilds dependent components without losing their state.
`MorphAppBar.preferredSize` has no `BuildContext`, so it reports the regular
height until the first frame resolves the live density.

### Coverage

Density-aware: buttons, icon buttons, button groups, split buttons (height,
paddings and icon gap), segmented buttons, chips and chip toggles, text fields
and the dropdown field, lists (rows, card-list gaps, expandable paddings),
cards, navigation bar, rail and drawer, tabs, app bars, toolbars (action gaps
and docked padding only), search bar, dialogs and full-screen dialogs,
snackbars, tooltips, badges, the selection app bar and select-all row, and
menus (desktop presentation).

Density-invariant by design: FAB, extended FAB and FAB menu (size tiers are
semantic), checkbox, radio and switch (control size and target are semantic),
slider, progress, loading indicator and skeleton (visual identity or caller
sized), carousel (layout-driven extents), date and time pickers (fixed Material
geometry), sheets, divider, page indicator and refresh indicator (layout
contracts and gesture thresholds), the search view (its header drives the
bar-to-view transition), dismissible list gaps (they drive the swipe-collapse
animation) and the toolbar container (shared with the FAB layout).

## Badges

Badge labels use `w600` (was `w500`) with slightly more padding, so the label is
easier to read without growing the badge's role in the layout. Font size, line
height, colors (`error` / `onError`, 6.5:1 light and 7.7:1 dark) and the 6 dp
dot are unchanged.

| Density | Horizontal padding | Vertical padding | Min size / radius |
| --- | --- | --- | --- |
| Compact | 4 | 0 | 16 / 8 (the previous footprint) |
| Standard | 5 | 1 | 18 / 9 |
| Comfortable | 6 | 1.5 | 19 / 9.5 |

`MorphBadgeTheme.density` overrides the global density for badges. Large badge
offsets moved by one pixel so the badge centre stays where it was.

## Desktop context menus

```dart
Widget fileTile(ValueChanged<String> handle) {
  return MorphContextMenuRegion<String>(
    onSelected: handle,
    children: <MorphMenuNode>[
      const MorphMenuEntry(
        label: 'Copy',
        trailingText: 'Ctrl+C',
        value: 'copy',
      ),
      const MorphMenuEntry(
        label: 'Paste',
        trailingText: 'Ctrl+V',
        value: 'paste',
      ),
      const MorphMenuSubmenu(
        label: 'Move to',
        children: <MorphMenuNode>[
          MorphMenuEntry(label: 'Documents', value: 'documents'),
          MorphMenuEntry(label: 'Archive', value: 'archive'),
        ],
      ),
      const MorphMenuDivider(),
      const MorphMenuEntry(
        label: 'Delete',
        isDestructive: true,
        value: 'delete',
      ),
    ],
    child: const Text('report.pdf'),
  );
}

Future<String?> openMenuAt(BuildContext context, Offset position) {
  return showMorphContextMenu<String>(
    context: context,
    position: position,
    children: const <MorphMenuNode>[
      MorphMenuEntry(label: 'Rename', value: 'rename'),
      MorphMenuEntry(label: 'Delete', isDestructive: true, value: 'delete'),
    ],
  );
}
```

`MorphContextMenuRegion` opens:

- on secondary click (mouse or trackpad): desktop presentation, top-left corner
  at the pointer;
- on touch long press: the standard (touch) presentation, unless
  `openOnLongPress: false`;
- from the keyboard on a focused region with Shift+F10 or the ContextMenu key:
  desktop presentation at the focused rect, first row highlighted.

`showMorphContextMenu` always uses the desktop presentation. `showMorphMenu`
keeps its standard geometry by default; pass
`presentation: MorphMenuPresentation.desktop` to opt in. Anchored menus,
dropdown menus and text-selection toolbars are unchanged.

```dart
Future<String?> desktopMenu(BuildContext context, Offset position) {
  return showMorphMenu<String>(
    context: context,
    anchor: position & const Size(1, 1),
    presentation: MorphMenuPresentation.desktop,
    children: const [
      MorphMenuEntry(label: 'Copy', trailingText: 'Ctrl+C', value: 'copy'),
    ],
  );
}
```

### Desktop geometry (`MorphMenuDesktopMetrics`)

| Metric | Compact | Standard | Comfortable | Standard presentation |
| --- | --- | --- | --- | --- |
| Item height | 28 | 32 | 40 | 48 |
| Icons | 16 | 16 | 18 | 20 |
| Container vertical padding | 4 | 4 | 6 | 4 |
| Container / item radius | 12 / 8 | 12 / 8 | 14 / 8 | 16·12 / 12 |
| Width | content-fit 180–320 | | | 112–280 |
| Open / close | 140 / 90 ms | | | 300 / 250 ms |

Rows reserve a stable leading slot (icons, check marks) whenever any sibling
uses it, so labels stay aligned. Shortcuts (`MorphMenuEntry.trailingText`) are
right-aligned in `onSurfaceVariant`; submenu chevrons use a fixed trailing slot.
Destructive rows use the error role; disabled rows never activate.

### Interaction

- Hover moves a single highlight; arrows skip disabled rows and dividers and
  wrap; Home/End; Enter/Space activate; Escape closes the submenu first.
- Right opens a submenu and focuses its first row; Left closes it.
- Hover opens a submenu after 120 ms. A safe-triangle and a 300 ms grace keep it
  open while the pointer travels diagonally toward it.
- The menu and its submenus flip at the right and bottom edges, mirror in RTL,
  and scroll internally when taller than the viewport minus 8 px margins.
- Click outside closes; a right click elsewhere reopens at the new position.
- Focus returns to the previously focused widget. Reduced motion opens and
  closes instantly.
