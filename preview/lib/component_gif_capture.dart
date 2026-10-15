import 'dart:async';

import 'package:material_ui/material_ui.dart';
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
      builder: (context, child) => MorphTheme(
        data: theme,
        child: child ?? const SizedBox.shrink(),
      ),
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
  final MorphDropdownController<String> _dropdown = MorphDropdownController<String>();
  final TextEditingController _search = TextEditingController();
  final TextEditingController _email = TextEditingController();
  final FocusNode _searchFocus = FocusNode();
  final FocusNode _emailFocus = FocusNode();

  bool _buttonSelected = false;
  bool _favorite = false;
  String _segment = 'Movies';
  String _chipToggle = 'Daily';
  int? _groupSelected = 0;
  bool _filterSelected = false;
  bool _inputSelected = false;
  double _sliderValue = 0.28;
  double _progressValue = 0.32;
  bool _showContainedLoaders = false;
  int _navigationIndex = 0;

  int get _delayMs {
    final raw = int.tryParse(Uri.base.queryParameters['delayMs'] ?? '800');
    return (raw ?? 800).clamp(250, 10000);
  }

  void _at(int offsetMs, VoidCallback action) {
    _timers.add(Timer(Duration(milliseconds: _delayMs + offsetMs), () {
      if (mounted) action();
    }));
  }

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
              (atMs: 960, action: () => setState(() => _buttonSelected = false)),
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
              (atMs: 0, action: () => setState(() {
                _segment = 'TV Shows';
                _groupSelected = 1;
              })),
              (atMs: 560, action: () => setState(() {
                _segment = 'Movies';
                _groupSelected = 2;
              })),
              (atMs: 1120, action: () => setState(() {
                _segment = 'TV Shows';
                _groupSelected = 0;
              })),
              (atMs: 1680, action: () => setState(() {
                _segment = 'Movies';
                _groupSelected = 0;
              })),
            ],
          );
        case 'textfields':
          _scheduleLoop(
            cycleMs: 2200,
            cycles: 2,
            events: [
              (atMs: 0, action: _searchFocus.requestFocus),
              (atMs: 220, action: () => _search.text = 'Morph Expressive'),
              (atMs: 700, action: () => _search.clear()),
              (atMs: 960, action: _emailFocus.requestFocus),
              (atMs: 1320, action: () => _email.text = 'hello@morph.dev'),
              (atMs: 1760, action: () {
                _email.clear();
                _emailFocus.unfocus();
              }),
            ],
          );
        case 'chips':
          _scheduleLoop(
            cycleMs: 2200,
            cycles: 2,
            events: [
              (atMs: 0, action: () => setState(() => _filterSelected = true)),
              (atMs: 460, action: () => setState(() => _chipToggle = 'Weekly')),
              (atMs: 920, action: () => setState(() => _inputSelected = true)),
              (atMs: 1380, action: () => setState(() {
                _chipToggle = 'Monthly';
                _filterSelected = false;
              })),
              (atMs: 1840, action: () => setState(() {
                _chipToggle = 'Daily';
                _inputSelected = false;
              })),
            ],
          );
        case 'sliders':
          _scheduleDoubleSequence(const [
            0.30, 0.32, 0.35, 0.38, 0.41, 0.44, 0.47, 0.50, 0.53, 0.56,
            0.59, 0.62, 0.65, 0.68, 0.71, 0.74, 0.71, 0.68, 0.65, 0.62,
            0.59, 0.56, 0.53, 0.50, 0.47, 0.44, 0.41, 0.38, 0.35, 0.32, 0.30,
            0.32, 0.35, 0.38, 0.41, 0.44, 0.47, 0.50, 0.53, 0.56, 0.59,
          ], apply: (value) => _sliderValue = value, stepMs: 90);
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
        case 'loading':
          _scheduleDoubleSequence(const [
            0.32, 0.38, 0.44, 0.50, 0.56, 0.62, 0.68, 0.74, 0.68, 0.62, 0.56,
            0.50, 0.44, 0.38, 0.32, 0.38, 0.44, 0.50, 0.56, 0.62, 0.68, 0.74,
            0.68, 0.62, 0.56, 0.50, 0.44, 0.38, 0.32,
          ], apply: (value) => _progressValue = value, stepMs: 140);
          _scheduleLoop(
            cycleMs: 2200,
            cycles: 2,
            events: [
              (atMs: 720, action: () => setState(() => _showContainedLoaders = true)),
              (atMs: 1540, action: () => setState(() => _showContainedLoaders = false)),
            ],
          );
      }
    });
  }

  @override
  void dispose() {
    for (final timer in _timers) {
      timer.cancel();
    }
    _dropdown.dispose();
    _search.dispose();
    _email.dispose();
    _searchFocus.dispose();
    _emailFocus.dispose();
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
      'textfields' => ('Text fields', 'Animated focus and outline'),
      'chips' => ('Chips', 'Filter, input and connected selection'),
      'sliders' => ('Sliders', 'Linear and animated wavy tracks'),
      'loading' => ('Progress + loading', 'Progress indicators and expressive loaders'),
      'navigation' => ('Navigation', 'Compact and wide layouts'),
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
              Text(subtitle,
                style: (morph.textTheme.bodyMedium ?? const TextStyle()).copyWith(
                  color: scheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
        Positioned(
          top: widget.scene == 'dropdown' ? 104 : 137,
          left: 34,
          child: SizedBox(
            width: 572,
            child: Align(
              alignment: Alignment.topLeft,
              child: _content(),
            ),
          ),
        ),
        Positioned(
          bottom: 19,
          right: 30,
          child: Text('MORPH EXPRESSIVE', style: (morph.textTheme.labelSmall ?? const TextStyle()).copyWith(
            color: scheme.onSurfaceVariant,
            letterSpacing: 2,
          )),
        ),
      ],
    );
  }

  Widget _content() => switch (widget.scene) {
    'buttons' => Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Wrap(spacing: 12, runSpacing: 16, children: [
          MorphButton(
            onPressed: () => setState(() => _buttonSelected = !_buttonSelected),
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
        ]),
        const SizedBox(height: 30),
        Row(children: [
          MorphIconButton(
            variant: MorphIconButtonVariant.filled,
            icon: Icon(_favorite ? MorphIcons.favorite : MorphIcons.favorite_border),
            onPressed: () => setState(() => _favorite = !_favorite),
          ),
          const SizedBox(width: 14),
          MorphButton(
            onPressed: () {},
            style: MorphButtonStyle.text,
            label: const Text('Text button'),
          ),
        ]),
      ],
    ),
    'dropdown' => SizedBox(
      width: 360,
      child: MorphDropdownMenu<String>(
        controller: _dropdown,
        singleSelect: true,
        fieldStyle: const MorphDropdownFieldStyle(hintText: 'Choose a framework'),
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
            onSelectedIndexChanged: (next) => setState(() => _groupSelected = next),
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
        children: [
          MorphTextField(
            controller: _search,
            focusNode: _searchFocus,
            placeholder: 'Search for a movie',
            leading: const Icon(MorphIcons.search),
            showClearButton: true,
          ),
          const SizedBox(height: 20),
          MorphTextField(
            controller: _email,
            focusNode: _emailFocus,
            label: 'Email',
            placeholder: 'hello@example.com',
            variant: MorphTextFieldVariant.outlined,
          ),
        ],
      ),
    ),
    'chips' => Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Wrap(spacing: 12, runSpacing: 12, children: [
          MorphChip(
            label: 'Filter',
            type: MorphChipType.filter,
            selected: _filterSelected,
            onPressed: () => setState(() => _filterSelected = !_filterSelected),
          ),
          MorphChip(
            label: 'Input',
            type: MorphChipType.input,
            selected: _inputSelected,
            onPressed: () => setState(() => _inputSelected = !_inputSelected),
          ),
          MorphChip(label: 'Assist', onPressed: () {}),
        ]),
        const SizedBox(height: 28),
        MorphChipToggle<String>(
          options: const [
            MorphChipToggleOption(value: 'Daily', label: 'Daily'),
            MorphChipToggleOption(value: 'Weekly', label: 'Weekly'),
            MorphChipToggleOption(value: 'Monthly', label: 'Monthly'),
          ],
          selected: _chipToggle,
          onChanged: (value) => setState(() => _chipToggle = value),
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
              onDestinationSelected: (index) => setState(() => _navigationIndex = index),
              destinations: const [
                MorphNavigationBarDestination(
                  icon: Icon(MorphIcons.home),
                  label: 'Home',
                ),
                MorphNavigationBarDestination(
                  icon: Icon(MorphIcons.search),
                  label: 'Search',
                ),
                MorphNavigationBarDestination(
                  icon: Icon(MorphIcons.favorite_border),
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
              onDestinationSelected: (index) => setState(() => _navigationIndex = index),
              destinations: const [
                MorphNavigationBarDestination(
                  icon: Icon(MorphIcons.home),
                  label: 'Home',
                ),
                MorphNavigationBarDestination(
                  icon: Icon(MorphIcons.search),
                  label: 'Search',
                ),
                MorphNavigationBarDestination(
                  icon: Icon(MorphIcons.favorite_border),
                  label: 'Saved',
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
              MorphProgressIndicator.circularWavy(value: ((_progressValue * 0.88).clamp(0.0, 1.0)).toDouble(), size: 44),
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
              value: ((_progressValue * 0.93).clamp(0.0, 1.0)).toDouble(),
              linearSize: MorphProgressIndicatorSize.s,
            ),
          ),
        ],
      ),
    ),
    _ => const SizedBox.shrink(),
  };
}
