import 'package:flutter/gestures.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart' show Scaffold;
import 'package:morph_expressive/morph_expressive.dart';

/// Default test viewport.
const Size kContextViewport = Size(800, 600);

/// Sizes the test window (device pixel ratio 1) and restores it on teardown.
void setContextViewport(WidgetTester tester, [Size size = kContextViewport]) {
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
}

/// Standard menu content used by most context-menu tests.
List<MorphMenuNode> sampleMenu({bool icons = true}) => <MorphMenuNode>[
  MorphMenuEntry(
    label: 'Open',
    value: 'open',
    leading: icons ? const Icon(MorphIcons.check_rounded) : null,
    trailingText: 'Ctrl+O',
  ),
  const MorphMenuEntry(label: 'Rename', value: 'rename'),
  const MorphMenuEntry(label: 'Disabled', value: 'disabled', enabled: false),
  const MorphMenuDivider(),
  const MorphMenuSubmenu(
    label: 'Move to',
    children: <MorphMenuNode>[
      MorphMenuEntry(label: 'Design', value: 'design'),
      MorphMenuEntry(label: 'Archive', value: 'archive'),
    ],
  ),
  const MorphMenuEntry(label: 'Delete', value: 'delete', isDestructive: true),
];

/// A full-window region (right-click anywhere opens [children]).
Widget contextHost({
  List<MorphMenuNode>? children,
  MorphDensity density = MorphDensity.standard,
  bool dark = false,
  MorphSurfaceGlass? glass,
  ValueChanged<Object>? onSelected,
  FocusNode? focusNode,
  Widget? child,
  bool openOnLongPress = true,
  bool enabled = true,
  MorphDensity? regionDensity,
  MorphThemeData? theme,
  TextDirection direction = TextDirection.ltr,
}) {
  final MorphThemeData data =
      theme ??
      (dark ? MorphThemeData.dark() : MorphThemeData.light()).copyWith(
        density: density,
      );
  return MorphMaterialApp(
    data: data,
    appBuilder: (BuildContext context, Widget? child) =>
        Directionality(textDirection: direction, child: child!),
    home: Scaffold(
      body: MorphContextMenuRegion<Object>(
        children: children ?? sampleMenu(),
        onSelected: onSelected,
        glass: glass,
        focusNode: focusNode,
        density: regionDensity,
        openOnLongPress: openOnLongPress,
        enabled: enabled,
        child: child ?? const SizedBox.expand(),
      ),
    ),
  );
}

/// Secondary-button click at [at] with a mouse (the pointer is removed again,
/// so a later [mousePointer] starts clean). With [settle] false only one frame
/// is pumped.
Future<void> rightClick(
  WidgetTester tester,
  Offset at, {
  bool settle = true,
}) async {
  final TestGesture gesture = await tester.createGesture(
    kind: PointerDeviceKind.mouse,
    buttons: kSecondaryMouseButton,
  );
  await gesture.addPointer(location: at);
  await gesture.down(at);
  await gesture.up();
  await gesture.removePointer();
  if (settle) {
    await settleMenu(tester);
  } else {
    await tester.pump();
  }
}

/// Lets the (short) menu animations finish.
Future<void> settleMenu(WidgetTester tester) async {
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 200));
  await tester.pump(const Duration(milliseconds: 200));
}

/// A mouse pointer parked inside the window.
Future<TestGesture> mousePointer(
  WidgetTester tester, [
  Offset at = const Offset(700, 550),
]) async {
  final TestGesture gesture = await tester.createGesture(
    kind: PointerDeviceKind.mouse,
  );
  await gesture.addPointer(location: at);
  addTearDown(gesture.removePointer);
  return gesture;
}

/// Keyed panel (surface plus shadow margin) of the desktop menus.
Finder get panelFinder =>
    find.byKey(const ValueKey<String>('morph-menu-panel'));

/// Visible surface rect of the root (first) or deepest (last) desktop menu:
/// the panel without its shadow margin (elevation level2 * 2 = 6 px).
Rect surfaceRect(WidgetTester tester, {bool deepest = false}) {
  final Finder panels = panelFinder;
  return tester.getRect(deepest ? panels.last : panels.first).deflate(6);
}

/// Rect of the row labelled [label].
Rect rowRect(WidgetTester tester, String label) {
  return tester.getRect(
    find
        .ancestor(of: find.text(label), matching: find.byType(MorphMenuItem))
        .first,
  );
}

/// Whether [label] is the focused (highlighted) row.
bool rowFocused(WidgetTester tester, String label) {
  final FocusNode? primary = FocusManager.instance.primaryFocus;
  if (primary == null || primary.context == null) {
    return false;
  }
  final Finder row = find.ancestor(
    of: find.text(label),
    matching: find.byType(MorphMenuItem),
  );
  if (row.evaluate().isEmpty) {
    return false;
  }
  final Element rowElement = row.first.evaluate().single;
  var found = false;
  primary.context!.visitAncestorElements((Element e) {
    if (identical(e, rowElement)) {
      found = true;
      return false;
    }
    return true;
  });
  return found;
}
