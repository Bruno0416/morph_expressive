// Maps every exported Morph widget (preview/lib/component_catalog.dart, generated
// by tool/generate_preview_catalog.py) to the Widgetbook navigation path(s) that
// exercise it. `test/widgetbook/coverage_test.dart` checks that the manifest
// covers the whole catalog and that every path exists in the generated tree.

/// Where one exported widget is exercised in the Widgetbook catalog.
class MorphCoverage {
  const MorphCoverage(this.paths, {this.note});

  /// Navigation paths (`Category/Family`) that exercise the widget.
  final List<String> paths;

  /// Required when the widget has no use case of its own and is exercised as a
  /// part of its family; explains where it is visible.
  final String? note;
}

/// Coverage of every widget in `morphComponentCatalog`.
const morphCoverageManifest = <String, MorphCoverage>{
  'MorphAppBar': MorphCoverage(['Navigation/App Bars']),
  'MorphBadge': MorphCoverage(['Surfaces & Content/Badges']),
  'MorphBottomSheet': MorphCoverage(['Overlays/Bottom sheets']),
  'MorphButtonGroup': MorphCoverage(['Actions/Button Groups']),
  'MorphReactiveButtonGroup': MorphCoverage(['Actions/Button Groups']),
  'MorphAsyncButton': MorphCoverage(['Actions/Async Buttons']),
  'MorphButton': MorphCoverage(['Actions/Buttons']),
  'MorphOperationGlyphSlot': MorphCoverage(
    ['Actions/Async Buttons'],
    note: 'Internal glyph slot of MorphAsyncButton; rendered by every Async Buttons state (loading, success, error).',
  ),
  'MorphShapeButton': MorphCoverage(['Actions/Shape Buttons']),
  'MorphCard': MorphCoverage(['Surfaces & Content/Cards']),
  'MorphCardGroup': MorphCoverage(['Surfaces & Content/Cards']),
  'MorphCarousel': MorphCoverage(['Surfaces & Content/Carousels']),
  'MorphCarouselShowAll': MorphCoverage([
    'Surfaces & Content/Carousels',
  ], note: 'Shown in Carousels/Wrapper and show all.'),
  'MorphCarouselView': MorphCoverage(['Surfaces & Content/Carousels']),
  'MorphCarouselWrapper': MorphCoverage(['Surfaces & Content/Carousels']),
  'MorphCheckbox': MorphCoverage(['Selection/Checkbox']),
  'MorphChip': MorphCoverage(['Selection/Chips']),
  'MorphChipGroup': MorphCoverage(['Selection/Chips']),
  'MorphChipToggle': MorphCoverage(['Selection/Chips']),
  'MorphCalendarDatePicker': MorphCoverage(['Inputs/Date pickers']),
  'MorphCalendarDateRangePicker': MorphCoverage(['Inputs/Date pickers']),
  'MorphDatePickerActions': MorphCoverage(
    ['Inputs/Date pickers'],
    note: 'Dialog actions of the date picker; shown in Date pickers/Building blocks and dialogs.',
  ),
  'MorphDatePickerDialog': MorphCoverage(['Inputs/Date pickers']),
  'MorphDatePickerEntryModeButton': MorphCoverage(
    ['Inputs/Date pickers'],
    note: 'Entry mode toggle of the date picker; shown in Date pickers/Building blocks.',
  ),
  'MorphDatePickerHeader': MorphCoverage([
    'Inputs/Date pickers',
  ], note: 'Header of the date picker; shown in Date pickers/Building blocks.'),
  'MorphDateRangePickerDialog': MorphCoverage(
    ['Inputs/Date pickers'],
    note: 'Range dialog opened by MorphDatePicker.showRange (Date pickers/Dialogs).',
  ),
  'MorphDayPicker': MorphCoverage(['Inputs/Date pickers']),
  'MorphInputDatePickerFormField': MorphCoverage(['Inputs/Date pickers']),
  'MorphInputDateRangePickerFormField': MorphCoverage([
    'Inputs/Date pickers',
  ], note: 'Shown in Date pickers/Input fields.'),
  'MorphMonthPicker': MorphCoverage(
    ['Inputs/Date pickers'],
    note:
        'Month grid of the date picker; shown in Date pickers/Building blocks.',
  ),
  'MorphYearPicker': MorphCoverage(
    ['Inputs/Date pickers'],
    note:
        'Year grid of the date picker; shown in Date pickers/Building blocks.',
  ),
  'MorphAdaptiveDialog': MorphCoverage([
    'Overlays/Dialogs',
  ], note: 'Opened from Dialogs/Playground (dialog = adaptive).'),
  'MorphDialog': MorphCoverage(['Overlays/Dialogs']),
  'MorphDialogInset': MorphCoverage(['Overlays/Dialogs']),
  'MorphFullScreenDialog': MorphCoverage([
    'Overlays/Dialogs',
  ], note: 'Opened from Dialogs/Playground (dialog = fullScreen).'),
  'MorphDivider': MorphCoverage(['Surfaces & Content/Dividers']),
  'MorphDropdownMenu': MorphCoverage(['Inputs/Dropdowns']),
  'MorphExtendedFab': MorphCoverage(['Actions/Extended FAB']),
  'MorphExtendedFabScrollVisibility': MorphCoverage(['Actions/Extended FAB']),
  'MorphFabMenu': MorphCoverage(['Actions/FAB Menu']),
  'MorphFab': MorphCoverage(['Actions/FAB']),
  'MorphFabScrollVisibility': MorphCoverage(['Actions/FAB']),
  'MorphComponentTheme': MorphCoverage(['Foundations/Colors & Themes']),
  'MorphDynamicColorHost': MorphCoverage(
    ['Foundations/Colors & Themes'],
    note: 'Shown in Colors & Themes/Component theme builder (reports whether device dynamic colour is available).',
  ),
  'MorphFocusRing': MorphCoverage(
    ['Foundations/Motion'],
    note: 'Shown in Motion/Tappable and state layer (focus ring knob; press Tab).',
  ),
  'MorphInkSplashTheme': MorphCoverage(['Foundations/Motion']),
  'MorphLiquidUnfold': MorphCoverage(['Foundations/Surfaces']),
  'MorphMaterialApp': MorphCoverage(['Foundations/Colors & Themes']),
  'MorphMotionScope': MorphCoverage(['Foundations/Motion']),
  'MorphResolvedTheme': MorphCoverage(
    ['Foundations/Colors & Themes'],
    note: 'Shown in Colors & Themes/Component theme builder (teal resolved theme).',
  ),
  'MorphRoundedSurface': MorphCoverage(['Foundations/Surfaces']),
  'MorphShapeContainer': MorphCoverage(['Foundations/Shapes']),
  'MorphShapeView': MorphCoverage(['Foundations/Shapes']),
  'MorphStateLayerOverlay': MorphCoverage([
    'Foundations/Motion',
  ], note: 'Shown in Motion/Tappable and state layer.'),
  'MorphTappable': MorphCoverage(['Foundations/Motion']),
  'MorphTheme': MorphCoverage(['Foundations/Colors & Themes']),
  'MorphThemeScope': MorphCoverage(['Foundations/Colors & Themes']),
  'MorphIconButton': MorphCoverage(['Actions/Icon Buttons']),
  'MorphCardListItem': MorphCoverage([
    'Surfaces & Content/Lists',
  ], note: 'Row surface composed by MorphList; shown by Lists/Playground.'),
  'MorphExpandableItem': MorphCoverage(['Surfaces & Content/Lists']),
  'MorphList': MorphCoverage(['Surfaces & Content/Lists']),
  'MorphListAvatar': MorphCoverage(
    ['Surfaces & Content/Lists'],
    note: 'Leading avatar of MorphListItem; select leading = avatar in Lists/Playground.',
  ),
  'MorphListImage': MorphCoverage(
    ['Surfaces & Content/Lists'],
    note: 'Leading image of MorphListItem; select leading = image in Lists/Playground.',
  ),
  'MorphListItem': MorphCoverage([
    'Surfaces & Content/Lists',
  ], note: 'Row of MorphList; shown by every Lists use case.'),
  'MorphListKeyTarget': MorphCoverage(
    ['Surfaces & Content/Lists'],
    note: 'Keyboard target of MorphList rows; shown in Lists/Building blocks.',
  ),
  'MorphListKeyboardGroup': MorphCoverage(
    ['Surfaces & Content/Lists'],
    note: 'Keyboard navigation group of MorphList; shown in Lists/Building blocks.',
  ),
  'MorphListRowSurface': MorphCoverage(['Surfaces & Content/Lists']),
  'MorphListVideo': MorphCoverage(
    ['Surfaces & Content/Lists'],
    note: 'Leading video thumbnail of MorphListItem; select leading = video in Lists/Playground.',
  ),
  'MorphMeasureSize': MorphCoverage(
    ['Surfaces & Content/Lists'],
    note: 'Measurement helper used by expandable rows; shown in Lists/Building blocks.',
  ),
  'MorphLoadingIndicator': MorphCoverage(['Feedback/Loading indicator']),
  'MorphContextMenuRegion': MorphCoverage(['Overlays/Context menus']),
  'MorphMenu': MorphCoverage(['Overlays/Menus']),
  'MorphMenuContent': MorphCoverage(
    ['Overlays/Menus'],
    note: 'Menu panel composed by MorphMenu and MorphMenuPopup; shown whenever a menu opens.',
  ),
  'MorphMenuDividerWidget': MorphCoverage(
    ['Overlays/Menus'],
    note: 'Row rendered by MorphMenuDivider nodes; also shown standalone in Menus/Nodes.',
  ),
  'MorphMenuItem': MorphCoverage([
    'Overlays/Menus',
  ], note: 'Row rendered by menu nodes; also shown standalone in Menus/Nodes.'),
  'MorphMenuPopup': MorphCoverage(
    ['Overlays/Menus', 'Overlays/Context menus'],
    note: 'Popup route content of MorphMenu; shown whenever a menu opens (and by the desktop context menu lab).',
  ),
  'MorphNavigationBar': MorphCoverage(['Navigation/Navigation Bar']),
  'MorphNavigationBarHost': MorphCoverage(['Navigation/Navigation Bar']),
  'MorphNavigationDrawer': MorphCoverage(['Navigation/Drawer']),
  'MorphNavigationRail': MorphCoverage(['Navigation/Rail']),
  'MorphPageIndicator': MorphCoverage(['Navigation/Page Indicator']),
  'MorphProgressIndicator': MorphCoverage(['Feedback/Progress']),
  'MorphRadio': MorphCoverage(['Selection/Radio']),
  'MorphRadioGroup': MorphCoverage([
    'Selection/Radio',
  ], note: 'Wraps the options in Radio/Radio group.'),
  'MorphRefreshIndicator': MorphCoverage(['Feedback/Refresh indicator']),
  'MorphSearchAnchor': MorphCoverage(['Inputs/Search']),
  'MorphSearchBar': MorphCoverage(['Inputs/Search']),
  'MorphSearchBarInput': MorphCoverage(
    ['Inputs/Search'],
    note: 'Text input inside MorphSearchBar; rendered by Search/Search bar and Search anchor.',
  ),
  'MorphSliverSearchBar': MorphCoverage(['Inputs/Search']),
  'MorphSegmentedButton': MorphCoverage(['Selection/Segmented']),
  'MorphSegmentedToggle': MorphCoverage(['Selection/Segmented']),
  'MorphSelection': MorphCoverage(['Surfaces & Content/Lists']),
  'MorphSelectionAppBar': MorphCoverage([
    'Surfaces & Content/Lists',
  ], note: 'Contextual bar of MorphSelection; shown in Lists/Selection mode.'),
  'MorphSelectionFlip': MorphCoverage(['Surfaces & Content/Lists']),
  'MorphSelectionLeading': MorphCoverage([
    'Surfaces & Content/Lists',
  ], note: 'Selection leading slot; shown in Lists/Selection flip.'),
  'MorphSideSheet': MorphCoverage(['Overlays/Side sheets']),
  'MorphSideSheetLayout': MorphCoverage(['Overlays/Side sheets']),
  'MorphSkeleton': MorphCoverage(['Feedback/Skeleton']),
  'MorphSkeletonGroup': MorphCoverage(['Feedback/Skeleton']),
  'MorphRangeSlider': MorphCoverage(['Inputs/Sliders']),
  'MorphSlider': MorphCoverage(['Inputs/Sliders']),
  'MorphSliderCenteredTrack': MorphCoverage(
    ['Inputs/Sliders'],
    note: 'Track part composed by MorphSlider.centered; shown in Sliders/Playground (centered types) and All types.',
  ),
  'MorphSliderThumb': MorphCoverage(
    ['Inputs/Sliders'],
    note: 'Thumb part composed by every MorphSlider; shown with custom thumb length in Sliders/Slider parts.',
  ),
  'MorphSliderTrack': MorphCoverage([
    'Inputs/Sliders',
  ], note: 'Track part composed by MorphSlider.'),
  'MorphSliderValueIndicator': MorphCoverage(
    ['Inputs/Sliders'],
    note: 'Value indicator composed by MorphSlider; visible while dragging with the value label enabled.',
  ),
  'MorphSnackbar': MorphCoverage(['Feedback/Snackbar']),
  'MorphSnackbarHost': MorphCoverage(
    ['Feedback/Snackbar'],
    note: 'Overlay host used by MorphSnackbar.show; shown whenever a snackbar appears in Snackbar/Playground.',
  ),
  'MorphSplitButton': MorphCoverage(['Actions/Split Buttons']),
  'MorphSwitch': MorphCoverage(['Selection/Switch']),
  'MorphTabs': MorphCoverage(['Navigation/Tabs']),
  'MorphTabsView': MorphCoverage(['Navigation/Tabs']),
  'MorphTextField': MorphCoverage(['Inputs/Text Fields']),
  'MorphDayPeriodControl': MorphCoverage(['Inputs/Time pickers']),
  'MorphDialTimePicker': MorphCoverage(['Inputs/Time pickers']),
  'MorphHourMinuteTextField': MorphCoverage(
    ['Inputs/Time pickers'],
    note: 'Hour/minute input of the time picker; shown in Time pickers/Building blocks.',
  ),
  'MorphInputTimePickerFormField': MorphCoverage(['Inputs/Time pickers']),
  'MorphTimePickerActions': MorphCoverage(
    ['Inputs/Time pickers'],
    note: 'Actions of the time picker; shown in Time pickers/Building blocks.',
  ),
  'MorphTimePickerDialog': MorphCoverage(['Inputs/Time pickers']),
  'MorphTimePickerDialogContent': MorphCoverage(
    ['Inputs/Time pickers'],
    note: 'Dialog content wrapper of the time picker; shown in Time pickers/Building blocks.',
  ),
  'MorphTimePickerEntryModeButton': MorphCoverage(
    ['Inputs/Time pickers'],
    note: 'Entry mode toggle of the time picker; shown in Time pickers/Building blocks.',
  ),
  'MorphTimePickerHeader': MorphCoverage([
    'Inputs/Time pickers',
  ], note: 'Header of the time picker; shown in Time pickers/Building blocks.'),
  'MorphToolbar': MorphCoverage(['Navigation/Toolbars']),
  'MorphToolbarActionsRow': MorphCoverage(
    ['Navigation/Toolbars'],
    note: 'Internal row composed by MorphToolbar; shown by every Toolbars/Playground constructor.',
  ),
  'MorphToolbarBody': MorphCoverage([
    'Navigation/Toolbars',
  ], note: 'Internal layout of MorphToolbar; shown by Toolbars/Playground.'),
  'MorphToolbarExpandingActions': MorphCoverage(
    ['Navigation/Toolbars'],
    note: 'Internal expanding action cluster of MorphToolbar.floating; shown by Toolbars/Playground.',
  ),
  'MorphToolbarFabSlot': MorphCoverage(
    ['Navigation/Toolbars'],
    note:
        'FAB slot of MorphToolbar; enable the FAB knob in Toolbars/Playground.',
  ),
  'MorphToolbarIconButton': MorphCoverage(
    ['Navigation/Toolbars'],
    note:
        'Action button composed by MorphToolbar; shown by Toolbars/Playground.',
  ),
  'MorphToolbarOverflowMenu': MorphCoverage(
    ['Navigation/Toolbars'],
    note: 'Overflow menu of MorphToolbar; lower "max inline actions" in Toolbars/Playground.',
  ),
  'MorphToolbarScrollWrapper': MorphCoverage(
    ['Navigation/Toolbars'],
    note: 'Scroll behaviour wrapper used by docked MorphToolbar; shown by Toolbars/Playground.',
  ),
  'MorphToolbarTitleBlock': MorphCoverage(
    ['Navigation/Toolbars'],
    note: 'Title and subtitle block of MorphToolbar; shown by Toolbars/Playground.',
  ),
  'MorphTooltip': MorphCoverage(['Overlays/Tooltips']),
};
