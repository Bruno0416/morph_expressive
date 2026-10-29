# Component catalog

Import `package:morph_expressive/morph_expressive.dart` to access public
components and foundations. The public `morph_components.dart` exports
components spanning 39 showcase families:

| Group | Families |
| --- | --- |
| Actions | Buttons, icon buttons, button groups, segmented buttons, split buttons, FABs, extended FABs, FAB menus, toolbars |
| Selection & input | Checkbox, radio, switch, chips, sliders (linear / centered / wavy / range), dropdown menus, text fields, date pickers, time pickers |
| Containment | Cards, carousel, lists, selection, dialogs, bottom sheets, side sheets, dividers |
| Navigation | App bars (including frosted), navigation bar, rail, drawer, page indicator, tabs, search |
| Feedback | Badges, progress indicators, loading indicator, refresh indicator, snackbars, tooltips |

The `preview/` gallery includes 40 interactive component families. A public export
in the source inventory is not necessarily a standalone component requiring a
separate showcase scene. See [Navigation](NAVIGATION_MORPH.md) for
`MorphNavigationBarDestination` migration, frosted AppBars and scroll hosts.

To start from a smaller, application-style example, explore
[`example/main.dart`](../example/main.dart): it combines buttons, selections,
validated fields, swipeable lists and a modal dialog.

## Chip variants and selection

The standard MD3-inspired chips (filter, input and assist) are distinct from
`MorphChipToggle<T>`, which animates a connected selection pill. Its
**single-selection** mode remains the default: provide `selected` and
`onChanged`. `MorphSegmentedToggle<T>` is another single-selection family,
with its own stretchy selection indicator.

To enable **multiple selection**, retain the selected values in the parent
widget state and supply a `Set<T>`:

```dart
MorphChipToggle<String>(
  multiSelection: true,
  options: const [
    MorphChipToggleOption(value: 'Daily', label: 'Daily'),
    MorphChipToggleOption(value: 'Weekly', label: 'Weekly'),
    MorphChipToggleOption(value: 'Monthly', label: 'Monthly'),
  ],
  selectedValues: selectedPeriods,
  onSelectionChanged: (next) => setState(() => selectedPeriods = next),
)
```

Here `selectedPeriods` is a `Set<String>` field in a `State` class; the callback
returns a fresh unmodifiable set. Empty multi-selection is allowed.

**Motion rules (0.2.0):** from zero to one selected, a 4 px circle expands
uniformly and becomes the pill; from one to zero, it shrinks back into a
circle with fade. Adding a second/third chip duplicates a pill from the
nearest active selection with a trailing-edge delay. Removing a chip while
others remain merges its pill toward the nearest survivor. The default chip
motion is 289 ms with a 77 ms trailing-edge delay; use `duration` and
`stretchDelay` to customize it.

![Standard, expressive single and expressive multi chips](assets/gifs/chips.gif)

## Filled text fields and floating labels

A `MorphTextField` using `MorphTextFieldVariant.filled` places an empty,
unfocused label inside the filled surface. On focus it moves diagonally toward
the leading side **above** the surface, revealing `placeholder`; once populated
it remains above even after focus is lost. It uses `onSurface` while focused,
with slightly larger-than-`bodyMedium` default floating typography. The
`outlined` variant retains its existing placement and defaults.

```dart
MorphTextField(
  variant: MorphTextFieldVariant.filled,
  label: 'Email',
  placeholder: 'name@example.com',
  floatingLabelTextStyle: const TextStyle(fontSize: 17), // optional
)
```

Customize `floatingLabelTextStyle` on the widget or through
`MorphTextFieldTheme`; the inline label and typed content are unaffected.

When placing two filled inputs side by side, enable
`reserveFloatingLabelSpace: true` on both. The field then reserves its
floating-label slot even when empty, keeping the painted surfaces level as
focus and content change. This is opt-in; ordinary single fields keep their
original compact layout. The date-range input dialog uses it automatically.

```dart
Row(
  children: [
    Expanded(child: MorphTextField(
      label: 'Start',
      reserveFloatingLabelSpace: true,
    )),
    const SizedBox(width: 8),
    Expanded(child: MorphTextField(
      label: 'End',
      reserveFloatingLabelSpace: true,
    )),
  ],
)
```

![Search, outlined and filled text fields](assets/gifs/textfields.gif)

### Validation: onUnfocus or an errorText expression (0.4.0)

`MorphTextField.onUnfocus` is an optional `ValueChanged<String>` callback.
It receives the field's latest text once when focus is lost (tap outside,
keyboard Tab navigation, or an explicit `FocusNode.unfocus()`). It does not
run on the initial build, on text changes while focused, or when the widget
is disposed. `onTapOutside` is separate: it responds to taps, while
`onUnfocus` also works for keyboard and programmatic focus changes.

**Validate on unfocus:** store a message in the surrounding `State` and pass
it to `errorText`. The field automatically handles the error color, supporting
message and accessibility semantics when `errorText` is non-null:

```dart
String? emailError; // State field

MorphTextField(
  label: 'Email',
  onUnfocus: (value) {
    setState(() {
      emailError = value.trim().contains('@') ? null : 'Enter a valid email';
    });
  },
  errorText: emailError,
)
```

**Validate by expression:** keep the previous approach if validation should
update as the user types. `onUnfocus` is not required:

```dart
String email = ''; // State field

MorphTextField(
  label: 'Email',
  onChanged: (value) => setState(() => email = value),
  errorText: email.isNotEmpty && !email.contains('@')
      ? 'Enter a valid email'
      : null,
)
```

Both approaches use the same `errorText` rendering. `onUnfocus` is a focus
notification, not an internal validation engine, and does not return an error
message. A parent may combine the approaches when needed.

### Validation error icons

`errorText` applies error styling and an accessible error message without
adding an icon by default. Opt into a custom `errorIcon` and set its location
with `MorphTextFieldErrorIconPosition.prefix` or `.suffix` (suffix is the
default). Both filled and outlined fields support either position. The
explicit error icon is only rendered when `errorText` is present, and can
coexist with your `leading` or `trailing` content. `showErrorIcon: true` is
retained for existing users of the built-in error glyph, but is now opt-in.

```dart
MorphTextField(
  label: 'Email',
  errorText: 'Please enter a valid address',
  errorIcon: const Icon(MorphIcons.error),
  errorIconPosition: MorphTextFieldErrorIconPosition.prefix,
  variant: MorphTextFieldVariant.outlined,
)
```

## Tabs and focus-driven scrolling

`MorphTabs` and `MorphTabs.sliver` now default to
`autoScrollToFocusedTab: false`. Switching or focusing a primary or secondary
tab does not automatically move its enclosing scroll viewport. Opt in with
`autoScrollToFocusedTab: true` if the app needs focus-following scrolling.
The animated indicator and keyboard focus behavior remain available.

## Refresh, progress indicators and sliders (0.4.0)

`MorphRefreshIndicator` includes an animated circular progress ring during
pull, an indeterminate ring while `onRefresh` is running, and a completion
spin and impact on success. The default pull distance is more responsive;
`armThreshold` (0 < value <= 1) and `pullSensitivity` (> 0) are configurable:

```dart
MorphRefreshIndicator(
  armThreshold: 0.78,
  pullSensitivity: 1.25,
  onRefresh: reload,
  child: scrollable,
)
```

`reload` must return a `Future<void>` and `scrollable` must support an
overscroll/pull gesture. Theme-managed haptics can be disabled globally.

Circular indicators already accept `size` on both standard and wavy
constructors, and 0.4.0 scales the stroke for compact use:

```dart
const MorphProgressIndicator.circular(size: 20)
const MorphProgressIndicator.circularWavy(size: 64)
```

`MorphSlider` / `MorphRangeSlider` without `divisions` do not generate
repeated detent haptics. Set `divisions` for feedback at each discrete value
change. The native touch lab illustrates both modes in the same screen.

## Swipe actions on Morph lists

Swipe actions are built into `MorphList`; no dependency on `flutter_slidable`
is required. Set `swipe` on each `MorphListItem` (a standalone item does
not provide the drag host). Swipe actions retain the standard Morph card
surface, spring motion, radii, pill buttons, and list spacing. Swipeable
rows can expose an automatic trailing three-dot affordance when enabled by
the list host. Gesture reveal or a dismiss controller remain available.

```dart
MorphList(
  itemCount: items.length,
  itemBuilder: (context, index) => MorphListItem(
    headline: items[index].title,
    swipe: MorphListItemSwipe(
      mode: MorphListSwipeMode.reveal,
      leading: [
        MorphListSwipeAction(
          icon: const Icon(MorphIcons.star),
          tooltip: 'Favorite',
          onPressed: () => favorite(items[index]),
        ),
      ],
      trailing: [
        MorphListSwipeAction(
          icon: const Icon(MorphIcons.archive),
          tooltip: 'Archive',
          onPressed: () => archive(items[index]),
        ),
      ],
    ),
  ),
)
```

![MorphList swipe actions](assets/gifs/lists.gif)

Floating dialogs use the same expressive motion system; see the
[dialog capture](assets/gifs/dialogs.gif) for entrance and exit transitions.

`MorphListSwipeMode.reveal` only opens actions; `dismiss` performs a full
swipe; `both` supports both gestures. `MorphListSwipeAction` supports
`tooltip`, `semanticLabel`, `enabled`, `autoClose`, optional colors, and
`isPrimary` for full-swipe actions. Use `MorphDismissibleListController` to
reveal, dismiss or close a row from your app.

If you enable full dismissal, `onDismiss` returns a `Future<bool>`: `false`
restores the card, while `true` permits its animation and the optional primary
action. It is safe to await a confirmation dialog. Update the application
collection to reflect confirmed deletion and provide stable item identities
when items can reorder. A disabled `MorphListItem` ignores swipe commands.

## Haptic feedback

`MorphThemeData.hapticsEnabled` defaults to `true`; its
`hapticFeedback` defaults to `MorphHapticFeedback.light`. The resolved Light,
Medium or Heavy setting also governs list actions and selection ticks in 0.4.0.
Globally disabling haptics prevents Morph-managed controls from forcing a local impact. Local
component overrides support `inherit` and `none` where provided. See
[Theming](THEMING.md) for details and device limitations.

For constructor parameters and the complete public API, consult Dart API
references and the exports in `lib/`.
