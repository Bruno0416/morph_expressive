import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:morph_expressive/morph_expressive.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  final calls = <String>[];

  setUp(() {
    calls.clear();
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(SystemChannels.platform, (call) async {
          if (call.method == 'HapticFeedback.vibrate') {
            calls.add(call.arguments as String);
          }
          return null;
        });
  });
  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(SystemChannels.platform, null);
  });

  test('defaults and copy/derived themes preserve haptic settings', () {
    final original = MorphThemeData.light();
    expect(original.hapticsEnabled, true);
    expect(original.hapticFeedback, MorphHapticFeedback.light);
    final modified = original.copyWith(
      hapticsEnabled: false,
      hapticFeedback: MorphHapticFeedback.heavy,
    );
    final derived = modified.deriveDarkTemplate();
    expect(derived.hapticsEnabled, false);
    expect(derived.hapticFeedback, MorphHapticFeedback.heavy);
    expect(derived.copyWith(hapticsEnabled: true).hapticsEnabled, true);
    expect(derived.copyWith(hapticsEnabled: true).hapticFeedback,
        MorphHapticFeedback.heavy);
  });

  testWidgets('nested theme disables feedback including an explicit override',
      (tester) async {
    final enabled = MorphThemeData.light().copyWith(
      hapticFeedback: MorphHapticFeedback.medium,
    );
    final disabled = enabled.copyWith(hapticsEnabled: false);
    await tester.pumpWidget(MaterialApp(
      home: MorphTheme(
        data: enabled,
        child: Column(children: [
          Builder(builder: (context) {
            return TextButton(
              onPressed: () {
                MorphHaptics.triggerFor(context);
                MorphHaptics.selectionFor(context);
              },
              child: const Text('parent'),
            );
          }),
          MorphTheme(data: disabled, child: Builder(builder: (context) {
            return TextButton(
              onPressed: () {
                MorphHaptics.triggerFor(context, MorphHapticFeedback.heavy);
                MorphHaptics.selectionFor(context);
              },
              child: const Text('child'),
            );
          })),
        ]),
      ),
    ));
    await tester.tap(find.text('parent'));
    await tester.pump();
    expect(calls, ['HapticFeedbackType.mediumImpact',
      'HapticFeedbackType.selectionClick']);
    calls.clear();
    await tester.tap(find.text('child'));
    await tester.pump();
    expect(calls, isEmpty);
  });

  testWidgets('explicit none, inherited level and selection tick', (tester) async {
    final data = MorphThemeData.light().copyWith(
      hapticFeedback: MorphHapticFeedback.heavy,
    );
    await tester.pumpWidget(MaterialApp(home: MorphTheme(
      data: data,
      child: Builder(builder: (context) => TextButton(
        onPressed: () {
          MorphHaptics.triggerFor(context, MorphHapticFeedback.none);
          MorphHaptics.triggerFor(context);
          MorphHaptics.selectionFor(context);
        },
        child: const Text('go'),
      )),
    )));
    await tester.tap(find.text('go'));
    await tester.pump();
    expect(calls, ['HapticFeedbackType.heavyImpact',
      'HapticFeedbackType.selectionClick']);
  });
}
