import 'package:material_ui/material_ui.dart'
    show
        BuildContext,
        Column,
        CrossAxisAlignment,
        EdgeInsets,
        MainAxisSize,
        Padding,
        SizedBox,
        State,
        StatefulWidget,
        VoidCallback,
        Widget,
        WrapCrossAlignment;
import 'package:morph_expressive/morph_expressive.dart';
import 'package:widgetbook/widgetbook.dart';
import 'package:widgetbook_annotation/widgetbook_annotation.dart' as widgetbook;

import '../../addons/background_addon.dart';
import '../../utilities/demo.dart';
import '../../utilities/knobs.dart';
import '../../utilities/stage.dart';

const _path = '[Surfaces & Content]/Cards';

/// Builds a [MorphCard] through the named constructor for [type].
Widget _cardOfType(
  MorphCardType type, {
  MorphVariant? variant,
  MorphSurface surface = MorphSurface.solid,
  VoidCallback? onPressed,
  String? headline,
  String? subhead,
  String? supportingText,
  Widget? child,
  Widget? media,
  bool enabled = true,
  double? width,
}) {
  switch (type) {
    case MorphCardType.elevated:
      return MorphCard.elevated(
        variant: variant,
        surface: surface,
        onPressed: onPressed,
        headline: headline,
        subhead: subhead,
        supportingText: supportingText,
        media: media,
        enabled: enabled,
        width: width,
        child: child,
      );
    case MorphCardType.filled:
      return MorphCard.filled(
        variant: variant,
        surface: surface,
        onPressed: onPressed,
        headline: headline,
        subhead: subhead,
        supportingText: supportingText,
        media: media,
        enabled: enabled,
        width: width,
        child: child,
      );
    case MorphCardType.outlined:
      return MorphCard.outlined(
        variant: variant,
        surface: surface,
        onPressed: onPressed,
        headline: headline,
        subhead: subhead,
        supportingText: supportingText,
        media: media,
        enabled: enabled,
        width: width,
        child: child,
      );
  }
}

@widgetbook.UseCase(name: 'Matrix', type: MorphCard, path: _path)
Widget cardMatrixUseCase(BuildContext context) {
  final enabled = context.knobs.boolean(label: 'enabled', initialValue: true);
  final interactive = context.knobs.boolean(
    label: 'interactive',
    initialValue: true,
  );
  final withMedia = context.knobs.boolean(label: 'media');
  final variants = <MorphVariant?>[null, ...MorphVariant.values];
  Widget cell(MorphCardType type, MorphVariant? variant, MorphSurface surface) {
    return _cardOfType(
      type,
      variant: variant,
      surface: surface,
      width: 168,
      enabled: enabled,
      onPressed: interactive ? () {} : null,
      headline: variant?.name ?? 'default',
      supportingText: type.name,
      media: withMedia
          ? const SizedBox(height: 56, child: DemoImage(index: 1))
          : null,
    );
  }

  return Stage(
    children: [
      for (final type in MorphCardType.values)
        StageSection(
          title: 'MorphCard.${type.name}',
          note:
              'Solid surface. Columns: default (null) and every MorphVariant.',
          child: StageWrap(
            spacing: 14,
            runSpacing: 14,
            crossAxisAlignment: WrapCrossAlignment.start,
            children: [
              for (final variant in variants)
                cell(type, variant, MorphSurface.solid),
            ],
          ),
        ),
      StageSection(
        title: 'Frosted over a decorative background',
        note: 'surface: MorphSurface.frosted for every type and variant.',
        child: MorphBackdrop(
          style: MorphPreviewBackground.pattern,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                for (final type in MorphCardType.values) ...[
                  StageWrap(
                    spacing: 14,
                    runSpacing: 14,
                    crossAxisAlignment: WrapCrossAlignment.start,
                    children: [
                      for (final variant in variants)
                        cell(type, variant, MorphSurface.frosted),
                    ],
                  ),
                  const SizedBox(height: 14),
                ],
              ],
            ),
          ),
        ),
      ),
    ],
  );
}

@widgetbook.UseCase(name: 'Playground', type: MorphCard, path: _path)
Widget cardPlaygroundUseCase(BuildContext context) {
  final type = enumKnob<MorphCardType>(
    context,
    label: 'type',
    values: MorphCardType.values,
  );
  final variant = variantKnob(context);
  final surface = surfaceKnob(context);
  final enabled = context.knobs.boolean(label: 'enabled', initialValue: true);
  final interactive = context.knobs.boolean(
    label: 'interactive',
    initialValue: true,
  );
  final headline = context.knobs.string(
    label: 'headline',
    initialValue: 'Card headline',
  );
  final subhead = context.knobs.string(
    label: 'subhead',
    initialValue: 'Supporting subhead',
  );
  final body = context.knobs.string(
    label: 'supporting text',
    initialValue: 'A card with structured slots, ready to be tapped.',
  );
  final media = context.knobs.boolean(label: 'media');
  final width = context.knobs.double.slider(
    label: 'width',
    initialValue: 320,
    min: 160,
    max: 560,
  );
  return _CardHarness(
    type: type,
    variant: variant,
    surface: surface,
    enabled: enabled,
    interactive: interactive,
    headline: headline,
    subhead: subhead,
    body: body,
    media: media,
    width: width,
  );
}

class _CardHarness extends StatefulWidget {
  const _CardHarness({
    required this.type,
    required this.variant,
    required this.surface,
    required this.enabled,
    required this.interactive,
    required this.headline,
    required this.subhead,
    required this.body,
    required this.media,
    required this.width,
  });

  final MorphCardType type;
  final MorphVariant? variant;
  final MorphSurface surface;
  final bool enabled;
  final bool interactive;
  final String headline;
  final String subhead;
  final String body;
  final bool media;
  final double width;

  @override
  State<_CardHarness> createState() => _CardHarnessState();
}

class _CardHarnessState extends State<_CardHarness> {
  int _taps = 0;

  @override
  Widget build(BuildContext context) {
    return StageCenter(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _cardOfType(
            widget.type,
            variant: widget.variant,
            surface: widget.surface,
            enabled: widget.enabled,
            width: widget.width,
            onPressed: widget.interactive
                ? () => setState(() => _taps++)
                : null,
            headline: widget.headline,
            subhead: widget.subhead,
            supportingText: widget.body,
            media: widget.media
                ? const SizedBox(height: 120, child: DemoImage(index: 2))
                : null,
          ),
          const SizedBox(height: 16),
          DemoReadout('Tapped $_taps times'),
        ],
      ),
    );
  }
}

@widgetbook.UseCase(name: 'Card group', type: MorphCardGroup, path: _path)
Widget cardGroupUseCase(BuildContext context) {
  final layout = enumKnob<MorphCardGroupLayout>(
    context,
    label: 'layout',
    values: MorphCardGroupLayout.values,
    initial: MorphCardGroupLayout.list,
  );
  final count = context.knobs.int.slider(
    label: 'cards',
    initialValue: 5,
    min: 2,
    max: 12,
  );
  final type = enumKnob<MorphCardType>(
    context,
    label: 'type',
    values: MorphCardType.values,
    initial: MorphCardType.filled,
  );
  return Stage(
    children: [
      SizedBox(
        height: layout == MorphCardGroupLayout.carousel ? 220 : null,
        child: MorphCardGroup(
          key: resetKey([layout, count, type]),
          layout: layout,
          children: [
            for (var i = 0; i < count; i++)
              _cardOfType(
                type,
                headline: 'Card ${i + 1}',
                supportingText: 'Grouped content',
                onPressed: () {},
              ),
          ],
        ),
      ),
    ],
  );
}
