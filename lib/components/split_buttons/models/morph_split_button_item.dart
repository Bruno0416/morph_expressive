import 'package:morph_expressive/components/split_buttons/morph_split_buttons.dart'
    show MorphSplitButton;
import 'package:morph_expressive/morph_components.dart'
    show MorphSplitButton;

/// A single selectable entry in an [MorphSplitButton] menu.
class MorphSplitButtonItem<T> {
  /// MorphSplitButtonItem.
  const MorphSplitButtonItem({
    required this.value,
    required this.child,
    this.enabled = true,
  });

  /// value.

  final T value;

  /// child.
  final Object child;

  /// enabled.
  final bool enabled;
}
