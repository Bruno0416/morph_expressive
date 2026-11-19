import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart' show MaterialApp, ThemeData;
import 'package:morph_expressive/morph_expressive.dart';

import 'foundations_color_test_utils.dart';

void main() {
  late StateSetter rebuild;

  Widget host(MorphThemeData Function() data, {String? fontFamily}) {
    return StatefulBuilder(
      builder: (BuildContext context, StateSetter setState) {
        rebuild = setState;
        return MorphMaterialApp(
          data: data(),
          fontFamily: fontFamily,
          home: const SizedBox(),
        );
      },
    );
  }

  ThemeData dark(WidgetTester t) =>
      t.widget<MaterialApp>(find.byType(MaterialApp)).darkTheme!;
  ThemeData light(WidgetTester t) =>
      t.widget<MaterialApp>(find.byType(MaterialApp)).theme!;

  testWidgets('derived dark/light ThemeData are reused across rebuilds', (
    WidgetTester tester,
  ) async {
    final MorphThemeData data = MorphThemeData.light(
      seedColor: kFoundationsSeeds['blue'],
    );
    await tester.pumpWidget(host(() => data));
    final ThemeData firstDark = dark(tester);
    final ThemeData firstLight = light(tester);

    rebuild(() {});
    await tester.pump();
    rebuild(() {});
    await tester.pump();

    expect(identical(dark(tester), firstDark), isTrue);
    expect(identical(light(tester), firstLight), isTrue);
  });

  testWidgets('the cache is invalidated when the theme data changes', (
    WidgetTester tester,
  ) async {
    MorphThemeData data = MorphThemeData.light(
      seedColor: kFoundationsSeeds['blue'],
    );
    await tester.pumpWidget(host(() => data));
    final ThemeData blueDark = dark(tester);

    data = MorphThemeData.light(seedColor: kFoundationsSeeds['red']);
    rebuild(() {});
    await tester.pump();

    final ThemeData redDark = dark(tester);
    expect(identical(redDark, blueDark), isFalse);
    expect(redDark.colorScheme.primary, isNot(blueDark.colorScheme.primary));
    expect(
      redDark.colorScheme.primary,
      MorphThemeData.dark(seedColor: kFoundationsSeeds['red'])
          .colorScheme
          .primary,
    );
  });

  testWidgets('typography overrides also invalidate the cache', (
    WidgetTester tester,
  ) async {
    final MorphThemeData data = MorphThemeData.light();
    String? family;
    await tester.pumpWidget(host(() => data, fontFamily: family));
    final ThemeData before = dark(tester);

    family = 'Roboto';
    await tester.pumpWidget(host(() => data, fontFamily: family));
    final ThemeData after = dark(tester);

    expect(identical(before, after), isFalse);
    expect(after.textTheme.bodyMedium?.fontFamily, 'Roboto');
  });
}
