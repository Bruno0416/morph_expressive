import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/services.dart' show LogicalKeyboardKey;
import 'package:material_ui/material_ui.dart' show MaterialApp, Scaffold;
import 'package:morph_expressive/morph_expressive.dart';

void main() {
  testWidgets('shape button supports keyboard and disable while held', (
    tester,
  ) async {
    final focus = FocusNode();
    var selected = false, enabled = true, actions = 0;
    late StateSetter update;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: StatefulBuilder(
            builder: (context, setState) {
              update = setState;
              return Center(
                child: MorphShapeButton(
                  shape: MorphShapeCatalog.cookie7Sided,
                  pressedShape: MorphShapeCatalog.softBurst,
                  selectedShape: MorphShapeCatalog.pentagon,
                  focusNode: focus,
                  selected: selected,
                  enabled: enabled,
                  onPressed: () => actions++,
                  child: const Text('Favorite'),
                ),
              );
            },
          ),
        ),
      ),
    );
    focus.requestFocus();
    await tester.pump();
    await tester.sendKeyEvent(LogicalKeyboardKey.enter);
    await tester.pump();
    expect(actions, 1);
    final gesture = await tester.startGesture(
      tester.getCenter(find.byType(MorphShapeButton)),
    );
    await tester.pump(const Duration(milliseconds: 40));
    update(() => selected = true);
    await tester.pump();
    update(() => enabled = false);
    await tester.pump();
    await gesture.up();
    await tester.pump(const Duration(milliseconds: 200));
    expect(actions, 1);
    expect(tester.takeException(), isNull);
    await tester.pumpWidget(const SizedBox());
    focus.dispose();
  });
  testWidgets(
    'shape button activates only on release and selection stays controlled',
    (tester) async {
      var actions = 0;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Center(
              child: MorphShapeButton(
                shape: MorphShapeCatalog.cookie7Sided,
                pressedShape: MorphShapeCatalog.softBurst,
                selectedShape: MorphShapeCatalog.pentagon,
                selected: true,
                onPressed: () => actions++,
                child: const Text('Favorite'),
              ),
            ),
          ),
        ),
      );
      final gesture = await tester.startGesture(
        tester.getCenter(find.byType(MorphShapeButton)),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 20));
      expect(actions, 0);
      await gesture.up();
      await tester.pump(const Duration(milliseconds: 180));
      expect(actions, 1);
      expect(
        tester.widget<MorphShapeButton>(find.byType(MorphShapeButton)).selected,
        isTrue,
      );
      expect(tester.takeException(), isNull);
    },
  );
}
