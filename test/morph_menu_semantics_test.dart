import 'dart:ui' show SemanticsRole;

import 'package:flutter/rendering.dart' show SemanticsNode;
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:morph_expressive/morph_expressive.dart';

bool _hasMenuRole(WidgetTester tester) {
  // Walk up from the item (if any) looking for a menu-role ancestor.
  final items = find.bySemanticsLabel('Item');
  if (items.evaluate().isEmpty) return false;
  SemanticsNode? node = tester.getSemantics(items);
  while (node != null) {
    if (node.getSemanticsData().role == SemanticsRole.menu) return true;
    node = node.parent;
  }
  return false;
}

void main() {
  testWidgets('menu role disappears instead of leaving an empty menu', (
    tester,
  ) async {
    final handle = tester.ensureSemantics();
    Widget host(List<Widget> items) => MorphMaterialApp(
      data: MorphThemeData.light(),
      home: Center(
        child: SizedBox(
          width: 200,
          height: 100,
          child: MorphMenuSemantics(child: Column(children: items)),
        ),
      ),
    );
    // No accessible item at all: must not assert ("a menu cannot be empty").
    await tester.pumpWidget(host(const <Widget>[SizedBox(height: 20)]));
    await tester.pump();
    expect(tester.takeException(), isNull);
    // With an accessible item the menu role is exposed.
    await tester.pumpWidget(
      host(<Widget>[
        Semantics(
          container: true,
          label: 'Item',
          button: true,
          child: const SizedBox(width: 60, height: 20),
        ),
      ]),
    );
    await tester.pump();
    expect(tester.takeException(), isNull);
    expect(_hasMenuRole(tester), isTrue);
    // Items disappear again (culled / excluded): back to no empty menu.
    await tester.pumpWidget(host(const <Widget>[SizedBox(height: 20)]));
    await tester.pump();
    expect(tester.takeException(), isNull);
    expect(_hasMenuRole(tester), isFalse);
    handle.dispose();
  });

  testWidgets('navigation rail whose destinations are all clipped is valid', (
    tester,
  ) async {
    final handle = tester.ensureSemantics();
    await tester.pumpWidget(
      MorphMaterialApp(
        data: MorphThemeData.light(),
        home: SizedBox(
          height: 300,
          child: ListView(
            children: <Widget>[
              const SizedBox(height: 296),
              SizedBox(
                height: 400,
                child: MorphNavigationRail(
                  selectedIndex: 0,
                  onDestinationSelected: (_) {},
                  sections: <MorphNavigationRailSection>[
                    MorphNavigationRailSection(
                      destinations: <MorphNavigationRailDestination>[
                        for (var i = 0; i < 3; i++)
                          MorphNavigationRailDestination(
                            icon: const SizedBox(width: 24, height: 24),
                            label: 'Dest $i',
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
    for (var i = 0; i < 5; i++) {
      await tester.pump(const Duration(milliseconds: 16));
      expect(tester.takeException(), isNull, reason: 'frame $i');
    }
    handle.dispose();
  });
}
