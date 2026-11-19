import 'package:material_ui/material_ui.dart'
    show BuildContext, Icon, SizedBox, Widget;
import 'package:morph_expressive/morph_expressive.dart';
import 'package:widgetbook/widgetbook.dart';
import 'package:widgetbook_annotation/widgetbook_annotation.dart' as widgetbook;

import '../../utilities/knobs.dart';
import '../../utilities/stage.dart';

@widgetbook.UseCase(
  name: 'Playground',
  type: MorphBadge,
  path: '[Surfaces & Content]/Badges',
)
Widget badgePlaygroundUseCase(BuildContext context) {
  final count = context.knobs.int.slider(
    label: 'count (0 = none)',
    initialValue: 5,
    min: 0,
    max: 1200,
  );
  final maxCount = context.knobs.int.slider(
    label: 'max count',
    initialValue: 99,
    min: 1,
    max: 999,
  );
  final dot = context.knobs.boolean(label: 'dot');
  final label = context.knobs.string(label: 'text label');
  final alignment = enumKnob<MorphBadgeAlignment>(
    context,
    label: 'alignment',
    values: MorphBadgeAlignment.values,
  );
  return StageCenter(
    child: MorphBadge(
      count: count == 0 ? null : count,
      maxCount: maxCount,
      showDot: dot,
      label: label.isEmpty ? null : label,
      alignment: alignment,
      child: Icon(FluentIcons.line.mail, size: 40),
    ),
  );
}

@widgetbook.UseCase(
  name: 'Playground',
  type: MorphDivider,
  path: '[Surfaces & Content]/Dividers',
)
Widget dividerPlaygroundUseCase(BuildContext context) {
  final axis = enumKnob<MorphDividerAxis>(
    context,
    label: 'axis',
    values: MorphDividerAxis.values,
  );
  final inset = enumKnob<MorphDividerInset>(
    context,
    label: 'inset',
    values: MorphDividerInset.values,
  );
  final thickness = context.knobs.double.slider(
    label: 'thickness',
    initialValue: 1,
    min: 1,
    max: 8,
  );
  final margin = context.knobs.boolean(label: 'outer margin');
  final vertical = axis == MorphDividerAxis.vertical;
  return StageCenter(
    child: SizedBox(
      width: vertical ? null : 360,
      height: vertical ? 160 : null,
      child: MorphDivider(
        axis: axis,
        inset: inset,
        thickness: thickness,
        outerMargin: margin,
      ),
    ),
  );
}
