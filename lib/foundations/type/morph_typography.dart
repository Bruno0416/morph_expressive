import 'package:flutter/widgets.dart';
import 'package:material_ui/material_ui.dart' show TextTheme;

import 'morph_type_style_conversion.dart';
import 'morph_type_style_tokens.dart';
import 'morph_variable_font_config.dart';

/// Whether token tables use static or variable-font tracking defaults.
enum MorphTypeScaleMode {
  /// Static M3 tokens with non-zero tracking on body and label roles.
  static,

  /// Variable-font tokens with zero tracking on every role.
  variable,
}

/// Brand and plain typeface names for the M3 type scale.
@immutable
class MorphTypefaceConfig {
  /// Creates brand/plain typeface names.
  const MorphTypefaceConfig({this.brand, this.plain});

  /// Typeface for display, headline, and title roles.
  final String? brand;

  /// Typeface for body and label roles.
  final String? plain;
}

/// The Material 3 type scale (15 roles).
///
/// Each role stores the font size, line height and tracking (letter spacing)
/// published in the M3 type system.
@immutable
class MorphTypeScale {
  /// Creates a complete Material 3 type scale.
  const MorphTypeScale({
    required this.displayLarge,
    required this.displayMedium,
    required this.displaySmall,
    required this.headlineLarge,
    required this.headlineMedium,
    required this.headlineSmall,
    required this.titleLarge,
    required this.titleMedium,
    required this.titleSmall,
    required this.bodyLarge,
    required this.bodyMedium,
    required this.bodySmall,
    required this.labelLarge,
    required this.labelMedium,
    required this.labelSmall,
  });

  /// The baseline Material 3 type scale using the platform default font.
  factory MorphTypeScale.baseline() {
    return MorphTypeScale.fromTokens(MorphTypeScaleTokens.baseline);
  }

  /// The emphasized Material 3 type scale (`md.sys.typescale.emphasized.*`).
  factory MorphTypeScale.emphasized() {
    return MorphTypeScale.fromTokens(MorphTypeScaleTokens.emphasized);
  }

  /// Variable-font baseline tokens (`md.sys.typescale.variable.*`).
  factory MorphTypeScale.variableBaseline() {
    return MorphTypeScale.fromTokens(MorphTypeScaleTokens.variableBaseline);
  }

  /// Variable-font emphasized tokens (`md.sys.typescale.variable.emphasized.*`).
  factory MorphTypeScale.variableEmphasized() {
    return MorphTypeScale.fromTokens(MorphTypeScaleTokens.variableEmphasized);
  }

  /// Builds a type scale from a token table.
  factory MorphTypeScale.fromTokens(
    Map<MorphTypeRole, MorphTypeStyleTokens> tokens, {
    MorphTypefaceConfig? typeface,
  }) {
    TextStyle build(MorphTypeRole role) {
      final String? family = typeface == null
          ? null
          : role.isBrandRole
          ? typeface.brand
          : typeface.plain;
      return tokens[role]!.toTextStyle(fontFamily: family);
    }

    return MorphTypeScale(
      displayLarge: build(MorphTypeRole.displayLarge),
      displayMedium: build(MorphTypeRole.displayMedium),
      displaySmall: build(MorphTypeRole.displaySmall),
      headlineLarge: build(MorphTypeRole.headlineLarge),
      headlineMedium: build(MorphTypeRole.headlineMedium),
      headlineSmall: build(MorphTypeRole.headlineSmall),
      titleLarge: build(MorphTypeRole.titleLarge),
      titleMedium: build(MorphTypeRole.titleMedium),
      titleSmall: build(MorphTypeRole.titleSmall),
      bodyLarge: build(MorphTypeRole.bodyLarge),
      bodyMedium: build(MorphTypeRole.bodyMedium),
      bodySmall: build(MorphTypeRole.bodySmall),
      labelLarge: build(MorphTypeRole.labelLarge),
      labelMedium: build(MorphTypeRole.labelMedium),
      labelSmall: build(MorphTypeRole.labelSmall),
    );
  }

  /// Largest display role.
  final TextStyle displayLarge;

  /// Medium display role.
  final TextStyle displayMedium;

  /// Smallest display role.
  final TextStyle displaySmall;

  /// Largest headline role.
  final TextStyle headlineLarge;

  /// Medium headline role.
  final TextStyle headlineMedium;

  /// Smallest headline role.
  final TextStyle headlineSmall;

  /// Largest title role.
  final TextStyle titleLarge;

  /// Medium title role.
  final TextStyle titleMedium;

  /// Smallest title role.
  final TextStyle titleSmall;

  /// Largest body role.
  final TextStyle bodyLarge;

  /// Medium body role.
  final TextStyle bodyMedium;

  /// Smallest body role.
  final TextStyle bodySmall;

  /// Largest label role.
  final TextStyle labelLarge;

  /// Medium label role.
  final TextStyle labelMedium;

  /// Smallest label role.
  final TextStyle labelSmall;

  /// Every role in declaration order.
  Iterable<TextStyle> get roles sync* {
    for (final MorphTypeRole role in MorphTypeRole.values) {
      yield roleStyle(role);
    }
  }

  /// Returns the [TextStyle] for [role].
  TextStyle roleStyle(MorphTypeRole role) {
    switch (role) {
      case MorphTypeRole.displayLarge:
        return displayLarge;
      case MorphTypeRole.displayMedium:
        return displayMedium;
      case MorphTypeRole.displaySmall:
        return displaySmall;
      case MorphTypeRole.headlineLarge:
        return headlineLarge;
      case MorphTypeRole.headlineMedium:
        return headlineMedium;
      case MorphTypeRole.headlineSmall:
        return headlineSmall;
      case MorphTypeRole.titleLarge:
        return titleLarge;
      case MorphTypeRole.titleMedium:
        return titleMedium;
      case MorphTypeRole.titleSmall:
        return titleSmall;
      case MorphTypeRole.bodyLarge:
        return bodyLarge;
      case MorphTypeRole.bodyMedium:
        return bodyMedium;
      case MorphTypeRole.bodySmall:
        return bodySmall;
      case MorphTypeRole.labelLarge:
        return labelLarge;
      case MorphTypeRole.labelMedium:
        return labelMedium;
      case MorphTypeRole.labelSmall:
        return labelSmall;
    }
  }

  /// Adapts a framework [TextTheme] into an [MorphTypeScale].
  ///
  /// Each role is taken from [textTheme] when present, falling back to the
  /// [MorphTypeScale.baseline] value otherwise.
  factory MorphTypeScale.fromTextTheme(TextTheme textTheme) {
    final base = MorphTypeScale.baseline();
    return MorphTypeScale(
      displayLarge: textTheme.displayLarge ?? base.displayLarge,
      displayMedium: textTheme.displayMedium ?? base.displayMedium,
      displaySmall: textTheme.displaySmall ?? base.displaySmall,
      headlineLarge: textTheme.headlineLarge ?? base.headlineLarge,
      headlineMedium: textTheme.headlineMedium ?? base.headlineMedium,
      headlineSmall: textTheme.headlineSmall ?? base.headlineSmall,
      titleLarge: textTheme.titleLarge ?? base.titleLarge,
      titleMedium: textTheme.titleMedium ?? base.titleMedium,
      titleSmall: textTheme.titleSmall ?? base.titleSmall,
      bodyLarge: textTheme.bodyLarge ?? base.bodyLarge,
      bodyMedium: textTheme.bodyMedium ?? base.bodyMedium,
      bodySmall: textTheme.bodySmall ?? base.bodySmall,
      labelLarge: textTheme.labelLarge ?? base.labelLarge,
      labelMedium: textTheme.labelMedium ?? base.labelMedium,
      labelSmall: textTheme.labelSmall ?? base.labelSmall,
    );
  }

  /// The per-size label font sizes used by expressive buttons.
  MorphButtonFontSize get buttonFontSize => const MorphButtonFontSize();

  /// A framework [TextTheme] mirroring these baseline roles.
  TextTheme toTextTheme() {
    final TextTheme? cached = _textThemeCache[this];
    if (cached != null) {
      return cached;
    }
    final textTheme = TextTheme(
      displayLarge: displayLarge,
      displayMedium: displayMedium,
      displaySmall: displaySmall,
      headlineLarge: headlineLarge,
      headlineMedium: headlineMedium,
      headlineSmall: headlineSmall,
      titleLarge: titleLarge,
      titleMedium: titleMedium,
      titleSmall: titleSmall,
      bodyLarge: bodyLarge,
      bodyMedium: bodyMedium,
      bodySmall: bodySmall,
      labelLarge: labelLarge,
      labelMedium: labelMedium,
      labelSmall: labelSmall,
    );
    _textThemeCache[this] = textTheme;
    return textTheme;
  }

  /// Returns a copy with [color] applied to every role.
  MorphTypeScale withColor(Color color) => apply(color: color);

  /// Applies shared typography attributes to every role.
  MorphTypeScale apply({
    String? fontFamily,
    MorphTypefaceConfig? typeface,
    List<String>? fontFamilyFallback,
    String? package,
    double fontSizeFactor = 1.0,
    double fontSizeDelta = 0.0,
    Color? color,
    TextDecoration? decoration,
    Color? decorationColor,
    TextDecorationStyle? decorationStyle,
    List<FontVariation>? fontVariations,
  }) {
    final mapped = <MorphTypeRole, TextStyle>{};
    for (final MorphTypeRole role in MorphTypeRole.values) {
      final TextStyle style = roleStyle(role);
      final String? family = typeface != null
          ? role.isBrandRole
                ? typeface.brand
                : typeface.plain
          : fontFamily;
      mapped[role] = style.copyWith(
        fontFamily: family,
        fontFamilyFallback: fontFamilyFallback,
        package: package,
        fontSize: style.fontSize == null
            ? null
            : style.fontSize! * fontSizeFactor + fontSizeDelta,
        color: color,
        decoration: decoration,
        decorationColor: decorationColor,
        decorationStyle: decorationStyle,
        fontVariations: fontVariations,
      );
    }
    return MorphTypeScale._fromMapped(mapped);
  }

  /// Applies per-role variable-font axes from [config].
  MorphTypeScale applyVariableFont(
    MorphVariableFontConfig config, {
    bool isEmphasizedScale = false,
  }) {
    final mapped = <MorphTypeRole, TextStyle>{};
    for (final MorphTypeRole role in MorphTypeRole.values) {
      final TextStyle style = roleStyle(role);
      mapped[role] = style.copyWith(
        fontVariations: config.resolveForRole(
          role,
          style,
          isEmphasizedScale: isEmphasizedScale,
        ),
      );
    }
    return MorphTypeScale._fromMapped(mapped);
  }

  /// Builds a [TextStyle] for [role] using [variant] tokens and optional overrides.
  TextStyle styleFor(
    MorphTypeRole role, {
    MorphTypeScaleVariant variant = MorphTypeScaleVariant.baseline,
    MorphTypeStyleTokens? overrides,
    MorphVariableFontConfig? variableFont,
  }) {
    MorphTypeStyleTokens tokens = MorphTypeStyleConversion.tokensFor(role, variant);
    if (overrides != null) {
      tokens = tokens.copyWith(
        fontSize: overrides.fontSize,
        lineHeight: overrides.lineHeight,
        letterSpacing: overrides.letterSpacing,
        fontWeight: overrides.fontWeight,
      );
    }

    final TextStyle base = roleStyle(role);
    TextStyle result = tokens.toTextStyle(fontFamily: base.fontFamily);
    result = result.copyWith(
      fontFamilyFallback: base.fontFamilyFallback,
      color: base.color,
      decoration: base.decoration,
      decorationColor: base.decorationColor,
      decorationStyle: base.decorationStyle,
    );

    if (variableFont != null) {
      result = result.copyWith(
        fontVariations: variableFont.resolveForRole(
          role,
          result,
          isEmphasizedScale: variant.isEmphasized,
        ),
      );
    }

    return result;
  }

  MorphTypeScale._fromMapped(Map<MorphTypeRole, TextStyle> mapped)
    : displayLarge = mapped[MorphTypeRole.displayLarge]!,
      displayMedium = mapped[MorphTypeRole.displayMedium]!,
      displaySmall = mapped[MorphTypeRole.displaySmall]!,
      headlineLarge = mapped[MorphTypeRole.headlineLarge]!,
      headlineMedium = mapped[MorphTypeRole.headlineMedium]!,
      headlineSmall = mapped[MorphTypeRole.headlineSmall]!,
      titleLarge = mapped[MorphTypeRole.titleLarge]!,
      titleMedium = mapped[MorphTypeRole.titleMedium]!,
      titleSmall = mapped[MorphTypeRole.titleSmall]!,
      bodyLarge = mapped[MorphTypeRole.bodyLarge]!,
      bodyMedium = mapped[MorphTypeRole.bodyMedium]!,
      bodySmall = mapped[MorphTypeRole.bodySmall]!,
      labelLarge = mapped[MorphTypeRole.labelLarge]!,
      labelMedium = mapped[MorphTypeRole.labelMedium]!,
      labelSmall = mapped[MorphTypeRole.labelSmall]!;
}

/// Baseline and emphasized Material 3 type scales (30 styles total).
@immutable
class MorphTypography {
  /// Creates baseline and emphasized type scales.
  const MorphTypography({required this.baseline, required this.emphasized});

  /// Default M3 typography for [mode].
  factory MorphTypography.material3({
    MorphTypeScaleMode mode = MorphTypeScaleMode.static,
  }) {
    switch (mode) {
      case MorphTypeScaleMode.static:
        return MorphTypography(
          baseline: MorphTypeScale.baseline(),
          emphasized: MorphTypeScale.emphasized(),
        );
      case MorphTypeScaleMode.variable:
        return MorphTypography(
          baseline: MorphTypeScale.variableBaseline(),
          emphasized: MorphTypeScale.variableEmphasized(),
        );
    }
  }

  /// Default UI type styles (`md.sys.typescale.*` or variable equivalent).
  final MorphTypeScale baseline;

  /// Emphasized type styles (`md.sys.typescale.emphasized.*`).
  final MorphTypeScale emphasized;

  /// Returns a copy with [color] applied to both scales.
  MorphTypography withColor(Color color) => apply(color: color);

  /// Applies shared typography attributes to both scales.
  MorphTypography apply({
    String? fontFamily,
    MorphTypefaceConfig? typeface,
    List<String>? fontFamilyFallback,
    String? package,
    double fontSizeFactor = 1.0,
    double fontSizeDelta = 0.0,
    Color? color,
    TextDecoration? decoration,
    Color? decorationColor,
    TextDecorationStyle? decorationStyle,
    List<FontVariation>? fontVariations,
  }) {
    return MorphTypography(
      baseline: baseline.apply(
        fontFamily: fontFamily,
        typeface: typeface,
        fontFamilyFallback: fontFamilyFallback,
        package: package,
        fontSizeFactor: fontSizeFactor,
        fontSizeDelta: fontSizeDelta,
        color: color,
        decoration: decoration,
        decorationColor: decorationColor,
        decorationStyle: decorationStyle,
        fontVariations: fontVariations,
      ),
      emphasized: emphasized.apply(
        fontFamily: fontFamily,
        typeface: typeface,
        fontFamilyFallback: fontFamilyFallback,
        package: package,
        fontSizeFactor: fontSizeFactor,
        fontSizeDelta: fontSizeDelta,
        color: color,
        decoration: decoration,
        decorationColor: decorationColor,
        decorationStyle: decorationStyle,
        fontVariations: fontVariations,
      ),
    );
  }

  /// Applies per-role variable-font axes to both scales.
  MorphTypography applyVariableFont(MorphVariableFontConfig config) {
    return MorphTypography(
      baseline: baseline.applyVariableFont(config),
      emphasized: emphasized.applyVariableFont(config, isEmphasizedScale: true),
    );
  }
}

/// Named Roboto Flex axis presets for Material 3 Expressive type.
///
/// Static and mono fonts ignore axes they do not define.
enum MorphTypeVariations {
  /// No extra axes; the baseline scale weights stand.
  regular,

  /// Weight and grade axis bump (`wght` + `GRAD`).
  ///
  /// Not the M3 emphasized type scale — use [MorphTypography.emphasized] for
  /// `md.sys.typescale.emphasized.*` roles.
  emphasized,

  /// Condensed width (`wdth` 75).
  condensed,

  /// Extra-condensed width (`wdth` 50).
  extraCondensed,

  /// Wide width (`wdth` 125).
  wide,

  /// Extra-wide width (`wdth` 151).
  extraWide,

  /// Roundness on (`ROND` 100).
  round;

  /// Documented alias for [emphasized] axis preset (not the emphasized scale).
  static const MorphTypeVariations graded = emphasized;

  /// Variable-font axes for this preset.
  List<FontVariation> get variations {
    switch (this) {
      case MorphTypeVariations.regular:
        return const <FontVariation>[];
      case MorphTypeVariations.emphasized:
        return const <FontVariation>[
          FontVariation('wght', 600),
          FontVariation('GRAD', 50),
        ];
      case MorphTypeVariations.condensed:
        return const <FontVariation>[FontVariation('wdth', 75)];
      case MorphTypeVariations.extraCondensed:
        return const <FontVariation>[FontVariation('wdth', 50)];
      case MorphTypeVariations.wide:
        return const <FontVariation>[FontVariation('wdth', 125)];
      case MorphTypeVariations.extraWide:
        return const <FontVariation>[FontVariation('wdth', 151)];
      case MorphTypeVariations.round:
        return const <FontVariation>[FontVariation('ROND', 100)];
    }
  }
}

/// Per-size label font sizes for expressive buttons.
@immutable
class MorphButtonFontSize {
  /// Creates button label sizes for each expressive size step.
  const MorphButtonFontSize({
    this.xs = 14,
    this.sm = 14,
    this.md = 16,
    this.lg = 20,
    this.xl = 24,
  });

  /// Extra-small button label size.
  final double xs;

  /// Small button label size.
  final double sm;

  /// Medium button label size.
  final double md;

  /// Large button label size.
  final double lg;

  /// Extra-large button label size.
  final double xl;
}

/// Memoises [MorphTypeScale.toTextTheme] results per instance.
final Expando<TextTheme> _textThemeCache = Expando<TextTheme>();
