import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

import '../../../foundations/foundations.dart';
import 'morph_list_focus_ring.dart';
import 'morph_list_keyboard.dart';

/// Registers a trailing action with the enclosing [MorphListKeyboardGroup].
///
/// Arrows move from the row to its actions, then to the next row.
class MorphListKeyTarget extends StatefulWidget {
  /// Creates a list action focus target.
  const MorphListKeyTarget({
    required this.index,
    required this.child,
    this.slot = 1,
    this.enabled = true,
    this.onActivate,
    super.key,
  });

  /// Row index this action belongs to.
  final int index;

  /// Slot order within the row. Higher slots come later.
  final int slot;

  /// Whether the action can take focus.
  final bool enabled;

  /// Called for Space or Enter when the child does not handle them.
  final VoidCallback? onActivate;

  /// Action control.
  final Widget child;

  @override
  State<MorphListKeyTarget> createState() => _MorphListKeyTargetState();
}

class _MorphListKeyTargetState extends State<MorphListKeyTarget> {
  MorphListKeyboardRegistration? _registration;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _registration ??= MorphListKeyboardGroup.maybeOf(context)
        ?.register(index: widget.index, slot: widget.slot);
    _registration?.enabled = widget.enabled;
  }

  @override
  void didUpdateWidget(MorphListKeyTarget oldWidget) {
    super.didUpdateWidget(oldWidget);
    _registration?.enabled = widget.enabled;
  }

  @override
  void dispose() {
    final MorphListKeyboardRegistration? registration = _registration;
    _registration = null;
    super.dispose();
    registration?.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final MorphListKeyboardRegistration? registration = _registration;
    if (registration == null) {
      return widget.child;
    }
    final MorphThemeData theme = MorphTheme.of(context);
    return ListenableBuilder(
      listenable: Listenable.merge(<Listenable>[
        registration.node,
        MorphFocusInteraction.instance,
      ]),
      builder: (BuildContext context, Widget? _) =>
          _buildFocusRing(registration, theme),
    );
  }

  Widget _buildFocusRing(
    MorphListKeyboardRegistration registration,
    MorphThemeData theme,
  ) {
    final itemTheme = theme.listTheme.item;
    return Focus(
      focusNode: registration.node,
      skipTraversal: !registration.tabStop,
      onKeyEvent: (FocusNode node, KeyEvent event) => _handleKeyEvent(event),
      child: MorphListFocusRing(
        focused:
            registration.node.hasPrimaryFocus && theme.keyboardFocusIndicators,
        radius: BorderRadius.circular(itemTheme.selectedRadius),
        color: itemTheme.resolveFocusIndicator(theme.colorScheme),
        thickness: itemTheme.focusIndicatorThickness,
        inset: itemTheme.focusIndicatorInset,
        child: widget.child,
      ),
    );
  }

  KeyEventResult _handleKeyEvent(KeyEvent event) {
    if (widget.onActivate == null || event is! KeyDownEvent) {
      return KeyEventResult.ignored;
    }
    if (event.logicalKey == LogicalKeyboardKey.enter ||
        event.logicalKey == LogicalKeyboardKey.space) {
      widget.onActivate!();
      return KeyEventResult.handled;
    }
    return KeyEventResult.ignored;
  }
}
