// cupertino_ui is not a direct dependency and material_ui does not re-export
// the iOS selection handle controls, so the framework library is the only source.
// ignore: deprecated_member_use
import 'package:flutter/cupertino.dart'
    show
        cupertinoDesktopTextSelectionHandleControls,
        cupertinoTextSelectionHandleControls;
import 'package:flutter/widgets.dart';
import 'package:material_ui/material_ui.dart'
    show
        desktopTextSelectionHandleControls,
        materialTextSelectionHandleControls;

/// Platform text selection handles for the search input.
TextSelectionControls morphSearchSelectionControls(TargetPlatform platform) {
  return switch (platform) {
    TargetPlatform.iOS => cupertinoTextSelectionHandleControls,
    TargetPlatform.macOS => cupertinoDesktopTextSelectionHandleControls,
    TargetPlatform.android ||
    TargetPlatform.fuchsia => materialTextSelectionHandleControls,
    TargetPlatform.linux ||
    TargetPlatform.windows => desktopTextSelectionHandleControls,
  };
}
