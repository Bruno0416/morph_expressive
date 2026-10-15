import 'package:flutter/widgets.dart';

/// Reports the rendered size of [child] to [onChange] after each layout.
class MorphMeasureSize extends StatefulWidget {
  /// child.
  final Widget child;

  /// Function.
  final void Function(Size) onChange;

  /// MorphMeasureSize.

  const MorphMeasureSize({
    super.key,
    required this.child,
    required this.onChange,
  });

  @override
  State<MorphMeasureSize> createState() => _MorphMeasureSizeState();
}

class _MorphMeasureSizeState extends State<MorphMeasureSize> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _notifySize());
  }

  @override
  void didUpdateWidget(covariant MorphMeasureSize oldWidget) {
    super.didUpdateWidget(oldWidget);
    WidgetsBinding.instance.addPostFrameCallback((_) => _notifySize());
  }

  void _notifySize() {
    if (mounted) {
      final box = context.findRenderObject() as RenderBox?;
      if (box != null && box.hasSize) {
        widget.onChange(box.size);
      }
    }
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
