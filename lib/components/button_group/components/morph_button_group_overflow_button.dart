part of '../morph_button_group.dart';

/// Overflow trigger button for [_MorphButtonGroupState].
extension _MorphButtonGroupOverflowButton on _MorphButtonGroupState {
  Widget _buildOverflowIndicatorButton(
    BuildContext context, {
    required int start,
    required int end,
    required Widget icon,
    required String semanticLabel,
    required bool isFirst,
    required bool isLast,
    required VoidCallback onPressed,
  }) {
    final groupTheme = MorphTheme.of(context).buttonGroupTheme;
    final segmentHeight = groupTheme.containerHeightFor(
      widget.size,
      density: widget.density,
    );
    return KeyedSubtree(
      key: ValueKey('button-overflow-$start-$end-$isFirst-$isLast'),
      child: MorphButtonGroupItemScope(
        index: isLast ? MorphButtonConstants.kOverflowTriggerScopeIndex : 0,
        count: 1,
        child: SizedBox(
          height: segmentHeight,
          child: MorphButton(
            icon: icon,
            isSelected: _selectedActionInRange(start, end) != null,
            onPressed: onPressed,
            style: widget.style,
            size: _mapSize(widget.size),
            shape: widget.shape,
            decoration:
                widget.decoration ??
                MorphButtonDecoration(minimumSize: Size(0, segmentHeight)),
            isGroupConnected: widget._connected,
            isFirstInGroup: isFirst,
            isLastInGroup: isLast,
            semanticLabel: semanticLabel,
            enableFeedback: widget.enableFeedback,
          ),
        ),
      ),
    );
  }
}
