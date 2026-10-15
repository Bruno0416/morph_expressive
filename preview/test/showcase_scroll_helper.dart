import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

/// Reveals a lazily built family in the continuous Morph gallery.
///
/// The showcase uses a ListView.builder whose rows are materialized on
/// demand. Flutter's generic scrollUntilVisible may run out of attempts
/// before the target widget exists, particularly with responsive row heights.
/// Use the gallery's own Scrollable and advance in small, bounded steps.
Future<Finder> revealShowcaseCategory(
  WidgetTester tester,
  String category,
) async {
  final target = find.byKey(ValueKey('showcase_$category'));
  final gallery = find.byKey(const ValueKey('morph_showcase_scroll'));
  expect(gallery, findsOneWidget);

  final scrollable = find.descendant(
    of: gallery,
    matching: find.byType(Scrollable),
  ).first;
  final position = tester.state<ScrollableState>(scrollable).position;

  // A step smaller than the viewport prevents skipping short sliver rows.
  // Do not use pumpAndSettle: some samples animate continuously.
  const maxSteps = 160;
  for (var step = 0; step < maxSteps && target.evaluate().isEmpty; step++) {
    final delta = (position.viewportDimension * 0.35)
        .clamp(120.0, 320.0)
        .toDouble();
    final next = (position.pixels + delta)
        .clamp(position.minScrollExtent, position.maxScrollExtent)
        .toDouble();
    if (next - position.pixels < 0.5) break;
    position.jumpTo(next);
    await tester.pump();
  }

  expect(
    target,
    findsOneWidget,
    reason: 'The showcase did not build the family "$category" while scrolling.',
  );
  await tester.ensureVisible(target);
  await tester.pump();
  return target;
}
