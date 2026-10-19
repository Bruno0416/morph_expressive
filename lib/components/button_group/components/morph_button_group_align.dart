part of '../morph_button_group.dart';

/// Sets cross-axis alignment for a child inside an [MorphButtonGroup].
class MorphButtonGroupAlign
    extends ParentDataWidget<MorphButtonGroupParentData> {
  /// Creates an alignment widget for a group child.
  const MorphButtonGroupAlign({
    super.key,
    required this.alignment,
    required super.child,
  });

  /// Cross-axis alignment applied to the child.
  final CrossAxisAlignment alignment;

  @override
  void applyParentData(RenderObject renderObject) {
    assert(
      renderObject.parentData is MorphButtonGroupParentData,
      'parentData must be MorphButtonGroupParentData',
    );
    final parentData = renderObject.parentData! as MorphButtonGroupParentData;
    var needsLayout = false;

    if (parentData.alignment != alignment) {
      parentData.alignment = alignment;
      needsLayout = true;
    }

    if (needsLayout) {
      final targetParent = renderObject.parent;
      if (targetParent is RenderObject) {
        targetParent.markNeedsLayout();
      }
    }
  }

  @override
  Type get debugTypicalAncestorWidgetClass => MorphButtonGroup;
}
