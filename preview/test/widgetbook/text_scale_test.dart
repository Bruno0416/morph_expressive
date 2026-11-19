import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart' show MediaQuery, Size, SizedBox;
import 'package:morph_expressive_preview/widgetbook/addons/morph_scope_addon.dart';

import 'support.dart';

/// Use cases whose stages must give large text room (scroll or wrap) instead
/// of overflowing, at a phone width with 1.6x text scaling.
void main() {
  const suffixes = [
    'morphextendedfab/sizes-and-colors',
    'morphdaypicker/building-blocks',
    'morphtabs/playground',
    'morphcheckbox/playground',
  ];
  for (final suffix in suffixes) {
    testWidgets('1.6x text scale does not overflow: $suffix', (tester) async {
      final path = allUseCases()
          .firstWhere((u) => u.path.endsWith(suffix))
          .path;
      for (final mode in ['Light', 'Dark']) {
        await openUseCase(
          tester,
          path,
          size: const Size(390, 844),
          mode: mode,
          extra: {
            'morph': '{mode:$mode,seed:Violet}',
            'text-scale': '{factor:1.6}',
          },
        );
        final scaler = MediaQuery.of(tester.element(find.byType(MorphScope)))
            .textScaler;
        expect(scaler.scale(10), closeTo(16, 0.01));
        expect(tester.takeException(), isNull, reason: '$path $mode');
        await tester.pumpWidget(const SizedBox.shrink());
        await tester.pump();
      }
    });
  }
}
