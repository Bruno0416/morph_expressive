import 'package:flutter/widgets.dart';

import '../models/morph_search_anchor_surface.dart';

/// Shares a [MorphSearchAnchorSurface] with search bars built by an anchor.
class MorphSearchAnchorScope extends InheritedWidget {
  /// MorphSearchAnchorScope.
  const MorphSearchAnchorScope({
    required this.surface,
    required super.child,
    super.key,
  });

  /// Surface the anchor measures for its container transform.
  final MorphSearchAnchorSurface surface;

  /// Nearest surface, without a rebuild dependency.
  static MorphSearchAnchorSurface? maybeOf(BuildContext context) {
    return context
        .getInheritedWidgetOfExactType<MorphSearchAnchorScope>()
        ?.surface;
  }

  @override
  bool updateShouldNotify(MorphSearchAnchorScope oldWidget) =>
      surface != oldWidget.surface;
}
