import 'dart:math' as math;

import 'package:gap/gap.dart';
import 'package:material_ui/material_ui.dart'
    show
        Align,
        Alignment,
        AlwaysScrollableScrollPhysics,
        Border,
        BorderRadius,
        BoxConstraints,
        BoxDecoration,
        BoxShape,
        BuildContext,
        Center,
        CircleBorder,
        ClipRRect,
        Color,
        ColoredBox,
        Column,
        ConstrainedBox,
        Container,
        CrossAxisAlignment,
        EdgeInsets,
        FontWeight,
        Icon,
        IconButton,
        IgnorePointer,
        InkWell,
        KeyedSubtree,
        LayoutBuilder,
        ListTile,
        ListView,
        MainAxisSize,
        Navigator,
        Padding,
        Positioned,
        RepaintBoundary,
        RoundedRectangleBorder,
        Row,
        Scaffold,
        Semantics,
        SizedBox,
        Stack,
        State,
        StatefulWidget,
        Text,
        TextStyle,
        ValueChanged,
        ValueKey,
        Widget,
        Wrap,
        WrapCrossAlignment;
import 'package:morph_expressive/morph_expressive.dart';

import 'component_catalog.dart';
import 'floating_navigation_sample.dart';

// ---------- catalogo de componentes ----------

// La galería muestra grupos amplios, sin panel lateral ni filtros obligatorios.
// Las familias se derivan del catálogo público para evitar perder widgets.
const _showcaseGroups = <String, List<String>>{
  'Buttons': [
    'buttons',
    'icon_buttons',
    'button_group',
    'split_buttons',
    'floating_action_buttons',
    'extended_fabs',
    'fab_menu',
    'toolbars',
  ],
  'Navigation': [
    'app_bars',
    'tabs',
    'navigation_bar',
    'navigation_rail',
    'navigation_drawer',
    'page_indicator',
    'search',
  ],
  'Selectors': [
    'segmented_buttons',
    'chips',
    'checkbox',
    'radio_button',
    'switch_control',
    'sliders',
    'date_pickers',
    'time_pickers',
  ],
  'Inputs': ['text_fields', 'dropdown_menus'],
  'Containers': ['cards', 'lists', 'carousel', 'bottom_sheets', 'side_sheets'],
  'Feedback': [
    'progress_indicators',
    'loading_indicator',
    'snackbar',
    'dialogs',
    'tooltips',
    'badges',
    'refresh_indicator',
    'selection',
  ],
};

/// Explorador de widgets con muestras funcionales e inventario completo.
class MorphComponentGallery extends StatefulWidget {
  const MorphComponentGallery({
    super.key,
    required this.seed,
    required this.onSeedChanged,
    this.categories,
  });

  final Color seed;
  final ValueChanged<Color> onSeedChanged;

  /// Optional subset for isolated component audits; null keeps the full gallery.
  final Set<String>? categories;

  @override
  State<MorphComponentGallery> createState() => _MorphComponentGalleryState();
}

class _MorphComponentGalleryState extends State<MorphComponentGallery> {
  String _title(String value) => value
      .split('_')
      .map((word) {
        if (word.isEmpty) return word;
        return '${word[0].toUpperCase()}${word.substring(1)}';
      })
      .join(' ');

  @override
  Widget build(BuildContext context) {
    final morph = MorphTheme.of(context);
    final scheme = morph.colorScheme;
    final available =
        morphComponentCatalog.map((entry) => entry.category).toSet()
          ..remove('foundation');
    if (widget.categories case final selected?) {
      available.retainAll(selected);
    }
    final sections = <(String, List<String>)>[];
    final placed = <String>{};
    for (final group in _showcaseGroups.entries) {
      final categories = group.value.where(available.contains).toList();
      if (categories.isEmpty) continue;
      sections.add((group.key, categories));
      placed.addAll(categories);
    }
    final extras = available.difference(placed).toList()..sort();
    if (extras.isNotEmpty) sections.add(('Others', extras));

    return LayoutBuilder(
      builder: (context, viewport) {
        // Un solo scroll lazy: cada familia tiene un ancho preferido y ocupa
        // la siguiente fila únicamente cuando ya no cabe horizontalmente.
        // No se crean subscrolls ni se montan todas las familias a la vez.
        const horizontalGap = 24.0;
        final contentWidth = math.min(
          1400.0,
          math.max(0.0, viewport.maxWidth - 48),
        );
        final rows = <(String?, List<String>)>[];
        for (final (group, categories) in sections) {
          rows.add((group, const []));
          final current = <String>[];
          var used = 0.0;
          for (final category in categories) {
            final width = math.min(
              contentWidth,
              _preferredCategoryWidth(category),
            );
            final proposed =
                used + (current.isEmpty ? 0 : horizontalGap) + width;
            if (current.isNotEmpty && proposed > contentWidth) {
              rows.add((null, List<String>.of(current)));
              current.clear();
              used = 0;
            }
            used += (current.isEmpty ? 0 : horizontalGap) + width;
            current.add(category);
          }
          if (current.isNotEmpty) rows.add((null, List<String>.of(current)));
        }

        return ListView.builder(
          key: const ValueKey('morph_showcase_scroll'),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 28),
          itemCount: rows.length + 1,
          itemBuilder: (context, index) {
            if (index == 0) {
              return Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 1400),
                  child: SizedBox(
                    width: double.infinity,
                    child: Padding(
                      padding: const EdgeInsets.only(bottom: 32),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Morph Expressive',
                            style: morph.textTheme.headlineLarge,
                          ),
                          const Gap(16),
                          _seedSelector(scheme),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            }
            final (group, categories) = rows[index - 1];
            if (group != null) {
              return Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 1400),
                  child: SizedBox(
                    width: double.infinity,
                    child: Padding(
                      padding: const EdgeInsets.only(top: 18, bottom: 24),
                      child: Text(
                        group,
                        key: ValueKey('group_${group.toLowerCase()}'),
                        style: morph.textTheme.headlineMedium,
                      ),
                    ),
                  ),
                ),
              );
            }
            return Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 1400),
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 28),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      for (var i = 0; i < categories.length; i++) ...[
                        if (i > 0) const Gap(horizontalGap),
                        SizedBox(
                          width: math.min(
                            contentWidth,
                            _preferredCategoryWidth(categories[i]),
                          ),
                          child: KeyedSubtree(
                            key: ValueKey('showcase_${categories[i]}'),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  _title(categories[i]),
                                  style: morph.textTheme.titleLarge,
                                ),
                                const Gap(14),
                                _MorphSampleFamily(category: categories[i]),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  // Anchos de las demostraciones, no columnas predeterminadas. Estos valores
  // protegen los controles amplios sin expandir artificialmente widgets
  // pequeños como switches, badges o botones flotantes.
  double _preferredCategoryWidth(String category) => switch (category) {
    'buttons' => 520,
    'icon_buttons' => 280,
    'button_group' => 500,
    'split_buttons' => 260,
    'floating_action_buttons' || 'fab_menu' => 190,
    'extended_fabs' => 260,
    'toolbars' => 520,
    'app_bars' => 600,
    'tabs' || 'navigation_bar' => 610,
    'navigation_rail' => 290,
    'navigation_drawer' => 390,
    'search' => 520,
    'segmented_buttons' => 620,
    'chips' => 600,
    'checkbox' || 'radio_button' || 'switch_control' => 230,
    'sliders' => 640,
    'date_pickers' => 390,
    'time_pickers' => 230,
    'text_fields' => 640,
    'dropdown_menus' => 470,
    'cards' => 660,
    'lists' => 560,
    'carousel' => 680,
    'bottom_sheets' || 'side_sheets' => 260,
    'progress_indicators' => 420,
    'loading_indicator' => 260,
    'snackbar' || 'dialogs' => 360,
    'tooltips' || 'badges' => 260,
    'refresh_indicator' => 440,
    'selection' => 540,
    _ => 320,
  };

  Widget _seedSelector(MorphColorScheme scheme) => Wrap(
    spacing: 12,
    runSpacing: 10,
    crossAxisAlignment: WrapCrossAlignment.center,
    children: [
      for (final (name, color) in const [
        ('Purple', Color(0xFF6750A4)),
        ('Teal', Color(0xFF006B5E)),
        ('Blue', Color(0xFF3867D6)),
      ])
        MorphTooltip(
          message: '$name seed',
          child: InkWell(
            key: ValueKey('seed_$name'),
            customBorder: const CircleBorder(),
            onTap: () => widget.onSeedChanged(color),
            child: Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: color,
                border: Border.all(
                  color: widget.seed == color
                      ? scheme.onSurface
                      : scheme.outlineVariant,
                  width: widget.seed == color ? 2.5 : 1,
                ),
              ),
              child: widget.seed == color
                  ? Icon(
                      FluentIcons.filled.checkmark,
                      color: const Color(0xFFFFFFFF),
                      size: 20,
                    )
                  : null,
            ),
          ),
        ),
    ],
  );

  // Un nombre y su muestra, sin cards ni explicaciones alrededor.
  // Muestras de ancho estable, sin tarjetas de presentación.
}

/// Each family owns its own interaction state and repaint surface.
/// Changing one sample must not rebuild all the other visible families.
class _MorphSampleFamily extends StatefulWidget {
  const _MorphSampleFamily({required this.category});

  final String category;

  @override
  State<_MorphSampleFamily> createState() => _MorphSampleFamilyState();
}

class _MorphSampleFamilyState extends State<_MorphSampleFamily> {
  bool _checked = true;
  bool _switchValue = true;
  bool _favorite = false;
  final Set<MorphChipType> _selectedChips = <MorphChipType>{};
  int _chipActions = 0;
  String _lastChipAction = 'None';
  double _rangeStart = 0.25;
  double _rangeEnd = 0.78;
  int _drawerIndex = 0;
  int _railIndex = 0;
  String _menuAction = 'None';
  String _lastSwipeAction = 'None';
  String _splitChoice = 'One';
  int _tabIndex = 0;
  int _pageIndex = 0;
  String _radioValue = 'one';
  double _sliderValue = 0.6;
  int _presses = 0;
  int? _groupSelected = 0;
  String _toggleChipSelection = 'Daily';
  Set<String> _toggleChipMultiSelection = {'Daily', 'Monthly'};
  String _mediaSelection = 'Movies';
  Set<String> _segmented = {'One'};
  List<String> _multiValues = [];
  String? _singleValue;

  @override
  Widget build(BuildContext context) => RepaintBoundary(
    child: _samples(
      MorphTheme.of(context).colorScheme,
      category: widget.category,
    ),
  );

  Widget _panel(String title, Widget content, {double? width}) => LayoutBuilder(
    builder: (context, constraints) {
      final sampleWidth = (width ?? constraints.maxWidth)
          .clamp(0.0, constraints.maxWidth)
          .toDouble();
      return SizedBox(
        width: sampleWidth,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              title,
              style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
            ),
            const Gap(12),
            content,
          ],
        ),
      );
    },
  );

  Widget _samples(MorphColorScheme scheme, {required String category}) {
    final samples = <Widget>[];
    switch (category) {
      case 'buttons':
        samples.add(
          _panel(
            'Five button styles · labels and icons',
            Wrap(
              spacing: 10,
              runSpacing: 12,
              children: [
                for (final style in MorphButtonStyle.values)
                  MorphButton(
                    style: style,
                    label: Text(style.name),
                    icon: Icon(FluentIcons.line.add, size: 20),
                    onPressed: () => setState(() => _presses++),
                  ),
                Text('Pressed $_presses times'),
              ],
            ),
          ),
        );
        break;
      case 'icon_buttons':
        samples.add(
          _panel(
            'Icon button variants',
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                for (final variant in MorphIconButtonVariant.values)
                  MorphTooltip(
                    message: variant.name,
                    child: MorphIconButton(
                      variant: variant,
                      icon: Icon(
                        _favorite
                            ? FluentIcons.filled.heart
                            : FluentIcons.line.heart,
                        size: 24,
                      ),
                      onPressed: () => setState(() => _favorite = !_favorite),
                    ),
                  ),
              ],
            ),
          ),
        );
        break;
      case 'button_group':
        samples.add(
          _panel(
            'Connected selection',
            MorphButtonGroup(
              type: MorphButtonGroupType.connected,
              overflow: MorphButtonGroupOverflow.none,
              neighborSquish: true,
              selectedIndex: _groupSelected,
              selectionRequired: true,
              onSelectedIndexChanged: (next) =>
                  setState(() => _groupSelected = next),
              actions: const [
                MorphButtonGroupAction(label: Text('Day')),
                MorphButtonGroupAction(label: Text('Week')),
                MorphButtonGroupAction(label: Text('Month')),
              ],
            ),
          ),
        );
        break;
      case 'app_bars':
        samples.add(
          _panel(
            'Centered AppBar · asymmetric actions',
            Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text('The vertical guide crosses the exact bar center'),
                const Gap(12),
                SizedBox(
                  height: 136,
                  child: Stack(
                    children: [
                      Positioned.fill(
                        child: Scaffold(
                          appBar: MorphAppBar.top(
                            titleText: 'Geometric center',
                            centerTitle: true,
                            automaticallyImplyLeading: false,
                            leading: IconButton(
                              tooltip: 'Back',
                              onPressed: () {},
                              icon: const Icon(MorphIcons.arrow_back),
                            ),
                            actions: [
                              IconButton(
                                onPressed: () {},
                                tooltip: 'Search',
                                icon: Icon(FluentIcons.line.search),
                              ),
                              IconButton(
                                onPressed: () {},
                                tooltip: 'More',
                                icon: const Icon(MorphIcons.more_vert),
                              ),
                            ],
                          ),
                          body: const Center(
                            child: Text('1 leading · 2 actions'),
                          ),
                        ),
                      ),
                      IgnorePointer(
                        child: Align(
                          alignment: Alignment.center,
                          child: Container(
                            width: 1,
                            height: double.infinity,
                            color: scheme.primary.withValues(alpha: 0.65),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const Gap(12),
                SizedBox(
                  height: 110,
                  child: Stack(
                    children: [
                      Positioned.fill(
                        child: Scaffold(
                          appBar: MorphAppBar.top(
                            titleText: 'No leading',
                            centerTitle: true,
                            automaticallyImplyLeading: false,
                            actions: [
                              IconButton(
                                onPressed: () {},
                                icon: Icon(FluentIcons.line.search),
                              ),
                            ],
                          ),
                          body: const Center(
                            child: Text('0 leading · 1 action'),
                          ),
                        ),
                      ),
                      IgnorePointer(
                        child: Align(
                          alignment: Alignment.center,
                          child: Container(
                            width: 1,
                            height: double.infinity,
                            color: scheme.primary.withValues(alpha: 0.65),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            width: 640,
          ),
        );
        break;
      case 'bottom_sheets':
        samples.add(
          _panel(
            'Modal bottom sheet',
            MorphButton(
              onPressed: () => MorphBottomSheet.show<void>(
                context,
                builder: (sheetContext) => Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Morph Bottom Sheet',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 20,
                        ),
                      ),
                      const Gap(12),
                      const Text('Drag down or press Close to dismiss.'),
                      const Gap(20),
                      MorphButton(
                        onPressed: () => Navigator.of(sheetContext).pop(),
                        label: const Text('Close'),
                      ),
                    ],
                  ),
                ),
              ),
              icon: Icon(FluentIcons.line.arrow_up),
              label: const Text('Open bottom sheet'),
            ),
          ),
        );
        break;
      case 'carousel':
        samples.add(
          _panel(
            'Contained carousel · swipe to explore',
            SizedBox(
              height: 200,
              child: MorphCarousel(
                type: MorphCarouselType.contained,
                height: 190,
                children: [
                  for (var i = 0; i < 6; i++)
                    MorphCarouselItem(
                      onTap: () {},
                      image: ColoredBox(
                        color: Color.lerp(
                          scheme.primaryContainer,
                          scheme.tertiaryContainer,
                          i / 5,
                        )!,
                        child: Center(
                          child: Text(
                            '${i + 1}',
                            style: TextStyle(
                              color: scheme.onPrimaryContainer,
                              fontSize: 38,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
            width: 700,
          ),
        );
        break;
      case 'dropdown_menus':
        samples.add(
          _panel(
            'Single selection · text only',
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                MorphDropdownMenu<String>(
                  singleSelect: true,
                  searchEnabled: true,
                  searchStyle: MorphDropdownSearchStyle(
                    searchIcon: Icon(FluentIcons.line.search, size: 23),
                    minHeight: 54,
                  ),
                  items: const [
                    MorphDropdownItem(label: 'Flutter', value: 'flutter'),
                    MorphDropdownItem(label: 'Dart', value: 'dart'),
                    MorphDropdownItem(label: 'Kotlin', value: 'kotlin'),
                  ],
                  onSelectionChanged: (items) => setState(
                    () =>
                        _singleValue = items.isEmpty ? null : items.first.label,
                  ),
                ),
                const Gap(12),
                Text('Selection: ${_singleValue ?? 'none'}'),
              ],
            ),
          ),
        );
        samples.add(
          _panel(
            'Multiple selection · removable chips',
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                MorphDropdownMenu<String>(
                  singleSelect: false,
                  searchEnabled: true,
                  searchStyle: MorphDropdownSearchStyle(
                    searchIcon: Icon(FluentIcons.line.search, size: 23),
                    minHeight: 54,
                  ),
                  items: const [
                    MorphDropdownItem(label: 'Flutter', value: 'flutter'),
                    MorphDropdownItem(label: 'Dart', value: 'dart'),
                    MorphDropdownItem(label: 'Kotlin', value: 'kotlin'),
                  ],
                  onSelectionChanged: (items) => setState(
                    () =>
                        _multiValues = items.map((item) => item.label).toList(),
                  ),
                ),
                const Gap(12),
                Text('Selections: ${_multiValues.join(', ')}'),
              ],
            ),
          ),
        );
        break;
      case 'text_fields':
        samples.add(
          _panel(
            'Rounded Morph text fields · focus to morph',
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Semantics(
                  label: 'Search for a movie',
                  child: const MorphTextField(
                    placeholder: 'Search for a movie',
                    leading: Icon(MorphIcons.search),
                    showClearButton: true,
                  ),
                ),
                const Gap(16),
                MorphTextField(
                  label: 'Email',
                  placeholder: 'name@example.com',
                  leading: Icon(FluentIcons.line.mail),
                  variant: MorphTextFieldVariant.filled,
                ),
                const Gap(16),
                const MorphTextField(
                  label: 'Email (outlined)',
                  placeholder: 'example@mail.com',
                  variant: MorphTextFieldVariant.outlined,
                  supportingText:
                      'Outlined fields use the same animated corners.',
                ),
                const Gap(16),
                const MorphTextField(
                  label: 'Message',
                  maxLines: 3,
                  variant: MorphTextFieldVariant.outlined,
                ),
                const Gap(16),
                const MorphTextField(
                  label: 'Validation · no icon (default)',
                  placeholder: 'name@example.com',
                  errorText: 'Enter a valid email address.',
                  variant: MorphTextFieldVariant.filled,
                ),
                const Gap(16),
                const MorphTextField(
                  label: 'Validation · suffix icon',
                  errorText: 'A valid email is required.',
                  errorIcon: Icon(MorphIcons.error),
                  errorIconPosition: MorphTextFieldErrorIconPosition.suffix,
                  variant: MorphTextFieldVariant.outlined,
                ),
                const Gap(16),
                const MorphTextField(
                  label: 'Validation · prefix icon',
                  errorText: 'This field is required.',
                  errorIcon: Icon(MorphIcons.error),
                  errorIconPosition: MorphTextFieldErrorIconPosition.prefix,
                  variant: MorphTextFieldVariant.filled,
                ),
                const Gap(16),
                const MorphTextField(label: 'Disabled', enabled: false),
              ],
            ),
            width: 680,
          ),
        );
        break;
      case 'checkbox':
        samples.add(
          _panel(
            'Checkbox and toggle',
            Column(
              children: [
                MorphCheckbox(
                  label: const Text('Enabled'),
                  value: _checked,
                  onChanged: (v) => setState(() => _checked = v ?? false),
                ),
                const Gap(14),
                MorphSwitch(
                  value: _switchValue,
                  onChanged: (v) => setState(() => _switchValue = v),
                ),
              ],
            ),
          ),
        );
        break;
      case 'chips':
        samples.add(
          _panel(
            'Assist / filter / input / suggestion',
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                MorphChipGroup(
                  groupLabel: 'Chip variants',
                  child: Wrap(
                    spacing: 10,
                    runSpacing: 12,
                    children: [
                      for (final type in MorphChipType.values)
                        MorphChip(
                          key: ValueKey('chip_${type.name}'),
                          label: type.name,
                          type: type,
                          selected: _selectedChips.contains(type),
                          onPressed: () => setState(() {
                            if (type == MorphChipType.filter ||
                                type == MorphChipType.input) {
                              if (!_selectedChips.add(type)) {
                                _selectedChips.remove(type);
                              }
                            } else {
                              _chipActions++;
                              _lastChipAction = type.name;
                            }
                          }),
                        ),
                    ],
                  ),
                ),
                const Gap(14),
                Text('Last action: $_lastChipAction ($_chipActions)'),
              ],
            ),
            width: 640,
          ),
        );
        samples.add(
          _panel(
            'Elevated, leading icon, and removable',
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: [
                MorphChip(
                  label: 'Elevated',
                  elevated: true,
                  leading: Icon(FluentIcons.line.star),
                  onPressed: () => setState(() => _chipActions++),
                ),
                MorphChip(
                  label: 'Input',
                  type: MorphChipType.input,
                  selected: _selectedChips.contains(MorphChipType.input),
                  onPressed: () => setState(() {
                    if (!_selectedChips.add(MorphChipType.input)) {
                      _selectedChips.remove(MorphChipType.input);
                    }
                  }),
                  onDeleted: () => setState(
                    () => _selectedChips.remove(MorphChipType.input),
                  ),
                ),
                const MorphChip(label: 'Disabled', type: MorphChipType.filter),
              ],
            ),
          ),
        );
        samples.add(
          _panel(
            'Animated chip toggle · single',
            MorphChipToggle<String>(
              options: const [
                MorphChipToggleOption(value: 'Daily', label: 'Daily'),
                MorphChipToggleOption(value: 'Weekly', label: 'Weekly'),
                MorphChipToggleOption(value: 'Monthly', label: 'Monthly'),
              ],
              selected: _toggleChipSelection,
              onChanged: (next) => setState(() => _toggleChipSelection = next),
            ),
          ),
        );
        samples.add(
          _panel(
            'Animated chip toggle · multiple',
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                MorphChipToggle<String>(
                  key: const ValueKey('morph_multi_chip_preview'),
                  multiSelection: true,
                  options: const [
                    MorphChipToggleOption(value: 'Daily', label: 'Daily'),
                    MorphChipToggleOption(value: 'Weekly', label: 'Weekly'),
                    MorphChipToggleOption(value: 'Monthly', label: 'Monthly'),
                  ],
                  selectedValues: _toggleChipMultiSelection,
                  onSelectionChanged: (values) =>
                      setState(() => _toggleChipMultiSelection = values),
                ),
                const Gap(10),
                Text('Selected: ${_toggleChipMultiSelection.join(', ')}'),
              ],
            ),
          ),
        );
        break;
      case 'segmented_buttons':
        samples.add(
          _panel(
            'Morph segmented toggle · elastic selection',
            MorphSegmentedToggle<String>(
              key: const ValueKey('morph_segmented_toggle_preview'),
              options: const [
                MorphSegmentedToggleOption(value: 'Movies', label: 'Movies'),
                MorphSegmentedToggleOption(
                  value: 'TV Shows',
                  label: 'TV Shows',
                ),
              ],
              selected: _mediaSelection,
              onChanged: (value) => setState(() => _mediaSelection = value),
            ),
            width: 680,
          ),
        );
        samples.add(
          _panel(
            'Standard segmented button',
            MorphSegmentedButton<String>(
              segments: const [
                MorphSegment(value: 'One', label: 'One'),
                MorphSegment(value: 'Two', label: 'Two'),
                MorphSegment(value: 'Three', label: 'Three'),
              ],
              selected: _segmented,
              onSelectionChanged: (selected) =>
                  setState(() => _segmented = selected),
            ),
          ),
        );
        break;
      case 'sliders':
        samples.add(
          _panel(
            'Linear, centered & wavy',
            SizedBox(
              width: 600,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Linear'),
                  const Gap(8),
                  MorphSlider(
                    value: _sliderValue,
                    label: '${(_sliderValue * 100).round()}%',
                    onChanged: (v) => setState(() => _sliderValue = v),
                  ),
                  const Gap(14),
                  const Text('Centered'),
                  const Gap(8),
                  MorphSlider.centered(
                    value: _sliderValue,
                    onChanged: (v) => setState(() => _sliderValue = v),
                  ),
                  const Gap(14),
                  const Text('Wavy'),
                  const Gap(8),
                  MorphSlider.wavy(
                    value: _sliderValue,
                    onChanged: (v) => setState(() => _sliderValue = v),
                  ),
                  const Gap(14),
                  const Text('Wavy centered'),
                  const Gap(8),
                  MorphSlider.wavyCentered(
                    value: _sliderValue,
                    onChanged: (v) => setState(() => _sliderValue = v),
                  ),
                ],
              ),
            ),
            width: 640,
          ),
        );
        samples.add(
          _panel(
            'Range and wavy range',
            SizedBox(
              width: 580,
              child: Column(
                children: [
                  MorphRangeSlider(
                    values: MorphSliderRange(_rangeStart, _rangeEnd),
                    onChanged: (range) => setState(() {
                      _rangeStart = range.start;
                      _rangeEnd = range.end;
                    }),
                  ),
                  const Gap(20),
                  MorphRangeSlider.wavy(
                    values: MorphSliderRange(_rangeStart, _rangeEnd),
                    onChanged: (range) => setState(() {
                      _rangeStart = range.start;
                      _rangeEnd = range.end;
                    }),
                  ),
                ],
              ),
            ),
            width: 640,
          ),
        );
        break;
      case 'progress_indicators':
        samples.add(
          _panel(
            'Progress and loading',
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Wrap(
                  spacing: 28,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    MorphProgressIndicator.circular(value: 0.75, size: 45),
                    MorphProgressIndicator.circularWavy(value: 0.55, size: 45),
                    MorphLoadingIndicator(size: 45),
                  ],
                ),
                Gap(24),
                Text('Linear'),
                Gap(8),
                MorphProgressIndicator.linear(
                  value: 0.65,
                  linearSize: MorphProgressIndicatorSize.s,
                ),
                Gap(18),
                Text('Wavy linear'),
                Gap(8),
                MorphProgressIndicator.linearWavy(
                  value: 0.45,
                  linearSize: MorphProgressIndicatorSize.s,
                ),
              ],
            ),
          ),
        );
        break;
      case 'tooltips':
        samples.add(
          _panel(
            'Themed tooltip shapes',
            Wrap(
              spacing: 28,
              children: [
                MorphTooltip(
                  message: 'Pill tooltip',
                  child: Icon(FluentIcons.line.info, size: 27),
                ),
                MorphTooltip(
                  message: 'Custom shape',
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(FluentIcons.line.settings, size: 27),
                ),
              ],
            ),
          ),
        );
        break;
      case 'cards':
        samples.add(
          _panel(
            'Elevated / filled / outlined',
            Wrap(
              spacing: 14,
              runSpacing: 14,
              children: [
                for (final variant in MorphCardVariant.values)
                  MorphCard(
                    key: ValueKey('card_${variant.name}'),
                    variant: variant,
                    width: 184,
                    onPressed: () => setState(() => _presses++),
                    child: Padding(
                      padding: const EdgeInsets.all(18),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(FluentIcons.line.heart, size: 24),
                          const Gap(14),
                          Text(variant.name),
                          const Gap(5),
                          const Text('Interactive surface'),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
            width: 660,
          ),
        );
        samples.add(
          _panel(
            'Structured content & group',
            MorphCardGroup(
              layout: MorphCardGroupLayout.list,
              children: [
                MorphCard(
                  variant: MorphCardVariant.filled,
                  headline: 'Headline',
                  subhead: 'Supporting subtitle',
                  supportingText: 'A card with structured slots.',
                  onPressed: () => setState(() => _presses++),
                ),
                MorphCard(
                  variant: MorphCardVariant.outlined,
                  child: const Padding(
                    padding: EdgeInsets.all(18),
                    child: Text('Grouped card with a custom child'),
                  ),
                ),
              ],
            ),
            width: 570,
          ),
        );
        break;
      case 'tabs':
        samples.add(
          _panel(
            'Morph tabs',
            MorphTabs(
              tabs: const [
                MorphTab(label: 'Home'),
                MorphTab(label: 'Explore'),
                MorphTab(label: 'Saved'),
              ],
              selectedIndex: _tabIndex,
              onTabSelected: (index) => setState(() => _tabIndex = index),
            ),
            width: 620,
          ),
        );
        samples.add(
          _panel(
            'Secondary tabs · icon and label',
            MorphTabs(
              variant: MorphTabsVariant.secondary,
              tabs: [
                MorphTab(label: 'Home', icon: Icon(FluentIcons.line.home)),
                MorphTab(
                  label: 'Discover',
                  icon: Icon(FluentIcons.line.search),
                ),
                MorphTab(
                  label: 'Favorites',
                  icon: Icon(FluentIcons.line.heart),
                ),
              ],
              selectedIndex: _tabIndex,
              onTabSelected: (index) => setState(() => _tabIndex = index),
            ),
            width: 620,
          ),
        );
        samples.add(
          _panel(
            'Swipeable tab body',
            SizedBox(
              height: 100,
              child: MorphTabsView(
                selectedIndex: _tabIndex,
                onTabSelected: (index) => setState(() => _tabIndex = index),
                children: [
                  for (final label in ['Home', 'Discover', 'Favorites'])
                    Center(child: Text('Swipe $label left or right')),
                ],
              ),
            ),
            width: 620,
          ),
        );
        break;
      case 'navigation_bar':
        samples.add(
          _panel(
            'Compact navigation',
            _IndependentNavigationSample(
              key: const ValueKey('preview_nav_compact'),
              builder: (selectedIndex, onSelected) => MorphNavigationBar(
                safeArea: false,
                autoLayout: false,
                layout: MorphNavBarLayout.compact,
                selectedIndex: selectedIndex,
                onDestinationSelected: onSelected,
                destinations: [
                  MorphNavigationBarDestination(
                    icon: Icon(FluentIcons.line.home),
                    label: 'Home',
                  ),
                  MorphNavigationBarDestination(
                    icon: Icon(FluentIcons.line.search),
                    label: 'Search',
                  ),
                  MorphNavigationBarDestination(
                    icon: Icon(FluentIcons.line.heart),
                    label: 'Saved',
                  ),
                ],
              ),
            ),
            width: 620,
          ),
        );
        samples.add(
          _panel(
            'Wide navigation · alternative indicator layout',
            _IndependentNavigationSample(
              key: const ValueKey('preview_nav_wide'),
              builder: (selectedIndex, onSelected) => MorphNavigationBar(
                safeArea: false,
                autoLayout: false,
                layout: MorphNavBarLayout.wide,
                selectedIndex: selectedIndex,
                onDestinationSelected: onSelected,
                destinations: [
                  MorphNavigationBarDestination(
                    icon: Icon(FluentIcons.line.home),
                    label: 'Home',
                  ),
                  MorphNavigationBarDestination(
                    icon: Icon(FluentIcons.line.search),
                    label: 'Search',
                  ),
                  MorphNavigationBarDestination(
                    icon: Icon(FluentIcons.line.heart),
                    label: 'Saved',
                  ),
                ],
              ),
            ),
            width: 750,
          ),
        );
        samples.add(
          _panel(
            'Morph · shared sliding pill',
            _IndependentNavigationSample(
              key: const ValueKey('preview_nav_morph_compact'),
              builder: (selectedIndex, onSelected) => MorphNavigationBar.morph(
                safeArea: false,
                autoLayout: false,
                selectedIndex: selectedIndex,
                onDestinationSelected: onSelected,
                destinations: [
                  MorphNavigationBarDestination(
                    icon: Icon(FluentIcons.line.home),
                    selectedIcon: Icon(FluentIcons.filled.home),
                    label: 'Home',
                  ),
                  MorphNavigationBarDestination(
                    icon: Icon(FluentIcons.line.bookmark),
                    label: 'Saved',
                  ),
                  MorphNavigationBarDestination(
                    icon: Icon(FluentIcons.line.person),
                    label: 'Profile',
                  ),
                ],
              ),
            ),
            width: 620,
          ),
        );
        samples.add(
          _panel(
            'Morph · wide sliding pill',
            _IndependentNavigationSample(
              key: const ValueKey('preview_nav_morph_wide'),
              builder: (selectedIndex, onSelected) => MorphNavigationBar.morph(
                safeArea: false,
                autoLayout: false,
                layout: MorphNavBarLayout.wide,
                selectedIndex: selectedIndex,
                onDestinationSelected: onSelected,
                destinations: [
                  MorphNavigationBarDestination(
                    icon: Icon(FluentIcons.line.home),
                    selectedIcon: Icon(FluentIcons.filled.home),
                    label: 'Home',
                  ),
                  MorphNavigationBarDestination(
                    icon: Icon(FluentIcons.line.bookmark),
                    label: 'Saved',
                  ),
                  MorphNavigationBarDestination(
                    icon: Icon(FluentIcons.line.person),
                    label: 'Profile',
                  ),
                ],
              ),
            ),
            width: 620,
          ),
        );
        samples.add(
          _panel(
            'Expressive · full width, top dash',
            _IndependentNavigationSample(
              key: const ValueKey('preview_nav_expressive'),
              builder: (selectedIndex, onSelected) =>
                  MorphNavigationBar.expressive(
                    safeArea: false,
                    selectedIndex: selectedIndex,
                    onDestinationSelected: onSelected,
                    destinations: [
                      MorphNavigationBarDestination(
                        icon: Icon(FluentIcons.line.home),
                        selectedIcon: Icon(FluentIcons.filled.home),
                        label: 'Home',
                      ),
                      MorphNavigationBarDestination(
                        icon: Icon(FluentIcons.line.bookmark),
                        label: 'Saved',
                      ),
                      MorphNavigationBarDestination(
                        icon: Icon(FluentIcons.line.person),
                        label: 'Profile',
                      ),
                    ],
                  ),
            ),
            width: 620,
          ),
        );
        samples.add(
          _panel(
            'Expressive · floating glass, scroll and pull to refresh',
            const SizedBox(height: 320, child: FloatingNavigationSample()),
            width: 620,
          ),
        );
        break;
      case 'page_indicator':
        samples.add(
          _panel(
            'Morph onboarding · equal pills',
            MorphPageIndicator(
              count: 3,
              selectedIndex: _pageIndex,
              activeWidth: 16,
              inactiveWidth: 16,
              effect: MorphPageIndicatorEffect.slide,
              onPageSelected: (i) => setState(() => _pageIndex = i),
            ),
          ),
        );
        samples.add(
          _panel(
            'Morph onboarding · long active capsule',
            MorphPageIndicator(
              count: 3,
              selectedIndex: _pageIndex,
              activeWidth: 40,
              inactiveWidth: 16,
              onPageSelected: (i) => setState(() => _pageIndex = i),
            ),
          ),
        );
        samples.add(
          _panel(
            'Morph onboarding · expanding dots',
            MorphPageIndicator(
              count: 3,
              selectedIndex: _pageIndex,
              activeWidth: 28,
              inactiveWidth: 10,
              height: 20,
              inactiveHeight: 10,
              onPageSelected: (i) => setState(() => _pageIndex = i),
            ),
          ),
        );
        samples.add(
          _panel(
            'Read-only page status',
            MorphPageIndicator(count: 3, selectedIndex: _pageIndex),
          ),
        );
        break;
      case 'dialogs':
        samples.add(
          _panel(
            'Modal dialog',
            MorphButton(
              onPressed: () => MorphDialog.show<void>(
                context,
                dialog: MorphDialog(
                  title: 'Morph Dialog',
                  content: const Text(
                    'A customizable Material 3 Expressive dialog.',
                  ),
                  actions: [
                    MorphButton(
                      onPressed: () => Navigator.of(context).pop(),
                      label: const Text('Close'),
                    ),
                  ],
                ),
              ),
              label: const Text('Open dialog'),
              icon: Icon(FluentIcons.line.info),
            ),
          ),
        );
        samples.add(
          _panel(
            'Full-screen and adaptive dialogs',
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                MorphButton(
                  style: MorphButtonStyle.outlined,
                  label: const Text('Full screen'),
                  onPressed: () => MorphDialog.showFullScreen<void>(
                    context,
                    title: 'Full-screen Morph Dialog',
                    body: const Padding(
                      padding: EdgeInsets.all(20),
                      child: Text(
                        'A full-screen dialog with the Morph entrance and exit.',
                      ),
                    ),
                  ),
                ),
                MorphButton(
                  style: MorphButtonStyle.outlined,
                  label: const Text('Adaptive'),
                  onPressed: () => MorphDialog.show<void>(
                    context,
                    dialog: MorphAdaptiveDialog(
                      title: 'Adaptive Morph Dialog',
                      content: const Text(
                        'Resize the screen to check its responsive layout.',
                      ),
                      confirmLabel: 'Done',
                      onConfirm: () => Navigator.of(context).pop(),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
        break;
      case 'search':
        samples.add(
          _panel(
            'Morph search bar',
            const MorphSearchBar(hintText: 'Search…'),
            width: 620,
          ),
        );
        break;
      case 'badges':
        samples.add(
          _panel(
            'Badges: notification and count',
            Wrap(
              spacing: 32,
              children: [
                MorphBadge(
                  showDot: true,
                  child: Icon(FluentIcons.line.mail, size: 28),
                ),
                MorphBadge(
                  count: 5,
                  child: Icon(FluentIcons.line.alert, size: 28),
                ),
              ],
            ),
          ),
        );
        break;
      case 'divider':
        samples.add(
          _panel(
            'Divider thickness',
            const Column(
              children: [MorphDivider(), Gap(18), MorphDivider(thickness: 2)],
            ),
          ),
        );
        break;
      case 'floating_action_buttons':
        samples.add(
          _panel(
            'Floating action button',
            MorphFab(onPressed: () {}, icon: Icon(FluentIcons.line.add)),
          ),
        );
        break;
      case 'radio_button':
        samples.add(
          _panel(
            'Radio selection',
            MorphRadio<String>(
              value: 'one',
              groupValue: _radioValue,
              label: const Text('Option one'),
              onChanged: (value) => setState(() => _radioValue = value),
            ),
          ),
        );
        break;
      case 'switch_control':
        samples.add(
          _panel(
            'Switch selection',
            MorphSwitch(
              value: _switchValue,
              onChanged: (v) => setState(() => _switchValue = v),
            ),
          ),
        );
        break;
      case 'loading_indicator':
        samples.add(
          _panel(
            'Indeterminate loading',
            Wrap(
              spacing: 30,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: const [
                MorphLoadingIndicator(size: 48),
                MorphLoadingIndicator(size: 64),
              ],
            ),
          ),
        );
        break;
      case 'date_pickers':
        samples.add(
          _panel(
            'Calendar and date picker dialog',
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(
                  width: 340,
                  child: MorphCalendarDatePicker(
                    firstDate: DateTime(2020),
                    lastDate: DateTime(2035),
                    onDateChanged: (value) =>
                        setState(() => _menuAction = '$value'),
                  ),
                ),
                const Gap(12),
                MorphButton(
                  style: MorphButtonStyle.outlined,
                  label: const Text('Open date range picker'),
                  onPressed: () => MorphDatePicker.showRange(
                    context,
                    firstDate: DateTime(2020),
                    lastDate: DateTime(2035),
                  ),
                ),
                const Gap(12),
                MorphButton(
                  label: const Text('Open date picker'),
                  onPressed: () => MorphDatePicker.show(
                    context,
                    firstDate: DateTime(2020),
                    lastDate: DateTime(2035),
                    initialDate: DateTime.now(),
                  ),
                ),
              ],
            ),
            width: 480,
          ),
        );
        break;
      case 'time_pickers':
        samples.add(
          _panel(
            'Time picker dialog',
            MorphButton(
              label: const Text('Choose time'),
              onPressed: () => MorphTimePicker.show(
                context,
                initialTime: const MorphTime(hour: 9, minute: 30),
              ),
            ),
          ),
        );
        break;
      case 'extended_fabs':
        samples.add(
          _panel(
            'Extended floating action button',
            Wrap(
              spacing: 14,
              runSpacing: 12,
              children: [
                MorphExtendedFab(
                  label: 'Compose',
                  icon: Icon(FluentIcons.line.add),
                  onPressed: () => setState(() => _presses++),
                ),
                MorphExtendedFab(
                  label: 'Compact',
                  extended: false,
                  icon: Icon(FluentIcons.line.add),
                  onPressed: () => setState(() => _presses++),
                ),
              ],
            ),
          ),
        );
        break;
      case 'fab_menu':
        samples.add(
          _panel(
            'Expandable FAB menu',
            MorphFabMenu(
              items: [
                MorphFabMenuItem(
                  icon: Icon(FluentIcons.line.add),
                  label: 'Create',
                  onPressed: () => setState(() => _presses++),
                ),
                MorphFabMenuItem(
                  icon: Icon(FluentIcons.line.heart),
                  label: 'Save',
                  onPressed: () => setState(() => _presses++),
                ),
              ],
            ),
            width: 400,
          ),
        );
        break;
      case 'lists':
        samples.add(
          _panel(
            'MorphList · rows and dividers',
            MorphList(
              itemCount: 3,
              itemBuilder: (context, index) => MorphListItem(
                headline: 'Item ${index + 1}',
                supportingText: 'Secondary text in an interactive row',
                leading: Icon(FluentIcons.line.heart),
                onTap: () => setState(() => _presses++),
              ),
            ),
            width: 560,
          ),
        );
        samples.add(
          _panel(
            'MorphList · swipe actions',
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('Swipe left/right or tap ⋮ to reveal actions'),
                const Gap(12),
                MorphList(
                  itemCount: 3,
                  itemBuilder: (context, index) => MorphListItem(
                    headline: 'Swipe item ${index + 1}',
                    supportingText: 'Reveal Morph action pills',
                    leading: const Icon(MorphIcons.star),
                    swipe: MorphListItemSwipe(
                      mode: MorphListSwipeMode.reveal,
                      leading: [
                        MorphListSwipeAction(
                          icon: const Icon(MorphIcons.star),
                          tooltip: 'Favorite',
                          onPressed: () => setState(
                            () => _lastSwipeAction =
                                'Favorited item ${index + 1}',
                          ),
                        ),
                      ],
                      trailing: [
                        MorphListSwipeAction(
                          icon: const Icon(MorphIcons.archive),
                          tooltip: 'Archive',
                          onPressed: () => setState(
                            () =>
                                _lastSwipeAction = 'Archived item ${index + 1}',
                          ),
                        ),
                        MorphListSwipeAction(
                          icon: const Icon(MorphIcons.delete),
                          tooltip: 'Delete',
                          backgroundColor: scheme.error,
                          foregroundColor: scheme.onError,
                          onPressed: () => setState(
                            () => _lastSwipeAction =
                                'Delete tapped on item ${index + 1}',
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const Gap(8),
                Text('Last action: $_lastSwipeAction'),
              ],
            ),
            width: 560,
          ),
        );
        break;
      case 'menus':
        samples.add(
          _panel(
            'Anchored Morph menu',
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                MorphMenu.entries(
                  anchorBuilder: (context, open) => MorphButton(
                    onPressed: open,
                    label: const Text('Open menu'),
                  ),
                  entries: [
                    MorphMenuEntry(
                      label: 'First',
                      onPressed: () => setState(() => _menuAction = 'First'),
                    ),
                    MorphMenuEntry(
                      label: 'Second',
                      onPressed: () => setState(() => _menuAction = 'Second'),
                    ),
                  ],
                ),
                const Gap(8),
                Text('Last action: $_menuAction'),
              ],
            ),
          ),
        );
        break;
      case 'navigation_drawer':
        samples.add(
          _panel(
            'Standard navigation drawer',
            SizedBox(
              height: 320,
              width: 310,
              child: MorphNavigationDrawer.morph(
                headline: 'Navigation',
                selectedIndex: _drawerIndex,
                onDestinationSelected: (i) => setState(() => _drawerIndex = i),
                destinations: [
                  MorphNavigationDestination(
                    label: 'Home',
                    icon: Icon(FluentIcons.line.home),
                  ),
                  MorphNavigationDestination(
                    label: 'Search',
                    icon: Icon(FluentIcons.line.search),
                  ),
                  MorphNavigationDestination(
                    label: 'Saved',
                    icon: Icon(FluentIcons.line.heart),
                  ),
                ],
              ),
            ),
            width: 380,
          ),
        );
        break;
      case 'navigation_rail':
        samples.add(
          _panel(
            'Navigation rail',
            SizedBox(
              height: 360,
              width: 280,
              child: MorphNavigationRail.morph(
                // This is an isolated demo. The neighboring swipeable tabs emit
                // horizontal ScrollNotifications through the shared observer;
                // they must not tint the rail as if its own content scrolled under.
                scrollUnder: false,
                selectedIndex: _railIndex,
                onDestinationSelected: (i) => setState(() => _railIndex = i),
                sections: [
                  MorphNavigationRailSection(
                    destinations: [
                      MorphNavigationRailDestination(
                        label: 'Home',
                        icon: Icon(FluentIcons.line.home),
                      ),
                      MorphNavigationRailDestination(
                        label: 'Search',
                        icon: Icon(FluentIcons.line.search),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            width: 360,
          ),
        );
        break;
      case 'refresh_indicator':
        samples.add(
          _panel(
            'Pull-to-refresh',
            SizedBox(
              height: 250,
              width: 420,
              child: MorphRefreshIndicator(
                onRefresh: () async {
                  if (mounted) setState(() => _presses++);
                },
                child: ListView.builder(
                  physics: const AlwaysScrollableScrollPhysics(),
                  itemCount: 12,
                  itemBuilder: (_, i) =>
                      ListTile(title: Text('Refresh item ${i + 1}')),
                ),
              ),
            ),
          ),
        );
        break;
      case 'selection':
        samples.add(
          _panel(
            'Selection host & contextual bar',
            ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: ColoredBox(
                color: scheme.surfaceContainer,
                child: SizedBox(
                  key: const ValueKey('selection_preview_host'),
                  height: 360,
                  width: 520,
                  child: MorphSelection(
                    scaffold: false,
                    itemCount: 3,
                    appBar: MorphSelectionAppBar(
                      idle: const Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: 18,
                          vertical: 20,
                        ),
                        child: Text('Select rows below'),
                      ),
                    ),
                    // La lista desplaza su contenido si cambian las fuentes o
                    // aumenta la altura de la barra de selección contextual.
                    body: Padding(
                      padding: const EdgeInsets.all(12),
                      child: MorphList.scrollable(
                        itemCount: 3,
                        selection: true,
                        itemBuilder: (_, i) =>
                            MorphListItem(headline: 'Selectable item ${i + 1}'),
                      ),
                    ),
                  ),
                ),
              ),
            ),
            width: 560,
          ),
        );
        break;
      case 'side_sheets':
        samples.add(
          _panel(
            'Side sheet',
            MorphButton(
              label: const Text('Open side sheet'),
              onPressed: () => MorphSideSheet.show(
                context,
                title: 'Morph Side Sheet',
                body: const Padding(
                  padding: EdgeInsets.all(20),
                  child: Text('Editable secondary content'),
                ),
              ),
            ),
          ),
        );
        break;
      case 'snackbar':
        samples.add(
          _panel(
            'Snackbar notifications',
            Wrap(
              spacing: 10,
              children: [
                MorphButton(
                  label: const Text('Show snackbar'),
                  onPressed: () => MorphSnackbar.show(
                    context,
                    message: 'Saved successfully',
                  ),
                ),
                MorphButton(
                  style: MorphButtonStyle.outlined,
                  label: const Text('With action'),
                  onPressed: () => MorphSnackbar.show(
                    context,
                    message: 'Item archived',
                    actionLabel: 'Undo',
                    onAction: () => setState(() => _presses++),
                  ),
                ),
                MorphButton(
                  style: MorphButtonStyle.tonal,
                  label: const Text('Swipe to dismiss'),
                  onPressed: () => MorphSnackbar.show(
                    context,
                    message: 'Swipe horizontally to dismiss',
                    showCloseButton: true,
                    swipeDismissible: true,
                  ),
                ),
              ],
            ),
          ),
        );
        break;
      case 'split_buttons':
        samples.add(
          _panel(
            'Split button · menu',
            MorphSplitButton<String>(
              label: 'Choose',
              items: const [
                MorphSplitButtonItem(value: 'One', child: Text('One')),
                MorphSplitButtonItem(value: 'Two', child: Text('Two')),
              ],
              selectedValue: _splitChoice,
              onSelected: (value) => setState(() => _splitChoice = value),
            ),
          ),
        );
        break;
      case 'toolbars':
        samples.add(
          _panel(
            'Docked & floating toolbar',
            Column(
              children: [
                MorphToolbar(
                  titleText: 'Morph Toolbar',
                  onFabPressed: () => setState(() => _presses++),
                ),
                const Gap(12),
                MorphToolbar.floating(titleText: 'Floating toolbar'),
              ],
            ),
            width: 620,
          ),
        );
        break;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (samples.isEmpty)
          _panel(
            'No live sample yet',
            Text(
              'Example pending.',
              style: TextStyle(color: scheme.onSurfaceVariant),
            ),
          ),
        for (var i = 0; i < samples.length; i++) ...[
          if (i != 0) const Gap(18),
          samples[i],
        ],
      ],
    );
  }
}

/// Isolates the selected tab of each navigation variant. In particular,
/// clicking one bar no longer simultaneously starts four other animations.
class _IndependentNavigationSample extends StatefulWidget {
  const _IndependentNavigationSample({required this.builder, super.key});

  final Widget Function(int selectedIndex, ValueChanged<int> onSelected)
  builder;

  @override
  State<_IndependentNavigationSample> createState() =>
      _IndependentNavigationSampleState();
}

class _IndependentNavigationSampleState
    extends State<_IndependentNavigationSample> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) => RepaintBoundary(
    child: widget.builder(_selectedIndex, (next) {
      if (next != _selectedIndex) setState(() => _selectedIndex = next);
    }),
  );
}
