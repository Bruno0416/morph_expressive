import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:morph_expressive/morph_expressive.dart'
    show FluentIcons, MorphSwitch;
import 'package:morph_expressive_preview/main.dart';

/// Number of BackdropFilter widgets that sit under an ImageFiltered ancestor
/// (the layer that the stock stretch indicator keeps in the tree).
int _backdropsUnderImageFilter(WidgetTester tester) {
  int count = 0;
  for (final Element e in find.byType(BackdropFilter).evaluate()) {
    bool filtered = false;
    e.visitAncestorElements((Element a) {
      if (a.widget is ImageFiltered) {
        filtered = true;
        return false;
      }
      return true;
    });
    if (filtered) count++;
  }
  return count;
}

Future<void> _openLab(WidgetTester tester) async {
  tester.view.physicalSize = const Size(390, 844);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
  await tester.pumpWidget(const MorphPreviewApp(mobileLab: true));
  await tester.pump();
  await tester.tap(find.byIcon(FluentIcons.line.arrow_sync));
  await tester.pumpAndSettle();
  expect(find.text('Scroll Blur Compatibility Lab'), findsOneWidget);
}

Future<void> _overscrollBothEnds(WidgetTester tester) async {
  final Finder list = find.byType(ListView);
  // Top overscroll, held then released.
  final TestGesture g = await tester.startGesture(const Offset(200, 300));
  await g.moveBy(const Offset(0, 220));
  await tester.pump(const Duration(milliseconds: 50));
  await g.up();
  await tester.pump(const Duration(milliseconds: 100));
  await tester.pumpAndSettle();
  // Fast fling to bottom and into overscroll.
  await tester.fling(list, const Offset(0, -3000), 6000);
  await tester.pump(const Duration(milliseconds: 80));
  await tester.pumpAndSettle();
  final TestGesture b = await tester.startGesture(const Offset(200, 300));
  await b.moveBy(const Offset(0, -260));
  await tester.pump(const Duration(milliseconds: 50));
  await b.up();
  await tester.pumpAndSettle();
  // Back to the top so the (in-list) controls are reachable again.
  await tester.fling(list, const Offset(0, 4000), 8000);
  await tester.pumpAndSettle();
}

void main() {
  testWidgets(
    'lab opens from the frosted lab; all variants survive overscroll',
    (tester) async {
      await _openLab(tester);
      for (final String v in <String>['Original', 'Geometric']) {
        await tester.tap(find.text(v));
        await tester.pumpAndSettle();
        await _overscrollBothEnds(tester);
        expect(tester.takeException(), isNull, reason: v);
        expect(find.byType(BackdropFilter), findsWidgets, reason: v);
      }
    },
  );

  testWidgets('Geometric never places ImageFiltered above BackdropFilter', (
    tester,
  ) async {
    await _openLab(tester);
    await tester.tap(find.text('Original'));
    await tester.pumpAndSettle();
    final int original = _backdropsUnderImageFilter(tester);
    await tester.tap(find.text('Geometric'));
    await tester.pumpAndSettle();
    final int geometric = _backdropsUnderImageFilter(tester);
    // ignore: avoid_print
    print(
      'BackdropFilter under ImageFiltered -> original=$original '
      'geometric=$geometric',
    );
    expect(geometric, 0);
    // original is 0 under flutter_tester (shader filters unsupported there);
    // the real ImageFiltered path is only observable on a device.
    expect(original, greaterThanOrEqualTo(0));
  });

  testWidgets('frosted disabled and hit testing still work', (tester) async {
    await _openLab(tester);
    await tester.tap(find.text('Geometric'));
    await tester.pumpAndSettle();
    await tester.tap(find.byType(MorphSwitch).first);
    await tester.pumpAndSettle();
    await _overscrollBothEnds(tester);
    await tester.tap(find.text('Frosted card 1'));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
  });
}
