# Component API: type, variant and surface

Morph Expressive components are configured along three independent axes:

| Axis | How you choose it | What it controls |
| --- | --- | --- |
| **Visual type** | Named constructor (`MorphButton.outlined`, `MorphCard.filled`, ...) | Structure and presentation: fill, border, elevation |
| **Chromatic variant** | `variant: MorphVariant?` | Which color role the type uses |
| **Surface finish** | `surface: MorphSurface` | Opaque (`solid`) or frosted glass (`frosted`) |

Everything is available from the single public entry point,
`package:morph_expressive/morph_expressive.dart`:

```dart
Widget deleteButton(VoidCallback onDelete) {
  return MorphButton.outlined(
    variant: .danger,
    surface: .frosted,
    onPressed: onDelete,
    child: const Text('Delete'),
  );
}
```

Dart's enum shorthand (`.danger`, `.frosted`) works because the parameter types
are known (Dart 3.10 or newer, which the package requires). The fully
qualified form (`MorphVariant.danger`) is also valid. The snippets in this
page are compiled by `test/doc_examples_test.dart`.

## Shared types

- `MorphVariant`: `primary`, `secondary`, `tertiary`, `muted`, `danger`.
- `MorphSurface`: `solid`, `frosted` (with the getter `isFrosted`).

`MorphVariantPalette.of(scheme, variant)` (or `variant.resolve(scheme)`)
returns the resolved colors for a role in the active `MorphColorScheme`:

```dart
MorphVariantPalette dangerPalette(BuildContext context) {
  final MorphColorScheme scheme = MorphTheme.of(context).colorScheme;
  return MorphVariantPalette.of(scheme, MorphVariant.danger);
  // palette.color / onColor, container / onContainer, accent, outline
}
```

| Variant | `color` / `onColor` | `container` / `onContainer` | `accent` | `outline` |
| --- | --- | --- | --- | --- |
| `primary` | primary / onPrimary | primaryContainer / onPrimaryContainer | primary | outline |
| `secondary` | secondary / onSecondary | secondaryContainer / onSecondaryContainer | secondary | outline |
| `tertiary` | tertiary / onTertiary | tertiaryContainer / onTertiaryContainer | tertiary | outline |
| `muted` | surfaceContainerHighest / onSurface | surfaceContainerHigh / onSurfaceVariant | onSurfaceVariant | outlineVariant |
| `danger` | error / onError | errorContainer / onErrorContainer | error | error |

Each visual type maps the palette onto its own slots:

| Type | Container | Content | Border |
| --- | --- | --- | --- |
| filled | `color` | `onColor` | none |
| tonal | `container` | `onContainer` | none |
| elevated | `surfaceContainerLow` | `accent` | none |
| outlined | transparent | `accent` | `outline` |
| text / standard | transparent | `accent` | none |

A role therefore keeps one chromatic meaning across families without forcing
the same background on every type.

Cards are content surfaces, so their outlined and elevated types keep the
neutral surface and show the role in the headline (`accent`). An outlined card
keeps its own `outlineVariant` border for primary, secondary and tertiary, and
uses the role outline only for `danger` and `muted`. A filled card uses
`container` / `onContainer` for its fill and text.

### `variant: null` (the default)

When `variant` is omitted, each type keeps its canonical Material 3 pairing and
renders exactly as in earlier versions. For example, `MorphButton.tonal` uses the
secondary container, `MorphButton.outlined` uses `onSurfaceVariant` content and
`MorphButton.text` uses `primary` content. Pass a variant to opt into a role.

### Toggle buttons

When `isSelected` is non-null (toggle mode) and a variant is set, the selected
state uses `color` / `onColor` for every type except text. Unselected filled
toggles keep the `surfaceContainer` background with `accent` content; unselected
tonal, elevated and outlined toggles keep their resting colors.

### Disabled state

Disabled components ignore the variant and use the shared tokens
`MorphStateOpacity.disabledContent` (0.38) and
`MorphStateOpacity.disabledContainer` (0.12) applied to `onSurface`.

## Surface finish

`MorphSurface.frosted` reuses the Morph frosted renderer (`MorphGlassSurface`):
a backdrop blur clipped to the component's animated shape, a tint derived from
the resolved container color, and an optional hairline. Content, ink, the state
layer, the focus ring and the motion are never blurred or changed. The
configuration comes from, in order:

1. the widget's explicit `glass:` parameter, where one exists (`MorphCard`);
2. `MorphThemeData.floatingSurfaceGlass`, when set and enabled;
3. the default `const MorphSurfaceGlass()` (blur 12, tint opacity 0.65).

Transparent types (outlined, text, standard icon buttons) use
`surfaceContainerLow` as the tint base so the glass stays visible. Legibility,
high contrast, performance and platform notes are in
[Frosted surfaces](FROSTED_SURFACES.md).

Only `MorphButton`, `MorphAsyncButton`, `MorphIconButton` and `MorphCard` take
`surface:`. Floating surfaces (menus, dropdown panels, dialogs, sheets,
tooltips, snackbars, toolbars and app bars) keep their `glass:` parameter,
which distinguishes inherited, explicit and disabled configurations
(`MorphSurfaceGlass.disabled()`).

## Style precedence

1. Explicit widget overrides (`decoration`, explicit colors, `glass`).
2. The widget's `variant`.
3. The component theme (`MorphButtonTheme`, `MorphCardTheme`, ...).
4. The Morph theme tokens and the default pairing of the visual type.

A `variant` is an explicit call-site choice, so it wins over per-type theme
defaults such as `MorphCardTheme.filledContainerColor`.

## Families

| Family | Named constructors | `variant` | `surface` | Default |
| --- | --- | --- | --- | --- |
| `MorphButton` | `.filled`, `.tonal`, `.elevated`, `.outlined`, `.text`, `.icon` | yes | yes | `MorphButton()` is filled |
| `MorphAsyncButton` | none (takes `style`) | yes | yes | filled |
| `MorphIconButton` | `.standard`, `.filled`, `.tonal`, `.outlined` | yes | yes | `type: .filled` |
| `MorphCard` | `.elevated`, `.filled`, `.outlined` | yes | yes | `type: .elevated` |
| `MorphSplitButton` | existing named constructors | yes | no | unchanged |
| `MorphButtonGroup` | none | yes (forwarded to every button) | no | unchanged |
| `MorphShapeButton` | none | yes (filled pair) | no | unchanged |
| `MorphTextField` | `.filled`, `.outlined` | no | no | `variant: MorphTextFieldVariant.filled` |
| `MorphChip` | `.assist`, `.filter`, `.input`, `.suggestion` | no | no | unchanged |

Families without these axes keep their APIs. In particular:

- `MorphFab`, `MorphExtendedFab` and `MorphFabMenu` keep `MorphFabColor` /
  `MorphFabMenuColorSet`, which combine a role with a tone (`primaryFilled`,
  `surface`) that `MorphVariant` does not model.
- In `MorphTabs`, `MorphAppBar`, `MorphMenu`, `MorphDialog`, the sheets,
  `MorphToolbar`, `MorphLoadingIndicator`, `MorphTextField` and the list
  widgets, the historical `variant` parameter still names a **structural
  type**, not a color role.
- `MorphSplitButton` and `MorphButtonGroup` do not take `surface:`: a blur per
  segment would multiply backdrop filters and break the connected silhouette.
- Text fields and chips have no color roles. Their state colors (error,
  selection) are semantic.

## Examples

`save`, `skip`, `explore`, ... are your own callbacks:

```dart
Widget apiExamples({
  required VoidCallback save,
  required VoidCallback skip,
  required VoidCallback explore,
  required VoidCallback remove,
  required VoidCallback open,
  required VoidCallback add,
  required VoidCallback edit,
  required TextEditingController controller,
  required bool isOpen,
  required VoidCallback toggleOpen,
}) {
  return Column(
    spacing: 8,
    children: [
      // Types
      MorphButton(onPressed: save, child: const Text('Default')),
      MorphButton.tonal(onPressed: save, child: const Text('Tonal')),
      MorphButton.text(onPressed: skip, child: const Text('Skip')),

      // Roles
      MorphButton.filled(
        variant: .tertiary,
        onPressed: explore,
        child: const Text('Explore'),
      ),
      MorphButton.outlined(
        variant: .danger,
        onPressed: remove,
        child: const Text('Remove'),
      ),
      MorphButton.text(
        variant: .muted,
        onPressed: skip,
        child: const Text('Not now'),
      ),

      // Finish
      MorphButton.tonal(
        variant: .secondary,
        surface: .frosted,
        onPressed: open,
        child: const Text('Open'),
      ),

      // Other families
      MorphIconButton.filled(
        variant: .primary,
        onPressed: add,
        icon: Icon(FluentIcons.line.add),
      ),
      MorphIconButton.outlined(
        variant: .secondary,
        onPressed: edit,
        icon: Icon(FluentIcons.line.edit),
      ),
      const MorphCard.filled(variant: .muted, headline: 'Muted card'),
      const MorphCard.outlined(
        variant: .secondary,
        surface: .frosted,
        headline: 'Frosted outlined card',
      ),
      MorphTextField.outlined(controller: controller, label: 'Name'),
      MorphChip.filter(
        label: 'Open now',
        selected: isOpen,
        onPressed: toggleOpen,
      ),
    ],
  );
}
```

See [Upgrading to the v1 component API](UPGRADE_1_0_0.md) for the migration of
renamed parameters, and [Components](COMPONENTS.md) for the full catalog.
