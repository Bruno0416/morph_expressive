part of '../morph_toolbars.dart';

extension _MorphToolbarExitOffset on _MorphToolbarState {
  Offset _exitOffset(BuildContext context, double offset) {
    switch (_exitDirection) {
      case MorphToolbarExitDirection.top:
        return Offset(0, offset);
      case MorphToolbarExitDirection.bottom:
        return Offset(0, -offset);
      case MorphToolbarExitDirection.start:
        final isRtl = Directionality.of(context) == TextDirection.rtl;
        return Offset(isRtl ? -offset : offset, 0);
      case MorphToolbarExitDirection.end:
        final isRtl = Directionality.of(context) == TextDirection.rtl;
        return Offset(isRtl ? offset : -offset, 0);
    }
  }
}
