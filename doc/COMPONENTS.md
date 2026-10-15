# Component catalog

Import `package:morph_expressive/morph_expressive.dart` to access public components and
foundations. These families are currently exported from `morph_components.dart`:

| Group | Families |
| --- | --- |
| Actions | Buttons, icon buttons, button groups, segmented buttons, split buttons, FABs, extended FABs, FAB menus, toolbars |
| Selection & input | Checkbox, radio, switch, chips, sliders (linear / centered / wavy / range), dropdown menus, text fields, date pickers, time pickers |
| Containment | Cards, carousel, lists, selection, dialogs, bottom sheets, side sheets, dividers |
| Navigation | App bars, navigation bar, rail, drawer, tabs, search |
| Feedback | Badges, progress indicators, loading indicator, refresh indicator, snackbars, tooltips |

The `preview/` application contains live examples by family. Its public widget
inventory is generated from the source; an item in that inventory is not
necessarily a standalone widget that needs an independent demo.

`MorphSegmentedToggle<T>` is included in 0.1.0. It uses a stretching,
rounded selection indicator and is shown in the interactive preview.

For current constructor parameters and feature-specific customization,
consult the Dart API documentation and public exports in `lib/`.
