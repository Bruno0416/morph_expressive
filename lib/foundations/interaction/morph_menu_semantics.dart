import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';

/// Marks its subtree as a semantic `menu` **only while it has accessible
/// children**.
///
/// Flutter asserts (`a menu cannot be empty`, in `SemanticsNode._addToUpdate`)
/// when a node with `SemanticsRole.menu` ends up without children, which
/// happens legitimately when every item is clipped out of a viewport, excluded
/// or not built yet (scrolled lists, opening/closing animations). This wrapper
/// decides at semantics-assembly time, from the real child nodes, so a closed
/// or fully culled menu leaves no empty container behind. Nothing is faked and
/// no assertion is suppressed.
class MorphMenuSemantics extends SingleChildRenderObjectWidget {
  const MorphMenuSemantics({super.key, this.label, super.child});

  /// Optional accessible name of the menu.
  final String? label;

  @override
  RenderObject createRenderObject(BuildContext context) =>
      _RenderMenuSemantics(label);

  @override
  void updateRenderObject(BuildContext context, RenderObject renderObject) {
    (renderObject as _RenderMenuSemantics).label = label;
  }
}

class _RenderMenuSemantics extends RenderProxyBox {
  _RenderMenuSemantics(this._label);

  String? _label;
  set label(String? v) {
    if (v == _label) return;
    _label = v;
    markNeedsSemanticsUpdate();
  }

  @override
  void describeSemanticsConfiguration(SemanticsConfiguration config) {
    super.describeSemanticsConfiguration(config);
    config
      ..isSemanticBoundary = true
      ..explicitChildNodes = true
      ..role = SemanticsRole.menu;
    if (_label != null) config.label = _label!;
  }

  @override
  void assembleSemanticsNode(
    SemanticsNode node,
    SemanticsConfiguration config,
    Iterable<SemanticsNode> children,
  ) {
    // Decide from the real child nodes. Content merged into this node (items
    // that are not their own nodes) is kept; only the menu role is dropped
    // when there is no accessible child. The role is set every time because
    // the configuration object is cached between assemblies.
    config.role = children.isEmpty ? SemanticsRole.none : SemanticsRole.menu;
    super.assembleSemanticsNode(node, config, children);
  }
}
