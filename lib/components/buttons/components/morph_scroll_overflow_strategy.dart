import 'package:material_ui/material_ui.dart';

import '../../button_group/models/morph_button_group_action.dart';
import '../enums/morph_button_enums.dart';
import '../styles/morph_button_decoration.dart';
import 'morph_overflow_strategy.dart';

/// Overflow strategy that scrolls the actions inline in a single axis.
class MorphScrollOverflowStrategy extends MorphOverflowStrategy {
  /// MorphScrollOverflowStrategy.
  const MorphScrollOverflowStrategy();

  @override
  String get id => 'scroll';

  @override
  Widget buildLayout({
    required BuildContext context,
    required List<MorphButtonGroupAction> actions,
    required int visibleCount,
    required double spacing,
    required Axis direction,
    required MorphButtonStyle style,
    required MorphButtonSize size,
    required MorphButtonDecoration? decoration,
    required bool connected,
    required bool isRtl,
    required Widget Function(
      int index, {
      required bool isFirst,
      required bool isLast,
    })
    buildButton,
  }) {
    final children = MorphOverflowStrategy.buildVisibleButtons(
      count: actions.length,
      isRtl: isRtl,
      buildButton: buildButton,
    );

    return SingleChildScrollView(
      scrollDirection: direction,
      primary: false,
      child: MorphOverflowStrategy.axisFlex(children, direction),
    );
  }

  @override
  Widget? buildOverflowTrigger({
    required BuildContext context,
    required int hiddenCount,
    required MorphButtonStyle style,
    required MorphButtonSize size,
    required MorphButtonDecoration? decoration,
    required bool connected,
    required bool isFirst,
    required bool isLast,
    required VoidCallback onPressed,
    required bool isSelected,
  }) => null;

  @override
  Future<int?> showOverflowMenu({
    required BuildContext context,
    required List<MorphButtonGroupAction> actions,
    required int firstHiddenIndex,
    required int? selectedIndex,
  }) async => null;
}
