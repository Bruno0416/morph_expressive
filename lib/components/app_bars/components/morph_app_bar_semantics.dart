import 'package:flutter/rendering.dart';
import 'package:material_ui/material_ui.dart';

/// MorphSliverSemantic.

class MorphSliverSemantic extends SingleChildRenderObjectWidget {
  /// MorphSliverSemantic.
  const MorphSliverSemantic({
    super.key,
    required this.label,
    required Widget child,
  }) : super(child: child);

  /// label.
  final String label;
  @override
  RenderObject createRenderObject(BuildContext context) =>
      MorphSliverSemanticRender(label);
  @override
  void updateRenderObject(
    BuildContext context,
    covariant MorphSliverSemanticRender renderObject,
  ) {
    renderObject.label = label;
  }
}

/// MorphSliverSemanticRender.

class MorphSliverSemanticRender extends RenderProxySliver {
  /// MorphSliverSemanticRender.
  MorphSliverSemanticRender(this._label);
  String _label;

  /// The label.
  String get label => _label;

  /// label.
  set label(String v) {
    if (v == _label) {
      return;
    }
    _label = v;
    markNeedsSemanticsUpdate();
  }

  @override
  void describeSemanticsConfiguration(SemanticsConfiguration config) {
    super.describeSemanticsConfiguration(config);
    config
      ..label = _label
      ..isSemanticBoundary = true;
  }
}
