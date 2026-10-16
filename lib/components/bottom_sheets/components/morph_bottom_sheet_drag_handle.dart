import 'package:flutter/semantics.dart';
import 'package:flutter/widgets.dart';
import 'package:material_ui/material_ui.dart'
    show InkSparkle, InkWell, Material, MaterialType, WidgetState;

import '../../../foundations/foundations.dart';
import '../styles/morph_bottom_sheet_theme.dart';

/// Drag handle button of a bottom sheet.
///
/// A 48dp target around the 32×4 handle. Tab focuses it; tap, Space and
/// Enter call [onActivate]. Only this element is labelled (role button).
class MorphBottomSheetDragHandle extends StatelessWidget {
  /// MorphBottomSheetDragHandle.
  const MorphBottomSheetDragHandle({
    required this.theme,
    required this.label,
    required this.value,
    required this.onActivate,
    this.actions = const <CustomSemanticsAction, VoidCallback>{},
    this.focusNode,
    super.key,
  });

  /// Resolved sheet theme.
  final MorphBottomSheetTheme theme;

  /// Accessibility label.
  final String label;

  /// Spoken current height.
  final String value;

  /// Cycles the preset heights.
  final VoidCallback? onActivate;

  /// Expand / collapse / dismiss semantic actions.
  final Map<CustomSemanticsAction, VoidCallback> actions;

  /// Focus node of the handle.
  final FocusNode? focusNode;

  @override
  Widget build(BuildContext context) {
    final MorphBottomSheetDragHandleStyle style = theme.dragHandle;
    return MorphTappable(
      materialInk: true,
      onTap: onActivate,
      focusNode: focusNode,
      focusOverlay: false,
      mouseCursor: style.mouseCursor,
      semanticLabel: label,
      builder: (BuildContext context, MorphInteractionState state) {
        return Semantics(
          value: value,
          customSemanticsActions: actions,
          child: SizedBox.square(
            dimension: style.targetSize,
            child: Builder(
              builder: (BuildContext context) =>
                  _ink(context, state, Center(child: _pill(context, state))),
            ),
          ),
        );
      },
    );
  }

  Widget _pill(BuildContext context, MorphInteractionState state) {
    final MorphColorScheme scheme = MorphTheme.of(context).colorScheme;
    final radius = BorderRadius.circular(theme.handleCornerRadius);
    return MorphFocusRing(
      focused: state.focused,
      radius: radius,
      color: theme.focusRingColor(scheme),
      width: theme.dragHandle.focusRingWidth,
      gap: theme.dragHandle.focusRingGap,
      child: Container(
        width: theme.handleWidth,
        height: theme.handleHeight,
        decoration: BoxDecoration(
          color: theme.handleColor(scheme),
          borderRadius: radius,
        ),
      ),
    );
  }

  Widget _ink(BuildContext context, MorphInteractionState state, Widget child) {
    final MorphTappableInkScope? ink = MorphTappableInkScope.maybeOf(context);
    if (ink == null || !ink.isInteractive) {
      return child;
    }
    final MorphBottomSheetDragHandleStyle style = theme.dragHandle;
    final Color color = theme.handleStateColor(
      MorphTheme.of(context).colorScheme,
    );
    const shape = CircleBorder();
    return Material(
      type: MaterialType.transparency,
      shape: shape,
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        enableFeedback: false,
        onTap: ink.onTap,
        onTapDown: ink.onTapDown,
        onTapUp: ink.onTapUp,
        onTapCancel: ink.onTapCancel,
        onHover: ink.onHover,
        mouseCursor: ink.mouseCursor ?? MouseCursor.defer,
        canRequestFocus: false,
        customBorder: shape,
        splashFactory: InkSparkle.splashFactory,
        splashColor: color.withValues(alpha: style.pressedOpacity),
        highlightColor: const Color(0x00000000),
        overlayColor: WidgetStateProperty.resolveWith((Set<WidgetState> s) {
          if (s.contains(WidgetState.pressed)) {
            return null;
          }
          if (s.contains(WidgetState.hovered)) {
            return color.withValues(alpha: style.hoverOpacity);
          }
          return state.showFocusFill
              ? color.withValues(alpha: style.focusOpacity)
              : null;
        }),
        child: child,
      ),
    );
  }
}
