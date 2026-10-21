import 'package:flutter_test/flutter_test.dart';
import 'package:morph_expressive/morph_components.dart';
import 'package:material_ui/material_ui.dart'
    show Center, ClipPath, Color, MaterialApp, Path, Scaffold, Size, Widget;

Widget _host(Widget child) {
  return MaterialApp(
    home: MorphTheme(
      data: MorphThemeData.light(),
      child: Scaffold(body: Center(child: child)),
    ),
  );
}

void main() {
  test('every MorphShapeKind has a polygon', () {
    expect(MorphShapeKind.all, hasLength(35));
    for (final MorphShapeKind kind in MorphShapeKind.all) {
      expect(kind.polygon, isNotNull);
      expect(kind.polygon.toPath().getBounds().isEmpty, isFalse);
    }
  });

  test('MorphShapeClipper scales a non-empty path to 100x100', () {
    const clipper = MorphShapeClipper(MorphShapeKind.gem);
    final Path path = clipper.getClip(const Size(100, 100));
    expect(path.getBounds().isEmpty, isFalse);
    expect(path.getBounds().width, moreOrLessEquals(100, epsilon: 0.5));
    expect(path.getBounds().height, moreOrLessEquals(100, epsilon: 0.5));
  });

  testWidgets('MorphShapeContainer.heart pumps', (tester) async {
    await tester.pumpWidget(
      _host(
        const MorphShapeContainer.heart(
          width: 48,
          height: 48,
          color: Color(0xFF6750A4),
        ),
      ),
    );
    expect(find.byType(MorphShapeContainer), findsOneWidget);
    expect(find.byType(ClipPath), findsOneWidget);
  });
}
