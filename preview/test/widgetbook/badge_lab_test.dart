import 'package:flutter_test/flutter_test.dart';
import 'package:morph_expressive/morph_expressive.dart';

import 'support.dart';

String _path(String suffix) =>
    allUseCases().firstWhere((u) => u.path.endsWith(suffix)).path;

void main() {
  testWidgets('badge lab: contrast readout is computed for every role', (
    tester,
  ) async {
    await openUseCase(tester, _path('badges/morphbadge/contrast'));
    // Light and dark sections, six roles each.
    expect(find.textContaining(RegExp(r'^text \d')), findsNWidgets(12));
    expect(find.textContaining(' · AA'), findsWidgets);
    expect(tester.takeException(), isNull);
  });

  testWidgets('badge lab: counts cap at maxCount', (tester) async {
    await openUseCase(tester, _path('badges/morphbadge/counts'));
    expect(find.text('999+'), findsOneWidget);
    expect(find.text('99+'), findsNWidgets(3));
    expect(find.text('0'), findsWidgets);
    expect(tester.takeException(), isNull);
  });

  testWidgets('badge lab: density columns resize the real badge', (
    tester,
  ) async {
    await openUseCase(tester, _path('badges/morphbadge/density'));
    final badges = find.byType(MorphBadge);
    expect(badges, findsNWidgets(12));
    double minHeight(int column) {
      // Labelled badges ("New") are the fourth in each column.
      final pill = tester.getSize(
        find.descendant(
          of: badges.at(column * 4 + 3),
          matching: find.text('New'),
        ),
      );
      return pill.height;
    }

    // The label metrics never change with density; only the pill around the
    // text (resolved minimum size, padding) moves.
    final theme = MorphThemeData.light().badgeTheme;
    expect(
      theme.resolveDensity(MorphDensity.compact).labelMinSize,
      lessThan(theme.resolveDensity(MorphDensity.comfortable).labelMinSize),
    );
    expect(minHeight(0), minHeight(2));
    expect(tester.takeException(), isNull);
  });
}
