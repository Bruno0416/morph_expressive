import 'package:flutter_test/flutter_test.dart';
import 'package:morph_expressive/morph_components.dart';
import 'package:material_ui/material_ui.dart'
    show
        Axis,
        BuildContext,
        Canvas,
        Center,
        Color,
        CustomPaint,
        CustomPainter,
        Directionality,
        Matrix4,
        MediaQuery,
        MediaQueryData,
        Offset,
        Paint,
        Path,
        Rect,
        Size,
        SizedBox,
        StatefulBuilder,
        TextDirection,
        Widget;

Widget _host(Widget child) {
  return Directionality(
    textDirection: TextDirection.ltr,
    child: MediaQuery(
      data: const MediaQueryData(),
      child: MorphTheme(
        data: MorphThemeData.light(seedColor: const Color(0xFF6750A4)),
        child: Center(child: child),
      ),
    ),
  );
}

void main() {
  testWidgets('continuous drag updates value', _continuousDragUpdatesValue);
  testWidgets('discrete divisions snap', _discreteDivisionsSnap);
  testWidgets('centered constructor builds', _centeredConstructorBuilds);
  testWidgets(
    'wavy constructor builds and updates',
    _wavyConstructorBuildsAndUpdates,
  );
  testWidgets('wavy range constructor builds', _wavyRangeConstructorBuilds);
  testWidgets(
    'custom trackThickness thumbLength and dotBuilder',
    _customTrackthicknessThumblengthAndDotbuilder,
  );
  test(
    'dotSpacing pads outer edge of end stops from track ends',
    _dotspacingPadsOuterEdgeOfEndStopsFromTrackEnds,
  );
  testWidgets('range thumbs cannot cross', _rangeThumbsCannotCross);
  testWidgets('vertical drag updates value', _verticalDragUpdatesValue);
  testWidgets(
    'vertical min is at bottom and max at top',
    _verticalMinIsAtBottomAndMaxAtTop,
  );
  testWidgets('disabled when onChanged is null', _disabledWhenOnchangedIsNull);
}

Future<void> _continuousDragUpdatesValue(WidgetTester tester) async {
  var value = 0.25;
  await tester.pumpWidget(
    _host(
      SizedBox(
        width: 200,
        height: 48,
        child: MorphSlider(value: value, onChanged: (double v) => value = v),
      ),
    ),
  );

  await tester.tapAt(tester.getCenter(find.byType(MorphSlider)));
  await tester.pump();
  expect(value, closeTo(0.5, 0.05));
}

Future<void> _discreteDivisionsSnap(WidgetTester tester) async {
  double value = 0;
  await tester.pumpWidget(
    StatefulBuilder(
      builder: (context, setState) {
        return _host(
          SizedBox(
            width: 200,
            height: 48,
            child: MorphSlider(
              value: value,
              max: 4,
              divisions: 4,
              onChanged: (double v) => setState(() => value = v),
            ),
          ),
        );
      },
    ),
  );

  final Offset topLeft = tester.getTopLeft(find.byType(MorphSlider));
  await tester.tapAt(topLeft + const Offset(150, 24));
  await tester.pump();
  expect(value, anyOf(3.0, 4.0));
}

Future<void> _centeredConstructorBuilds(WidgetTester tester) async {
  await tester.pumpWidget(
    _host(
      SizedBox(
        width: 200,
        height: 48,
        child: MorphSlider.centered(
          value: 0,
          min: -100,
          max: 100,
          onChanged: (_) {},
        ),
      ),
    ),
  );
  expect(tester.takeException(), isNull);
  expect(find.byType(MorphSlider), findsOneWidget);
}

Future<void> _wavyConstructorBuildsAndUpdates(WidgetTester tester) async {
  var value = 0.3;
  await tester.pumpWidget(
    StatefulBuilder(
      builder: (context, setState) {
        return _host(
          SizedBox(
            width: 200,
            height: 48,
            child: MorphSlider.wavy(
              value: value,
              onChanged: (double v) => setState(() => value = v),
            ),
          ),
        );
      },
    ),
  );

  expect(find.byType(MorphSlider), findsOneWidget);
  await tester.pump(const Duration(milliseconds: 100));
  await tester.tapAt(tester.getCenter(find.byType(MorphSlider)));
  await tester.pump();
  expect(value, closeTo(0.5, 0.05));
}

Future<void> _wavyRangeConstructorBuilds(WidgetTester tester) async {
  await tester.pumpWidget(
    _host(
      SizedBox(
        width: 200,
        height: 48,
        child: MorphRangeSlider.wavy(
          values: const MorphSliderRange(0.2, 0.8),
          onChanged: (_) {},
        ),
      ),
    ),
  );
  expect(tester.takeException(), isNull);
  expect(find.byType(MorphRangeSlider), findsOneWidget);
  await tester.pump(const Duration(milliseconds: 100));
}

Future<void> _customTrackthicknessThumblengthAndDotbuilder(
  WidgetTester tester,
) async {
  await tester.pumpWidget(
    _host(
      SizedBox(
        width: 200,
        height: 48,
        child: MorphSlider(
          value: 0.5,
          max: 4,
          divisions: 4,
          trackThickness: 20,
          thumbLength: 32,
          dotSize: 10,
          dotSpacing: 8,
          onChanged: (_) {},
          dotBuilder:
              ({
                required BuildContext context,
                required Color color,
                required double size,
                required bool active,
              }) {
                return CustomPaint(
                  painter: _TestShapeDotPainter(
                    polygon: MorphMaterialNewShapes.cookie4Sided,
                    color: color,
                  ),
                );
              },
        ),
      ),
    ),
  );
  expect(tester.takeException(), isNull);
  expect(find.byType(CustomPaint), findsWidgets);
}

void _dotspacingPadsOuterEdgeOfEndStopsFromTrackEnds() {
  const size = Size(200, 48);
  const double trackHeight = 16;
  const double dotSize = 12;
  const double spacing = 8;
  final MorphSliderColors colors = MorphSliderTheme.defaults.colors(
    MorphThemeData.light(seedColor: const Color(0xFF6750A4)).colorScheme,
    enabled: true,
  );

  final List<MorphSliderDotPlacement> dots = MorphSliderDotLayout.resolve(
    size: size,
    mode: MorphSliderPaintMode.single,
    trackKind: MorphSliderTrackKind.standard,
    activeStartFraction: 0,
    activeEndFraction: 0.5,
    tickFractions: const <double>[],
    colors: colors,
    trackHeight: trackHeight,
    handleGap: 6,
    handleThickness: 4,
    stopIndicatorSize: dotSize,
    tickSize: dotSize,
    edgeInset: spacing,
    axis: Axis.horizontal,
    textDirection: TextDirection.ltr,
  );

  // Only the trailing stop is on the inactive track for value 0.5.
  expect(dots, isNotEmpty);
  final MorphSliderDotPlacement end = dots.last;
  final double outerEdge = end.primary + end.size / 2;
  expect(size.width - outerEdge, closeTo(spacing, 0.001));
}

Future<void> _rangeThumbsCannotCross(WidgetTester tester) async {
  var values = const MorphSliderRange(0.4, 0.6);
  await tester.pumpWidget(
    StatefulBuilder(
      builder: (context, setState) {
        return _host(
          SizedBox(
            width: 200,
            height: 48,
            child: MorphRangeSlider(
              values: values,
              onChanged: (MorphSliderRange v) => setState(() => values = v),
            ),
          ),
        );
      },
    ),
  );

  // Drag the start thumb far right; it must clamp at the end thumb.
  final Offset topLeft = tester.getTopLeft(find.byType(MorphRangeSlider));
  await tester.dragFrom(topLeft + const Offset(80, 24), const Offset(120, 0));
  await tester.pumpAndSettle();

  expect(values.start, lessThanOrEqualTo(values.end));
  expect(values.start, closeTo(0.6, 0.05));
}

Future<void> _verticalDragUpdatesValue(WidgetTester tester) async {
  var value = 0.2;
  await tester.pumpWidget(
    StatefulBuilder(
      builder: (context, setState) {
        return _host(
          SizedBox(
            width: 48,
            height: 200,
            child: MorphSlider.vertical(
              value: value,
              onChanged: (double v) => setState(() => value = v),
            ),
          ),
        );
      },
    ),
  );

  await tester.tapAt(tester.getCenter(find.byType(MorphSlider)));
  await tester.pump();
  expect(value, closeTo(0.5, 0.05));
}

Future<void> _verticalMinIsAtBottomAndMaxAtTop(WidgetTester tester) async {
  var value = 0.5;
  await tester.pumpWidget(
    StatefulBuilder(
      builder: (context, setState) {
        return _host(
          SizedBox(
            width: 48,
            height: 200,
            child: MorphSlider.vertical(
              value: value,
              onChanged: (double v) => setState(() => value = v),
            ),
          ),
        );
      },
    ),
  );

  final Offset topLeft = tester.getTopLeft(find.byType(MorphSlider));
  // Near the top → high value.
  await tester.tapAt(topLeft + const Offset(24, 20));
  await tester.pump();
  expect(value, greaterThan(0.75));

  // Near the bottom → low value.
  await tester.tapAt(topLeft + const Offset(24, 180));
  await tester.pump();
  expect(value, lessThan(0.25));
}

Future<void> _disabledWhenOnchangedIsNull(WidgetTester tester) async {
  await tester.pumpWidget(
    _host(
      const SizedBox(
        width: 200,
        height: 48,
        child: MorphSlider(value: 0.5, onChanged: null),
      ),
    ),
  );
  expect(tester.takeException(), isNull);
  await tester.tap(find.byType(MorphSlider));
  await tester.pump();
  expect(find.byType(MorphSlider), findsOneWidget);
}

class _TestShapeDotPainter extends CustomPainter {
  const _TestShapeDotPainter({required this.polygon, required this.color});

  final RoundedPolygon polygon;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final Path path = polygon.toPath();
    final scale = Matrix4.diagonal3Values(size.width, size.height, 1);
    final Path scaled = path.transform(scale.storage);
    final Rect bounds = scaled.getBounds();
    final Path centered = scaled.shift(
      Offset(size.width / 2, size.height / 2) - bounds.center,
    );
    canvas.drawPath(centered, Paint()..color = color);
  }

  @override
  bool shouldRepaint(covariant _TestShapeDotPainter oldDelegate) {
    return oldDelegate.polygon != polygon || oldDelegate.color != color;
  }
}
