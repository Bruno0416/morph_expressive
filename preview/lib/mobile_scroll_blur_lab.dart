import 'package:gap/gap.dart';
import 'package:material_ui/material_ui.dart'
    show
        AlwaysScrollableScrollPhysics,
        BuildContext,
        ClampingScrollPhysics,
        Color,
        Colors,
        TextAlign,
        ValueKey,
        Column,
        CrossAxisAlignment,
        MainAxisAlignment,
        ScrollableDetails,
        EdgeInsets,
        Expanded,
        FontWeight,
        Icon,
        ListView,
        Navigator,
        Row,
        SafeArea,
        Scaffold,
        ScrollBehavior,
        ScrollConfiguration,
        ScrollPhysics,
        Stack,
        StackFit,
        State,
        StatefulWidget,
        StretchingOverscrollIndicator,
        Text,
        ValueChanged,
        VoidCallback,
        Widget;
import 'package:morph_expressive/morph_expressive.dart';

import 'mobile_frosted_surfaces_lab.dart';

/// Scroll strategies compared by [MorphScrollBlurLab].
enum ScrollBlurVariant {
  /// Stock Flutter `StretchingOverscrollIndicator` (wraps an `ImageFiltered`).
  originalStretch('Original Stretch'),

  /// Geometric stretch from the public Morph scroll behavior.
  geometricStretch('Geometric Stretch');

  const ScrollBlurVariant(this.label);
  final String label;
}

/// Experimental lab: frosted [MorphCard]s inside a scroll view over a fixed
/// backdrop that lives OUTSIDE the scrollable. Used to check whether each
/// overscroll strategy keeps the cards' real backdrop blur.
///
/// No global scroll configuration, MorphCard or frosted renderer is changed.
/// The geometric variant exercises the public Morph scroll behavior.
class MorphScrollBlurLab extends StatefulWidget {
  const MorphScrollBlurLab({
    required this.darkMode,
    required this.onToggleTheme,
    required this.glassEnabled,
    required this.onGlassEnabledChanged,
    required this.blur,
    required this.onBlurChanged,
    required this.tintOpacity,
    required this.onTintOpacityChanged,
    this.initialVariant = ScrollBlurVariant.geometricStretch,
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
  final ScrollBlurVariant initialVariant;

  @override
  State<MorphScrollBlurLab> createState() => _MorphScrollBlurLabState();
}

class _MorphScrollBlurLabState extends State<MorphScrollBlurLab> {
  late ScrollBlurVariant _variant = widget.initialVariant;

  ScrollBehavior _behaviorFor(ScrollBlurVariant v) {
    switch (v) {
      case ScrollBlurVariant.originalStretch:
        return const _LabScrollBehavior();
      case ScrollBlurVariant.geometricStretch:
        return const MorphScrollBehavior();
    }
  }

  @override
  Widget build(BuildContext context) {
    final morph = MorphTheme.of(context);
    final scheme = morph.colorScheme;
    final type = morph.typeScale;
    final Color on = widget.darkMode ? Colors.white : const Color(0xFF10131C);

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        fit: StackFit.expand,
        children: <Widget>[
          // Fixed backdrop, deliberately outside the scrollable.
          FrostedBackdrop(dark: widget.darkMode),
          SafeArea(
            child: ScrollConfiguration(
              behavior: _behaviorFor(_variant),
              // Key per variant so each strategy builds from a clean state.
              child: ListView(
                key: ValueKey<ScrollBlurVariant>(_variant),
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 40),
                children: <Widget>[
                  Row(
                    children: <Widget>[
                      MorphIconButton(
                        icon: Icon(FluentIcons.line.arrow_left),
                        tooltip: 'Back',
                        variant: MorphIconButtonVariant.tonal,
                        onPressed: () => Navigator.of(context).maybePop(),
                      ),
                      Gap(12),
                      Expanded(
                        child: Text(
                          'Scroll Blur Compatibility Lab',
                          style: type.titleLarge.copyWith(
                            color: on,
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
                    ],
                  ),
                  Gap(12),
                  _controls(type, scheme),
                  Gap(12),
                  Text(
                    'Drag past the top / bottom and release. Blur must stay '
                    'real (backdrop visible through each card) in every state.',
                    style: type.bodySmall.copyWith(color: on),
                  ),
                  Gap(12),
                  for (int i = 0; i < 14; i++) ...<Widget>[
                    MorphCard(
                      key: ValueKey<String>('lab-card-$i'),
                      frosted: true,
                      headline: 'Frosted card ${i + 1}',
                      supportingText:
                          '${_variant.label} · blur ${widget.blur.round()} · '
                          'tint ${(widget.tintOpacity * 100).round()}%',
                      onPressed: () {},
                    ),
                    Gap(12),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _controls(MorphTypeScale type, MorphColorScheme scheme) {
    return MorphCard(
      key: const ValueKey<String>('lab-controls'),
      frosted: true,
      padding: const EdgeInsets.all(16),
      color: scheme.surfaceContainerHigh.withValues(alpha: 0.72),
      elevation: 0,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          MorphSegmentedButton<ScrollBlurVariant>(
            segments: <MorphSegment<ScrollBlurVariant>>[
              for (final ScrollBlurVariant v in ScrollBlurVariant.values)
                MorphSegment<ScrollBlurVariant>(
                  value: v,
                  label: switch (v) {
                    ScrollBlurVariant.originalStretch => 'Original',
                    ScrollBlurVariant.geometricStretch => 'Geometric',
                  },
                ),
            ],
            selected: <ScrollBlurVariant>{_variant},
            onSelectionChanged: (Set<ScrollBlurVariant> s) =>
                setState(() => _variant = s.first),
          ),
          Gap(4),
          Text(
            _variant.label,
            textAlign: TextAlign.center,
            style: type.labelLarge.copyWith(color: scheme.primary),
          ),
          Gap(8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Text(
                'Frosted enabled',
                style: type.bodyMedium.copyWith(color: scheme.onSurfaceVariant),
              ),
              MorphSwitch(
                value: widget.glassEnabled,
                onChanged: widget.onGlassEnabledChanged,
              ),
            ],
          ),
          Text(
            'Blur ${widget.blur.round()} px',
            style: type.labelMedium.copyWith(color: scheme.onSurfaceVariant),
          ),
          MorphSlider(
            value: widget.blur,
            min: 0,
            max: 30,
            divisions: 30,
            label: '${widget.blur.round()}',
            onChanged: widget.onBlurChanged,
          ),
          Text(
            'Tint opacity ${(widget.tintOpacity * 100).round()}%',
            style: type.labelMedium.copyWith(color: scheme.onSurfaceVariant),
          ),
          MorphSlider(
            value: widget.tintOpacity,
            min: 0,
            max: 1,
            divisions: 20,
            label: '${(widget.tintOpacity * 100).round()}%',
            onChanged: widget.onTintOpacityChanged,
          ),
        ],
      ),
    );
  }
}

/// Baseline used only for comparison with the supported geometric behavior.
class _LabScrollBehavior extends ScrollBehavior {
  const _LabScrollBehavior();

  @override
  ScrollPhysics getScrollPhysics(BuildContext context) =>
      const ClampingScrollPhysics(parent: AlwaysScrollableScrollPhysics());

  @override
  Widget buildOverscrollIndicator(
    BuildContext context,
    Widget child,
    ScrollableDetails details,
  ) => StretchingOverscrollIndicator(
    axisDirection: details.direction,
    child: child,
  );
}
