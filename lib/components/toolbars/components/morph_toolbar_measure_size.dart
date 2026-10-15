import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';

/// Reports child size changes for scroll-exit offsetLimit updates.
class MorphToolbarMeasureSize extends SingleChildRenderObjectWidget {
  /// MorphToolbarMeasureSize.
  const MorphToolbarMeasureSize({
    required this.onChange,
    required Widget super.child,
    super.key,
  });

  /// onChange.
  final ValueChanged<Size> onChange;

  @override
  RenderObject createRenderObject(BuildContext context) {
    return RenderMorphToolbarMeasureSize(onChange: onChange);
  }

  @override
  void updateRenderObject(
    BuildContext context,
    covariant RenderMorphToolbarMeasureSize renderObject,
  ) {
    renderObject.onChange = onChange;
  }
}

/// Render object that notifies [onChange] when the child size changes.
class RenderMorphToolbarMeasureSize extends RenderProxyBox {
  /// Creates a measure-size render object.
  RenderMorphToolbarMeasureSize({required this.onChange});

  /// Called when the laid-out child size changes.
  ValueChanged<Size> onChange;
  Size? _oldSize;

  @override
  void performLayout() {
    super.performLayout();
    final Size? newSize = child?.size;
    if (newSize != null && _oldSize != newSize) {
      _oldSize = newSize;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        onChange(newSize);
      });
    }
  }
}
