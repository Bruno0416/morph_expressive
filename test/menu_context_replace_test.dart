import 'package:flutter/gestures.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart'
    show
        BuildContext,
        Builder,
        Column,
        GestureDetector,
        Scaffold,
        SizedBox,
        Text,
        ValueKey,
        Widget;
import 'package:morph_expressive/morph_components.dart';

/// Three targets; right-click opens a menu named after the target.
Widget _app({List<String>? log, void Function()? onPrimary}) {
  return MorphMaterialApp(
    data: MorphThemeData.light(),
    home: Scaffold(
      body: Builder(
        builder: (BuildContext context) {
          Widget target(String id) {
            return GestureDetector(
              key: ValueKey<String>('target-$id'),
              onTap: onPrimary,
              onSecondaryTapDown: (TapDownDetails d) {
                showMorphMenu<String>(
                  context: context,
                  anchor: d.globalPosition & const Size(1, 1),
                  children: <MorphMenuNode>[
                    MorphMenuSubmenu(
                      label: 'Item $id',
                      children: <MorphMenuNode>[
                        MorphMenuEntry(label: 'Sub $id', value: 'sub-$id'),
                      ],
                    ),
                  ],
                ).then((String? v) => log?.add('closed:$id:$v'));
              },
              child: SizedBox(height: 80, child: Text('Target $id')),
            );
          }

          return Column(
            children: <Widget>[target('A'), target('B'), target('C')],
          );
        },
      ),
    ),
  );
}

Future<void> _rightClick(WidgetTester tester, Finder f) async {
  final TestGesture g = await tester.startGesture(
    tester.getCenter(f),
    kind: PointerDeviceKind.mouse,
    buttons: kSecondaryMouseButton,
  );
  await g.up();
  // Build the new overlay entry, then advance a little of its open spring.
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 60));
  await tester.pump(const Duration(milliseconds: 60));
  await tester.pump(const Duration(milliseconds: 60));
}

void main() {
  testWidgets('right-click A -> B -> C replaces menus, no outside clicks', (
    WidgetTester tester,
  ) async {
    final List<String> log = <String>[];
    await tester.pumpWidget(_app(log: log));
    await _rightClick(tester, find.byKey(const ValueKey<String>('target-A')));
    expect(find.text('Item A'), findsOneWidget);

    // Mid-animation: no pumpAndSettle.
    await _rightClick(tester, find.byKey(const ValueKey<String>('target-B')));
    expect(find.text('Item A'), findsNothing);
    expect(find.text('Item B'), findsOneWidget);

    await _rightClick(tester, find.byKey(const ValueKey<String>('target-C')));
    expect(find.text('Item B'), findsNothing);
    expect(find.text('Item C'), findsOneWidget);
    expect(log, <String>['closed:A:null', 'closed:B:null']);

    await tester.pumpAndSettle(const Duration(milliseconds: 50));
    expect(find.text('Item C'), findsOneWidget);
    expect(find.text('Item A'), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('right-click same target repositions single menu', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(_app());
    final Finder a = find.byKey(const ValueKey<String>('target-A'));
    await _rightClick(tester, a);
    await tester.pumpAndSettle(const Duration(milliseconds: 50));
    final Offset first = tester.getTopLeft(find.text('Item A'));
    final TestGesture g = await tester.startGesture(
      tester.getCenter(a) + const Offset(0, -30),
      kind: PointerDeviceKind.mouse,
      buttons: kSecondaryMouseButton,
    );
    await g.up();
    await tester.pumpAndSettle(const Duration(milliseconds: 50));
    expect(find.text('Item A'), findsOneWidget);
    expect(tester.getTopLeft(find.text('Item A')), isNot(first));
  });

  testWidgets('replace while submenu open and while closing', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(_app());
    await _rightClick(tester, find.byKey(const ValueKey<String>('target-A')));
    await tester.pumpAndSettle(const Duration(milliseconds: 50));
    await tester.tap(find.text('Item A'));
    await tester.pumpAndSettle(const Duration(milliseconds: 50));
    expect(find.text('Sub A'), findsOneWidget);

    // Start closing with Escape, then right-click B mid-close.
    await tester.sendKeyEvent(LogicalKeyboardKey.escape);
    await tester.pump(const Duration(milliseconds: 20));
    await _rightClick(tester, find.byKey(const ValueKey<String>('target-B')));
    expect(find.text('Item A'), findsNothing);
    expect(find.text('Sub A'), findsNothing);
    expect(find.text('Item B'), findsOneWidget);
    await tester.pumpAndSettle(const Duration(milliseconds: 50));
    expect(find.text('Item B'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('right-click on empty area closes menu', (tester) async {
    await tester.pumpWidget(_app());
    await _rightClick(tester, find.byKey(const ValueKey<String>('target-A')));
    await tester.pumpAndSettle(const Duration(milliseconds: 50));
    final TestGesture g = await tester.startGesture(
      const Offset(780, 580),
      kind: PointerDeviceKind.mouse,
      buttons: kSecondaryMouseButton,
    );
    await g.up();
    await tester.pumpAndSettle(const Duration(milliseconds: 50));
    expect(find.text('Item A'), findsNothing);
  });

  testWidgets('touch tap outside only dismisses, target not activated', (
    tester,
  ) async {
    int taps = 0;
    await tester.pumpWidget(_app(onPrimary: () => taps++));
    await _rightClick(tester, find.byKey(const ValueKey<String>('target-A')));
    await tester.pumpAndSettle(const Duration(milliseconds: 50));
    await tester.tap(find.byKey(const ValueKey<String>('target-C')));
    await tester.pumpAndSettle(const Duration(milliseconds: 50));
    expect(taps, 0);
    expect(find.text('Item A'), findsNothing);
    await tester.tap(find.byKey(const ValueKey<String>('target-C')));
    expect(taps, 1);
  });
}
