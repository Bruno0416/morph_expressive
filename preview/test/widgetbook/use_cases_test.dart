import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart' show Size, SizedBox;

import 'package:morph_expressive_preview/widgetbook/addons/morph_scope_addon.dart';

import 'support.dart';

/// Every use case of the generated catalog must build without exceptions or
/// overflow, in light and dark, at a desktop and a mobile viewport.
void main() {
  const desktop = Size(1280, 800);
  const mobile = Size(390, 844);

  for (final useCase in allUseCases()) {
    testWidgets('builds: ${useCase.path}', (tester) async {
      for (final size in [desktop, mobile]) {
        for (final mode in ['Light', 'Dark']) {
          await openUseCase(tester, useCase.path, size: size, mode: mode);
          expect(
            tester.takeException(),
            isNull,
            reason: '${useCase.path} @ ${size.width.toInt()}px $mode',
          );
          expect(find.byType(MorphScope), findsOneWidget);
          // Tear the scene down so the next combination starts clean and
          // every controller, timer and ticker is disposed.
          await tester.pumpWidget(const SizedBox.shrink());
          await tester.pump();
          expect(tester.takeException(), isNull, reason: 'dispose');
        }
      }
    });
  }
}
