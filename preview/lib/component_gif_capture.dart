import 'dart:async';

import 'package:material_ui/material_ui.dart'
    show
        Align,
        Alignment,
        AnimatedSwitcher,
        BuildContext,
        Color,
        Column,
        CrossAxisAlignment,
        Curves,
        FocusNode,
        Icon,
        MaterialApp,
        Navigator,
        Positioned,
        Row,
        Scaffold,
        SizedBox,
        Stack,
        State,
        StatefulWidget,
        StatelessWidget,
        Text,
        TextEditingController,
        TextStyle,
        ValueKey,
        VoidCallback,
        Widget,
        WidgetsBinding,
        Wrap,
        WrapCrossAlignment;
import 'package:morph_expressive/morph_expressive.dart';

/// Escenas aisladas para generar los GIFs del README con Playwright.
///
/// Ejemplo: /?capture=dropdown&theme=teal&delayMs=950
/// Cada escena ejecuta las transiciones desde Flutter, sin clicks ni cursor.
class MorphGifCaptureApp extends StatelessWidget {
  const MorphGifCaptureApp({required this.scene, super.key});

  final String scene;

  static const Map<String, Color> _captureSeeds = {
    'purple': Color(0xFF6750A4),
    'teal': Color(0xFF006B5E),
    'blue': Color(0xFF3867D6),
  };

  @override
  Widget build(BuildContext context) {
    final themeName = Uri.base.queryParameters['theme'] ?? 'purple';
    final seed = _captureSeeds[themeName] ?? const Color(0xFF6750A4);
    final theme = MorphThemeData.dark(seedColor: seed);
    return MaterialApp(
      title: 'Morph Expressive — $scene',
      debugShowCheckedModeBanner: false,
      theme: theme.toThemeData(),
      builder: (context, child) =>
          MorphTheme(data: theme, child: child ?? const SizedBox.shrink()),
      home: Scaffold(
        backgroundColor: theme.colorScheme.surface,
        body: _CaptureScene(scene: scene),
      ),
    );
  }
}

class _CaptureScene extends StatefulWidget {
  const _CaptureScene({required this.scene});

  final String scene;

  @override
  State<_CaptureScene> createState() => _CaptureSceneState();
}

class _CaptureSceneState extends State<_CaptureScene> {
  final List<Timer> _timers = [];
  final MorphDropdownController<String> _dropdown =
      MorphDropdownController<String>();
  final TextEditingController _search = TextEditingController();
  final TextEditingController _email = TextEditingController();
  final TextEditingController _filled = TextEditingController();
  final MorphDismissibleListController _listController =
      MorphDismissibleListController();
  final FocusNode _searchFocus = FocusNode();
  final FocusNode _emailFocus = FocusNode();
  final FocusNode _filledFocus = FocusNode();

  bool _buttonSelected = false;
  bool _favorite = false;
  String _segment = 'Movies';
  String _chipToggle = 'Daily';
  Set<String> _chipMulti = <String>{};
  int? _groupSelected = 0;
  bool _filterSelected = false;
  bool _inputSelected = false;
  double _sliderValue = 0.28;
  double _progressValue = 0.32;
  bool _showContainedLoaders = false;
  int _navigationIndex = 0;
  int _expressiveNavigationIndex = 0;
  int _morphNavigationIndex = 0;
  int _pageIndex = 0;
  int _railIndex = 0;
  int _drawerIndex = 0;

  int get _delayMs {
    final raw = int.tryParse(Uri.base.queryParameters['delayMs'] ?? '800');
    return (raw ?? 800).clamp(250, 10000);
  }

  void _at(int offsetMs, VoidCallback action) {
    _timers.add(
      Timer(Duration(milliseconds: _delayMs + offsetMs), () {
        if (mounted) action();
      }),
    );
  }

  // Enter text a character at a time so the focus/label transition is visible
  // in the exported GIF rather than jumping to the final value in one frame.
  void _typeForCapture(
    TextEditingController controller,
    String text, {
    required int startMs,
    int letterDelayMs = 46,
  }) {
    for (var i = 1; i <= text.length; i++) {
      final value = text.substring(0, i);
      _at(startMs + (i - 1) * letterDelayMs, () => controller.text = value);
    }
  }

  // Keep the multi selector externally controlled, exactly like the gallery.
  void _addMultiChip(String value) => setState(() {
    _chipMulti = <String>{..._chipMulti, value};
  });

  void _removeMultiChip(String value) => setState(() {
    _chipMulti = <String>{..._chipMulti}..remove(value);
  });

  void _scheduleDoubleSequence(
    List<double> values, {
    required void Function(double value) apply,
    int startMs = 0,
    int stepMs = 180,
  }) {
    for (var i = 0; i < values.length; i++) {
      _at(startMs + (i * stepMs), () => setState(() => apply(values[i])));
    }
  }

  void _scheduleLoop({
    required int cycleMs,
    required int cycles,
    required List<({int atMs, VoidCallback action})> events,
  }) {
    for (var cycle = 0; cycle < cycles; cycle++) {
      final baseMs = cycle * cycleMs;
      for (final event in events) {
        _at(baseMs + event.atMs, event.action);
      }
    }
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      switch (widget.scene) {
        case 'buttons':
          _scheduleLoop(
            cycleMs: 2200,
            cycles: 2,
            events: [
              (atMs: 0, action: () => setState(() => _buttonSelected = true)),
              (atMs: 420, action: () => setState(() => _favorite = true)),
              (
                atMs: 960,
                action: () => setState(() => _buttonSelected = false),
              ),
              (atMs: 1500, action: () => setState(() => _favorite = false)),
            ],
          );
        case 'dropdown':
          _scheduleLoop(
            cycleMs: 2200,
            cycles: 2,
            events: [
              (atMs: 0, action: _dropdown.openDropdown),
              (atMs: 680, action: _dropdown.closeDropdown),
              (atMs: 1140, action: _dropdown.openDropdown),
              (atMs: 1820, action: _dropdown.closeDropdown),
            ],
          );
        case 'segmented':
          _scheduleLoop(
            cycleMs: 2200,
            cycles: 2,
            events: [
              (
                atMs: 0,
                action: () => setState(() {
                  _segment = 'TV Shows';
                  _groupSelected = 1;
                }),
              ),
              (
                atMs: 560,
                action: () => setState(() {
                  _segment = 'Movies';
                  _groupSelected = 2;
                }),
              ),
              (
                atMs: 1120,
                action: () => setState(() {
                  _segment = 'TV Shows';
                  _groupSelected = 0;
                }),
              ),
              (
                atMs: 1680,
                action: () => setState(() {
                  _segment = 'Movies';
                  _groupSelected = 0;
                }),
              ),
            ],
          );
        case 'textfields':
          // Show the existing search and outlined fields, then the new filled
          // label transition: focus -> type -> blur (label stays outside) -> clear.
          // This scene needs a longer recording than the other components.
          _typeForCapture(_filled, 'hello@morph.dev', startMs: 3320);
          _typeForCapture(
            _filled,
            'morph@flutter.dev',
            startMs: 6450,
            letterDelayMs: 40,
          );
          for (final event in <({int atMs, VoidCallback action})>[
            (atMs: 0, action: _searchFocus.requestFocus),
            (atMs: 300, action: () => _search.text = 'Morph Expressive'),
            (atMs: 1050, action: _search.clear),
            (atMs: 1250, action: _emailFocus.requestFocus),
            (atMs: 1570, action: () => _email.text = 'hello@morph.dev'),
            (atMs: 2250, action: _emailFocus.unfocus),
            (atMs: 2670, action: _filledFocus.requestFocus),
            (atMs: 4430, action: _filledFocus.unfocus),
            (atMs: 5580, action: _filled.clear),
            (atMs: 5970, action: _filledFocus.requestFocus),
            (atMs: 7420, action: _filledFocus.unfocus),
          ]) {
            _at(event.atMs, event.action);
          }
        case 'chips':
          // Material 3 Expressive chips + moving single + independent multi.
          // Multi: 0->1 bloom, 1->2->3 borrowed-pill morph, 3->2->1
          // fusion, 1->0 bloom, then replay both behaviors for visibility.
          for (final event in <({int atMs, VoidCallback action})>[
            (
              atMs: 0,
              action: () => setState(() {
                _filterSelected = true;
                _chipToggle = 'Weekly';
              }),
            ),
            (atMs: 620, action: () => _addMultiChip('Daily')),
            (atMs: 1150, action: () => setState(() => _chipToggle = 'Monthly')),
            (atMs: 1460, action: () => _addMultiChip('Weekly')),
            (atMs: 2020, action: () => setState(() => _inputSelected = true)),
            (atMs: 2280, action: () => _addMultiChip('Monthly')),
            (atMs: 2860, action: () => setState(() => _chipToggle = 'Daily')),
            (atMs: 3150, action: () => _removeMultiChip('Weekly')),
            (atMs: 3820, action: () => _removeMultiChip('Monthly')),
            (atMs: 4480, action: () => _removeMultiChip('Daily')),
            (atMs: 5150, action: () => _addMultiChip('Monthly')),
            (atMs: 5810, action: () => _addMultiChip('Daily')),
            (atMs: 6250, action: () => setState(() => _chipToggle = 'Weekly')),
            (atMs: 6450, action: () => _removeMultiChip('Monthly')),
            (atMs: 6980, action: () => _removeMultiChip('Daily')),
            (atMs: 7490, action: () => _addMultiChip('Daily')),
            (
              atMs: 7850,
              action: () => setState(() {
                _filterSelected = false;
                _inputSelected = false;
                _chipToggle = 'Daily';
              }),
            ),
          ]) {
            _at(event.atMs, event.action);
          }
        case 'dialogs':
          // Capture MorphDialog's own animated route transition and scrim.
          for (final event in <({int atMs, VoidCallback action})>[
            (atMs: 250, action: _showCaptureDialog),
            (atMs: 1900, action: () => Navigator.of(context).maybePop()),
            (atMs: 3100, action: _showCaptureDialog),
            (atMs: 4750, action: () => Navigator.of(context).maybePop()),
          ]) {
            _at(event.atMs, event.action);
          }
        case 'lists':
          _scheduleLoop(
            cycleMs: 2800,
            cycles: 2,
            events: [
              (
                atMs: 360,
                action: () => _listController.reveal(1, leading: false),
              ),
              (atMs: 1540, action: _listController.close),
              (
                atMs: 1940,
                action: () => _listController.reveal(2, leading: true),
              ),
              (atMs: 2440, action: _listController.close),
            ],
          );
        case 'sliders':
          // Slow down near the upper threshold to make the 90–98% smoothstep
          // flattening clearly visible on both wavy slider variants.
          _scheduleDoubleSequence(
            const [
              0.52,
              0.72,
              0.86,
              0.90,
              0.91,
              0.92,
              0.93,
              0.94,
              0.95,
              0.96,
              0.97,
              0.98,
              1.00,
              0.98,
              0.97,
              0.96,
              0.95,
              0.94,
              0.93,
              0.92,
              0.91,
              0.90,
              0.85,
              0.65,
              0.50,
              0.72,
              0.88,
              0.90,
              0.92,
              0.94,
              0.96,
              0.98,
            ],
            apply: (value) => _sliderValue = value,
            stepMs: 178,
          );
        case 'navigation':
          _scheduleLoop(
            cycleMs: 2200,
            cycles: 2,
            events: [
              (atMs: 0, action: () => setState(() => _navigationIndex = 1)),
              (atMs: 520, action: () => setState(() => _navigationIndex = 2)),
              (atMs: 1040, action: () => setState(() => _navigationIndex = 1)),
              (atMs: 1560, action: () => setState(() => _navigationIndex = 0)),
            ],
          );
        case 'navigation_morph':
          _scheduleLoop(
            cycleMs: 3300,
            cycles: 2,
            events: [
              (
                atMs: 0,
                action: () => setState(() => _expressiveNavigationIndex = 1),
              ),
              (
                atMs: 350,
                action: () => setState(() => _morphNavigationIndex = 2),
              ),
              (atMs: 740, action: () => setState(() => _pageIndex = 1)),
              (
                atMs: 1100,
                action: () => setState(() => _expressiveNavigationIndex = 2),
              ),
              (
                atMs: 1450,
                action: () => setState(() => _morphNavigationIndex = 1),
              ),
              (atMs: 1830, action: () => setState(() => _pageIndex = 3)),
              (
                atMs: 2250,
                action: () => setState(() => _expressiveNavigationIndex = 0),
              ),
              (
                atMs: 2640,
                action: () => setState(() => _morphNavigationIndex = 0),
              ),
              (atMs: 2960, action: () => setState(() => _pageIndex = 0)),
            ],
          );
        case 'navigation_rail_drawer':
          _scheduleLoop(
            cycleMs: 3000,
            cycles: 2,
            events: [
              (atMs: 0, action: () => setState(() => _railIndex = 1)),
              (atMs: 470, action: () => setState(() => _drawerIndex = 2)),
              (atMs: 950, action: () => setState(() => _railIndex = 2)),
              (atMs: 1470, action: () => setState(() => _drawerIndex = 1)),
              (atMs: 2010, action: () => setState(() => _railIndex = 0)),
              (atMs: 2460, action: () => setState(() => _drawerIndex = 0)),
            ],
          );
        case 'loading':
          // Both determinate wavy indicators now sweep all the way through
          // the 90–98% envelope instead of topping out around 70%.
          _scheduleDoubleSequence(
            const [
              0.50,
              0.70,
              0.87,
              0.90,
              0.91,
              0.92,
              0.93,
              0.94,
              0.95,
              0.96,
              0.97,
              0.98,
              1.00,
              0.98,
              0.97,
              0.96,
              0.95,
              0.94,
              0.93,
              0.92,
              0.91,
              0.90,
              0.80,
              0.60,
              0.75,
              0.88,
              0.90,
              0.92,
              0.94,
              0.96,
              0.98,
            ],
            apply: (value) => _progressValue = value,
            stepMs: 180,
          );
          _scheduleLoop(
            cycleMs: 2300,
            cycles: 3,
            events: [
              (
                atMs: 720,
                action: () => setState(() => _showContainedLoaders = true),
              ),
              (
                atMs: 1540,
                action: () => setState(() => _showContainedLoaders = false),
              ),
            ],
          );
      }
    });
  }

  void _showCaptureDialog() {
    MorphDialog.show<void>(
      context,
      dialog: MorphDialog(
        title: 'Save your changes?',
        icon: Icon(FluentIcons.line.info),
        content: const Text('Your edits will be saved to the current project.'),
        actions: <Widget>[
          MorphButton(
            style: MorphButtonStyle.text,
            label: const Text('Cancel'),
            onPressed: () => Navigator.of(context).pop(),
          ),
          MorphButton(
            label: const Text('Save'),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    for (final timer in _timers) {
      timer.cancel();
    }
    _dropdown.dispose();
    _search.dispose();
    _email.dispose();
    _filled.dispose();
    _searchFocus.dispose();
    _emailFocus.dispose();
    _filledFocus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final morph = MorphTheme.of(context);
    final scheme = morph.colorScheme;
    final (title, subtitle) = switch (widget.scene) {
      'buttons' => ('Buttons', 'Expressive actions and selection'),
      'dropdown' => ('Dropdown', 'Spring-powered expand and collapse'),
      'segmented' => ('Segmented toggle', 'Elastic selection indicator'),
      'textfields' => (
        'Text fields',
        'Search, outlined and animated filled labels',
      ),
      'chips' => ('Chips', 'M3 Expressive, single and multi-selection'),
      'sliders' => ('Sliders', 'Linear and animated wavy tracks'),
      'loading' => (
        'Progress + loading',
        'Progress indicators and expressive loaders',
      ),
      'navigation' => ('Navigation', 'Compact and wide layouts'),
      'navigation_morph' => (
        'Morph navigation',
        'Elastic selection, expressive dash and page indicators',
      ),
      'navigation_rail_drawer' => (
        'Navigation rail + drawer',
        'Shared Morph selection in vertical navigation',
      ),
      'lists' => ('MorphList', 'Swipe to reveal expressive actions'),
      'dialogs' => ('Floating dialogs', 'Expressive modal entrances and exits'),
      _ => ('Morph Expressive', 'Component capture'),
    };

    return Stack(
      key: ValueKey('morph_gif_${widget.scene}'),
      children: [
        Positioned(
          top: 28,
          left: 34,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: morph.textTheme.headlineMedium),
              const SizedBox(height: 6),
              Text(
                subtitle,
                style: (morph.textTheme.bodyMedium ?? const TextStyle())
                    .copyWith(color: scheme.onSurfaceVariant),
              ),
            ],
          ),
        ),
        Positioned(
          top: widget.scene == 'dropdown' ? 104 : 137,
          left: 34,
          child: SizedBox(
            width: 572,
            child: Align(alignment: Alignment.topLeft, child: _content()),
          ),
        ),
        Positioned(
          bottom: 19,
          right: 30,
          child: Text(
            'MORPH EXPRESSIVE',
            style: (morph.textTheme.labelSmall ?? const TextStyle()).copyWith(
              color: scheme.onSurfaceVariant,
              letterSpacing: 2,
            ),
          ),
        ),
      ],
    );
  }

  Widget _captureLabel(String label) {
    final theme = MorphTheme.of(context);
    return Text(
      label,
      style: (theme.textTheme.labelMedium ?? const TextStyle()).copyWith(
        color: theme.colorScheme.onSurfaceVariant,
        letterSpacing: 0.3,
      ),
    );
  }

  Widget _content() => switch (widget.scene) {
    'buttons' => Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Wrap(
          spacing: 12,
          runSpacing: 16,
          children: [
            MorphButton(
              onPressed: () =>
                  setState(() => _buttonSelected = !_buttonSelected),
              isSelected: _buttonSelected,
              label: const Text('Select'),
              selectedLabel: const Text('Selected'),
              icon: const Icon(MorphIcons.check),
            ),
            MorphButton(
              onPressed: () {},
              style: MorphButtonStyle.outlined,
              label: const Text('Outlined'),
              icon: const Icon(MorphIcons.add),
            ),
            MorphButton(
              onPressed: () {},
              style: MorphButtonStyle.tonal,
              label: const Text('Tonal'),
            ),
          ],
        ),
        const SizedBox(height: 30),
        Row(
          children: [
            MorphIconButton(
              variant: MorphIconButtonVariant.filled,
              icon: Icon(
                _favorite ? MorphIcons.favorite : MorphIcons.favorite_border,
              ),
              onPressed: () => setState(() => _favorite = !_favorite),
            ),
            const SizedBox(width: 14),
            MorphButton(
              onPressed: () {},
              style: MorphButtonStyle.text,
              label: const Text('Text button'),
            ),
          ],
        ),
      ],
    ),
    'dropdown' => SizedBox(
      width: 360,
      child: MorphDropdownMenu<String>(
        controller: _dropdown,
        singleSelect: true,
        fieldStyle: const MorphDropdownFieldStyle(
          hintText: 'Choose a framework',
        ),
        items: const [
          MorphDropdownItem(label: 'Flutter', value: 'flutter'),
          MorphDropdownItem(label: 'Kotlin', value: 'kotlin'),
          MorphDropdownItem(label: 'Swift', value: 'swift'),
        ],
      ),
    ),
    'segmented' => SizedBox(
      width: 520,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          MorphSegmentedToggle<String>(
            options: const [
              MorphSegmentedToggleOption(value: 'Movies', label: 'Movies'),
              MorphSegmentedToggleOption(value: 'TV Shows', label: 'TV Shows'),
            ],
            selected: _segment,
            onChanged: (value) => setState(() => _segment = value),
          ),
          const SizedBox(height: 26),
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
        ],
      ),
    ),
    'textfields' => SizedBox(
      width: 535,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _captureLabel('Search'),
          const SizedBox(height: 8),
          MorphTextField(
            key: const ValueKey('gif_textfield_search'),
            controller: _search,
            focusNode: _searchFocus,
            placeholder: 'Search for a movie',
            leading: const Icon(MorphIcons.search),
            showClearButton: true,
          ),
          const SizedBox(height: 18),
          _captureLabel('Outlined'),
          const SizedBox(height: 8),
          MorphTextField(
            key: const ValueKey('gif_textfield_outlined'),
            controller: _email,
            focusNode: _emailFocus,
            label: 'Email',
            placeholder: 'hello@example.com',
            variant: MorphTextFieldVariant.outlined,
          ),
          const SizedBox(height: 26),
          _captureLabel('Filled · floating label'),
          const SizedBox(height: 8),
          MorphTextField(
            key: const ValueKey('gif_textfield_filled'),
            controller: _filled,
            focusNode: _filledFocus,
            label: 'Email address',
            placeholder: 'name@example.com',
            leading: Icon(FluentIcons.line.mail),
            variant: MorphTextFieldVariant.filled,
          ),
        ],
      ),
    ),
    'dialogs' => SizedBox(
      width: 560,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 12),
          const Text('A rounded modal dialog with a spring entrance.'),
          const SizedBox(height: 18),
          MorphButton(
            label: const Text('Open floating dialog'),
            icon: Icon(FluentIcons.line.info),
            onPressed: _showCaptureDialog,
          ),
        ],
      ),
    ),
    'lists' => SizedBox(
      width: 560,
      child: MorphList(
        dismissController: _listController,
        itemCount: 3,
        itemBuilder: (context, index) => MorphListItem(
          headline: index == 0 ? 'Regular item' : 'Swipe item $index',
          supportingText: index == 0
              ? 'Standard MorphList row'
              : 'Reveal Morph action pills',
          leading: const Icon(MorphIcons.star),
          swipe: index == 0
              ? null
              : MorphListItemSwipe(
                  mode: MorphListSwipeMode.reveal,
                  leading: [
                    MorphListSwipeAction(
                      icon: const Icon(MorphIcons.star),
                      tooltip: 'Favorite',
                      onPressed: () {},
                    ),
                  ],
                  trailing: [
                    MorphListSwipeAction(
                      icon: const Icon(MorphIcons.archive),
                      tooltip: 'Archive',
                      onPressed: () {},
                    ),
                    MorphListSwipeAction(
                      icon: const Icon(MorphIcons.delete),
                      tooltip: 'Delete',
                      backgroundColor: MorphTheme.of(context).colorScheme.error,
                      foregroundColor: MorphTheme.of(context)
                          .colorScheme
                          .onError,
                      onPressed: () {},
                    ),
                  ],
                ),
        ),
      ),
    ),
    'chips' => Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _captureLabel('Material 3 Expressive · filter, input, assist'),
        const SizedBox(height: 10),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: [
            MorphChip(
              label: 'Filter',
              type: MorphChipType.filter,
              selected: _filterSelected,
              onPressed: () =>
                  setState(() => _filterSelected = !_filterSelected),
            ),
            MorphChip(
              label: 'Input',
              type: MorphChipType.input,
              selected: _inputSelected,
              onPressed: () => setState(() => _inputSelected = !_inputSelected),
            ),
            MorphChip(label: 'Assist', onPressed: () {}),
          ],
        ),
        const SizedBox(height: 20),
        _captureLabel('Morph expressive · single'),
        const SizedBox(height: 10),
        MorphChipToggle<String>(
          key: const ValueKey('gif_chips_single'),
          options: const [
            MorphChipToggleOption(value: 'Daily', label: 'Daily'),
            MorphChipToggleOption(value: 'Weekly', label: 'Weekly'),
            MorphChipToggleOption(value: 'Monthly', label: 'Monthly'),
          ],
          selected: _chipToggle,
          onChanged: (value) => setState(() => _chipToggle = value),
        ),
        const SizedBox(height: 20),
        _captureLabel('Morph expressive · multiple'),
        const SizedBox(height: 10),
        MorphChipToggle<String>(
          key: const ValueKey('gif_chips_multi'),
          multiSelection: true,
          options: const [
            MorphChipToggleOption(value: 'Daily', label: 'Daily'),
            MorphChipToggleOption(value: 'Weekly', label: 'Weekly'),
            MorphChipToggleOption(value: 'Monthly', label: 'Monthly'),
          ],
          selectedValues: _chipMulti,
          onSelectionChanged: (values) => setState(() => _chipMulti = values),
        ),
      ],
    ),
    'sliders' => SizedBox(
      width: 550,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Linear'),
          const SizedBox(height: 6),
          MorphSlider(
            value: _sliderValue,
            onChanged: (value) => setState(() => _sliderValue = value),
          ),
          const SizedBox(height: 26),
          const Text('Wavy'),
          const SizedBox(height: 6),
          MorphSlider.wavy(
            value: _sliderValue,
            onChanged: (value) => setState(() => _sliderValue = value),
          ),
          const SizedBox(height: 18),
          const Text('Wavy range'),
          const SizedBox(height: 6),
          MorphRangeSlider.wavy(
            values: MorphSliderRange(0.0, _sliderValue),
            onChanged: (range) => setState(() => _sliderValue = range.end),
          ),
        ],
      ),
    ),
    'navigation' => SizedBox(
      width: 560,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 520,
            child: MorphNavigationBar(
              safeArea: false,
              autoLayout: false,
              layout: MorphNavBarLayout.compact,
              selectedIndex: _navigationIndex,
              onDestinationSelected: (index) =>
                  setState(() => _navigationIndex = index),
              destinations: const [
                MorphNavigationBarDestination(
                  icon: MorphIcons.home,
                  label: 'Home',
                ),
                MorphNavigationBarDestination(
                  icon: MorphIcons.search,
                  label: 'Search',
                ),
                MorphNavigationBarDestination(
                  icon: MorphIcons.favorite_border,
                  label: 'Saved',
                ),
              ],
            ),
          ),
          const SizedBox(height: 22),
          SizedBox(
            width: 520,
            child: MorphNavigationBar(
              safeArea: false,
              autoLayout: false,
              layout: MorphNavBarLayout.wide,
              selectedIndex: _navigationIndex,
              onDestinationSelected: (index) =>
                  setState(() => _navigationIndex = index),
              destinations: const [
                MorphNavigationBarDestination(
                  icon: MorphIcons.home,
                  label: 'Home',
                ),
                MorphNavigationBarDestination(
                  icon: MorphIcons.search,
                  label: 'Search',
                ),
                MorphNavigationBarDestination(
                  icon: MorphIcons.favorite_border,
                  label: 'Saved',
                ),
              ],
            ),
          ),
        ],
      ),
    ),
    'navigation_morph' => SizedBox(
      width: 560,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _captureLabel('Expressive bar · shared elastic selection'),
          const SizedBox(height: 6),
          SizedBox(
            width: 520,
            child: MorphNavigationBar.expressive(
              key: const ValueKey('gif_navigation_expressive_bar'),
              safeArea: false,
              autoLayout: false,
              selectedIndex: _expressiveNavigationIndex,
              onDestinationSelected: (index) =>
                  setState(() => _expressiveNavigationIndex = index),
              destinations: const [
                MorphNavigationBarDestination(
                  icon: MorphIcons.home,
                  label: 'Home',
                ),
                MorphNavigationBarDestination(
                  icon: MorphIcons.search,
                  label: 'Search',
                ),
                MorphNavigationBarDestination(
                  icon: MorphIcons.favorite_border,
                  label: 'Saved',
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          _captureLabel('Morph bar · sliding top indicator'),
          const SizedBox(height: 6),
          SizedBox(
            width: 520,
            child: MorphNavigationBar.morph(
              key: const ValueKey('gif_navigation_morph_bar'),
              safeArea: false,
              iconSize: 32,
              unselectedIconScale: 0.9,
              selectedIndex: _morphNavigationIndex,
              onDestinationSelected: (index) =>
                  setState(() => _morphNavigationIndex = index),
              destinations: const [
                MorphNavigationBarDestination(
                  icon: MorphIcons.home,
                  label: 'Home',
                ),
                MorphNavigationBarDestination(
                  icon: MorphIcons.search,
                  label: 'Search',
                ),
                MorphNavigationBarDestination(
                  icon: MorphIcons.favorite_border,
                  label: 'Saved',
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          _captureLabel('Page indicator · expand / slide'),
          const SizedBox(height: 5),
          Row(
            children: [
              MorphPageIndicator(
                key: const ValueKey('gif_page_expand'),
                count: 4,
                selectedIndex: _pageIndex,
                activeWidth: 34,
                inactiveWidth: 12,
                height: 14,
                inactiveHeight: 12,
                spacing: 4,
              ),
              const SizedBox(width: 34),
              MorphPageIndicator(
                key: const ValueKey('gif_page_slide'),
                count: 4,
                selectedIndex: _pageIndex,
                effect: MorphPageIndicatorEffect.slide,
                activeWidth: 26,
                inactiveWidth: 12,
                height: 12,
                spacing: 5,
              ),
            ],
          ),
        ],
      ),
    ),
    'navigation_rail_drawer' => SizedBox(
      width: 560,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 232,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _captureLabel('Morph rail'),
                const SizedBox(height: 8),
                SizedBox(
                  width: 226,
                  height: 298,
                  child: MorphNavigationRail.morph(
                    key: const ValueKey('gif_navigation_morph_rail'),
                    expandedWidth: 215,
                    scrollUnder: false,
                    selectedIndex: _railIndex,
                    onDestinationSelected: (index) =>
                        setState(() => _railIndex = index),
                    sections: const [
                      MorphNavigationRailSection(
                        destinations: [
                          MorphNavigationRailDestination(
                            icon: Icon(MorphIcons.home),
                            label: 'Home',
                          ),
                          MorphNavigationRailDestination(
                            icon: Icon(MorphIcons.search),
                            label: 'Search',
                          ),
                          MorphNavigationRailDestination(
                            icon: Icon(MorphIcons.favorite_border),
                            label: 'Saved',
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 18),
          SizedBox(
            width: 310,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _captureLabel('Morph drawer'),
                const SizedBox(height: 8),
                SizedBox(
                  width: 304,
                  height: 298,
                  child: MorphNavigationDrawer.morph(
                    key: const ValueKey('gif_navigation_morph_drawer'),
                    headline: 'Navigation',
                    selectedIndex: _drawerIndex,
                    onDestinationSelected: (index) =>
                        setState(() => _drawerIndex = index),
                    destinations: const [
                      MorphNavigationDestination(
                        icon: Icon(MorphIcons.home),
                        label: 'Home',
                      ),
                      MorphNavigationDestination(
                        icon: Icon(MorphIcons.search),
                        label: 'Search',
                      ),
                      MorphNavigationDestination(
                        icon: Icon(MorphIcons.favorite_border),
                        label: 'Saved',
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    ),
    'loading' => SizedBox(
      width: 560,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            spacing: 24,
            runSpacing: 20,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              MorphProgressIndicator.circular(value: _progressValue, size: 44),
              MorphProgressIndicator.circularWavy(
                value: _progressValue,
                size: 44,
              ),
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 320),
                switchInCurve: Curves.easeOutCubic,
                switchOutCurve: Curves.easeInCubic,
                child: _showContainedLoaders
                    ? const MorphLoadingIndicator(
                        key: ValueKey('contained_loader'),
                        variant: MorphLoadingIndicatorVariant.contained,
                        size: 56,
                      )
                    : const MorphLoadingIndicator(
                        key: ValueKey('default_loader'),
                        size: 56,
                      ),
              ),
            ],
          ),
          const SizedBox(height: 28),
          SizedBox(
            width: 310,
            child: MorphProgressIndicator.linear(
              value: _progressValue,
              linearSize: MorphProgressIndicatorSize.s,
            ),
          ),
          const SizedBox(height: 14),
          SizedBox(
            width: 310,
            child: MorphProgressIndicator.linearWavy(
              value: _progressValue,
              linearSize: MorphProgressIndicatorSize.s,
            ),
          ),
        ],
      ),
    ),
    _ => const SizedBox.shrink(),
  };
}
