import 'package:flutter/widgets.dart';

import '../../foundations/foundations.dart';
import 'enums/morph_divider_axis.dart';
import 'enums/morph_divider_inset.dart';

export 'enums/morph_divider_axis.dart';
export 'enums/morph_divider_inset.dart';
export 'styles/morph_divider_theme.dart';

/// A Material 3 Expressive divider.
///
/// A thin decorative line. [MorphDividerInset.full] spans the cross axis.
/// [MorphDividerInset.inset] indents the leading edge. [MorphDividerInset.middle]
/// indents both edges. [outerMargin] adds the theme's end and bottom margins.
class MorphDivider extends StatelessWidget {
  /// Creates a divider.
  const MorphDivider({
    this.axis = MorphDividerAxis.horizontal,
    this.inset = MorphDividerInset.full,
    this.thickness,
    this.indent,
    this.endIndent,
    this.outerMargin = false,
    this.color,
    super.key,
  });

  /// Horizontal or vertical line.
  final MorphDividerAxis axis;

  /// Which measured inset to use when [indent] or [endIndent] is null.
  final MorphDividerInset inset;

  /// Line thickness. Null uses the theme thickness.
  final double? thickness;

  /// Leading inset along the line. Null uses [inset].
  final double? indent;

  /// Trailing inset along the line. Null uses [inset].
  final double? endIndent;

  /// Whether to add the theme end and bottom margins.
  final bool outerMargin;

  /// Line color. Null uses outline variant.
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return MorphComponentTheme(builder: _buildDivider);
  }

  Widget _buildDivider(BuildContext context) {
    final theme = MorphTheme.of(context);
    final dividerTheme = theme.dividerTheme;
    final Color line = color ?? dividerTheme.color(theme.colorScheme);
    final double lineThickness = thickness ?? dividerTheme.thickness;
    final double start = indent ?? dividerTheme.startFor(inset);
    final double end = endIndent ?? dividerTheme.endFor(inset);
    final EdgeInsetsGeometry padding = axis == MorphDividerAxis.vertical
        ? EdgeInsetsDirectional.only(
            top: start,
            bottom: end + (outerMargin ? dividerTheme.bottomMargin : 0),
            end: outerMargin ? dividerTheme.endMargin : 0,
          )
        : EdgeInsetsDirectional.only(
            start: start,
            end: end + (outerMargin ? dividerTheme.endMargin : 0),
            bottom: outerMargin ? dividerTheme.bottomMargin : 0,
          );

    final Widget rule = axis == MorphDividerAxis.vertical
        ? Padding(
            padding: padding,
            child: LayoutBuilder(
              builder: (BuildContext context, BoxConstraints constraints) {
                final double? height = constraints.hasBoundedHeight
                    ? constraints.maxHeight
                    : null;
                return SizedBox(
                  width: lineThickness,
                  height: height,
                  child: ColoredBox(color: line),
                );
              },
            ),
          )
        : Padding(
            padding: padding,
            child: SizedBox(
              height: lineThickness,
              width: double.infinity,
              child: ColoredBox(color: line),
            ),
          );

    return ExcludeSemantics(child: rule);
  }
}
