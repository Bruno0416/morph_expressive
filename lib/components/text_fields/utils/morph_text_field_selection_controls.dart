import 'package:flutter/cupertino.dart'
    show
        cupertinoDesktopTextSelectionHandleControls,
        cupertinoTextSelectionHandleControls;
import 'package:flutter/widgets.dart';
import 'package:material_ui/material_ui.dart'
    show
        desktopTextSelectionHandleControls,
        materialTextSelectionHandleControls;

/// Platform text selection handles for `MorphTextField`.
TextSelectionControls morphTextFieldSelectionControls(TargetPlatform platform) {
  return switch (platform) {
    TargetPlatform.iOS => cupertinoTextSelectionHandleControls,
    TargetPlatform.macOS => cupertinoDesktopTextSelectionHandleControls,
    TargetPlatform.android ||
    TargetPlatform.fuchsia => materialTextSelectionHandleControls,
    TargetPlatform.linux ||
    TargetPlatform.windows => desktopTextSelectionHandleControls,
  };
}

/// Whether force press selects text on [platform].
bool morphTextFieldForcePressEnabled(TargetPlatform platform) =>
    platform == TargetPlatform.iOS;
