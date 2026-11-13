import 'package:flutter/widgets.dart';

import '../../../foundations/foundations.dart';

/// Internal opt-in surface adapter; interaction remains entirely MorphButton's.
class MorphOperationSurface extends InheritedWidget {
  const MorphOperationSurface({
    super.key,
    required this.renderer,
    this.onRendererChanged,
    required super.child,
  });
  final MorphShapeRenderer renderer;
  final ValueChanged<MorphShapeRenderStatus>? onRendererChanged;
  @override
  bool updateShouldNotify(MorphOperationSurface oldWidget) =>
      renderer != oldWidget.renderer ||
      onRendererChanged != oldWidget.onRendererChanged;
}
