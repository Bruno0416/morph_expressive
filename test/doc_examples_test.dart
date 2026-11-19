// Compiles and pumps every non-trivial Dart snippet of the documentation.
//
// Source of truth for the snippets in:
//   doc/GETTING_STARTED.md, doc/THEMING.md, doc/COMPONENTS.md, doc/API_V1.md,
//   doc/FROSTED_SURFACES.md, doc/DENSITY_AND_CONTEXT_MENUS.md,
//   doc/ACCESSIBILITY.md, doc/UPGRADE_1_0_0.md and the README quick start
//   (test/doc_examples/readme_quick_start.dart, a full program).
//
// A snippet is the text between `// #docregion <name>` and
// `// #enddocregion <name>`. The documentation copies it verbatim; the final
// test below fails when a ```dart block of those documents is not found in this
// file or in test/doc_examples/. Fragments reference callbacks and state
// (`save`, `controller`, `selected`, ...) that the surrounding function in this
// file declares.
import 'dart:io';

import 'package:flutter/gestures.dart'
    show PointerDeviceKind, kSecondaryMouseButton;
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart'
    show
        Axis,
        Brightness,
        Builder,
        BuildContext,
        Center,
        Color,
        Column,
        Container,
        EdgeInsets,
        Expanded,
        Icon,
        ListView,
        MaterialApp,
        MediaQuery,
        MediaQueryData,
        Offset,
        Rect,
        Row,
        Scaffold,
        ScrollConfiguration,
        Size,
        SingleChildScrollView,
        SizedBox,
        State,
        StatefulWidget,
        Text,
        TextEditingController,
        TextScaler,
        Theme,
        ThemeData,
        ValueChanged,
        VoidCallback,
        Widget,
        Wrap;
import 'package:morph_expressive/morph_expressive.dart';

import 'doc_examples/material_app_integration.dart' as integration;
import '../example/v1_tour.dart' as tour;
import 'doc_examples/getting_started_app.dart' as getting_started;
import 'doc_examples/readme_quick_start.dart' as readme_quick_start;

// -- README.md snippets (verbatim) -------------------------------------------

void readmeDensity() {
  // ignore: unused_local_variable
  final theme = MorphThemeData.light(
    seedColor: const Color(0xFF6750A4),
    density: .compact, // compact | standard | comfortable
  );
}

Widget readmeComponentApi(VoidCallback onDelete) {
  return MorphButton.outlined(
    variant: .danger,
    surface: .frosted,
    onPressed: onDelete,
    child: const Text('Delete'),
  );
}

// -- Getting started --------------------------------------------------------

// #docregion first-widgets
Widget firstWidgets({
  required VoidCallback onContinue,
  required TextEditingController controller,
}) {
  return Column(
    spacing: 12,
    children: [
      MorphButton(onPressed: onContinue, child: const Text('Continue')),
      MorphIconButton.tonal(
        onPressed: () {},
        tooltip: 'Add',
        icon: Icon(FluentIcons.line.add),
      ),
      MorphTextField.outlined(controller: controller, label: 'Name'),
      MorphChip.filter(label: 'Open now', selected: true, onPressed: () {}),
      const MorphCard.filled(
        headline: 'Welcome',
        supportingText: 'A filled card in the primary container color.',
      ),
    ],
  );
}
// #enddocregion first-widgets

// #docregion density-theme
MorphThemeData compactTheme(Color seed) {
  return MorphThemeData.light(seedColor: seed, density: .compact);
}
// #enddocregion density-theme

// -- Component API ----------------------------------------------------------

// #docregion api-shorthand
Widget deleteButton(VoidCallback onDelete) {
  return MorphButton.outlined(
    variant: .danger,
    surface: .frosted,
    onPressed: onDelete,
    child: const Text('Delete'),
  );
}
// #enddocregion api-shorthand

// #docregion api-examples
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
// #enddocregion api-examples

// #docregion variant-palette
MorphVariantPalette dangerPalette(BuildContext context) {
  final MorphColorScheme scheme = MorphTheme.of(context).colorScheme;
  return MorphVariantPalette.of(scheme, MorphVariant.danger);
  // palette.color / onColor, container / onContainer, accent, outline
}
// #enddocregion variant-palette

// -- Components -------------------------------------------------------------

// #docregion component-buttons
Widget buttonFamilies(VoidCallback onPressed) {
  return Wrap(
    spacing: 8,
    runSpacing: 8,
    children: [
      MorphButton.filled(onPressed: onPressed, child: const Text('Filled')),
      MorphButton.tonal(onPressed: onPressed, child: const Text('Tonal')),
      MorphButton.elevated(onPressed: onPressed, child: const Text('Elevated')),
      MorphButton.outlined(onPressed: onPressed, child: const Text('Outlined')),
      MorphButton.text(onPressed: onPressed, child: const Text('Text')),
      MorphButton.icon(
        onPressed: onPressed,
        icon: Icon(FluentIcons.line.add),
        label: const Text('With icon'),
      ),
      // Sizes and shapes are independent from the visual type.
      MorphButton.filled(
        size: MorphButtonSize.lg,
        shape: MorphButtonShape.square,
        onPressed: onPressed,
        child: const Text('Large square'),
      ),
    ],
  );
}
// #enddocregion component-buttons

// #docregion component-icon-buttons
Widget iconButtons(VoidCallback onPressed) {
  return Row(
    spacing: 8,
    children: [
      MorphIconButton.standard(
        onPressed: onPressed,
        tooltip: 'Favorite',
        icon: Icon(FluentIcons.line.heart),
      ),
      MorphIconButton.filled(
        onPressed: onPressed,
        tooltip: 'Add',
        icon: Icon(FluentIcons.line.add),
      ),
      MorphIconButton.tonal(
        variant: .secondary,
        onPressed: onPressed,
        tooltip: 'Edit',
        icon: Icon(FluentIcons.line.edit),
      ),
      MorphIconButton.outlined(
        variant: .danger,
        onPressed: onPressed,
        tooltip: 'Delete',
        icon: Icon(FluentIcons.line.delete),
      ),
    ],
  );
}
// #enddocregion component-icon-buttons

// #docregion component-button-group
class PeriodPicker extends StatefulWidget {
  const PeriodPicker({super.key});

  @override
  State<PeriodPicker> createState() => _PeriodPickerState();
}

class _PeriodPickerState extends State<PeriodPicker> {
  int? selected = 1;

  @override
  Widget build(BuildContext context) {
    return MorphButtonGroup(
      type: MorphButtonGroupType.connected,
      style: MorphButtonStyle.tonal,
      selectedIndex: selected,
      onSelectedIndexChanged: (index) => setState(() => selected = index),
      actions: const [
        MorphButtonGroupAction(label: Text('Day')),
        MorphButtonGroupAction(label: Text('Week')),
        MorphButtonGroupAction(label: Text('Month')),
      ],
    );
  }
}
// #enddocregion component-button-group

// #docregion component-async-button
class SaveButton extends StatefulWidget {
  const SaveButton({super.key});

  @override
  State<SaveButton> createState() => _SaveButtonState();
}

class _SaveButtonState extends State<SaveButton> {
  MorphOperationState state = MorphOperationState.idle;

  Future<void> save() async {
    setState(() => state = MorphOperationState.loading);
    try {
      await Future<void>.delayed(const Duration(seconds: 1)); // your request
      setState(() => state = MorphOperationState.success);
    } catch (_) {
      setState(() => state = MorphOperationState.error);
    }
  }

  @override
  Widget build(BuildContext context) {
    return MorphAsyncButton(
      label: 'Save changes',
      state: state,
      labels: const {
        MorphOperationState.success: 'Saved',
        MorphOperationState.error: 'Retry',
      },
      onPressed: save,
    );
  }
}
// #enddocregion component-async-button

// #docregion component-text-fields
Widget textFields({
  required TextEditingController controller,
  required String? emailError,
  required ValueChanged<String> validate,
}) {
  return Column(
    spacing: 16,
    children: [
      MorphTextField.filled(
        controller: controller,
        label: 'Email',
        placeholder: 'name@example.com',
        errorText: emailError,
        onUnfocus: validate,
      ),
      MorphTextField.outlined(
        label: 'Search',
        supportingText: 'Press enter to search',
      ),
    ],
  );
}
// #enddocregion component-text-fields

// #docregion component-chips
Widget chips() {
  return Wrap(
    spacing: 8,
    children: [
      MorphChip.assist(label: 'Directions', onPressed: () {}),
      MorphChip.filter(label: 'Open now', selected: true, onPressed: () {}),
      MorphChip.input(label: 'Ada', onPressed: () {}, onDeleted: () {}),
      MorphChip.suggestion(label: 'Nearby', onPressed: () {}),
    ],
  );
}
// #enddocregion component-chips

// #docregion component-navigation
class AppNavigation extends StatefulWidget {
  const AppNavigation({super.key});

  @override
  State<AppNavigation> createState() => _AppNavigationState();
}

class _AppNavigationState extends State<AppNavigation> {
  int index = 0;

  @override
  Widget build(BuildContext context) {
    return MorphNavigationBar.expressive(
      selectedIndex: index,
      onDestinationSelected: (next) => setState(() => index = next),
      destinations: [
        MorphNavigationBarDestination(
          icon: FluentIcons.line.home,
          selectedIcon: FluentIcons.filled.home,
          label: 'Home',
        ),
        MorphNavigationBarDestination(
          icon: FluentIcons.line.search,
          label: 'Search',
        ),
        MorphNavigationBarDestination(
          icon: FluentIcons.line.mail,
          label: 'Mail',
          badgeCount: 3,
        ),
      ],
    );
  }
}
// #enddocregion component-navigation

// #docregion component-tabs
class OverviewTabs extends StatefulWidget {
  const OverviewTabs({super.key});

  @override
  State<OverviewTabs> createState() => _OverviewTabsState();
}

class _OverviewTabsState extends State<OverviewTabs> {
  final MorphTabsController controller = MorphTabsController();
  int tab = 0;

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        MorphTabs(
          controller: controller,
          tabs: const [
            MorphTab(label: 'Overview'),
            MorphTab(label: 'Activity'),
          ],
          selectedIndex: tab,
          onTabSelected: (index) => setState(() => tab = index),
        ),
        SizedBox(
          height: 80,
          child: MorphTabsView(
            controller: controller,
            selectedIndex: tab,
            onTabSelected: (index) => setState(() => tab = index),
            children: const [Text('Overview page'), Text('Activity page')],
          ),
        ),
      ],
    );
  }
}
// #enddocregion component-tabs

// #docregion component-progress
Widget progress(double value) {
  return Column(
    spacing: 12,
    children: [
      MorphProgressIndicator.linear(value: value),
      MorphProgressIndicator.linearWavy(value: value),
      MorphProgressIndicator.circular(value: value, size: 48),
      const MorphProgressIndicator.circularWavy(size: 48), // indeterminate
      const MorphLoadingIndicator(size: 48),
    ],
  );
}
// #enddocregion component-progress

// #docregion component-skeleton
Widget profilePlaceholder({required bool loading}) {
  return MorphSkeletonGroup(
    loading: loading,
    semanticLabel: 'Loading profile',
    placeholder: Column(
      children: [const MorphSkeleton.avatar(), MorphSkeleton.lines(count: 3)],
    ),
    child: const Text('Real content, same layout'),
  );
}
// #enddocregion component-skeleton

// #docregion component-cards-lists
Widget inboxList(List<String> items) {
  return Column(
    children: [
      const MorphCard.outlined(
        headline: 'Inbox',
        supportingText: 'Three conversations need a reply.',
      ),
      Expanded(
        child: MorphList(
          itemCount: items.length,
          itemBuilder: (context, index) => MorphListItem(
            headline: items[index],
            supportingText: 'Tap to open',
            onTap: () {},
            swipe: MorphListItemSwipe(
              mode: MorphListSwipeMode.reveal,
              trailing: [
                MorphListSwipeAction(
                  icon: const Icon(MorphIcons.archive),
                  tooltip: 'Archive',
                  onPressed: () {},
                ),
              ],
            ),
          ),
        ),
      ),
    ],
  );
}
// #enddocregion component-cards-lists

// #docregion component-chip-toggle
class PeriodChips extends StatefulWidget {
  const PeriodChips({super.key});

  @override
  State<PeriodChips> createState() => _PeriodChipsState();
}

class _PeriodChipsState extends State<PeriodChips> {
  Set<String> selectedPeriods = <String>{'Daily'};

  @override
  Widget build(BuildContext context) {
    return MorphChipToggle<String>(
      multiSelection: true,
      options: const [
        MorphChipToggleOption(value: 'Daily', label: 'Daily'),
        MorphChipToggleOption(value: 'Weekly', label: 'Weekly'),
        MorphChipToggleOption(value: 'Monthly', label: 'Monthly'),
      ],
      selectedValues: selectedPeriods,
      onSelectionChanged: (next) => setState(() => selectedPeriods = next),
    );
  }
}
// #enddocregion component-chip-toggle

// #docregion component-text-field-error
class EmailField extends StatefulWidget {
  const EmailField({super.key});

  @override
  State<EmailField> createState() => _EmailFieldState();
}

class _EmailFieldState extends State<EmailField> {
  String? emailError;

  @override
  Widget build(BuildContext context) {
    return MorphTextField.outlined(
      label: 'Email',
      onUnfocus: (value) {
        setState(() {
          emailError = value.trim().contains('@')
              ? null
              : 'Enter a valid email';
        });
      },
      errorText: emailError,
      errorIcon: const Icon(MorphIcons.error),
      errorIconPosition: MorphTextFieldErrorIconPosition.prefix,
    );
  }
}
// #enddocregion component-text-field-error

// #docregion component-refresh
Widget refreshable(Future<void> Function() reload, Widget scrollable) {
  return MorphRefreshIndicator(
    triggerMode: MorphRefreshTriggerMode.anywhere,
    semanticsLabel: 'Refresh inbox',
    onRefresh: reload,
    child: scrollable,
  );
}
// #enddocregion component-refresh

// #docregion component-context-menu
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
// #enddocregion component-context-menu

// -- Upgrading to 1.0.0 -----------------------------------------------------

// #docregion upgrade-icon-button
List<Widget> iconButtonMigration(Widget icon, VoidCallback f) {
  return [
    MorphIconButton.tonal(icon: icon, onPressed: f),
    MorphIconButton(type: MorphIconButtonType.tonal, icon: icon, onPressed: f),
  ];
}
// #enddocregion upgrade-icon-button

// #docregion upgrade-card
List<Widget> cardMigration(Widget child) {
  return [
    MorphCard.outlined(surface: .frosted, child: child),
    MorphCard(
      type: MorphCardType.outlined,
      surface: MorphSurface.frosted,
      child: child,
    ),
  ];
}
// #enddocregion upgrade-card

// -- Theming ----------------------------------------------------------------

// #docregion theme-seed
MorphThemeData lightTheme() =>
    MorphThemeData.light(seedColor: const Color(0xFF6750A4));
MorphThemeData darkTheme() =>
    MorphThemeData.dark(seedColor: const Color(0xFF6750A4));
// #enddocregion theme-seed

// #docregion theme-scheme-options
MorphThemeData vibrantHighContrast() {
  return MorphThemeData.light(
    seedColor: const Color(0xFF00796B),
    dynamicSchemeVariant: DynamicSchemeVariant.vibrant,
    contrastLevel: 0.5, // -1 (reduced) .. 0 (standard) .. 1 (high)
  );
}

MorphColorScheme schemeOnly() {
  return MorphColorScheme.fromSeed(
    const Color(0xFF00796B),
    brightness: Brightness.dark,
    dynamicSchemeVariant: DynamicSchemeVariant.fidelity,
  );
}
// #enddocregion theme-scheme-options

// #docregion theme-material-app
Widget adaptiveApp(Widget home) {
  return MorphMaterialApp(
    data: MorphThemeData.light(seedColor: const Color(0xFF6750A4)),
    autoTheming: true, // follow the platform brightness
    home: home,
  );
}
// #enddocregion theme-material-app

// #docregion theme-controller
class ThemeSwitcher extends StatefulWidget {
  const ThemeSwitcher({super.key});

  @override
  State<ThemeSwitcher> createState() => _ThemeSwitcherState();
}

class _ThemeSwitcherState extends State<ThemeSwitcher> {
  final MorphThemeController controller = MorphThemeController();

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MorphMaterialApp(
      data: MorphThemeData.light(seedColor: const Color(0xFF6750A4)),
      controller: controller,
      home: Scaffold(
        body: Center(
          child: MorphButton(
            onPressed: controller.toggleBrightness,
            child: const Text('Toggle light / dark'),
          ),
        ),
      ),
    );
  }
}
// #enddocregion theme-controller

// #docregion theme-dynamic-color
Widget dynamicColorApp(Widget home) {
  return MorphMaterialApp(
    // Used when the device does not provide a dynamic palette.
    data: MorphThemeData.light(seedColor: const Color(0xFF6750A4)),
    autoTheming: true,
    dynamicColoring: true, // Android 12+ wallpaper colors, desktop accents
    home: home,
  );
}
// #enddocregion theme-dynamic-color

// #docregion theme-read
Widget themedBox(BuildContext context) {
  final MorphThemeData theme = MorphTheme.of(context);
  final MorphColorScheme colors = theme.colorScheme;
  return Container(
    padding: const EdgeInsets.all(16),
    color: colors.surfaceContainerHigh,
    child: Text(
      'Seed-derived surface',
      style: theme.textTheme.titleMedium?.copyWith(color: colors.onSurface),
    ),
  );
}
// #enddocregion theme-read

// #docregion theme-nested
Widget compactSection(BuildContext context, Widget child) {
  final MorphThemeData parent = MorphTheme.of(context);
  return MorphTheme(
    // A nested theme replaces the inherited one for its subtree only.
    data: parent.copyWith(density: .compact, hapticsEnabled: false),
    child: child,
  );
}

Widget brandedSection(Widget child) {
  return MorphTheme(
    data: MorphThemeData.light(seedColor: const Color(0xFFB3261E)),
    child: child,
  );
}
// #enddocregion theme-nested

// #docregion theme-component-overrides
MorphThemeData customizedTheme() {
  final MorphThemeData base = MorphThemeData.light(
    seedColor: const Color(0xFF6750A4),
  );
  return base.copyWith(
    cardTheme: base.cardTheme.copyWith(radius: 20),
    buttonTheme: base.buttonTheme.copyWith(
      pressDuration: const Duration(milliseconds: 60),
    ),
    floatingSurfaceGlass: const MorphSurfaceGlass(
      blurX: 14,
      blurY: 14,
      tintOpacity: 0.7,
    ),
  );
}
// #enddocregion theme-component-overrides

// #docregion theme-from-material
MorphThemeData fromExistingTheme(ThemeData material) {
  return MorphThemeData.fromMaterial(material, density: .comfortable);
}
// #enddocregion theme-from-material

// #docregion theme-typography
MorphThemeData typographyTheme(ThemeData materialTheme) {
  return MorphThemeData.light(
    seedColor: const Color(0xFF6750A4),
    textTheme: materialTheme.textTheme,
  );
}
// #enddocregion theme-typography

// #docregion theme-haptics
MorphThemeData hapticsTheme() {
  final MorphThemeData theme = MorphThemeData.light(
    seedColor: const Color(0xFF6750A4),
  );
  return theme.copyWith(
    hapticsEnabled: true,
    hapticFeedback: MorphHapticFeedback.medium,
  );
}

MorphThemeData quietTheme(MorphThemeData theme) =>
    theme.copyWith(hapticsEnabled: false);
// #enddocregion theme-haptics

// -- Frosted surfaces -------------------------------------------------------

// #docregion frosted-glass-config
const MorphSurfaceGlass glass = MorphSurfaceGlass(
  blurX: 12,
  blurY: 12,
  tintOpacity: 0.65,
  borderColor: Color(0x66FFFFFF),
  borderWidth: 1,
);
// #enddocregion frosted-glass-config

// #docregion frosted-inflow
Widget frostedInFlow(VoidCallback onPressed) {
  return Column(
    spacing: 12,
    children: [
      MorphButton.tonal(
        surface: .frosted,
        onPressed: onPressed,
        child: const Text('Frosted button'),
      ),
      MorphIconButton.filled(
        surface: .frosted,
        onPressed: onPressed,
        tooltip: 'Add',
        icon: Icon(FluentIcons.line.add),
      ),
      const MorphCard(surface: .frosted, headline: 'Frosted card'),
      // Explicit glass on a card: no `surface:` needed.
      const MorphCard(
        headline: 'Locally frosted',
        glass: MorphSurfaceGlass(blurX: 10, blurY: 10, tintOpacity: 0.50),
      ),
      // Force an opaque card even when a parent or the theme enables glass.
      const MorphCard(
        surface: .frosted,
        glass: MorphSurfaceGlass.disabled(),
        headline: 'Opaque override',
      ),
    ],
  );
}
// #enddocregion frosted-inflow

// #docregion frosted-theme
MorphThemeData frostedTheme() {
  final MorphThemeData base = MorphThemeData.light(
    seedColor: const Color(0xFF6750A4),
  );
  return base.copyWith(
    floatingSurfaceGlass: const MorphSurfaceGlass(
      blurX: 12,
      blurY: 12,
      tintOpacity: 0.65,
    ),
  );
}
// #enddocregion frosted-theme

// #docregion frosted-dialog
Widget optionsDialog() {
  return const MorphDialog(
    title: 'Options',
    content: Text('Choose a setting.'),
    glass: MorphSurfaceGlass(blurX: 8, blurY: 8),
  );
}
// #enddocregion frosted-dialog

// #docregion frosted-menu
Future<String?> pickAction(BuildContext context, Rect anchorRect) {
  return showMorphMenu<String>(
    context: context,
    anchor: anchorRect,
    children: const [
      MorphMenuEntry(label: 'Rename', value: 'rename'),
      MorphMenuEntry(label: 'Delete', value: 'delete'),
    ],
    glass: const MorphSurfaceGlass(blurX: 10, blurY: 10),
  );
}
// #enddocregion frosted-menu

// #docregion frosted-fallbacks
const MorphSurfaceGlass tintOnlyOnWeb = MorphSurfaceGlass(
  webBackdropBlur: false, // keep tint and border, skip the blur on the web
);

const MorphSurfaceGlass alwaysTranslucent = MorphSurfaceGlass(
  opaqueInHighContrast: false, // default true: opaque under high contrast
);
// #enddocregion frosted-fallbacks

// #docregion frosted-scroll
Widget frostedScroller(List<Widget> children) {
  return ScrollConfiguration(
    behavior: const MorphScrollBehavior(),
    child: ListView(children: children),
  );
}
// #enddocregion frosted-scroll

// -- Density and context menus ----------------------------------------------

// #docregion density-global
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
// #enddocregion density-global

// #docregion density-menu-presentation
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
// #enddocregion density-menu-presentation

// -- Accessibility ----------------------------------------------------------

// #docregion a11y-semantics
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
// #enddocregion a11y-semantics

// #docregion a11y-theme
MorphThemeData accessibleTheme(Color seed) {
  return MorphThemeData.light(seedColor: seed, contrastLevel: 0.5).copyWith(
    reduceMotion: true, // opt in; the system setting is always honored
    hapticsEnabled: false, // no Morph-managed haptics
    keyboardFocusIndicators: true, // default: focus rings for Tab navigation
  );
}
// #enddocregion a11y-theme

// #docregion a11y-motion-scope
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
// #enddocregion a11y-motion-scope

// #docregion a11y-custom-motion
Duration customDuration(BuildContext context) {
  final bool reduced = MorphMotion.reduceMotionOf(context);
  return reduced
      ? Duration.zero
      : MorphMotion.durationOf(context, const Duration(milliseconds: 300));
}
// #enddocregion a11y-custom-motion

// -- Harness ----------------------------------------------------------------

Widget _app(Widget body, {MorphThemeData? data}) {
  return MorphMaterialApp(
    data: data ?? MorphThemeData.light(),
    home: Scaffold(
      body: SingleChildScrollView(child: Center(child: body)),
    ),
  );
}

Future<void> _pump(
  WidgetTester tester,
  Widget body, {
  MorphThemeData? data,
}) async {
  tester.view.physicalSize = const Size(1000, 2400);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);
  await tester.pumpWidget(_app(body, data: data));
  await tester.pump(const Duration(milliseconds: 400));
  expect(tester.takeException(), isNull);
}

void main() {
  const Color seed = Color(0xFF6750A4);

  group('getting started', () {
    testWidgets('README quick start program', (tester) async {
      readme_quick_start.main(); // runApp(MorphMaterialApp(...))
      await tester.pump(const Duration(milliseconds: 400));
      expect(find.byType(MorphButton), findsOneWidget);
      expect(find.text('Continue'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    test('README density and component API snippets', () {
      readmeDensity();
      expect(readmeComponentApi(() {}), isA<MorphButton>());
    });

    testWidgets('getting started program', (tester) async {
      await tester.pumpWidget(const getting_started.MyApp());
      await tester.pump(const Duration(milliseconds: 400));
      expect(find.byType(MorphButton), findsNWidgets(3));
      expect(tester.takeException(), isNull);
    });

    testWidgets('MaterialApp integration program', (tester) async {
      await tester.pumpWidget(const integration.ExistingApp());
      await tester.pump(const Duration(milliseconds: 400));
      expect(find.byType(MorphButton), findsOneWidget);
      final BuildContext context = tester.element(find.byType(MorphButton));
      expect(MorphTheme.of(context).colorScheme.brightness, Brightness.light);
      expect(tester.takeException(), isNull);
    });

    testWidgets('first widgets', (tester) async {
      final TextEditingController controller = TextEditingController();
      addTearDown(controller.dispose);
      int taps = 0;
      await _pump(
        tester,
        firstWidgets(onContinue: () => taps++, controller: controller),
      );
      await tester.tap(find.text('Continue'));
      await tester.pump();
      expect(taps, 1);
      expect(find.byType(MorphCard), findsOneWidget);
    });

    testWidgets('density theme', (tester) async {
      final MorphThemeData data = compactTheme(seed);
      expect(data.density, MorphDensity.compact);
      await _pump(tester, const MorphButton(onPressed: null), data: data);
    });
  });

  group('component API', () {
    testWidgets('shorthand button and examples', (tester) async {
      final TextEditingController controller = TextEditingController();
      addTearDown(controller.dispose);
      int saved = 0;
      await _pump(
        tester,
        Column(
          children: [
            deleteButton(() {}),
            apiExamples(
              save: () => saved++,
              skip: () {},
              explore: () {},
              remove: () {},
              open: () {},
              add: () {},
              edit: () {},
              controller: controller,
              isOpen: true,
              toggleOpen: () {},
            ),
          ],
        ),
      );
      await tester.tap(find.text('Default'));
      await tester.pump();
      expect(saved, 1);
      expect(find.byType(MorphIconButton), findsNWidgets(2));
      expect(find.byType(MorphCard), findsNWidgets(2));
    });

    testWidgets('variant palette matches the scheme', (tester) async {
      late MorphVariantPalette palette;
      await tester.pumpWidget(
        MorphMaterialApp(
          data: MorphThemeData.light(seedColor: seed),
          home: Builder(
            builder: (context) {
              palette = dangerPalette(context);
              return const SizedBox();
            },
          ),
        ),
      );
      expect(palette.color, MorphColorScheme.fromSeed(seed).error);
    });
  });

  group('components', () {
    testWidgets('buttons, icon buttons, chips and progress', (tester) async {
      await _pump(
        tester,
        Column(
          children: [
            buttonFamilies(() {}),
            iconButtons(() {}),
            chips(),
            progress(0.4),
          ],
        ),
      );
      expect(find.byType(MorphButton), findsNWidgets(7));
      expect(find.byType(MorphIconButton), findsNWidgets(4));
      expect(find.byType(MorphChip), findsNWidgets(4));
    });

    testWidgets('connected button group selection', (tester) async {
      await _pump(tester, const PeriodPicker());
      await tester.tap(find.text('Month').first);
      await tester.pump(const Duration(milliseconds: 400));
      expect(
        tester
            .widget<MorphButtonGroup>(find.byType(MorphButtonGroup))
            .selectedIndex,
        2,
      );
    });

    testWidgets('async button owns its state', (tester) async {
      await _pump(tester, const SaveButton());
      await tester.tap(find.text('Save changes'));
      await tester.pump(const Duration(milliseconds: 50));
      expect(
        tester.widget<MorphAsyncButton>(find.byType(MorphAsyncButton)).state,
        MorphOperationState.loading,
      );
      await tester.pump(const Duration(seconds: 2));
      await tester.pump(const Duration(milliseconds: 600));
      expect(
        tester.widget<MorphAsyncButton>(find.byType(MorphAsyncButton)).state,
        MorphOperationState.success,
      );
    });

    testWidgets('text fields and validation', (tester) async {
      final TextEditingController controller = TextEditingController();
      addTearDown(controller.dispose);
      await _pump(
        tester,
        Column(
          children: [
            SizedBox(
              width: 360,
              child: textFields(
                controller: controller,
                emailError: 'Enter a valid email',
                validate: (_) {},
              ),
            ),
            const SizedBox(width: 360, child: EmailField()),
          ],
        ),
      );
      expect(find.byType(MorphTextField), findsNWidgets(3));
    });

    testWidgets('navigation bar and tabs', (tester) async {
      await _pump(
        tester,
        const Column(
          children: [
            SizedBox(width: 420, child: AppNavigation()),
            SizedBox(width: 420, child: OverviewTabs()),
          ],
        ),
      );
      await tester.tap(find.text('Search'));
      await tester.pump(const Duration(milliseconds: 500));
      await tester.tap(find.text('Activity').first);
      await tester.pump(const Duration(milliseconds: 600));
      expect(find.byType(MorphNavigationBar), findsOneWidget);
      expect(find.byType(MorphTabsView), findsOneWidget);
    });

    testWidgets('skeleton group and chip toggle', (tester) async {
      await _pump(
        tester,
        Column(
          children: [
            SizedBox(width: 300, child: profilePlaceholder(loading: true)),
            const PeriodChips(),
          ],
        ),
      );
      expect(find.byType(MorphSkeletonGroup), findsOneWidget);
      expect(find.byType(MorphChipToggle<String>), findsOneWidget);
    });

    testWidgets('cards and list with swipe actions', (tester) async {
      await tester.binding.setSurfaceSize(const Size(800, 900));
      addTearDown(() => tester.binding.setSurfaceSize(null));
      await tester.pumpWidget(
        _app(
          SizedBox(
            width: 500,
            height: 600,
            child: inboxList(const ['Alice', 'Bob']),
          ),
        ),
      );
      await tester.pump(const Duration(milliseconds: 400));
      expect(find.text('Alice'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('refresh indicator', (tester) async {
      await tester.binding.setSurfaceSize(const Size(800, 900));
      addTearDown(() => tester.binding.setSurfaceSize(null));
      await tester.pumpWidget(
        MorphMaterialApp(
          data: MorphThemeData.light(),
          home: Scaffold(
            body: refreshable(
              () async {},
              ListView(children: const [Text('Row')]),
            ),
          ),
        ),
      );
      await tester.pump(const Duration(milliseconds: 400));
      expect(find.byType(MorphRefreshIndicator), findsOneWidget);
    });

    testWidgets('context menu region opens with a secondary click', (
      tester,
    ) async {
      String? chosen;
      await _pump(
        tester,
        SizedBox(width: 200, height: 80, child: fileTile((v) => chosen = v)),
      );
      final TestGesture gesture = await tester.startGesture(
        tester.getCenter(find.text('report.pdf')),
        kind: PointerDeviceKind.mouse,
        buttons: kSecondaryMouseButton,
      );
      await gesture.up();
      await tester.pump(const Duration(milliseconds: 300));
      expect(find.text('Copy'), findsOneWidget);
      await tester.tap(find.text('Copy'));
      await tester.pump(const Duration(milliseconds: 300));
      expect(chosen, 'copy');
    });

    testWidgets('imperative context menu', (tester) async {
      late BuildContext captured;
      await tester.pumpWidget(
        MorphMaterialApp(
          data: MorphThemeData.light(),
          home: Scaffold(
            body: Builder(
              builder: (context) {
                captured = context;
                return const SizedBox.expand();
              },
            ),
          ),
        ),
      );
      final Future<String?> result = openMenuAt(captured, const Offset(40, 40));
      await tester.pump(const Duration(milliseconds: 300));
      await tester.tap(find.text('Rename'));
      await tester.pump(const Duration(milliseconds: 300));
      expect(await result, 'rename');
    });
  });

  group('examples', () {
    testWidgets('v1 tour builds and responds', (tester) async {
      tester.view.physicalSize = const Size(1000, 3600);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);
      await tester.pumpWidget(const tour.V1TourApp());
      await tester.pump(const Duration(milliseconds: 400));
      expect(find.byType(MorphAsyncButton), findsOneWidget);
      expect(find.byType(MorphContextMenuRegion<String>), findsOneWidget);
      await tester.tap(find.text('compact'));
      await tester.pump(const Duration(milliseconds: 500));
      final BuildContext context = tester.element(
        find.byType(MorphAsyncButton),
      );
      expect(MorphTheme.of(context).density, MorphDensity.compact);
      await tester.tap(find.text('Light / dark'));
      await tester.pump(const Duration(milliseconds: 600));
      expect(
        MorphTheme.of(tester.element(find.byType(MorphAsyncButton))).brightness,
        Brightness.dark,
      );
      await tester.tap(find.text('Save changes'));
      await tester.pump(const Duration(milliseconds: 100));
      await tester.pump(const Duration(seconds: 4));
      expect(tester.takeException(), isNull);
    });
  });

  group('upgrade', () {
    testWidgets('migrated icon buttons and cards', (tester) async {
      await _pump(
        tester,
        Column(
          children: [
            ...iconButtonMigration(Icon(FluentIcons.line.add), () {}),
            ...cardMigration(const Text('Card body')),
          ],
        ),
      );
      expect(find.byType(MorphIconButton), findsNWidgets(2));
      expect(find.byType(MorphCard), findsNWidgets(2));
    });
  });

  group('theming', () {
    test('seed themes, scheme options and tokens', () {
      expect(lightTheme().brightness, Brightness.light);
      expect(darkTheme().brightness, Brightness.dark);
      expect(
        lightTheme().colorScheme.primary,
        MorphColorScheme.fromSeed(seed).primary,
      );
      final MorphThemeData vibrant = vibrantHighContrast();
      expect(vibrant.colorScheme.contrastLevel, 0.5);
      expect(
        vibrant.colorScheme.dynamicSchemeVariant,
        DynamicSchemeVariant.vibrant,
      );
      expect(schemeOnly().brightness, Brightness.dark);
      expect(customizedTheme().cardTheme.radius, 20);
      expect(customizedTheme().floatingSurfaceGlass?.tintOpacity, 0.7);
      expect(quietTheme(hapticsTheme()).hapticsEnabled, isFalse);
      expect(hapticsTheme().hapticFeedback, MorphHapticFeedback.medium);
    });

    test('derived dark theme equals the dark factory', () {
      final MorphThemeData derived = lightTheme().deriveDarkTemplate();
      expect(derived.colorScheme.primary, darkTheme().colorScheme.primary);
      expect(derived.colorScheme.secondary, darkTheme().colorScheme.secondary);
    });

    testWidgets('adaptive app, controller and dynamic color host', (
      tester,
    ) async {
      await tester.pumpWidget(
        adaptiveApp(const Scaffold(body: Text('adaptive'))),
      );
      await tester.pump(const Duration(milliseconds: 400));
      expect(find.text('adaptive'), findsOneWidget);

      await tester.pumpWidget(const ThemeSwitcher());
      await tester.pump(const Duration(milliseconds: 400));
      final BuildContext context = tester.element(find.byType(MorphButton));
      expect(MorphTheme.of(context).brightness, Brightness.light);
      await tester.tap(find.text('Toggle light / dark'));
      await tester.pump(const Duration(milliseconds: 600));
      final BuildContext after = tester.element(find.byType(MorphButton));
      expect(MorphTheme.of(after).brightness, Brightness.dark);

      await tester.pumpWidget(
        dynamicColorApp(const Scaffold(body: Text('dynamic'))),
      );
      await tester.pump(const Duration(milliseconds: 400));
      expect(find.text('dynamic'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('read, nest and convert themes', (tester) async {
      late BuildContext inner;
      await tester.pumpWidget(
        MorphMaterialApp(
          data: MorphThemeData.light(seedColor: seed),
          home: Scaffold(
            body: Builder(
              builder: (context) => Column(
                children: [
                  themedBox(context),
                  compactSection(
                    context,
                    Builder(
                      builder: (context) {
                        inner = context;
                        return brandedSection(const Text('branded'));
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
      await tester.pump(const Duration(milliseconds: 400));
      expect(MorphTheme.of(inner).density, MorphDensity.compact);
      expect(MorphTheme.of(inner).hapticsEnabled, isFalse);
      final MorphThemeData converted = fromExistingTheme(
        ThemeData(colorSchemeSeed: seed),
      );
      expect(converted.density, MorphDensity.comfortable);
      expect(typographyTheme(ThemeData()).brightness, Brightness.light);
    });
  });

  group('frosted surfaces', () {
    testWidgets('in-flow surfaces, dialog and scroll behavior', (tester) async {
      expect(glass.blurX, 12);
      expect(tintOnlyOnWeb.webBackdropBlur, isFalse);
      expect(alwaysTranslucent.opaqueInHighContrast, isFalse);
      await _pump(
        tester,
        Column(
          children: [
            frostedInFlow(() {}),
            SizedBox(
              width: 300,
              height: 120,
              child: frostedScroller(const [Text('a'), Text('b')]),
            ),
            optionsDialog(),
          ],
        ),
        data: frostedTheme(),
      );
      expect(find.byType(MorphCard), findsNWidgets(3));
    });

    testWidgets('anchored menu with glass', (tester) async {
      late BuildContext captured;
      await tester.pumpWidget(
        MorphMaterialApp(
          data: frostedTheme(),
          home: Scaffold(
            body: Builder(
              builder: (context) {
                captured = context;
                return const SizedBox.expand();
              },
            ),
          ),
        ),
      );
      final Future<String?> result = pickAction(
        captured,
        const Rect.fromLTWH(40, 40, 100, 40),
      );
      await tester.pumpAndSettle();
      await tester.tap(find.text('Delete'));
      await tester.pump(const Duration(milliseconds: 300));
      expect(await result, 'delete');
    });
  });

  group('density and accessibility', () {
    testWidgets('global density and desktop menu', (tester) async {
      final MorphThemeData data = densityThemes(seed);
      expect(data.density, MorphDensity.comfortable);
      late BuildContext captured;
      await tester.pumpWidget(
        MorphMaterialApp(
          data: data,
          home: Scaffold(
            body: Builder(
              builder: (context) {
                captured = context;
                return const SizedBox.expand();
              },
            ),
          ),
        ),
      );
      final Future<String?> result = desktopMenu(
        captured,
        const Offset(20, 20),
      );
      await tester.pump(const Duration(milliseconds: 300));
      await tester.tap(find.text('Copy'));
      await tester.pump(const Duration(milliseconds: 300));
      expect(await result, 'copy');
    });

    testWidgets('semantics, accessible theme and motion scope', (tester) async {
      final SemanticsHandle handle = tester.ensureSemantics();
      await _pump(
        tester,
        Column(
          children: [
            accessibleActions(onDelete: () {}, onShare: () {}),
            calmSelector('a', (_) {}),
          ],
        ),
        data: accessibleTheme(seed),
      );
      expect(find.bySemanticsLabel('Delete conversation'), findsOneWidget);
      expect(find.bySemanticsLabel('Share'), findsOneWidget);
      late BuildContext captured;
      await tester.pumpWidget(
        MorphMaterialApp(
          data: accessibleTheme(seed),
          home: Builder(
            builder: (context) {
              captured = context;
              return const SizedBox();
            },
          ),
        ),
      );
      expect(MorphMotion.reduceMotionOf(captured), isTrue);
      expect(customDuration(captured), Duration.zero);
      handle.dispose();
    });

    testWidgets('text scaling keeps controls usable', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: MediaQuery(
            data: const MediaQueryData(textScaler: TextScaler.linear(2)),
            child: MorphTheme(
              data: MorphThemeData.light(seedColor: seed),
              child: Scaffold(
                body: Center(
                  child: MorphButton(
                    onPressed: () {},
                    child: const Text('Large text'),
                  ),
                ),
              ),
            ),
          ),
        ),
      );
      expect(tester.takeException(), isNull);
      expect(
        tester.getSize(find.byType(MorphButton)).height,
        greaterThanOrEqualTo(48),
      );
      expect(Theme.of(tester.element(find.byType(MorphButton))), isNotNull);
    });
  });

  test('Axis is available for direction-aware snippets', () {
    expect(Axis.values, isNotEmpty);
  });

  test('every Dart block in the documents is a verified snippet', () {
    final List<File> sources = <File>[
      File('test/doc_examples_test.dart'),
      ...Directory('test/doc_examples')
          .listSync()
          .whereType<File>()
          .where((File f) => f.path.endsWith('.dart')),
    ];
    String squash(String text) => text.replaceAll(RegExp(r'\s+'), '');
    final String haystack = squash(
      sources.map((File f) => f.readAsStringSync()).join('\n'),
    );
    const List<String> documents = <String>[
      'README.md',
      'doc/GETTING_STARTED.md',
      'doc/THEMING.md',
      'doc/COMPONENTS.md',
      'doc/API_V1.md',
      'doc/FROSTED_SURFACES.md',
      'doc/DENSITY_AND_CONTEXT_MENUS.md',
      'doc/ACCESSIBILITY.md',
      'doc/UPGRADE_1_0_0.md',
    ];
    final RegExp fence = RegExp(r'```dart\n(.*?)```', dotAll: true);
    final List<String> missing = <String>[];
    int checked = 0;
    for (final String path in documents) {
      final File file = File(path);
      if (!file.existsSync()) {
        continue;
      }
      for (final RegExpMatch match in fence.allMatches(
        file.readAsStringSync(),
      )) {
        final String block = match.group(1)!.trim();
        // Pure imports and "Before" migration excerpts are not compilable.
        if (block.startsWith('// Before') ||
            (block.startsWith('import ') &&
                !block.contains('void main') &&
                !block.contains('class '))) {
          continue;
        }
        checked++;
        if (!haystack.contains(squash(block))) {
          missing.add('$path: ${block.split('\n').first}');
        }
      }
    }
    expect(
      missing,
      isEmpty,
      reason: 'Unverified blocks:\n${missing.join('\n')}',
    );
    expect(checked, greaterThan(0));
  });
}
