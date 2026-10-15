import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:morph_expressive/morph_components.dart';
import 'package:material_ui/material_ui.dart';

void setUpFocusNavReproTests() {
  MorphFocusInteraction.resetForTest();
  FocusManager.instance.highlightStrategy =
      FocusHighlightStrategy.alwaysTraditional;
}

void tearDownFocusNavReproTests() {
  MorphFocusInteraction.resetForTest();
  FocusManager.instance.highlightStrategy = FocusHighlightStrategy.automatic;
}

Future<void> pumpFocusNavTab(WidgetTester tester) async {
  await tester.sendKeyDownEvent(LogicalKeyboardKey.tab);
  await tester.pump();
  await tester.sendKeyUpEvent(LogicalKeyboardKey.tab);
  await tester.pumpAndSettle();
}

FocusScopeNode? findFabMenuScope() {
  FocusScopeNode? found;
  void walk(FocusNode node) {
    if (node is FocusScopeNode && node.debugLabel == 'MorphFabMenu') {
      found = node;
      return;
    }
    for (final FocusNode child in node.children) {
      walk(child);
      if (found != null) {
        return;
      }
    }
  }

  walk(FocusManager.instance.rootScope);
  return found;
}

Future<void> pumpFabMenuApp(
  WidgetTester tester, {
  required List<String> labels,
}) async {
  await tester.pumpWidget(
    MaterialApp(
      home: MorphTheme(
        data: MorphThemeData.light(),
        child: Scaffold(
          body: Align(
            alignment: Alignment.bottomCenter,
            child: MorphFabMenu(
              items: <MorphFabMenuItem>[
                for (final label in labels)
                  MorphFabMenuItem(
                    icon: const Icon(Icons.add),
                    label: label,
                    onPressed: () {},
                  ),
              ],
            ),
          ),
        ),
      ),
    ),
  );
}

Future<void> pumpSelectionDialogEnterApp(
  WidgetTester tester, {
  required void Function(List<String>?) onResult,
}) async {
  await tester.pumpWidget(
    MaterialApp(
      home: MorphTheme(
        data: MorphThemeData.light(),
        child: Builder(
          builder: (BuildContext context) {
            return Scaffold(
              body: MorphButton.filled(
                onPressed: () async {
                  onResult(
                    await MorphDialog.showSelectionScreen(
                      context,
                      title: 'Plan',
                      options: const <String>['A', 'B', 'C'],
                    ),
                  );
                },
                child: const Text('Open'),
              ),
            );
          },
        ),
      ),
    ),
  );
}

Future<void> pumpSelectionDialogShellOrderApp(WidgetTester tester) async {
  await tester.pumpWidget(
    MaterialApp(
      home: MorphTheme(
        data: MorphThemeData.light(),
        child: FocusTraversalGroup(
          policy: OrderedTraversalPolicy(),
          child: Scaffold(
            body: Column(
              children: <Widget>[
                FocusTraversalOrder(
                  order: const NumericFocusOrder(0),
                  child: FocusTraversalGroup(
                    child: MorphButton.filled(
                      onPressed: () {},
                      child: const Text('Chrome'),
                    ),
                  ),
                ),
                FocusTraversalOrder(
                  order: const NumericFocusOrder(1),
                  child: Expanded(
                    child: Builder(
                      builder: (BuildContext context) {
                        return Center(
                          child: MorphButton.filled(
                            onPressed: () {
                              MorphDialog.showSelectionScreen(
                                context,
                                title: 'Plan',
                                options: const <String>[
                                  'Standard',
                                  'Pro',
                                  'Team',
                                ],
                              );
                            },
                            child: const Text('Open selection'),
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    ),
  );
}

Future<void> pumpSearchBarTabApp(
  WidgetTester tester, {
  required FocusNode before,
  required FocusNode search,
  required TextEditingController controller,
}) async {
  await tester.pumpWidget(
    MaterialApp(
      home: MorphTheme(
        data: MorphThemeData.light(),
        child: Scaffold(
          body: FocusTraversalGroup(
            policy: OrderedTraversalPolicy(),
            child: Column(
              children: <Widget>[
                FocusTraversalOrder(
                  order: const NumericFocusOrder(0),
                  child: MorphButton.filled(
                    focusNode: before,
                    onPressed: () {},
                    child: const Text('Before'),
                  ),
                ),
                FocusTraversalOrder(
                  order: const NumericFocusOrder(1),
                  child: SizedBox(
                    width: 240,
                    child: MorphSearchBar(
                      focusNode: search,
                      controller: controller,
                      hintText: 'Search',
                      alignment: Alignment.center,
                    ),
                  ),
                ),
                FocusTraversalOrder(
                  order: const NumericFocusOrder(2),
                  child: MorphButton.filled(
                    onPressed: () {},
                    child: const Text('After'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    ),
  );
}
