import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:morph_expressive/morph_expressive.dart';
import 'package:morph_expressive_preview/main.dart';

void main() {
  testWidgets(
    'mobile Frosted Surfaces scroll uses MorphScrollBehavior locally',
    (tester) async {
      tester.view.physicalSize = const Size(390, 844);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(const MorphPreviewApp(mobileLab: true));
      await tester.pump();

      final scroll = find.byType(SingleChildScrollView);
      expect(scroll, findsOneWidget);
      final behavior = ScrollConfiguration.of(tester.element(scroll));
      expect(behavior, isA<MorphScrollBehavior>());
      expect(find.byType(BackdropFilter), findsWidgets);

      final gesture = await tester.startGesture(tester.getCenter(scroll));
      await gesture.moveBy(const Offset(0, 180));
      await tester.pump();
      await gesture.up();
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets(
    'the lab overrides the mobile default only for Original Stretch',
    (tester) async {
      tester.view.physicalSize = const Size(390, 844);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(const MorphPreviewApp(mobileLab: true));
      await tester.pump();
      await tester.tap(find.byIcon(FluentIcons.line.arrow_sync));
      await tester.pumpAndSettle();

      final list = find.byType(ListView);
      expect(list, findsOneWidget);
      expect(
        ScrollConfiguration.of(tester.element(list)),
        isA<MorphScrollBehavior>(),
      );

      await tester.tap(find.text('Original'));
      await tester.pumpAndSettle();
      expect(
        ScrollConfiguration.of(tester.element(list)),
        isNot(isA<MorphScrollBehavior>()),
      );

      await tester.tap(find.text('Geometric'));
      await tester.pumpAndSettle();
      expect(
        ScrollConfiguration.of(tester.element(list)),
        isA<MorphScrollBehavior>(),
      );
      expect(tester.takeException(), isNull);
    },
  );
}
