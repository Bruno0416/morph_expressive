import 'package:flutter_test/flutter_test.dart';
import 'package:morph_expressive/morph_components.dart';
import 'package:material_ui/material_ui.dart'
    show
        BuildContext,
        Color,
        DefaultTextStyle,
        FontVariation,
        FontWeight,
        MaterialApp,
        Text,
        TextStyle,
        Theme;

void main() {
  _registerApplyTests();
  _registerScaleTests();
  _registerVariableFontTests();
  _registerConversionTests();
}

void _registerApplyTests() {
  test(
    'apply sets fontFamily on every role without changing size or weight',
    _applySetsFontFamilyOnEveryRole,
  );
  test(
    'apply scales font sizes with factor and delta',
    _applyScalesFontSizesWithFactorAndDelta,
  );
  test(
    'apply copies fontVariations onto every role',
    _applyCopiesFontVariationsOntoEveryRole,
  );
  test('withColor still colors every role', _withColorStillColorsEveryRole);
  test(
    'copyWith fontFamily applies onto an explicit typeScale',
    _copyWithFontFamilyAppliesOntoAnExplicitTypescale,
  );
  testWidgets(
    'copyWith fontFamily projects to DefaultTextStyle and textTheme',
    _copyWithFontFamilyProjectsToDefaulttextstyleAndTexttheme,
  );
  testWidgets(
    'MorphMaterialApp.fontFamily projects to the shell and Material theme',
    _morphmaterialappFontfamilyProjectsToTheShellAndMaterialT,
  );
}

void _registerScaleTests() {
  test('baseline tokens match M3 spec for bodyLarge', _baselineTokensMatchSpec);
  test(
    'emphasized scale bumps labelLarge to w700',
    _emphasizedScaleBumpsLabelLargeToW700,
  );
  test(
    'MorphTypography.material3 exposes baseline and emphasized',
    _morphtypographyMaterial3ExposesBaselineAndEmphasized,
  );
  test(
    'typeScale getter on MorphThemeData returns baseline',
    _typescaleGetterOnM3ethemedataReturnsBaseline,
  );
  test(
    'copyWith typeScale preserves default emphasized scale',
    _copywithTypescalePreservesDefaultEmphasizedScale,
  );
}

void _registerVariableFontTests() {
  test(
    'applyVariableFont sets per-role opsz and split ROND',
    _applyvariablefontSetsPerRoleOpszAndSplitRond,
  );
  test(
    'applyVariableFont adds GRAD on emphasized scale only',
    _applyvariablefontAddsGradOnEmphasizedScaleOnly,
  );
  test('MorphTypeVariations.graded aliases emphasized preset', _gradedAlias);
  test(
    'MorphVariableFontAxes.toVariations omits null axes',
    _axesToVariationsOmitsNulls,
  );
  test(
    'global wght override beats auto sync',
    _globalWghtOverrideBeatsAutoSync,
  );
  test(
    'brand ROND beats global ROND for headline roles',
    _brandRondBeatsGlobalForHeadline,
  );
}

void _registerConversionTests() {
  test(
    'MorphTypeStyleTokens fromTextStyle round trip',
    _tokensFromTextStyleRoundTrip,
  );
  test(
    'toEmphasized bumps label weight to w700',
    _toemphasizedBumpsLabelWeight,
  );
  test(
    'nearestRole picks expected role by size',
    _nearestrolePicksExpectedRoleBySize,
  );
  test(
    'toVariant preserves color and applies emphasized tokens',
    _tovariantPreservesColorAndAppliesEmphasized,
  );
}

void _applySetsFontFamilyOnEveryRole() {
  final base = MorphTypeScale.baseline();
  final applied = base.apply(fontFamily: 'Courier');

  for (final (TextStyle next, TextStyle original) in _pairs(applied, base)) {
    expect(next.fontFamily, 'Courier');
    expect(next.fontSize, original.fontSize);
    expect(next.fontWeight, original.fontWeight);
    expect(next.letterSpacing, original.letterSpacing);
  }
}

void _applyScalesFontSizesWithFactorAndDelta() {
  final base = MorphTypeScale.baseline();
  final applied = base.apply(fontSizeFactor: 2, fontSizeDelta: 1);

  expect(applied.bodyMedium.fontSize, base.bodyMedium.fontSize! * 2 + 1);
  expect(applied.displayLarge.fontSize, base.displayLarge.fontSize! * 2 + 1);
}

void _applyCopiesFontVariationsOntoEveryRole() {
  final applied = MorphTypeScale.baseline().apply(
    fontVariations: MorphTypeVariations.graded.variations,
  );

  for (final TextStyle style in _roles(applied)) {
    expect(style.fontVariations, MorphTypeVariations.graded.variations);
  }
}

void _withColorStillColorsEveryRole() {
  const color = Color(0xFF123456);
  final applied = MorphTypeScale.baseline().withColor(color);

  for (final TextStyle style in _roles(applied)) {
    expect(style.color, color);
  }
}

void _copyWithFontFamilyAppliesOntoAnExplicitTypescale() {
  final sized = MorphTypeScale.baseline().apply(fontSizeFactor: 1.5);
  final data = MorphThemeData.light().copyWith(
    typeScale: sized,
    fontFamily: 'Courier',
  );

  expect(data.typeScale.bodyMedium.fontFamily, 'Courier');
  expect(data.typeScale.bodyMedium.fontSize, sized.bodyMedium.fontSize);
}

Future<void> _copyWithFontFamilyProjectsToDefaulttextstyleAndTexttheme(
  WidgetTester tester,
) async {
  await tester.pumpWidget(
    MaterialApp(
      home: MorphTheme(
        data: MorphThemeData.light().copyWith(fontFamily: 'Courier'),
        child: const Text('probe'),
      ),
    ),
  );

  final BuildContext context = tester.element(find.text('probe'));
  expect(DefaultTextStyle.of(context).style.fontFamily, 'Courier');
  expect(Theme.of(context).textTheme.bodyMedium?.fontFamily, 'Courier');
}

Future<void> _morphmaterialappFontfamilyProjectsToTheShellAndMaterialT(
  WidgetTester tester,
) async {
  await tester.pumpWidget(
    MorphMaterialApp(
      data: MorphThemeData.light(),
      fontFamily: 'Courier',
      fontVariations: MorphTypeVariations.wide.variations,
      home: const Text('probe'),
    ),
  );

  final BuildContext context = tester.element(find.text('probe'));
  final scale = MorphTheme.of(context).typeScale;
  expect(scale.bodyMedium.fontFamily, 'Courier');
  expect(scale.bodyMedium.fontVariations, MorphTypeVariations.wide.variations);
  expect(DefaultTextStyle.of(context).style.fontFamily, 'Courier');
  expect(Theme.of(context).textTheme.bodyMedium?.fontFamily, 'Courier');
}

void _baselineTokensMatchSpec() {
  final scale = MorphTypeScale.baseline();
  expect(scale.bodyLarge.fontSize, 16);
  expect(scale.bodyLarge.height, closeTo(24 / 16, 0.001));
  expect(scale.bodyLarge.letterSpacing, 0.5);
  expect(scale.bodyLarge.fontWeight, FontWeight.w400);
}

void _emphasizedScaleBumpsLabelLargeToW700() {
  final scale = MorphTypeScale.emphasized();
  expect(scale.labelLarge.fontWeight, FontWeight.w700);
  expect(scale.headlineSmall.fontWeight, FontWeight.w500);
}

void _morphtypographyMaterial3ExposesBaselineAndEmphasized() {
  final typography = MorphTypography.material3();
  expect(typography.baseline.bodyLarge.fontWeight, FontWeight.w400);
  expect(typography.emphasized.bodyLarge.fontWeight, FontWeight.w500);
  expect(typography.emphasized.labelLarge.fontWeight, FontWeight.w700);
}

void _typescaleGetterOnM3ethemedataReturnsBaseline() {
  final data = MorphThemeData.light();
  expect(identical(data.typeScale, data.typography.baseline), isTrue);
}

void _copywithTypescalePreservesDefaultEmphasizedScale() {
  final custom = MorphTypeScale.baseline().apply(fontSizeFactor: 2);
  final data = MorphThemeData.light().copyWith(typeScale: custom);
  expect(data.typeScale.bodyMedium.fontSize, 28);
  expect(data.typography.emphasized.labelLarge.fontWeight, FontWeight.w700);
}

void _applyvariablefontSetsPerRoleOpszAndSplitRond() {
  const config = MorphVariableFontConfig(rond: 25, bodyRond: 75);
  final applied = MorphTypeScale.baseline().applyVariableFont(config);

  expect(
    applied.headlineSmall.fontVariations,
    contains(const FontVariation('opsz', 24)),
  );
  expect(
    applied.headlineSmall.fontVariations,
    contains(const FontVariation('ROND', 25)),
  );
  expect(
    applied.bodyLarge.fontVariations,
    contains(const FontVariation('opsz', 16)),
  );
  expect(
    applied.bodyLarge.fontVariations,
    contains(const FontVariation('ROND', 75)),
  );
}

void _applyvariablefontAddsGradOnEmphasizedScaleOnly() {
  const config = MorphVariableFontConfig();
  final typography = MorphTypography.material3().applyVariableFont(config);

  expect(
    typography.baseline.bodyLarge.fontVariations,
    isNot(contains(const FontVariation('GRAD', 50))),
  );
  expect(
    typography.emphasized.bodyLarge.fontVariations,
    contains(const FontVariation('GRAD', 50)),
  );
}

void _gradedAlias() {
  expect(MorphTypeVariations.graded, MorphTypeVariations.emphasized);
  expect(
    MorphTypeVariations.graded.variations,
    MorphTypeVariations.emphasized.variations,
  );
}

void _axesToVariationsOmitsNulls() {
  const axes = MorphVariableFontAxes(wght: 500, opsz: 16);
  expect(axes.toVariations(), hasLength(2));
  expect(axes.toVariations(), contains(const FontVariation('wght', 500)));
}

void _globalWghtOverrideBeatsAutoSync() {
  const config = MorphVariableFontConfig(
    global: MorphVariableFontAxes(wght: 600),
  );
  const style = TextStyle(fontSize: 16, fontWeight: FontWeight.w400);
  final variations = config.resolveForRole(
    MorphTypeRole.bodyLarge,
    style,
    isEmphasizedScale: false,
  );
  expect(variations, contains(const FontVariation('wght', 600)));
  expect(variations, isNot(contains(const FontVariation('wght', 400))));
}

void _brandRondBeatsGlobalForHeadline() {
  const config = MorphVariableFontConfig(
    global: MorphVariableFontAxes(rond: 10),
    brand: MorphVariableFontAxes(rond: 40),
  );
  const style = TextStyle(fontSize: 24, fontWeight: FontWeight.w400);
  final headline = config.resolveForRole(
    MorphTypeRole.headlineSmall,
    style,
    isEmphasizedScale: false,
  );
  final body = config.resolveForRole(
    MorphTypeRole.bodyLarge,
    style,
    isEmphasizedScale: false,
  );
  expect(headline, contains(const FontVariation('ROND', 40)));
  expect(body, contains(const FontVariation('ROND', 10)));
}

void _tokensFromTextStyleRoundTrip() {
  const style = TextStyle(
    fontSize: 16,
    height: 24 / 16,
    letterSpacing: 0.5,
    fontWeight: FontWeight.w400,
  );
  final tokens = MorphTypeStyleTokens.fromTextStyle(style);
  expect(tokens.fontSize, 16);
  expect(tokens.lineHeight, 24);
  expect(tokens.letterSpacing, 0.5);
  expect(tokens.fontWeight, FontWeight.w400);
}

void _toemphasizedBumpsLabelWeight() {
  const tokens = MorphTypeStyleTokens(
    fontSize: 14,
    lineHeight: 20,
    letterSpacing: 0.1,
    fontWeight: FontWeight.w500,
  );
  expect(tokens.toEmphasized().fontWeight, FontWeight.w700);
}

void _nearestrolePicksExpectedRoleBySize() {
  expect(
    MorphTypeStyleConversion.nearestRole(const TextStyle(fontSize: 24)),
    MorphTypeRole.headlineSmall,
  );
  expect(
    MorphTypeStyleConversion.nearestRole(const TextStyle(fontSize: 16)),
    MorphTypeRole.bodyLarge,
  );
}

void _tovariantPreservesColorAndAppliesEmphasized() {
  const source = TextStyle(
    fontFamily: 'Roboto Flex',
    fontSize: 20,
    fontWeight: FontWeight.w400,
    color: Color(0xFF112233),
  );
  final result = MorphTypeStyleConversion.toVariant(
    source,
    variant: MorphTypeScaleVariant.emphasized,
    role: MorphTypeRole.bodyLarge,
  );
  expect(result.fontFamily, 'Roboto Flex');
  expect(result.color, const Color(0xFF112233));
  expect(result.fontWeight, FontWeight.w500);
  expect(result.fontSize, 16);
}

List<TextStyle> _roles(MorphTypeScale scale) {
  return scale.roles.toList();
}

Iterable<(TextStyle, TextStyle)> _pairs(
  MorphTypeScale next,
  MorphTypeScale original,
) {
  final List<TextStyle> a = _roles(next);
  final List<TextStyle> b = _roles(original);
  return <(TextStyle, TextStyle)>[
    for (int i = 0; i < a.length; i++) (a[i], b[i]),
  ];
}
