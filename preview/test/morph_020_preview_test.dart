import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart' show Size, ValueKey;
import 'package:morph_expressive/morph_expressive.dart';
import 'package:morph_expressive_preview/main.dart';

import 'showcase_scroll_helper.dart';

void main() {
  Future<void> start(WidgetTester tester) async {
    tester.view.physicalSize = const Size(1440, 900);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(const MorphPreviewApp());
  }

  testWidgets('preview controls switch the global haptic configuration', (
    tester,
  ) async {
    await start(tester);
    MorphThemeData data() =>
        MorphTheme.of(tester.element(find.byType(MorphButton).first));
    expect(data().hapticsEnabled, isTrue);
    expect(data().hapticFeedback, MorphHapticFeedback.light);
    await tester.tap(find.byTooltip('Haptic settings'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
    await tester.tap(find.text('Off').last);
    await tester.pump();
    expect(data().hapticsEnabled, isFalse);
    await tester.tap(find.byTooltip('Haptic settings'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
    await tester.tap(find.text('Heavy').last);
    await tester.pump();
    expect(data().hapticsEnabled, isTrue);
    expect(data().hapticFeedback, MorphHapticFeedback.heavy);
  });

  testWidgets('chip gallery exposes multi-selection independently', (
    tester,
  ) async {
    await start(tester);
    await revealShowcaseCategory(tester, 'chips');
    final multi = find.byKey(const ValueKey('morph_multi_chip_preview'));
    expect(multi, findsOneWidget);
    var control = tester.widget<MorphChipToggle<String>>(multi);
    expect(control.multiSelection, isTrue);
    expect(control.selectedValues, {'Daily', 'Monthly'});
    await tester.ensureVisible(multi);
    final weekly = find.descendant(of: multi, matching: find.text('Weekly'));
    await tester.tap(weekly);
    await tester.pump();
    control = tester.widget<MorphChipToggle<String>>(multi);
    expect(control.selectedValues, {'Daily', 'Weekly', 'Monthly'});
    expect(tester.takeException(), isNull);
  });

  testWidgets('the navigation rail demo ignores scroll-under from tab swipes', (
    tester,
  ) async {
    await start(tester);
    await revealShowcaseCategory(tester, 'navigation_rail');
    final rail = tester.widget<MorphNavigationRail>(
      find.byType(MorphNavigationRail),
    );
    expect(rail.scrollUnder, isFalse);
    expect(tester.takeException(), isNull);
  });

  testWidgets('filled gallery demonstrates exterior-label configuration', (
    tester,
  ) async {
    await start(tester);
    await revealShowcaseCategory(tester, 'text_fields');
    final filled = tester
        .widgetList<MorphTextField>(find.byType(MorphTextField))
        .where((w) => w.label == 'Email')
        .toList();
    expect(filled.length, 1);
    expect(filled.single.variant, MorphTextFieldVariant.filled);
    expect(filled.single.placeholder, 'name@example.com');
  });
}
