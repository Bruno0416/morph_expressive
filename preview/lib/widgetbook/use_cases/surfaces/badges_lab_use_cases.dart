import 'package:material_ui/material_ui.dart'
    show
        Brightness,
        BuildContext,
        Builder,
        Color,
        ColoredBox,
        Column,
        CrossAxisAlignment,
        EdgeInsets,
        Expanded,
        Icon,
        MediaQuery,
        Padding,
        Row,
        SizedBox,
        StatelessWidget,
        Text,
        TextScaler,
        TextStyle,
        Widget,
        Wrap;
import 'package:morph_expressive/morph_expressive.dart';
import 'package:widgetbook_annotation/widgetbook_annotation.dart' as widgetbook;

import '../../addons/morph_scope_addon.dart';
import '../../themes/seed_presets.dart';
import '../../utilities/density_lab.dart';
import '../../utilities/stage.dart';

const _path = '[Surfaces & Content]/Badges';

/// A role pairing the badge can use through `backgroundColor` and
/// `foregroundColor`; both colors always come from the real scheme.
class _Role {
  const _Role(this.name, this.background, this.foreground);

  final String name;
  final Color background;
  final Color foreground;
}

List<_Role> _roles(MorphColorScheme s) => [
  _Role('error (default)', s.error, s.onError),
  _Role('primary', s.primary, s.onPrimary),
  _Role('secondary', s.secondary, s.onSecondary),
  _Role('tertiary', s.tertiary, s.onTertiary),
  _Role('errorContainer', s.errorContainer, s.onErrorContainer),
  _Role('inverseSurface', s.inverseSurface, s.onInverseSurface),
];

Widget _host(Widget Function() badge) =>
    Padding(padding: const EdgeInsets.fromLTRB(6, 18, 30, 6), child: badge());

Widget _iconBadge({
  int? count,
  String? label,
  bool dot = false,
  int maxCount = 999,
  Color? background,
  Color? foreground,
  MorphBadgeAlignment alignment = MorphBadgeAlignment.topRight,
}) => _host(
  () => MorphBadge(
    count: count,
    label: label,
    showDot: dot,
    maxCount: maxCount,
    backgroundColor: background,
    foregroundColor: foreground,
    alignment: alignment,
    child: Icon(FluentIcons.line.mail, size: 32),
  ),
);

@widgetbook.UseCase(name: 'Variants & colors', type: MorphBadge, path: _path)
Widget badgeVariantsUseCase(BuildContext context) {
  final scheme = MorphTheme.of(context).colorScheme;
  return Stage(
    children: [
      StageSection(
        title: 'Kinds',
        note:
            'MorphBadge has one semantic role (error / onError) and three '
            'forms: a small dot, a numeric count and a text label.',
        child: StageWrap(
          spacing: 24,
          children: [
            StageCell(caption: 'dot', child: _iconBadge(dot: true)),
            StageCell(caption: 'count', child: _iconBadge(count: 7)),
            StageCell(
              caption: 'label',
              child: _iconBadge(label: 'New'),
            ),
          ],
        ),
      ),
      StageSection(
        title: 'Scheme roles',
        note:
            'The optional backgroundColor / foregroundColor take scheme role '
            'pairs. Each pair shows its computed contrast ratio.',
        child: Wrap(
          spacing: 28,
          runSpacing: 16,
          children: [
            for (final role in _roles(scheme))
              StageCell(
                caption: role.name,
                child: Row(
                  mainAxisSize: .min,
                  children: [
                    _iconBadge(
                      count: 12,
                      background: role.background,
                      foreground: role.foreground,
                    ),
                    _iconBadge(
                      dot: true,
                      background: role.background,
                      foreground: role.foreground,
                    ),
                    Text(contrastLabel(role.background, role.foreground)),
                  ],
                ),
              ),
          ],
        ),
      ),
      StageSection(
        title: 'Alignment',
        child: StageWrap(
          spacing: 24,
          children: [
            for (final alignment in MorphBadgeAlignment.values)
              StageCell(
                caption: alignment.name,
                child: _iconBadge(count: 3, alignment: alignment),
              ),
          ],
        ),
      ),
    ],
  );
}

@widgetbook.UseCase(name: 'Sizes', type: MorphBadge, path: _path)
Widget badgeSizesUseCase(BuildContext context) {
  final morph = MorphTheme.of(context);
  final theme = morph.badgeTheme.resolveDensity(morph.density);
  return Stage(
    children: [
      StageSection(
        title: 'Geometry',
        note:
            'Values read from the resolved MorphBadgeTheme for density '
            '${densityLabels[morph.density]}.',
        child: Column(
          crossAxisAlignment: .start,
          children: [
            Text('dot ${formatMetric(theme.dotSize)} dp'),
            Text(
              'label min size ${formatMetric(theme.labelMinSize)} dp · '
              'padding ${formatMetric(theme.labelHorizontalPadding)} x '
              '${formatMetric(theme.labelVerticalPadding)} · '
              'radius ${formatMetric(theme.labelCornerRadius)}',
            ),
            Text(
              'type ${formatMetric(theme.labelFontSize)} / '
              '${formatMetric(theme.labelLineHeight)} · '
              'weight ${theme.labelFontWeight.value}',
            ),
          ],
        ),
      ),
      StageSection(
        title: 'Dot, count and label',
        child: StageWrap(
          spacing: 24,
          children: [
            StageCell(caption: 'dot', child: _iconBadge(dot: true)),
            StageCell(caption: '1 digit', child: _iconBadge(count: 3)),
            StageCell(caption: '2 digits', child: _iconBadge(count: 42)),
            StageCell(caption: '3 digits', child: _iconBadge(count: 128)),
            StageCell(
              caption: 'label',
              child: _iconBadge(label: 'Beta'),
            ),
          ],
        ),
      ),
      StageSection(
        title: 'Text scale',
        note: 'The badge grows with the text; it never clips the label.',
        child: StageWrap(
          spacing: 24,
          children: [
            for (final scale in const [1.0, 1.5, 2.0])
              MediaQuery(
                data: MediaQuery.of(context)
                    .copyWith(textScaler: TextScaler.linear(scale)),
                child: StageCell(
                  caption: '${scale}x',
                  child: _iconBadge(count: 42),
                ),
              ),
          ],
        ),
      ),
    ],
  );
}

@widgetbook.UseCase(name: 'Counts', type: MorphBadge, path: _path)
Widget badgeCountsUseCase(BuildContext context) {
  const counts = [0, 1, 9, 10, 99, 100, 999, 1000];
  return Stage(
    children: [
      StageSection(
        title: 'maxCount 999 (default)',
        child: StageWrap(
          spacing: 24,
          children: [
            for (final c in counts)
              StageCell(
                caption: '$c',
                child: _iconBadge(count: c),
              ),
          ],
        ),
      ),
      StageSection(
        title: 'maxCount 99',
        note: 'Counts above the cap render as 99+.',
        child: StageWrap(
          spacing: 24,
          children: [
            for (final c in counts)
              StageCell(
                caption: '$c',
                child: _iconBadge(count: c, maxCount: 99),
              ),
          ],
        ),
      ),
    ],
  );
}

@widgetbook.UseCase(name: 'Labels', type: MorphBadge, path: _path)
Widget badgeLabelsUseCase(BuildContext context) {
  const labels = [
    'New',
    'Beta',
    'Sale',
    'Updated just now',
    'A considerably longer status label',
  ];
  return Stage(
    children: [
      StageSection(
        title: 'Short and long labels',
        note:
            'Long labels stay on one line and grow the badge; the badge '
            'overlays its child and never shifts it.',
        child: StageWrap(
          spacing: 40,
          runSpacing: 16,
          children: [
            for (final l in labels)
              StageCell(
                caption: l,
                child: _iconBadge(label: l),
              ),
          ],
        ),
      ),
    ],
  );
}

@widgetbook.UseCase(name: 'Light & dark compare', type: MorphBadge, path: _path)
Widget badgeLightDarkUseCase(BuildContext context) {
  return Stage(
    children: [
      StageSection(
        title: 'Same seed, both brightnesses',
        note:
            'Each panel is a real MorphTheme built from the selected seed; '
            'the contrast ratio is computed from the panel\'s scheme.',
        child: Wrap(
          spacing: 24,
          runSpacing: 24,
          children: [
            _ThemePanel(brightness: Brightness.light),
            _ThemePanel(brightness: Brightness.dark),
          ],
        ),
      ),
    ],
  );
}

class _ThemePanel extends StatelessWidget {
  const _ThemePanel({required this.brightness});

  final Brightness brightness;

  @override
  Widget build(BuildContext context) {
    final seed =
        activeMorphScope.value?.seed ?? morphSeedPresets[morphDefaultSeedName]!;
    final data = buildMorphTheme(
      seed,
      brightness,
      density: MorphTheme.of(context).density,
    );
    final scheme = data.colorScheme;
    return SizedBox(
      width: 360,
      child: MorphTheme(
        data: data,
        child: ColoredBox(
          color: scheme.surface,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  brightness == Brightness.dark ? 'Dark' : 'Light',
                  style: TextStyleHelper.title(data),
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  children: [
                    _iconBadge(dot: true),
                    _iconBadge(count: 7),
                    _iconBadge(count: 99),
                    _iconBadge(count: 1000),
                    _iconBadge(label: 'New'),
                  ],
                ),
                Text(
                  'error / onError ${contrastLabel(scheme.error, scheme.onError)}',
                  style: TextStyleHelper.caption(data),
                ),
                Text(
                  'badge vs surface ${contrastLabel(scheme.surface, scheme.error)}',
                  style: TextStyleHelper.caption(data),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Text styles resolved from a panel theme (its colors differ from the
/// ambient theme, so [DefaultTextStyle] is not enough).
class TextStyleHelper {
  static TextStyle title(MorphThemeData data) =>
      data.textTheme.titleSmall!.copyWith(color: data.colorScheme.onSurface);

  static TextStyle caption(MorphThemeData data) => data.textTheme.labelSmall!
      .copyWith(color: data.colorScheme.onSurfaceVariant);
}

@widgetbook.UseCase(name: 'Density', type: MorphBadge, path: _path)
Widget badgeDensityUseCase(BuildContext context) {
  return Stage(
    children: [
      StageSection(
        title: 'Compact, Standard, Comfortable',
        note:
            'Each column is a real nested MorphTheme. Padding, minimum size '
            'and radius move; the 11pt semi-bold label and the dot do not.',
        child: DensityColumns(
          width: 300,
          builder: (context, density) {
            final theme = MorphTheme.of(context).badgeTheme
                .resolveDensity(density);
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Wrap(
                  children: [
                    _iconBadge(dot: true),
                    _iconBadge(count: 7),
                    _iconBadge(count: 128),
                    _iconBadge(label: 'New'),
                  ],
                ),
                Text(
                  'min ${formatMetric(theme.labelMinSize)} · pad '
                  '${formatMetric(theme.labelHorizontalPadding)} x '
                  '${formatMetric(theme.labelVerticalPadding)} · radius '
                  '${formatMetric(theme.labelCornerRadius)}',
                ),
              ],
            );
          },
        ),
      ),
    ],
  );
}

@widgetbook.UseCase(name: 'Contrast', type: MorphBadge, path: _path)
Widget badgeContrastUseCase(BuildContext context) {
  final seed =
      activeMorphScope.value?.seed ?? morphSeedPresets[morphDefaultSeedName]!;
  return Stage(
    children: [
      for (final brightness in Brightness.values)
        Builder(
          builder: (context) {
            final data = buildMorphTheme(seed, brightness);
            final scheme = data.colorScheme;
            return StageSection(
              title: brightness == Brightness.dark ? 'Dark' : 'Light',
              note:
                  'WCAG 2.x contrast of the label on the badge container '
                  '(text needs 4.5:1) and of the container on the page '
                  '(non-text needs 3:1).',
              child: MorphTheme(
                data: data,
                child: ColoredBox(
                  color: scheme.surface,
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        for (final role in _roles(scheme))
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 4),
                            child: Row(
                              children: [
                                _iconBadge(
                                  count: 42,
                                  background: role.background,
                                  foreground: role.foreground,
                                ),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        role.name,
                                        style: TextStyleHelper.caption(data),
                                      ),
                                      Text(
                                        'text ${contrastLabel(role.background, role.foreground)}',
                                        style: TextStyleHelper.caption(data),
                                      ),
                                      Text(
                                        'on page ${contrastRatio(scheme.surface, role.background).toStringAsFixed(2)}:1',
                                        style: TextStyleHelper.caption(data),
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
              ),
            );
          },
        ),
    ],
  );
}
