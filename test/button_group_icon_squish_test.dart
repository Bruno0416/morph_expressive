import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:morph_expressive/morph_components.dart';
import 'package:material_ui/material_ui.dart';

Widget _host(Widget child) => MaterialApp(
  home: MorphTheme(
    data: MorphThemeData.light(),
    child: Scaffold(body: Center(child: child)),
  ),
);

List<double> _groupChildWidths(WidgetTester tester) {
  final root = tester.renderObject(find.byType(MorphButtonGroup));
  RenderBox? squish;
  void visit(RenderObject object) {
    if (squish != null) {
      return;
    }
    if (object is RenderBox && object is ContainerRenderObjectMixin) {
      var count = 0;
      object.visitChildren((_) => count++);
      if (count >= 3) {
        squish = object;
      }
    }
    object.visitChildren(visit);
  }

  visit(root);
  expect(squish, isNotNull, reason: 'squish layout host not found');
  final widths = <double>[];
  squish!.visitChildren((RenderObject child) {
    widths.add((child as RenderBox).size.width);
  });
  return widths;
}

void main() {
  _registerSquishTests();
  _registerSizeTokenTests();
  _registerResizeTests();
}

void _registerSquishTests() {
  testWidgets(
    'icon-only MorphButton actions squish with slot widths',
    _iconOnlyActionsSquishWithSlotWidths,
  );
  testWidgets(
    'connected group fills bounded width with equal segments',
    _connectedGroupFillsBoundedWidthWithEqualSegments,
  );
}

void _registerSizeTokenTests() {
  testWidgets(
    'size tokens drive visual height and standard between-space',
    _sizeTokensDriveVisualHeightAndStandardBetweenSpace,
  );
  testWidgets(
    'connected size tokens drive visual height and 2dp gap',
    _connectedSizeTokensDriveVisualHeightAnd2dpGap,
  );
  testWidgets(
    'density shrinks height and keeps between-space',
    _densityShrinksHeightAndKeepsBetweenSpace,
  );
}

void _registerResizeTests() {
  testWidgets(
    'size change recomputes text+icon group width',
    _sizeChangeRecomputesTextIconGroupWidth,
  );
  testWidgets(
    'minWidth change recomputes icon-only widths without interaction',
    _minWidthChangeRecomputesIconOnlyWidthsWithoutInteraction,
  );
}

Future<void> _iconOnlyActionsSquishWithSlotWidths(WidgetTester tester) async {
  await tester.pumpWidget(
    _host(
      MorphButtonGroup(
        expandedRatio: 0.25,
        selectedIndex: 0,
        onSelectedIndexChanged: (_) {},
        actions: const <MorphButtonGroupAction>[
          MorphButtonGroupAction(
            icon: Icon(Icons.home),
            semanticLabel: 'home',
            minWidth: 40,
          ),
          MorphButtonGroupAction(
            icon: Icon(Icons.star),
            semanticLabel: 'star',
            minWidth: 40,
          ),
          MorphButtonGroupAction(
            icon: Icon(Icons.settings),
            semanticLabel: 'settings',
            minWidth: 40,
          ),
        ],
      ),
    ),
  );
  await tester.pumpAndSettle();

  final buttons = find.byType(MorphButton);
  // Offstage measurers may also exist; use hit-testable instances.
  final visible = buttons.hitTestable();
  expect(visible, findsWidgets);

  final left0 = tester.getSize(visible.at(0)).width;
  final center0 = tester.getSize(visible.at(1)).width;
  final right0 = tester.getSize(visible.at(2)).width;
  expect(left0, closeTo(center0, 0.1));
  expect(right0, closeTo(center0, 0.1));

  final gesture = await tester.startGesture(tester.getCenter(visible.at(1)));
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 80));
  await tester.pump(const Duration(milliseconds: 160));

  final slots = _groupChildWidths(tester);
  expect(slots, hasLength(3));

  final left1 = tester.getSize(visible.at(0)).width;
  final center1 = tester.getSize(visible.at(1)).width;
  final right1 = tester.getSize(visible.at(2)).width;

  expect(center1, greaterThan(center0));
  expect(left1, lessThan(left0));
  expect(right1, lessThan(right0));

  expect(left1, closeTo(slots[0], 0.5));
  expect(center1, closeTo(slots[1], 0.5));
  expect(right1, closeTo(slots[2], 0.5));

  await gesture.up();
  await tester.pumpAndSettle();
}

Future<void> _connectedGroupFillsBoundedWidthWithEqualSegments(
  WidgetTester tester,
) async {
  await tester.pumpWidget(
    _host(
      SizedBox(
        width: 400,
        child: MorphButtonGroup(
          type: MorphButtonGroupType.connected,
          overflow: MorphButtonGroupOverflow.none,
          selectedIndex: 0,
          onSelectedIndexChanged: (_) {},
          actions: const <MorphButtonGroupAction>[
            MorphButtonGroupAction(label: Text('8 oz')),
            MorphButtonGroupAction(label: Text('12 oz')),
            MorphButtonGroupAction(label: Text('16 oz')),
          ],
        ),
      ),
    ),
  );
  await tester.pumpAndSettle();

  final buttons = find.byType(MorphButton).hitTestable();
  expect(buttons, findsNWidgets(3));
  final widths = <double>[
    tester.getSize(buttons.at(0)).width,
    tester.getSize(buttons.at(1)).width,
    tester.getSize(buttons.at(2)).width,
  ];
  // Spec: connected spans the surface; segments share width equally.
  expect(widths[0], closeTo(widths[1], 1));
  expect(widths[1], closeTo(widths[2], 1));
  expect(widths[0] + widths[1] + widths[2], greaterThan(350));
}

Future<void> _sizeTokensDriveVisualHeightAndStandardBetweenSpace(
  WidgetTester tester,
) async {
  await _pumpStandardPair(tester, MorphButtonSize.xs);
  final xsButtons = find.byType(MorphButton).hitTestable();
  expect(tester.getSize(xsButtons.first).height, 32);
  final xsGap =
      tester.getTopLeft(xsButtons.at(1)).dx -
      tester.getTopRight(xsButtons.at(0)).dx;
  expect(xsGap, closeTo(18, 0.5));

  await _pumpStandardPair(tester, MorphButtonSize.sm);
  final smButtons = find.byType(MorphButton).hitTestable();
  expect(tester.getSize(smButtons.first).height, 40);
  final smGap =
      tester.getTopLeft(smButtons.at(1)).dx -
      tester.getTopRight(smButtons.at(0)).dx;
  expect(smGap, closeTo(12, 0.5));

  await _pumpStandardPair(tester, MorphButtonSize.md);
  final mdButtons = find.byType(MorphButton).hitTestable();
  expect(tester.getSize(mdButtons.first).height, 56);
  final mdGap =
      tester.getTopLeft(mdButtons.at(1)).dx -
      tester.getTopRight(mdButtons.at(0)).dx;
  expect(mdGap, closeTo(8, 0.5));

  await _pumpStandardPair(tester, MorphButtonSize.lg);
  expect(tester.getSize(find.byType(MorphButton).hitTestable().first).height, 96);
}

Future<void> _pumpStandardPair(WidgetTester tester, MorphButtonSize size) async {
  await tester.pumpWidget(
    _host(
      MorphButtonGroup(
        size: size,
        overflow: MorphButtonGroupOverflow.none,
        neighborSquish: false,
        selectedIndex: 0,
        onSelectedIndexChanged: (_) {},
        actions: const <MorphButtonGroupAction>[
          MorphButtonGroupAction(label: Text('A')),
          MorphButtonGroupAction(label: Text('B')),
        ],
      ),
    ),
  );
  await tester.pumpAndSettle();
}

Future<void> _connectedSizeTokensDriveVisualHeightAnd2dpGap(
  WidgetTester tester,
) async {
  await _pumpConnectedPair(tester, MorphButtonSize.xs);
  final xsButtons = find.byType(MorphButton).hitTestable();
  expect(tester.getSize(xsButtons.first).height, 32);
  final xsGap =
      tester.getTopLeft(xsButtons.at(1)).dx -
      tester.getTopRight(xsButtons.at(0)).dx;
  expect(xsGap, closeTo(2, 0.5));

  await _pumpConnectedPair(tester, MorphButtonSize.md);
  expect(tester.getSize(find.byType(MorphButton).hitTestable().first).height, 56);

  await _pumpConnectedPair(tester, MorphButtonSize.xl);
  final xlButtons = find.byType(MorphButton).hitTestable();
  expect(tester.getSize(xlButtons.first).height, 136);
  final xlGap =
      tester.getTopLeft(xlButtons.at(1)).dx -
      tester.getTopRight(xlButtons.at(0)).dx;
  expect(xlGap, closeTo(2, 0.5));
}

Future<void> _pumpConnectedPair(WidgetTester tester, MorphButtonSize size) async {
  await tester.pumpWidget(
    _host(
      SizedBox(
        width: 320,
        child: MorphButtonGroup(
          type: MorphButtonGroupType.connected,
          size: size,
          overflow: MorphButtonGroupOverflow.none,
          selectedIndex: 0,
          onSelectedIndexChanged: (_) {},
          actions: const <MorphButtonGroupAction>[
            MorphButtonGroupAction(label: Text('A')),
            MorphButtonGroupAction(label: Text('B')),
          ],
        ),
      ),
    ),
  );
  await tester.pumpAndSettle();
  // Autofocus expands the connected gap for the focus ring; clear it.
  FocusManager.instance.primaryFocus?.unfocus();
  await tester.pumpAndSettle();
}

Future<void> _densityShrinksHeightAndKeepsBetweenSpace(
  WidgetTester tester,
) async {
  await tester.pumpWidget(
    _host(
      MorphButtonGroup(
        size: MorphButtonSize.md,
        density: MorphButtonGroupDensity.dense,
        overflow: MorphButtonGroupOverflow.none,
        neighborSquish: false,
        selectedIndex: 0,
        onSelectedIndexChanged: (_) {},
        actions: const <MorphButtonGroupAction>[
          MorphButtonGroupAction(label: Text('A')),
          MorphButtonGroupAction(label: Text('B')),
        ],
      ),
    ),
  );
  await tester.pumpAndSettle();

  final buttons = find.byType(MorphButton).hitTestable();
  // md 56 − 3×4 = 44
  expect(tester.getSize(buttons.first).height, 44);
  final gap =
      tester.getTopLeft(buttons.at(1)).dx -
      tester.getTopRight(buttons.at(0)).dx;
  expect(gap, closeTo(8, 0.5));
}

Future<void> _sizeChangeRecomputesTextIconGroupWidth(
  WidgetTester tester,
) async {
  tester.view.physicalSize = const Size(2000, 800);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);

  var size = MorphButtonSize.sm;

  await _pumpLabeledGroup(tester, size);
  final smWidth = tester.getSize(find.byType(MorphButtonGroup)).width;

  size = MorphButtonSize.md;
  await _pumpLabeledGroup(tester, size);
  final mdWidth = tester.getSize(find.byType(MorphButtonGroup)).width;
  expect(mdWidth, greaterThan(smWidth + 20));

  size = MorphButtonSize.sm;
  await _pumpLabeledGroup(tester, size);
  expect(
    tester.getSize(find.byType(MorphButtonGroup)).width,
    closeTo(smWidth, 2),
  );
}

Future<void> _pumpLabeledGroup(WidgetTester tester, MorphButtonSize size) async {
  await tester.pumpWidget(
    _host(
      MorphButtonGroup(
        size: size,
        overflow: MorphButtonGroupOverflow.none,
        selectedIndex: 0,
        onSelectedIndexChanged: (_) {},
        actions: const <MorphButtonGroupAction>[
          MorphButtonGroupAction(
            icon: Icon(Icons.format_align_left),
            label: Text('Left'),
          ),
          MorphButtonGroupAction(
            icon: Icon(Icons.format_align_center),
            label: Text('Center'),
          ),
          MorphButtonGroupAction(
            icon: Icon(Icons.format_align_right),
            label: Text('Right'),
          ),
        ],
      ),
    ),
  );
  await tester.pumpAndSettle();
}

Future<void> _minWidthChangeRecomputesIconOnlyWidthsWithoutInteraction(
  WidgetTester tester,
) async {
  tester.view.physicalSize = const Size(2000, 800);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);

  var middleMinWidth = 40.0;

  Future<void> pump() {
    return _pumpIconWidths(tester, middleMinWidth);
  }

  await pump();
  final buttons = find.byType(MorphButton).hitTestable();
  final narrowMiddle = tester.getSize(buttons.at(1)).width;

  middleMinWidth = 96;
  await pump();
  final wideMiddle = tester.getSize(buttons.at(1)).width;
  expect(wideMiddle, greaterThan(narrowMiddle + 20));

  middleMinWidth = 40;
  await pump();
  expect(tester.getSize(buttons.at(1)).width, closeTo(narrowMiddle, 2));
}

Future<void> _pumpIconWidths(WidgetTester tester, double middleMinWidth) async {
  await tester.pumpWidget(
    _host(
      MorphButtonGroup(
        overflow: MorphButtonGroupOverflow.none,
        selectedIndex: 0,
        onSelectedIndexChanged: (_) {},
        actions: <MorphButtonGroupAction>[
          const MorphButtonGroupAction(
            icon: Icon(Icons.format_align_left),
            semanticLabel: 'left',
            minWidth: 40,
          ),
          MorphButtonGroupAction(
            icon: const Icon(Icons.format_align_center),
            semanticLabel: 'center',
            minWidth: middleMinWidth,
          ),
          const MorphButtonGroupAction(
            icon: Icon(Icons.format_align_right),
            semanticLabel: 'right',
            minWidth: 64,
          ),
        ],
      ),
    ),
  );
  // One frame is enough — must not require a gesture to refresh.
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 16));
}
