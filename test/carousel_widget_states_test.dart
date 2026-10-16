import 'dart:ui' as ui;

import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:morph_expressive/morph_components.dart';

import 'helpers/carousel_test_helpers.dart';

void main() {
  testWidgets(
    'pointer hover and descendant rebuilds preserve carousel item states',
    (WidgetTester tester) async {
      final imageChanged = ValueNotifier<bool>(false);
      addTearDown(imageChanged.dispose);
      var tapCount = 0;

      await tester.pumpWidget(
        hostCarousel(
          MorphCarousel(
            type: MorphCarouselType.uncontained,
            uncontainedItemExtent: 150,
            children: <MorphCarouselItem>[
              MorphCarouselItem(
                onTap: () => tapCount++,
                image: ValueListenableBuilder<bool>(
                  valueListenable: imageChanged,
                  builder: (context, changed, child) {
                    // A descendant can rebuild without directly mutating the
                    // InkWell's shared WidgetStatesController during build.
                    return ColoredBox(
                      color: changed ? Colors.indigo : Colors.blue,
                      child: child,
                    );
                  },
                  child: const Center(child: Text('enabled item')),
                ),
              ),
              const MorphCarouselItem(
                // With no onTap this item is intentionally disabled.
                image: ColoredBox(
                  color: Colors.grey,
                  child: Center(child: Text('disabled item')),
                ),
              ),
            ],
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);

      final itemStates = tester
          .widgetList<InkWell>(find.byType(InkWell))
          .firstWhere((inkWell) => inkWell.statesController != null)
          .statesController!;

      final mouse = await tester.createGesture(
        kind: ui.PointerDeviceKind.mouse,
      );
      addTearDown(mouse.removePointer);
      await mouse.addPointer(location: Offset.zero);
      imageChanged.value = true;
      await mouse.moveTo(tester.getCenter(find.text('enabled item')));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      expect(itemStates.value, contains(WidgetState.hovered));
      expect(
        tester
            .widgetList<Material>(find.byType(Material))
            .any(
              (material) =>
                  material.elevation ==
                  MorphCarouselTheme.defaultHoverElevation,
            ),
        isTrue,
        reason: 'hover should update the item elevation',
      );

      await mouse.moveTo(Offset.zero);
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      expect(itemStates.value, isNot(contains(WidgetState.hovered)));

      // The visible text is covered by the full-size InkWell hit area.
      // Tap its screen position directly, then verify the callback ran.
      await tester.tapAt(tester.getCenter(find.text('enabled item')));
      await tester.pumpAndSettle();
      expect(tapCount, 1);
      expect(tester.takeException(), isNull);

      // A disabled carousel item must have no action installed on its InkWell.
      final disabledActions = tester
          .widgetList<InkWell>(find.byType(InkWell))
          .where(
            (inkWell) =>
                inkWell.statesController != null && inkWell.onTap == null,
          );
      expect(disabledActions, hasLength(1));
      await tester.tapAt(tester.getCenter(find.text('disabled item')));
      await tester.pump();
      expect(tapCount, 1);
      expect(tester.takeException(), isNull);

      await tester.pumpWidget(const SizedBox.shrink());
      await tester.pump();
      expect(tester.takeException(), isNull);
    },
  );
}
