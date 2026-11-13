import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart' show SizedBox;
import 'package:morph_expressive/morph_expressive.dart';

import '../example/whats_new_0_8_0.dart';

void main() {
  testWidgets('the 0.8.0 example builds and its controls respond', (
    tester,
  ) async {
    await tester.pumpWidget(const WhatsNewApp());
    await tester.pump(const Duration(milliseconds: 300));
    expect(find.byType(MorphAsyncButton), findsOneWidget);
    expect(find.byType(MorphSkeletonGroup), findsOneWidget);
    expect(find.byType(MorphReactiveButtonGroup), findsOneWidget);
    expect(find.byType(MorphShapeButton), findsOneWidget);
    expect(find.byType(MorphTabsView), findsOneWidget);
    expect(find.byType(MorphFabMenu), findsOneWidget);
    await tester.tap(find.text('Save changes'));
    await tester.pump(const Duration(milliseconds: 400));
    expect(
      tester.widget<MorphAsyncButton>(find.byType(MorphAsyncButton)).state,
      MorphOperationState.loading,
    );
    await tester.tap(find.text('Activity').first);
    // Shimmer, loader and rotation never settle: advance a fixed time.
    await tester.pump(const Duration(milliseconds: 600));
    expect(tester.takeException(), isNull);
    await tester.pumpWidget(const SizedBox());
  });
}
