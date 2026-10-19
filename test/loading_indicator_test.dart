import 'package:flutter/semantics.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:morph_expressive/morph_components.dart';
import 'package:material_ui/material_ui.dart';

Widget _host(Widget child, {MorphThemeData? theme}) {
  return MaterialApp(
    home: MorphTheme(
      data: theme ?? MorphThemeData.light(),
      child: Scaffold(body: Center(child: child)),
    ),
  );
}

void main() {
  _registerLoadingSizeTests();
  _registerLoadingShapeTests();
  _registerLoadingColorTests();
  _registerLoadingValidationTests();
}

void _registerLoadingSizeTests() {
  testWidgets(
    'uses the default container and indicator sizes',
    _usesTheDefaultContainerAndIndicatorSizes,
  );
  testWidgets(
    'instance dimensions override theme dimensions',
    _instanceDimensionsOverrideThemeDimensions,
  );
  testWidgets('uses theme dimensions', _usesThemeDimensions);
  testWidgets(
    'size scales outer and active with 38:48 ratio',
    _sizeScalesOuterAndActiveWith3848Ratio,
  );
  testWidgets(
    'debug asserts outer size outside 24–240',
    _debugAssertsOuterSizeOutside24To240,
  );
}

void _registerLoadingShapeTests() {
  testWidgets('uses the custom container shape', _usesTheCustomContainerShape);
  testWidgets('exposes loading semantics', _exposesLoadingSemantics);
  testWidgets(
    'defaults to CircleBorder container shape',
    _defaultsToCircleBorderContainerShape,
  );
}

void _registerLoadingColorTests() {
  test(
    'size cannot mix with independent dimensions',
    _sizeCannotMixWithIndependentDimensions,
  );
  testWidgets(
    'resolves default and contained colors from theme',
    _resolvesDefaultAndContainedColorsFromTheme,
  );
  testWidgets(
    'supports single and multiple indicator colors',
    _supportsSingleAndMultipleIndicatorColors,
  );
  test(
    'validates indicator color arguments',
    _validatesIndicatorColorArguments,
  );
}

void _registerLoadingValidationTests() {
  testWidgets(
    'rejects an empty indicator color list',
    _rejectsAnEmptyIndicatorColorList,
  );
  testWidgets(
    'rejects an empty indicator color list in the base indicator',
    _rejectsAnEmptyIndicatorColorListInTheBaseIndicator,
  );
  test('validates instance dimensions', _validatesInstanceDimensions);
  test(
    'prevents mixing constraints with container dimensions',
    _preventsMixingConstraintsWithContainerDimensions,
  );
  test('validates theme dimensions', _validatesThemeDimensions);
  test(
    'lerps and copies dimensions and container shape',
    _lerpsAndCopiesDimensionsAndContainerShape,
  );
}

Future<void> _usesTheDefaultContainerAndIndicatorSizes(
  WidgetTester tester,
) async {
  await tester.pumpWidget(_host(const MorphLoadingIndicator()));

  expect(
    tester.getSize(find.byType(MorphExpressiveLoadingIndicator)),
    const Size(48, 48),
  );
  expect(
    tester
        .widget<MorphExpressiveLoadingIndicator>(
          find.byType(MorphExpressiveLoadingIndicator),
        )
        .indicatorSize,
    38,
  );
}

Future<void> _instanceDimensionsOverrideThemeDimensions(
  WidgetTester tester,
) async {
  final theme = MorphThemeData.light().copyWith(
    loadingIndicatorTheme: const MorphLoadingIndicatorTheme(
      containerWidth: 64,
      containerHeight: 64,
      activeIndicatorSize: 52,
    ),
  );
  await tester.pumpWidget(
    _host(
      const MorphLoadingIndicator(
        indicatorSize: 24,
        containerWidth: 72,
        containerHeight: 56,
      ),
      theme: theme,
    ),
  );

  expect(
    tester.getSize(find.byType(MorphExpressiveLoadingIndicator)),
    const Size(72, 56),
  );
  expect(
    tester
        .widget<MorphExpressiveLoadingIndicator>(
          find.byType(MorphExpressiveLoadingIndicator),
        )
        .indicatorSize,
    24,
  );
}

Future<void> _usesThemeDimensions(WidgetTester tester) async {
  final theme = MorphThemeData.light().copyWith(
    loadingIndicatorTheme: const MorphLoadingIndicatorTheme(
      containerWidth: 60,
      containerHeight: 44,
      activeIndicatorSize: 30,
    ),
  );
  await tester.pumpWidget(_host(const MorphLoadingIndicator(), theme: theme));

  expect(
    tester.getSize(find.byType(MorphExpressiveLoadingIndicator)),
    const Size(60, 44),
  );
  expect(
    tester
        .widget<MorphExpressiveLoadingIndicator>(
          find.byType(MorphExpressiveLoadingIndicator),
        )
        .indicatorSize,
    30,
  );
}

Future<void> _usesTheCustomContainerShape(WidgetTester tester) async {
  const shape = RoundedRectangleBorder(
    borderRadius: BorderRadius.all(Radius.circular(8)),
  );
  await tester.pumpWidget(
    _host(const MorphLoadingIndicator(containerShape: shape)),
  );

  final decoratedBox = tester.widget<DecoratedBox>(
    find.byType(DecoratedBox).first,
  );
  final decoration = decoratedBox.decoration as ShapeDecoration;
  expect(decoration.shape, shape);
}

Future<void> _exposesLoadingSemantics(WidgetTester tester) async {
  await tester.pumpWidget(
    _host(
      const MorphLoadingIndicator(
        semanticLabel: 'Loading',
        semanticValue: 'In progress',
      ),
    ),
  );

  final semantics = tester.getSemantics(
    find.byType(MorphExpressiveLoadingIndicator),
  );
  expect(semantics.label, 'Loading');
  expect(semantics.role, SemanticsRole.progressBar);
  expect(semantics.value, '0%');
  expect(semantics.hint, 'In progress');
}

Future<void> _defaultsToCircleBorderContainerShape(WidgetTester tester) async {
  await tester.pumpWidget(_host(const MorphLoadingIndicator()));

  final decoratedBox = tester.widget<DecoratedBox>(
    find.byType(DecoratedBox).first,
  );
  final decoration = decoratedBox.decoration as ShapeDecoration;
  expect(decoration.shape, isA<CircleBorder>());
  expect(
    MorphLoadingIndicatorTheme.defaults.containerShape,
    isA<CircleBorder>(),
  );
}

Future<void> _sizeScalesOuterAndActiveWith3848Ratio(WidgetTester tester) async {
  await tester.pumpWidget(_host(const MorphLoadingIndicator(size: 96)));

  expect(
    tester.getSize(find.byType(MorphExpressiveLoadingIndicator)),
    const Size(96, 96),
  );
  expect(
    tester
        .widget<MorphExpressiveLoadingIndicator>(
          find.byType(MorphExpressiveLoadingIndicator),
        )
        .indicatorSize,
    76,
  );
}

Future<void> _debugAssertsOuterSizeOutside24To240(WidgetTester tester) async {
  await tester.pumpWidget(_host(const MorphLoadingIndicator(size: 20)));
  expect(tester.takeException(), isA<FlutterError>());

  await tester.pumpWidget(_host(const MorphLoadingIndicator(size: 241)));
  expect(tester.takeException(), isA<FlutterError>());
}

void _sizeCannotMixWithIndependentDimensions() {
  expect(
    () => MorphLoadingIndicator(size: 48, indicatorSize: 38),
    throwsAssertionError,
  );
  expect(
    () => MorphLoadingIndicator(size: 48, containerWidth: 48),
    throwsAssertionError,
  );
}

Future<void> _resolvesDefaultAndContainedColorsFromTheme(
  WidgetTester tester,
) async {
  final theme = MorphThemeData.light();

  await tester.pumpWidget(_host(const MorphLoadingIndicator(), theme: theme));
  var indicator = tester.widget<MorphExpressiveLoadingIndicator>(
    find.byType(MorphExpressiveLoadingIndicator),
  );
  expect(
    indicator.color,
    theme.loadingIndicatorTheme.activeColor(theme.colorScheme),
  );

  await tester.pumpWidget(
    _host(
      const MorphLoadingIndicator(
        variant: MorphLoadingIndicatorVariant.contained,
      ),
      theme: theme,
    ),
  );
  indicator = tester.widget<MorphExpressiveLoadingIndicator>(
    find.byType(MorphExpressiveLoadingIndicator),
  );
  expect(
    indicator.color,
    theme.loadingIndicatorTheme.containedActiveColor(theme.colorScheme),
  );
}

Future<void> _supportsSingleAndMultipleIndicatorColors(
  WidgetTester tester,
) async {
  const singleColor = Color(0xff123456);
  const initialColors = <Color>[
    Color(0xffff0000),
    Color(0xff00ff00),
    Color(0xff0000ff),
  ];
  const updatedColors = <Color>[Color(0xffffff00), Color(0xffff00ff)];

  await tester.pumpWidget(
    _host(const MorphLoadingIndicator(color: singleColor)),
  );
  var indicator = tester.widget<MorphExpressiveLoadingIndicator>(
    find.byType(MorphExpressiveLoadingIndicator),
  );
  expect(indicator.color, singleColor);
  expect(indicator.indicatorColors, <Color>[singleColor]);

  await tester.pumpWidget(
    _host(
      const MorphLoadingIndicator(
        key: ValueKey('indicator'),
        indicatorColors: initialColors,
      ),
    ),
  );
  indicator = tester.widget<MorphExpressiveLoadingIndicator>(
    find.byType(MorphExpressiveLoadingIndicator),
  );
  expect(indicator.indicatorColors, initialColors);
  await tester.pump(const Duration(seconds: 2));
  expect(tester.takeException(), isNull);

  await tester.pumpWidget(
    _host(
      const MorphLoadingIndicator(
        key: ValueKey('indicator'),
        indicatorColors: updatedColors,
      ),
    ),
  );
  indicator = tester.widget<MorphExpressiveLoadingIndicator>(
    find.byType(MorphExpressiveLoadingIndicator),
  );
  expect(indicator.indicatorColors, updatedColors);
}

void _validatesIndicatorColorArguments() {
  expect(
    () => MorphLoadingIndicator(
      color: const Color(0xff000000),
      indicatorColors: const <Color>[Color(0xffffffff)],
    ),
    throwsAssertionError,
  );
}

Future<void> _rejectsAnEmptyIndicatorColorList(WidgetTester tester) async {
  await tester.pumpWidget(
    _host(const MorphLoadingIndicator(indicatorColors: <Color>[])),
  );

  expect(tester.takeException(), isA<AssertionError>());
}

Future<void> _rejectsAnEmptyIndicatorColorListInTheBaseIndicator(
  WidgetTester tester,
) async {
  await tester.pumpWidget(
    _host(const MorphExpressiveLoadingIndicator(indicatorColors: <Color>[])),
  );

  expect(tester.takeException(), isA<AssertionError>());
}

void _validatesInstanceDimensions() {
  for (final indicatorSize in <double>[0, -1]) {
    expect(
      () => MorphLoadingIndicator(indicatorSize: indicatorSize),
      throwsAssertionError,
    );
  }
  for (final containerWidth in <double>[0, -1]) {
    expect(
      () => MorphLoadingIndicator(containerWidth: containerWidth),
      throwsAssertionError,
    );
  }
  for (final containerHeight in <double>[0, -1]) {
    expect(
      () => MorphLoadingIndicator(containerHeight: containerHeight),
      throwsAssertionError,
    );
  }
}

void _preventsMixingConstraintsWithContainerDimensions() {
  expect(
    () => MorphLoadingIndicator(
      constraints: const BoxConstraints.tightFor(width: 48, height: 48),
      containerWidth: 48,
    ),
    throwsAssertionError,
  );
  expect(
    () => MorphLoadingIndicator(
      constraints: const BoxConstraints.tightFor(width: 48, height: 48),
      containerHeight: 48,
    ),
    throwsAssertionError,
  );
}

void _validatesThemeDimensions() {
  expect(
    () => MorphLoadingIndicatorTheme(containerWidth: 0),
    throwsAssertionError,
  );
  expect(
    () => MorphLoadingIndicatorTheme(containerHeight: 0),
    throwsAssertionError,
  );
  expect(
    () => MorphLoadingIndicatorTheme(activeIndicatorSize: 0),
    throwsAssertionError,
  );
}

void _lerpsAndCopiesDimensionsAndContainerShape() {
  const theme = MorphLoadingIndicatorTheme.defaults;
  const shape = RoundedRectangleBorder(
    borderRadius: BorderRadius.all(Radius.circular(8)),
  );
  final copied = theme.copyWith(
    containerWidth: 64,
    containerHeight: 56,
    activeIndicatorSize: 40,
    containerShape: shape,
  );

  expect(copied.containerWidth, 64);
  expect(copied.containerHeight, 56);
  expect(copied.activeIndicatorSize, 40);
  expect(copied.containerShape, shape);

  final lerped = theme.lerp(copied, 1);
  expect(lerped.containerWidth, 64);
  expect(lerped.containerHeight, 56);
  expect(lerped.activeIndicatorSize, 40);
  expect(lerped.containerShape, isA<ShapeBorder>());
}
