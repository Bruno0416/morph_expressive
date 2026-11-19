import 'package:material_ui/material_ui.dart'
    show
        BuildContext,
        Column,
        CrossAxisAlignment,
        EdgeInsets,
        Padding,
        SizedBox,
        Text,
        TextOverflow,
        TextStyle,
        Widget;
import 'package:morph_expressive/morph_expressive.dart';
import 'package:widgetbook/widgetbook.dart';
import 'package:widgetbook_annotation/widgetbook_annotation.dart' as widgetbook;

import '../../utilities/stage.dart';

const _path = '[Foundations]/Typography';

@widgetbook.UseCase(name: 'Type scale', type: MorphTypography, path: _path)
Widget typeScaleUseCase(BuildContext context) {
  final morph = MorphTheme.of(context);
  final sample = context.knobs.string(
    label: 'sample text',
    initialValue: 'Expressive shapes, springs and colour',
  );
  final roles = <(String, TextStyle?)>[
    ('displayLarge', morph.textTheme.displayLarge),
    ('displayMedium', morph.textTheme.displayMedium),
    ('displaySmall', morph.textTheme.displaySmall),
    ('headlineLarge', morph.textTheme.headlineLarge),
    ('headlineMedium', morph.textTheme.headlineMedium),
    ('headlineSmall', morph.textTheme.headlineSmall),
    ('titleLarge', morph.textTheme.titleLarge),
    ('titleMedium', morph.textTheme.titleMedium),
    ('titleSmall', morph.textTheme.titleSmall),
    ('bodyLarge', morph.textTheme.bodyLarge),
    ('bodyMedium', morph.textTheme.bodyMedium),
    ('bodySmall', morph.textTheme.bodySmall),
    ('labelLarge', morph.textTheme.labelLarge),
    ('labelMedium', morph.textTheme.labelMedium),
    ('labelSmall', morph.textTheme.labelSmall),
  ];
  return Stage(
    gap: 14,
    children: [
      for (final (name, style) in roles)
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '$name · ${style?.fontSize?.toStringAsFixed(0) ?? '-'} px',
              style: morph.textTheme.labelSmall?.copyWith(
                color: morph.colorScheme.onSurfaceVariant,
              ),
            ),
            Text(sample, style: style),
          ],
        ),
    ],
  );
}

@widgetbook.UseCase(
  name: 'Text scale and direction',
  type: MorphTypography,
  path: _path,
)
Widget typeScaleDirectionUseCase(BuildContext context) {
  final morph = MorphTheme.of(context);
  final maxLines = context.knobs.int.slider(
    label: 'max lines',
    initialValue: 2,
    min: 1,
    max: 5,
  );
  return Stage(
    children: [
      StageSection(
        title: 'Responds to the Text scale and RTL controls',
        note:
            'Use the Text scale slider and the rtl switch in the Morph panel '
            'to check wrapping and ellipsis.',
        child: SizedBox(
          width: 320,
          child: MorphCard.outlined(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                'Material 3 Expressive uses motion, shape and colour to make '
                'interfaces feel alive. This paragraph wraps and truncates '
                'according to the active text scale.',
                maxLines: maxLines,
                overflow: TextOverflow.ellipsis,
                style: morph.textTheme.bodyLarge,
              ),
            ),
          ),
        ),
      ),
    ],
  );
}
