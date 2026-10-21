import 'package:flutter/semantics.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:morph_expressive/components/bottom_sheets/components/morph_bottom_sheet_drag_handle.dart';
import 'package:morph_expressive/components/bottom_sheets/components/morph_bottom_sheet_drag_region.dart';
import 'package:morph_expressive/components/bottom_sheets/components/morph_bottom_sheet_surface.dart';
import 'package:morph_expressive/morph_components.dart';
import 'package:material_ui/material_ui.dart'
    show
        BorderRadius,
        BoxDecoration,
        Brightness,
        BuildContext,
        Builder,
        Color,
        Container,
        DecoratedBox,
        GestureDetector,
        ListView,
        MaterialApp,
        Navigator,
        Offset,
        Positioned,
        Radius,
        Rect,
        ScrollPosition,
        Scrollable,
        ScrollableState,
        Size,
        SizedBox,
        Stack,
        Text,
        Transform,
        ValueListenableBuilder,
        ValueNotifier,
        Widget;

final MorphThemeData _theme = MorphThemeData.light(
  seedColor: const Color(0xFF6750A4),
);

final Finder _surface = find.byType(MorphBottomSheetSurface);
final Finder _handle = find.byType(MorphBottomSheetDragHandle);

void main() {
  setUp(MorphFocusInteraction.resetForTest);
  testWidgets('theme defaults match the spec', _themeDefaults);
  testWidgets('container shape, color, elevation and handle', _anatomy);
  testWidgets('width and margins follow the 640dp breakpoint', _responsive);
  testWidgets('modal opens capped at half the screen', _initialCap);
  testWidgets('drag, fling and slow release snap or dismiss', _dragSnap);
  testWidgets('Tab focuses the handle; Space / Enter cycle', _keyboard);
  testWidgets('Escape and scrim tap close the modal', _escapeScrim);
  testWidgets('only the handle is labelled, as a button', _semantics);
  testWidgets('controller drives and closes the sheet', _controller);
  testWidgets('standard sheet co-exists and hides', _standard);
  testWidgets('full-screen height shows a close header', _fullScreen);
  testWidgets('full-screen option spans the view width', _fullWidth);
  testWidgets('content clears the bottom system bar', _bottomInset);
  testWidgets('light theme: bar icons follow the sheet', _lightBars);
  testWidgets('dark theme: status icons stay light', _darkBars);
  testWidgets('showAdaptive swaps to a side sheet at 840dp', _adaptive);
  testWidgets('inner list grows the sheet before scrolling', _scrollHandOff);
  testWidgets('predictive back shrinks the sheet', _predictiveBack);
  testWidgets('predictive back keeps the inner list alive', _backKeepsScroll);
  testWidgets('predictive back exit keeps the scale steady', _backExitSteady);
  testWidgets('theme change keeps the sheet content alive', _themeKeepsContent);
  testWidgets(
    'content resize during exit does not bounce the sheet up',
    _exitResizeNoBounce,
  );
}

Future<BuildContext> _pump(
  WidgetTester tester,
  Size size, {
  MorphThemeData? theme,
}) async {
  tester.view
    ..physicalSize = size
    ..devicePixelRatio = 1;
  addTearDown(tester.view.reset);
  late BuildContext captured;
  await tester.pumpWidget(
    MorphTheme(
      data: theme ?? _theme,
      child: MaterialApp(
        home: Builder(
          builder: (BuildContext context) {
            captured = context;
            return const SizedBox.expand();
          },
        ),
      ),
    ),
  );
  return captured;
}

Widget _longList(BuildContext context) {
  return ListView(
    children: <Widget>[
      for (var i = 0; i < 60; i++) SizedBox(height: 48, child: Text('Row $i')),
    ],
  );
}

Widget _short(BuildContext context) =>
    const SizedBox(height: 100, child: Text('Short'));

Future<void> _themeDefaults(WidgetTester tester) async {
  const t = MorphBottomSheetTheme.defaults;
  expect(t.topCornerRadius, 28);
  expect(t.bottomCornerRadius, 0);
  expect(t.maxWidth, 640);
  expect(t.compactTopMargin, 72);
  expect(t.wideTopMargin, 56);
  expect(t.wideSideMargin, 56);
  expect(t.handleWidth, 32);
  expect(t.handleHeight, 4);
  expect(t.handleOpacity, 0.4);
  expect(t.handleVerticalPadding, 22);
  expect(t.dragRegionHeight, 48);
  expect(t.dragHandle.targetSize, 48);
  expect(t.dragHandle.focusRingWidth, 3);
  expect(t.dragHandle.focusRingGap, 2);
  expect(t.initialHeightFraction, 0.5);
  expect(t.modalElevation, MorphElevation.level1);
  expect(t.standardElevation, MorphElevation.level1);
  final MorphColorScheme s = _theme.colorScheme;
  expect(t.containerColor(s), s.surfaceContainerLow);
  expect(t.focusRingColor(s), s.secondary);
  expect(
    t.handleColor(s),
    MorphColorUtils.withOpacity(s.onSurfaceVariant, 0.4),
  );
  expect(t.scrimColor(s), s.scrim.withValues(alpha: 0.32));
}

Future<void> _anatomy(WidgetTester tester) async {
  final BuildContext context = await _pump(tester, const Size(400, 800));
  MorphBottomSheet.show<void>(context, builder: _short);
  await tester.pumpAndSettle();
  final DecoratedBox box = tester.widget<DecoratedBox>(
    find.descendant(of: _surface, matching: find.byType(DecoratedBox)).first,
  );
  final decoration = box.decoration as BoxDecoration;
  expect(decoration.color, _theme.colorScheme.surfaceContainerLow);
  expect(
    decoration.borderRadius,
    const BorderRadius.vertical(top: Radius.circular(28)),
  );
  expect(decoration.boxShadow, isNotEmpty);
  expect(tester.getSize(_surface).width, 400);
  expect(tester.getSize(find.byType(MorphBottomSheetDragRegion)).height, 48);
  expect(tester.getSize(_handle), const Size(48, 48));
  final Finder pill = find.descendant(
    of: _handle,
    matching: find.byWidgetPredicate(
      (Widget w) => w is Container && w.constraints?.maxWidth == 32,
    ),
  );
  expect(tester.getSize(pill), const Size(32, 4));
  expect(tester.getRect(pill).top - tester.getRect(_surface).top, 22);
}

Future<void> _responsive(WidgetTester tester) async {
  final expected = <double, (double, double)>{
    400: (400, 72),
    700: (588, 56),
    1000: (640, 56),
  };
  for (final MapEntry<double, (double, double)> e in expected.entries) {
    final BuildContext context = await _pump(tester, Size(e.key, 800));
    MorphBottomSheet.show<void>(
      context,
      initialValue: MorphBottomSheetValue.expanded,
      builder: _longList,
    );
    await tester.pumpAndSettle();
    final Rect rect = tester.getRect(_surface);
    expect(rect.width, e.value.$1, reason: 'width at ${e.key}');
    expect(rect.left, (e.key - e.value.$1) / 2);
    expect(rect.top, e.value.$2, reason: 'top margin at ${e.key}');
    Navigator.of(context).pop();
    await tester.pumpAndSettle();
  }
}

Future<void> _initialCap(WidgetTester tester) async {
  final BuildContext context = await _pump(tester, const Size(400, 800));
  final controller = MorphBottomSheetController();
  addTearDown(controller.dispose);
  MorphBottomSheet.show<void>(
    context,
    controller: controller,
    builder: _longList,
  );
  await tester.pumpAndSettle();
  expect(tester.getRect(_surface).top, 400);
  expect(controller.value, MorphBottomSheetValue.collapsed);
  expect(controller.availableValues, <MorphBottomSheetValue>[
    MorphBottomSheetValue.collapsed,
    MorphBottomSheetValue.expanded,
  ]);
}

Future<void> _dragSnap(WidgetTester tester) async {
  final BuildContext context = await _pump(tester, const Size(400, 800));
  var closed = false;
  MorphBottomSheet.show<void>(
    context,
    builder: _longList,
  ).then((_) => closed = true);
  await tester.pumpAndSettle();
  await tester.drag(
    find.byType(MorphBottomSheetDragRegion),
    const Offset(0, -280),
  );
  await tester.pumpAndSettle();
  expect(tester.getRect(_surface).top, 72, reason: 'snaps to expanded');

  await tester.fling(
    find.byType(MorphBottomSheetDragRegion),
    const Offset(0, 100),
    1500,
  );
  await tester.pumpAndSettle();
  expect(tester.getRect(_surface).top, 400, reason: 'flings one height down');

  await tester.timedDrag(
    find.byType(MorphBottomSheetDragRegion),
    const Offset(0, 250),
    const Duration(seconds: 1),
  );
  await tester.pumpAndSettle();
  expect(closed, isTrue, reason: 'below half the lowest height dismisses');
}

Future<void> _keyboard(WidgetTester tester) async {
  final BuildContext context = await _pump(tester, const Size(400, 800));
  final controller = MorphBottomSheetController();
  addTearDown(controller.dispose);
  MorphBottomSheet.show<void>(
    context,
    controller: controller,
    builder: _longList,
  );
  await tester.pumpAndSettle();
  await tester.sendKeyEvent(LogicalKeyboardKey.tab);
  await tester.pumpAndSettle();
  final MorphFocusRing ring = tester.widget<MorphFocusRing>(
    find.descendant(of: _handle, matching: find.byType(MorphFocusRing)),
  );
  expect(ring.focused, isTrue);
  expect(ring.color, _theme.colorScheme.secondary);
  expect(ring.width, 3);
  expect(ring.gap, 2);

  await tester.sendKeyEvent(LogicalKeyboardKey.space);
  await tester.pumpAndSettle();
  expect(controller.value, MorphBottomSheetValue.expanded);
  await tester.sendKeyEvent(LogicalKeyboardKey.enter);
  await tester.pumpAndSettle();
  expect(controller.value, MorphBottomSheetValue.collapsed, reason: 'wraps');

  await tester.tapAt(tester.getCenter(find.text('Row 1')));
  await tester.pumpAndSettle();
  expect(MorphFocusInteraction.instance.ringsAllowed, isFalse);
}

Future<void> _escapeScrim(WidgetTester tester) async {
  final BuildContext context = await _pump(tester, const Size(400, 800));
  var closed = 0;
  MorphBottomSheet.show<void>(context, builder: _short).then((_) => closed++);
  await tester.pumpAndSettle();
  await tester.sendKeyEvent(LogicalKeyboardKey.escape);
  await tester.pumpAndSettle();
  expect(closed, 1);

  MorphBottomSheet.show<void>(context, builder: _short).then((_) => closed++);
  await tester.pumpAndSettle();
  await tester.tapAt(const Offset(200, 100));
  await tester.pumpAndSettle();
  expect(closed, 2);
  expect(_surface, findsNothing);
}

Future<void> _semantics(WidgetTester tester) async {
  final SemanticsHandle handle = tester.ensureSemantics();
  final BuildContext context = await _pump(tester, const Size(400, 800));
  MorphBottomSheet.show<void>(context, builder: _longList);
  await tester.pumpAndSettle();
  expect(
    tester.getSemantics(find.bySemanticsLabel('Drag handle')),
    isSemantics(
      label: 'Drag handle',
      value: 'Collapsed',
      isButton: true,
      isFocusable: true,
      hasTapAction: true,
      customActions: <CustomSemanticsAction>[
        const CustomSemanticsAction(label: 'Expand'),
        const CustomSemanticsAction(label: 'Dismiss'),
      ],
    ),
  );
  handle.dispose();
}

Future<void> _controller(WidgetTester tester) async {
  final BuildContext context = await _pump(tester, const Size(400, 800));
  final controller = MorphBottomSheetController();
  addTearDown(controller.dispose);
  Object? result;
  MorphBottomSheet.show<String>(
    context,
    controller: controller,
    builder: _longList,
  ).then((String? r) => result = r);
  await tester.pumpAndSettle();
  expect(controller.isAttached, isTrue);
  controller.expand();
  await tester.pumpAndSettle();
  expect(controller.value, MorphBottomSheetValue.expanded);
  expect(controller.extent, 800 - 72);
  controller.collapse();
  await tester.pumpAndSettle();
  expect(controller.value, MorphBottomSheetValue.collapsed);
  controller.close('done');
  await tester.pumpAndSettle();
  expect(result, 'done');
  expect(controller.isAttached, isFalse);
}

Future<void> _standard(WidgetTester tester) async {
  await _pump(tester, const Size(400, 800));
  final controller = MorphBottomSheetController();
  addTearDown(controller.dispose);
  var taps = 0;
  await tester.pumpWidget(
    MorphTheme(
      data: _theme,
      child: MaterialApp(
        home: Stack(
          children: <Widget>[
            Positioned.fill(child: GestureDetector(onTap: () => taps++)),
            Positioned.fill(
              child: MorphBottomSheet.standard(
                controller: controller,
                initialValue: MorphBottomSheetValue.hidden,
                child: const SizedBox(height: 200, child: Text('Player')),
              ),
            ),
          ],
        ),
      ),
    ),
  );
  await tester.pumpAndSettle();
  expect(controller.value, MorphBottomSheetValue.hidden);
  expect(_handle.hitTestable(), findsNothing);
  controller.show();
  await tester.pumpAndSettle();
  expect(controller.value, MorphBottomSheetValue.expanded);
  expect(tester.getRect(_surface).top, 800 - 248);
  await tester.tapAt(const Offset(200, 100));
  expect(taps, 1, reason: 'main UI stays interactive');
  controller.hide();
  await tester.pumpAndSettle();
  expect(controller.value, MorphBottomSheetValue.hidden);
}

Future<void> _fullScreen(WidgetTester tester) async {
  final BuildContext context = await _pump(tester, const Size(400, 800));
  final controller = MorphBottomSheetController();
  addTearDown(controller.dispose);
  var closed = false;
  MorphBottomSheet.show<void>(
    context,
    controller: controller,
    expandToFullScreen: true,
    fullScreenTitle: 'Details',
    builder: _longList,
  ).then((_) => closed = true);
  await tester.pumpAndSettle();
  expect(find.byIcon(MorphIcons.close), findsNothing);
  controller.expand();
  await tester.pumpAndSettle();
  expect(controller.value, MorphBottomSheetValue.fullScreen);
  expect(tester.getRect(_surface).top, 0);
  expect(find.text('Details'), findsOneWidget);
  final DecoratedBox box = tester.widget<DecoratedBox>(
    find.descendant(of: _surface, matching: find.byType(DecoratedBox)).first,
  );
  expect((box.decoration as BoxDecoration).borderRadius, BorderRadius.zero);
  await tester.tap(find.byIcon(MorphIcons.close));
  await tester.pumpAndSettle();
  expect(closed, isTrue);
}

Future<void> _adaptive(WidgetTester tester) async {
  for (final width in <double>[400, 1000]) {
    final BuildContext context = await _pump(tester, Size(width, 800));
    MorphBottomSheet.showAdaptive<void>(
      context,
      title: 'Share',
      builder: _short,
    );
    await tester.pumpAndSettle();
    expect(
      find.byType(MorphSideSheet),
      width >= 840 ? findsOneWidget : findsNothing,
    );
    expect(_surface, width >= 840 ? findsNothing : findsOneWidget);
    Navigator.of(context).pop();
    await tester.pumpAndSettle();
  }
}

Future<void> _scrollHandOff(WidgetTester tester) async {
  final BuildContext context = await _pump(tester, const Size(400, 800));
  MorphBottomSheet.show<void>(context, builder: _longList);
  await tester.pumpAndSettle();
  await tester.drag(find.text('Row 2'), const Offset(0, -200));
  await tester.pumpAndSettle();
  expect(tester.getRect(_surface).top, 72, reason: 'sheet grew first');
  final ScrollPosition position = tester
      .state<ScrollableState>(find.byType(Scrollable))
      .position;
  expect(position.pixels, 0);
  await tester.drag(find.text('Row 2'), const Offset(0, -200));
  await tester.pumpAndSettle();
  expect(position.pixels, greaterThan(0), reason: 'then the list scrolls');
}

Future<void> _sendBack(
  WidgetTester tester,
  String method, [
  Map<String, dynamic>? args,
]) async {
  final ByteData data = const StandardMethodCodec().encodeMethodCall(
    MethodCall(method, args),
  );
  await tester.binding.defaultBinaryMessenger.handlePlatformMessage(
    SystemChannels.backGesture.name,
    data,
    (ByteData? _) {},
  );
}

Map<String, dynamic> _backArgs(double progress) => <String, dynamic>{
  'touchOffset': <double>[5, 600],
  'progress': progress,
  'swipeEdge': 0,
};

double _sheetScaleY(WidgetTester tester) {
  final Transform transform = tester.widget<Transform>(
    find.ancestor(of: _surface, matching: find.byType(Transform)).first,
  );
  return transform.transform.storage[5];
}

Future<void> _predictiveBack(WidgetTester tester) async {
  final BuildContext context = await _pump(tester, const Size(400, 800));
  var closed = false;
  MorphBottomSheet.show<void>(
    context,
    builder: _short,
  ).then((_) => closed = true);
  await tester.pumpAndSettle();

  await _sendBack(tester, 'startBackGesture', _backArgs(0));
  await _sendBack(tester, 'updateBackGestureProgress', _backArgs(1));
  await tester.pump();
  final Transform transform = tester.widget<Transform>(
    find.ancestor(of: _surface, matching: find.byType(Transform)).first,
  );
  expect(transform.transform.storage[0], closeTo(1 - 48 / 400, 0.001));
  await _sendBack(tester, 'commitBackGesture');
  await tester.pumpAndSettle();
  expect(closed, isTrue);
}

Future<void> _backKeepsScroll(WidgetTester tester) async {
  final BuildContext context = await _pump(tester, const Size(400, 800));
  MorphBottomSheet.show<void>(
    context,
    initialValue: MorphBottomSheetValue.expanded,
    builder: _longList,
  );
  await tester.pumpAndSettle();
  await tester.drag(find.text('Row 2'), const Offset(0, -200));
  await tester.pumpAndSettle();
  final ScrollableState scrollable = tester.state<ScrollableState>(
    find.byType(Scrollable),
  );
  expect(scrollable.position.pixels, greaterThan(0), reason: 'list scrolled');

  await _sendBack(tester, 'startBackGesture', _backArgs(0));
  await _sendBack(tester, 'updateBackGestureProgress', _backArgs(0.5));
  await tester.pump();
  expect(
    identical(
      scrollable,
      tester.state<ScrollableState>(find.byType(Scrollable)),
    ),
    isTrue,
    reason: 'the back drag must keep the sheet content alive',
  );
  expect(
    tester.state<ScrollableState>(find.byType(Scrollable)).position.pixels,
    scrollable.position.pixels,
  );

  await _sendBack(tester, 'cancelBackGesture');
  await tester.pumpAndSettle();
  expect(
    identical(
      scrollable,
      tester.state<ScrollableState>(find.byType(Scrollable)),
    ),
    isTrue,
    reason: 'the cancelled settle must keep the sheet content alive',
  );
  expect(
    tester.state<ScrollableState>(find.byType(Scrollable)).position.pixels,
    scrollable.position.pixels,
  );
}

Future<void> _backExitSteady(WidgetTester tester) async {
  final BuildContext context = await _pump(tester, const Size(400, 800));
  var closed = false;
  MorphBottomSheet.show<void>(
    context,
    initialValue: MorphBottomSheetValue.expanded,
    builder: _longList,
  ).then((_) => closed = true);
  await tester.pumpAndSettle();

  await _sendBack(tester, 'startBackGesture', _backArgs(0));
  await _sendBack(tester, 'updateBackGestureProgress', _backArgs(1));
  await tester.pump();
  final double scaleY = _sheetScaleY(tester);
  await _sendBack(tester, 'commitBackGesture');
  for (var i = 0; i < 30 && _surface.evaluate().isNotEmpty; i++) {
    await tester.pump(const Duration(milliseconds: 16));
    if (_surface.evaluate().isEmpty) {
      break;
    }
    expect(
      _sheetScaleY(tester),
      closeTo(scaleY, 0.0001),
      reason: 'the scale must stay put while the sheet exits (frame $i)',
    );
  }
  await tester.pumpAndSettle();
  expect(closed, isTrue);
}

Future<void> _themeKeepsContent(WidgetTester tester) async {
  final BuildContext context = await _pump(tester, const Size(400, 800));
  MorphBottomSheet.show<void>(
    context,
    initialValue: MorphBottomSheetValue.expanded,
    builder: _longList,
  );
  await tester.pumpAndSettle();
  await tester.drag(find.text('Row 2'), const Offset(0, -200));
  await tester.pumpAndSettle();
  final ScrollableState scrollable = tester.state<ScrollableState>(
    find.byType(Scrollable),
  );
  expect(scrollable.position.pixels, greaterThan(0), reason: 'list scrolled');

  await _pump(
    tester,
    const Size(400, 800),
    theme: MorphThemeData.dark(seedColor: const Color(0xFF6750A4)),
  );
  await tester.pumpAndSettle();
  expect(
    identical(
      scrollable,
      tester.state<ScrollableState>(find.byType(Scrollable)),
    ),
    isTrue,
    reason: 'the brightness flip must keep the sheet content alive',
  );
  expect(
    tester.state<ScrollableState>(find.byType(Scrollable)).position.pixels,
    scrollable.position.pixels,
  );
}

Future<void> _exitResizeNoBounce(WidgetTester tester) async {
  final BuildContext context = await _pump(tester, const Size(400, 800));
  final height = ValueNotifier<double>(100);
  addTearDown(height.dispose);
  MorphBottomSheet.show<void>(
    context,
    builder: (_) => ValueListenableBuilder<double>(
      valueListenable: height,
      builder: (BuildContext context, double value, Widget? child) =>
          SizedBox(height: value, child: child),
      child: const Text('Body'),
    ),
  );
  await tester.pumpAndSettle();

  // Start the exit through the normal pop path (same as the back button).
  Navigator.of(tester.element(_surface)).pop();
  await tester.pump();

  // Resize the content while the sheet is on its way out. Re-resolving the
  // detents must not re-settle the sheet height mid-exit.
  height.value = 700;

  // Sample the exit trajectory: the sheet travels down, so its top edge must
  // never move back up.
  final tops = <double>[tester.getRect(_surface).top];
  for (var i = 0; i < 24; i++) {
    await tester.pump(const Duration(milliseconds: 16));
    if (_surface.evaluate().isEmpty) {
      break;
    }
    tops.add(tester.getRect(_surface).top);
  }
  for (var i = 1; i < tops.length; i++) {
    expect(
      tops[i],
      greaterThanOrEqualTo(tops[i - 1] - 0.5),
      reason:
          'sheet must keep exiting, not bounce up '
          '(frame $i: ${tops[i - 1]} -> ${tops[i]})',
    );
  }
  await tester.pumpAndSettle();
}

Future<void> _fullWidth(WidgetTester tester) async {
  final BuildContext context = await _pump(tester, const Size(1000, 800));
  MorphBottomSheet.show<void>(
    context,
    expandToFullScreen: true,
    builder: _longList,
  );
  await tester.pumpAndSettle();
  final Rect rect = tester.getRect(_surface);
  expect(rect.width, 1000);
  expect(rect.left, 0);
}

Future<void> _bottomInset(WidgetTester tester) async {
  tester.view
    ..padding = const FakeViewPadding(bottom: 48)
    ..viewPadding = const FakeViewPadding(bottom: 48);
  addTearDown(tester.view.resetPadding);
  addTearDown(tester.view.resetViewPadding);
  final BuildContext context = await _pump(tester, const Size(400, 800));
  MorphBottomSheet.show<void>(context, builder: _short);
  await tester.pumpAndSettle();
  final Rect sheet = tester.getRect(_surface);
  expect(sheet.bottom, 800, reason: 'container paints under the bar');
  expect(tester.getRect(find.text('Short')).top, sheet.top + 48);
  expect(sheet.height, 48 + 100 + 48, reason: 'strip + content + inset');
}

SystemUiOverlayStyle? _styleAt(WidgetTester tester, Offset offset) {
  return tester.binding.renderViews.first.debugLayer!
      .find<SystemUiOverlayStyle>(offset);
}

Future<void> _lightBars(WidgetTester tester) async {
  final BuildContext context = await _pump(tester, const Size(400, 800));
  final controller = MorphBottomSheetController();
  addTearDown(controller.dispose);
  MorphBottomSheet.show<void>(
    context,
    controller: controller,
    expandToFullScreen: true,
    builder: _longList,
  );
  const top = Offset(200, 1);
  const bottom = Offset(200, 799);
  await tester.pump();
  expect(
    _styleAt(tester, bottom)?.systemNavigationBarIconBrightness,
    Brightness.light,
    reason: 'only the scrim sits under the navigation bar while opening',
  );
  await tester.pumpAndSettle();
  expect(_styleAt(tester, top)?.statusBarIconBrightness, Brightness.light);
  expect(
    _styleAt(tester, bottom)?.systemNavigationBarIconBrightness,
    Brightness.dark,
    reason: 'the light sheet sits under the navigation bar',
  );
  controller.expand();
  await tester.pumpAndSettle();
  expect(
    _styleAt(tester, top)?.statusBarIconBrightness,
    Brightness.dark,
    reason: 'the light sheet now sits under the status bar',
  );
}

Future<void> _darkBars(WidgetTester tester) async {
  final BuildContext context = await _pump(
    tester,
    const Size(400, 800),
    theme: MorphThemeData.dark(seedColor: const Color(0xFF6750A4)),
  );
  MorphBottomSheet.show<void>(
    context,
    expandToFullScreen: true,
    initialValue: MorphBottomSheetValue.fullScreen,
    builder: _longList,
  );
  await tester.pumpAndSettle();
  expect(
    _styleAt(tester, const Offset(200, 1)),
    MorphScrimSystemUi.bottomSheetOverlayStyle,
  );
  expect(
    _styleAt(tester, const Offset(200, 799)),
    MorphScrimSystemUi.bottomSheetOverlayStyle,
    reason: 'the sheet adds no style of its own in dark theme',
  );
}
