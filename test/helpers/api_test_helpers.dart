import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart'
    show ButtonStyle, ButtonStyleButton, Center, Scaffold;
import 'package:morph_expressive/morph_expressive.dart';

/// Hosts [child] in a [MorphMaterialApp] with the given [data].
Widget apiHost(
  Widget child, {
  MorphThemeData? data,
  Brightness brightness = Brightness.light,
}) {
  return MorphMaterialApp(
    data:
        data ??
        (brightness == Brightness.dark
            ? MorphThemeData.dark()
            : MorphThemeData.light()),
    home: Scaffold(body: Center(child: child)),
  );
}

/// The [MorphColorScheme] visible to widgets below the host scaffold.
MorphColorScheme apiScheme(WidgetTester tester) =>
    MorphTheme.of(tester.element(find.byType(Scaffold))).colorScheme;

/// The Material button style painted for the single button in the tree.
ButtonStyle apiMaterialStyle(WidgetTester tester) {
  final ButtonStyleButton button = tester.widget<ButtonStyleButton>(
    find.byWidgetPredicate((Widget w) => w is ButtonStyleButton),
  );
  return button.style!;
}

/// WCAG contrast ratio between two opaque colors.
double apiContrast(Color a, Color b) {
  final double la = a.computeLuminance();
  final double lb = b.computeLuminance();
  final double hi = la > lb ? la : lb;
  final double lo = la > lb ? lb : la;
  return (hi + 0.05) / (lo + 0.05);
}

/// Every [MorphVariant] in declaration order.
const List<MorphVariant> apiVariants = MorphVariant.values;

/// Asserts that [actual] is [configured] except for a tint opacity that may
/// have been raised (never lowered) to keep the content legible.
void expectGlassFrom(MorphSurfaceGlass actual, MorphSurfaceGlass configured) {
  expect(actual.copyWith(tintOpacity: configured.tintOpacity), configured);
  expect(actual.tintOpacity, greaterThanOrEqualTo(configured.tintOpacity));
}
