/// Visible index window for experimental paging overflow.
class MorphButtonGroupOverflowPagingWindow {
  /// Creates a paging window description.
  const MorphButtonGroupOverflowPagingWindow({
    required this.start,
    required this.end,
    required this.needsBack,
    required this.needsForward,
  });

  /// Inclusive start index of the visible range.
  final int start;

  /// Inclusive end index of the visible range.
  final int end;

  /// Whether a back overflow trigger should be shown.
  final bool needsBack;

  /// Whether a forward overflow trigger should be shown.
  final bool needsForward;
}
