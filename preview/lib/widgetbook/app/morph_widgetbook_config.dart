import 'package:material_ui/material_ui.dart'
    show
        BuildContext,
        Color,
        PageRouteBuilder,
        RouteSettings,
        Widget,
        WidgetBuilder,
        WidgetsApp;
import 'package:widgetbook/widgetbook.dart';

import '../addons/background_addon.dart';
import '../addons/morph_scope_addon.dart';
import '../addons/viewports.dart';

/// Addons of the catalog, outermost first: the viewport frames the Morph
/// scope, the scope provides the Material/Morph themes plus a Navigator and an
/// Overlay, and the remaining addons paint inside it.
List<WidgetbookAddon> morphWidgetbookAddons() => [
  ViewportAddon(morphViewports),
  TextScaleAddon(min: 0.8, max: 2.0, divisions: 12, initialScale: 1.0),
  MorphScopeAddon(),
  MorphBackgroundAddon(),
  InspectorAddon(),
];

/// Widgetbook's default WidgetsApp builder uses `home` without a
/// `pageRouteBuilder`, which asserts. This builder keeps a Navigator for the
/// workbench itself; each use case additionally gets its own MaterialApp
/// (Navigator + Overlay) from the Morph scope addon.
Widget morphWidgetbookAppBuilder(BuildContext context, Widget child) =>
    WidgetsApp(
      color: const Color(0xFF121014),
      debugShowCheckedModeBanner: false,
      home: child,
      pageRouteBuilder: <T>(RouteSettings settings, WidgetBuilder builder) =>
          PageRouteBuilder<T>(
            settings: settings,
            pageBuilder: (context, animation, secondaryAnimation) =>
                builder(context),
          ),
    );
