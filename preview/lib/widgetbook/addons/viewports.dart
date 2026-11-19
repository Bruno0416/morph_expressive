import 'package:material_ui/material_ui.dart' show TargetPlatform;
import 'package:widgetbook/widgetbook.dart';

/// Viewports offered by the Widgetbook viewport addon.
///
/// The first entry fills the canvas; the others render the use case in a
/// fixed-size frame so compact and expanded layouts can be compared.
final List<ViewportData> morphViewports = <ViewportData>[
  Viewports.none,
  const ViewportData(
    name: 'Compact mobile 320x568',
    width: 320,
    height: 568,
    pixelRatio: 2,
    platform: TargetPlatform.android,
  ),
  const ViewportData(
    name: 'Mobile 390x844',
    width: 390,
    height: 844,
    pixelRatio: 3,
    platform: TargetPlatform.android,
  ),
  const ViewportData(
    name: 'Tablet 834x1112',
    width: 834,
    height: 1112,
    pixelRatio: 2,
    platform: TargetPlatform.android,
  ),
  const ViewportData(
    name: 'Desktop 1280x800',
    width: 1280,
    height: 800,
    pixelRatio: 1,
    platform: TargetPlatform.linux,
  ),
];
