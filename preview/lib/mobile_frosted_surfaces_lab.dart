import 'package:gap/gap.dart';
import 'package:material_ui/material_ui.dart'
    show
        Alignment,
        BoxDecoration,
        BorderRadius,
        BoxShape,
        BuildContext,
        Color,
        Colors,
        Column,
        Container,
        CrossAxisAlignment,
        DecoratedBox,
        EdgeInsets,
        Expanded,
        FontWeight,
        Icon,
        IgnorePointer,
        LinearGradient,
        MainAxisAlignment,
        MainAxisSize,
        MaterialPageRoute,
        Navigator,
        Padding,
        Positioned,
        RadialGradient,
        Row,
        SafeArea,
        Scaffold,
        SingleChildScrollView,
        SizedBox,
        Stack,
        StackFit,
        State,
        StatefulWidget,
        StatelessWidget,
        TextAlign,
        Text,
        TextStyle,
        Transform,
        ValueChanged,
        VoidCallback,
        Widget,
        Wrap;
import 'package:morph_expressive/morph_expressive.dart';

import 'mobile_haptics_lab.dart';
import 'mobile_scroll_blur_lab.dart';

/// Mobile playground for the frosted floating surfaces.
///
/// The blur, tint and enable controls write a single global
/// [MorphSurfaceGlass] into `MorphThemeData.floatingSurfaceGlass` (held by the
/// app above), so every demo surface — and any overlay that is still open —
/// re-renders from the same configuration.
class MorphFrostedSurfacesLab extends StatefulWidget {
  const MorphFrostedSurfacesLab({
    required this.darkMode,
    required this.onToggleTheme,
    required this.glassEnabled,
    required this.onGlassEnabledChanged,
    required this.blur,
    required this.onBlurChanged,
    required this.tintOpacity,
    required this.onTintOpacityChanged,
    required this.hapticsEnabled,
    required this.hapticFeedback,
    required this.onHapticsEnabledChanged,
    required this.onHapticFeedbackChanged,
    super.key,
  });

  final bool darkMode;
  final VoidCallback onToggleTheme;

  final bool glassEnabled;
  final ValueChanged<bool> onGlassEnabledChanged;
  final double blur;
  final ValueChanged<double> onBlurChanged;
  final double tintOpacity;
  final ValueChanged<double> onTintOpacityChanged;

  /// Passed through so the haptics lab stays reachable from this screen.
  final bool hapticsEnabled;
  final MorphHapticFeedback hapticFeedback;
  final ValueChanged<bool> onHapticsEnabledChanged;
  final ValueChanged<MorphHapticFeedback> onHapticFeedbackChanged;

  @override
  State<MorphFrostedSurfacesLab> createState() =>
      _MorphFrostedSurfacesLabState();
}

class _MorphFrostedSurfacesLabState extends State<MorphFrostedSurfacesLab> {
  String? _fruit;
  String _lastAction = 'No action yet';

  static const List<MorphDropdownItem<String>> _fruits =
      <MorphDropdownItem<String>>[
        MorphDropdownItem(label: 'Apple', value: 'apple'),
        MorphDropdownItem(label: 'Banana', value: 'banana'),
        MorphDropdownItem(label: 'Cherry', value: 'cherry'),
        MorphDropdownItem(label: 'Dragon fruit', value: 'dragon'),
        MorphDropdownItem(label: 'Elderberry', value: 'elder'),
      ];

  static const List<MorphDropdownItem<String>> _languages =
      <MorphDropdownItem<String>>[
        MorphDropdownItem(label: 'Dart', value: 'dart'),
        MorphDropdownItem(label: 'Kotlin', value: 'kotlin'),
        MorphDropdownItem(label: 'Swift', value: 'swift'),
        MorphDropdownItem(label: 'TypeScript', value: 'ts'),
        MorphDropdownItem(label: 'Rust', value: 'rust'),
        MorphDropdownItem(label: 'Go', value: 'go'),
        MorphDropdownItem(label: 'Python', value: 'python'),
        MorphDropdownItem(label: 'Ruby', value: 'ruby'),
      ];

  void _openHapticsLab() {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (BuildContext context) => MorphMobileHapticsLab(
          hapticsEnabled: widget.hapticsEnabled,
          hapticFeedback: widget.hapticFeedback,
          onHapticsEnabledChanged: widget.onHapticsEnabledChanged,
          onHapticFeedbackChanged: widget.onHapticFeedbackChanged,
          darkMode: widget.darkMode,
          onToggleTheme: widget.onToggleTheme,
        ),
      ),
    );
  }

  void _openScrollBlurLab() {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (BuildContext context) => MorphScrollBlurLab(
          darkMode: widget.darkMode,
          onToggleTheme: widget.onToggleTheme,
          glassEnabled: widget.glassEnabled,
          onGlassEnabledChanged: widget.onGlassEnabledChanged,
          blur: widget.blur,
          onBlurChanged: widget.onBlurChanged,
          tintOpacity: widget.tintOpacity,
          onTintOpacityChanged: widget.onTintOpacityChanged,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final morph = MorphTheme.of(context);
    final scheme = morph.colorScheme;
    final type = morph.typeScale;
    final summary =
        'Blur ${widget.blur.round()} · Tint ${(widget.tintOpacity * 100).round()}%'
        ' · ${widget.darkMode ? 'Dark' : 'Light'}'
        ' · ${widget.glassEnabled ? 'Frosted on' : 'Frosted off'}';

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        fit: StackFit.expand,
        children: <Widget>[
          FrostedBackdrop(dark: widget.darkMode),
          SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 14, 16, 6),
                  child: Row(
                    children: <Widget>[
                      Expanded(
                        child: Text(
                          'Frosted Surfaces',
                          style: type.headlineSmall.copyWith(
                            color: _onBackdrop(scheme, widget.darkMode),
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      MorphIconButton(
                        icon: Icon(
                          widget.darkMode
                              ? FluentIcons.line.weather_sunny
                              : FluentIcons.line.weather_moon,
                        ),
                        tooltip: 'Switch theme',
                        variant: MorphIconButtonVariant.tonal,
                        onPressed: widget.onToggleTheme,
                      ),
                      Gap(8),
                      MorphIconButton(
                        icon: Icon(FluentIcons.line.phone_vibrate),
                        tooltip: 'Haptics lab',
                        variant: MorphIconButtonVariant.tonal,
                        onPressed: _openHapticsLab,
                      ),
                      Gap(8),
                      MorphIconButton(
                        icon: Icon(FluentIcons.line.arrow_sync),
                        tooltip: 'Scroll Blur Compatibility Lab',
                        variant: MorphIconButtonVariant.tonal,
                        onPressed: _openScrollBlurLab,
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(16, 6, 16, 32),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: <Widget>[
                        _card(
                          scheme,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: <Widget>[
                              _rowLabel(
                                type,
                                scheme,
                                'Frosted glass',
                                widget.glassEnabled ? 'On' : 'Off',
                              ),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: <Widget>[
                                  Text(
                                    'Enable global blur',
                                    style: type.bodyMedium.copyWith(
                                      color: scheme.onSurfaceVariant,
                                    ),
                                  ),
                                  MorphSwitch(
                                    value: widget.glassEnabled,
                                    onChanged: (value) =>
                                        widget.onGlassEnabledChanged(value),
                                  ),
                                ],
                              ),
                              Gap(10),
                              _rowLabel(
                                type,
                                scheme,
                                'Blur',
                                '${widget.blur.round()} px',
                              ),
                              MorphSlider(
                                value: widget.blur,
                                min: 0,
                                max: 30,
                                divisions: 30,
                                label: '${widget.blur.round()}',
                                onChanged: widget.onBlurChanged,
                              ),
                              Gap(6),
                              _rowLabel(
                                type,
                                scheme,
                                'Tint opacity',
                                '${(widget.tintOpacity * 100).round()}%',
                              ),
                              MorphSlider(
                                value: widget.tintOpacity,
                                min: 0,
                                max: 1,
                                divisions: 20,
                                label: '${(widget.tintOpacity * 100).round()}%',
                                onChanged: widget.onTintOpacityChanged,
                              ),
                              Gap(8),
                              Text(
                                summary,
                                textAlign: TextAlign.center,
                                style: type.labelLarge.copyWith(
                                  color: scheme.primary,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Gap(14),
                        _sectionTitle(type, scheme, 'Dropdowns'),
                        _card(
                          scheme,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: <Widget>[
                              Text(
                                _fruit == null
                                    ? 'Single choice'
                                    : 'Chosen: ${_capitalise(_fruit!)}',
                                style: type.labelMedium.copyWith(
                                  color: scheme.onSurfaceVariant,
                                ),
                              ),
                              Gap(6),
                              MorphDropdownMenu<String>(
                                items: _fruits
                                    .map(
                                      (item) => item.copyWith(
                                        selected: item.value == _fruit,
                                      ),
                                    )
                                    .toList(),
                                singleSelect: true,
                                fieldStyle: const MorphDropdownFieldStyle(
                                  hintText: 'Pick a fruit',
                                ),
                                onSelectionChanged: (selected) => setState(
                                  () => _fruit = selected.isEmpty
                                      ? null
                                      : selected.last.value,
                                ),
                              ),
                              Gap(14),
                              Text(
                                'Multiple with search',
                                style: type.labelMedium.copyWith(
                                  color: scheme.onSurfaceVariant,
                                ),
                              ),
                              Gap(6),
                              MorphDropdownMenu<String>(
                                items: _languages,
                                searchEnabled: true,
                                fieldStyle: const MorphDropdownFieldStyle(
                                  hintText: 'Search languages',
                                ),
                              ),
                            ],
                          ),
                        ),
                        Gap(14),
                        _sectionTitle(type, scheme, 'Menus'),
                        _card(
                          scheme,
                          child: Row(
                            children: <Widget>[
                              Expanded(
                                child: MorphMenu.entries(
                                  anchorBuilder: (context, open) => MorphButton(
                                    label: Text('Actions'),
                                    style: MorphButtonStyle.outlined,
                                    onPressed: open,
                                  ),
                                  entries: <MorphMenuEntry>[
                                    MorphMenuEntry(
                                      label: 'Edit',
                                      leading: Icon(FluentIcons.line.edit),
                                      value: 'edit',
                                      onPressed: () => _report('Edit'),
                                    ),
                                    MorphMenuEntry(
                                      label: 'Copy',
                                      leading: Icon(FluentIcons.line.copy),
                                      value: 'copy',
                                      onPressed: () => _report('Copy'),
                                    ),
                                    MorphMenuEntry(
                                      label: 'Delete',
                                      leading: Icon(FluentIcons.line.delete),
                                      isDestructive: true,
                                      value: 'delete',
                                      onPressed: () => _report('Delete'),
                                    ),
                                  ],
                                ),
                              ),
                              Gap(12),
                              Expanded(
                                child: MorphMenu(
                                  anchorBuilder: (context, open) => MorphButton(
                                    label: Text('With submenu'),
                                    style: MorphButtonStyle.outlined,
                                    onPressed: open,
                                  ),
                                  children: <MorphMenuNode>[
                                    MorphMenuEntry(
                                      label: 'Rename',
                                      onPressed: () => _report('Rename'),
                                    ),
                                    MorphMenuSubmenu(
                                      label: 'Move to',
                                      children: <MorphMenuNode>[
                                        MorphMenuEntry(
                                          label: 'Work',
                                          onPressed: () =>
                                              _report('Move: Work'),
                                        ),
                                        MorphMenuEntry(
                                          label: 'Home',
                                          onPressed: () =>
                                              _report('Move: Home'),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        Gap(6),
                        Text(
                          _lastAction,
                          textAlign: TextAlign.center,
                          style: type.bodySmall.copyWith(
                            color: _onBackdrop(scheme, widget.darkMode),
                          ),
                        ),
                        Gap(14),
                        _sectionTitle(type, scheme, 'Panels, dialogs & more'),
                        _card(
                          scheme,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: <Widget>[
                              Wrap(
                                spacing: 10,
                                runSpacing: 10,
                                children: <Widget>[
                                  MorphButton(
                                    label: Text('Bottom sheet'),
                                    onPressed: () => MorphBottomSheet.show<void>(
                                      context,
                                      builder: (context) => Padding(
                                        padding: const EdgeInsets.all(24),
                                        child: Column(
                                          mainAxisSize: MainAxisSize.min,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: <Widget>[
                                            Text(
                                              'Frosted bottom sheet',
                                              style: type.titleMedium,
                                            ),
                                            Gap(8),
                                            Text(
                                              'Drag the scrim or swipe down to '
                                              'close. The sheet blurs the moving '
                                              'backdrop behind it.',
                                              style: type.bodyMedium.copyWith(
                                                color: scheme.onSurfaceVariant,
                                              ),
                                            ),
                                            Gap(14),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                  MorphButton(
                                    label: Text('Side sheet'),
                                    style: MorphButtonStyle.outlined,
                                    onPressed: () => MorphSideSheet.show<void>(
                                      context,
                                      title: 'Frosted side sheet',
                                      body: Padding(
                                        padding: const EdgeInsets.all(16),
                                        child: Text(
                                          'Side sheets use the same global '
                                          'glass configuration.',
                                          style: type.bodyMedium,
                                        ),
                                      ),
                                    ),
                                  ),
                                  MorphButton(
                                    label: Text('Dialog'),
                                    style: MorphButtonStyle.text,
                                    onPressed: () => MorphDialog.show<void>(
                                      context,
                                      dialog: MorphDialog(
                                        title: 'Frosted dialog',
                                        content: Text(
                                          'The container blurs what is behind '
                                          'it while the text stays sharp.',
                                          style: type.bodyMedium,
                                        ),
                                        actions: <Widget>[
                                          MorphButton(
                                            label: Text('Close'),
                                            style: MorphButtonStyle.text,
                                            onPressed: () =>
                                                Navigator.of(context).pop(),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  MorphTooltip(
                                    message: 'Tooltips frosted too',
                                    child: MorphButton(
                                      label: Text('Tooltip'),
                                      icon: Icon(FluentIcons.line.comment),
                                      style: MorphButtonStyle.text,
                                      onPressed: () {},
                                    ),
                                  ),
                                  MorphButton(
                                    label: Text('Snackbar'),
                                    icon: Icon(FluentIcons.line.mail_inbox),
                                    style: MorphButtonStyle.text,
                                    onPressed: () => MorphSnackbar.show(
                                      context,
                                      message: 'Frosted snackbar',
                                      actionLabel: 'Nice',
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        Gap(14),
                        _sectionTitle(type, scheme, 'Cards'),
                        MorphCard(
                          frosted: true,
                          headline: 'Card · global glass',
                          supportingText: 'Inherits the theme blur and tint.',
                          onPressed: () => _report('Glass card'),
                        ),
                        Gap(10),
                        MorphCard(
                          headline: 'Card · opaque',
                          supportingText: 'Local glass disabled.',
                          glass: const MorphSurfaceGlass.disabled(),
                        ),
                        Gap(10),
                        MorphCard(
                          variant: MorphCardVariant.outlined,
                          headline: 'Card · custom glass',
                          supportingText: 'Independent blur and tint.',
                          glass: const MorphSurfaceGlass(
                            blurX: 20,
                            blurY: 20,
                            tintOpacity: 0.35,
                          ),
                        ),
                        Gap(14),
                        _sectionTitle(type, scheme, 'Frosted vs opaque'),
                        _card(
                          scheme,
                          child: Row(
                            children: <Widget>[
                              Expanded(
                                child: Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.stretch,
                                  children: <Widget>[
                                    Text(
                                      'Global frosted',
                                      textAlign: TextAlign.center,
                                      style: type.labelMedium.copyWith(
                                        color: scheme.primary,
                                      ),
                                    ),
                                    Gap(6),
                                    MorphDropdownMenu<String>(
                                      items: _fruits,
                                      singleSelect: true,
                                      fieldStyle: const MorphDropdownFieldStyle(
                                        hintText: 'Frosted',
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Gap(12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.stretch,
                                  children: <Widget>[
                                    Text(
                                      'Local disabled()',
                                      textAlign: TextAlign.center,
                                      style: type.labelMedium.copyWith(
                                        color: scheme.onSurfaceVariant,
                                      ),
                                    ),
                                    Gap(6),
                                    MorphDropdownMenu<String>(
                                      items: _fruits,
                                      singleSelect: true,
                                      glass: const MorphSurfaceGlass.disabled(),
                                      fieldStyle: const MorphDropdownFieldStyle(
                                        hintText: 'Opaque',
                                      ),
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
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _report(String action) {
    setState(() => _lastAction = 'Last action: $action');
  }

  static String _capitalise(String value) =>
      value.isEmpty ? value : value[0].toUpperCase() + value.substring(1);

  static Color _onBackdrop(MorphColorScheme scheme, bool dark) =>
      dark ? Colors.white : const Color(0xFF10131C);

  Widget _sectionTitle(MorphTypeScale type, MorphColorScheme scheme, String s) {
    return Padding(
      padding: const EdgeInsets.only(left: 6, bottom: 6),
      child: Text(
        s,
        style: type.titleSmall.copyWith(
          color: _onBackdrop(scheme, widget.darkMode),
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _rowLabel(
    MorphTypeScale type,
    MorphColorScheme scheme,
    String label,
    String value,
  ) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: <Widget>[
        Text(label, style: type.titleSmall.copyWith(color: scheme.onSurface)),
        Text(value, style: type.labelLarge.copyWith(color: scheme.primary)),
      ],
    );
  }

  /// Section surface using the same glass treatment as application cards.
  Widget _card(MorphColorScheme scheme, {required Widget child}) {
    return MorphCard(
      frosted: true,
      padding: const EdgeInsets.all(18),
      color: scheme.surfaceContainerHigh.withValues(alpha: 0.72),
      borderRadius: BorderRadius.circular(26),
      elevation: 0,
      child: child,
    );
  }
}

/// High-contrast pattern background for judging real blur: gradients, solid
/// circles, rotated tiles, stripes and big typography behind every surface.
class FrostedBackdrop extends StatelessWidget {
  const FrostedBackdrop({required this.dark, super.key});

  final bool dark;

  @override
  Widget build(BuildContext context) {
    final base = dark
        ? const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: <Color>[Color(0xFF1B1035), Color(0xFF04211F)],
          )
        : const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: <Color>[Color(0xFFFFE7C2), Color(0xFFCFE4FF)],
          );
    final accent = dark
        ? const <Color>[Color(0xFFFF6D01), Color(0xFF62FFB3), Color(0xFFFF2B6E)]
        : const <Color>[
            Color(0xFFFFB142),
            Color(0xFF22B573),
            Color(0xFFE5326E),
          ];

    return IgnorePointer(
      child: Stack(
        fit: StackFit.expand,
        children: <Widget>[
          DecoratedBox(decoration: BoxDecoration(gradient: base)),
          // Large colour circles that the blur smears unmistakably.
          _circle(left: -40, top: 90, size: 200, color: accent[0]),
          _circle(right: -60, top: 300, size: 260, color: accent[1]),
          _circle(left: 70, top: 620, size: 180, color: accent[2]),
          // Rotated high-contrast tiles.
          Positioned(
            left: 190,
            top: 40,
            child: Transform.rotate(
              angle: 0.6,
              child: Container(
                width: 130,
                height: 130,
                decoration: BoxDecoration(
                  color: accent[1].withValues(alpha: dark ? 0.85 : 0.7),
                  borderRadius: BorderRadius.circular(28),
                ),
              ),
            ),
          ),
          Positioned(
            left: 20,
            top: 380,
            child: Transform.rotate(
              angle: -0.4,
              child: Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  color: accent[2].withValues(alpha: dark ? 0.8 : 0.65),
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
            ),
          ),
          // Black/white checker strip for sigma judgement.
          Positioned(
            left: 0,
            right: 0,
            top: 240,
            child: SizedBox(
              height: 44,
              child: Row(
                children: List<Widget>.generate(12, (i) {
                  return Expanded(
                    child: Container(
                      color: i.isEven
                          ? (dark ? Colors.white : Colors.black).withValues(
                              alpha: 0.85,
                            )
                          : Colors.transparent,
                    ),
                  );
                }),
              ),
            ),
          ),
          // Diagonal watermark typography.
          Positioned(
            right: -30,
            bottom: 120,
            child: Transform.rotate(
              angle: -0.25,
              child: Text(
                'BLUR',
                style: TextStyle(
                  fontSize: 96,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 6,
                  color: (dark ? Colors.white : Colors.black).withValues(
                    alpha: 0.16,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _circle({
    double? left,
    double? right,
    required double top,
    required double size,
    required Color color,
  }) {
    return Positioned(
      left: left,
      right: right,
      top: top,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: RadialGradient(
            colors: <Color>[color, color.withValues(alpha: 0.0)],
          ),
        ),
      ),
    );
  }
}
