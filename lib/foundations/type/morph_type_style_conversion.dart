import 'package:flutter/widgets.dart';

import 'morph_type_style_tokens.dart';
import 'morph_variable_font_config.dart';

/// Which M3 token table to use when resolving a type style.
enum MorphTypeScaleVariant {
  /// `md.sys.typescale.*`
  baseline,

  /// `md.sys.typescale.emphasized.*`
  emphasized,

  /// `md.sys.typescale.variable.*`
  variableBaseline,

  /// `md.sys.typescale.variable.emphasized.*`
  variableEmphasized,
}

/// Whether the variant is an emphasized token set.
extension MorphTypeScaleVariantX on MorphTypeScaleVariant {
  /// True for emphasized and variable emphasized variants.
  bool get isEmphasized {
    return this == MorphTypeScaleVariant.emphasized ||
        this == MorphTypeScaleVariant.variableEmphasized;
  }
}

/// Converts arbitrary text styles to M3 type scale variants.
final class MorphTypeStyleConversion {
  /// Creates a conversion helper instance.
  const MorphTypeStyleConversion();

  /// Tie-break priority when font size matches multiple roles.
  ///
  /// Higher value wins on equal distance (prefers label/body over display).
  static const Map<MorphTypeRole, int> _tiePriority = <MorphTypeRole, int>{
    MorphTypeRole.displayLarge: 1,
    MorphTypeRole.displayMedium: 2,
    MorphTypeRole.displaySmall: 3,
    MorphTypeRole.headlineLarge: 4,
    MorphTypeRole.headlineMedium: 5,
    MorphTypeRole.headlineSmall: 6,
    MorphTypeRole.titleLarge: 7,
    MorphTypeRole.titleMedium: 8,
    MorphTypeRole.titleSmall: 9,
    MorphTypeRole.bodyLarge: 10,
    MorphTypeRole.bodyMedium: 11,
    MorphTypeRole.bodySmall: 12,
    MorphTypeRole.labelLarge: 13,
    MorphTypeRole.labelMedium: 14,
    MorphTypeRole.labelSmall: 15,
  };

  /// Nearest type role by font size; ties prefer smaller roles.
  MorphTypeRole nearestRoleFor(TextStyle style) {
    final size = style.fontSize ?? 14;
    MorphTypeRole best = MorphTypeRole.bodyMedium;
    double bestDistance = double.infinity;
    var bestPriority = -1;

    for (final MorphTypeRole role in MorphTypeRole.values) {
      final MorphTypeStyleTokens tokens = MorphTypeScaleTokens.baseline[role]!;
      final double distance = (tokens.fontSize - size).abs();
      final int priority = _tiePriority[role]!;
      if (distance < bestDistance ||
          (distance == bestDistance && priority > bestPriority)) {
        bestDistance = distance;
        bestPriority = priority;
        best = role;
      }
    }
    return best;
  }

  /// Spec tokens for [role] and [variant].
  MorphTypeStyleTokens resolveTokens(
    MorphTypeRole role,
    MorphTypeScaleVariant variant,
  ) {
    final Map<MorphTypeRole, MorphTypeStyleTokens> table = switch (variant) {
      MorphTypeScaleVariant.baseline => MorphTypeScaleTokens.baseline,
      MorphTypeScaleVariant.emphasized => MorphTypeScaleTokens.emphasized,
      MorphTypeScaleVariant.variableBaseline =>
        MorphTypeScaleTokens.variableBaseline,
      MorphTypeScaleVariant.variableEmphasized =>
        MorphTypeScaleTokens.variableEmphasized,
    };
    return table[role]!;
  }

  /// Converts [source] to [variant], preserving family, color, and decoration.
  TextStyle toVariantFor(
    TextStyle source, {
    required MorphTypeScaleVariant variant,
    MorphTypeRole? role,
    MorphTypeStyleTokens? tokenOverrides,
    MorphVariableFontConfig? variableFont,
  }) {
    final MorphTypeRole resolvedRole = role ?? nearestRoleFor(source);
    MorphTypeStyleTokens tokens = resolveTokens(resolvedRole, variant);
    if (tokenOverrides != null) {
      tokens = tokens.copyWith(
        fontSize: tokenOverrides.fontSize,
        lineHeight: tokenOverrides.lineHeight,
        letterSpacing: tokenOverrides.letterSpacing,
        fontWeight: tokenOverrides.fontWeight,
      );
    }

    TextStyle result = tokens.toTextStyle(fontFamily: source.fontFamily);
    result = result.copyWith(
      fontFamilyFallback: source.fontFamilyFallback,
      color: source.color,
      decoration: source.decoration,
      decorationColor: source.decorationColor,
      decorationStyle: source.decorationStyle,
      backgroundColor: source.backgroundColor,
    );

    if (variableFont != null) {
      result = result.copyWith(
        fontVariations: variableFont.resolveForRole(
          resolvedRole,
          result,
          isEmphasizedScale: variant.isEmphasized,
        ),
      );
    } else if (source.fontVariations != null) {
      result = result.copyWith(fontVariations: source.fontVariations);
    }

    return result;
  }

  /// Nearest type role by font size; ties prefer smaller roles.
  static MorphTypeRole nearestRole(TextStyle style) {
    return const MorphTypeStyleConversion().nearestRoleFor(style);
  }

  /// Spec tokens for [role] and [variant].
  static MorphTypeStyleTokens tokensFor(
    MorphTypeRole role,
    MorphTypeScaleVariant variant,
  ) {
    return const MorphTypeStyleConversion().resolveTokens(role, variant);
  }

  /// Converts [source] to [variant], preserving family, color, and decoration.
  static TextStyle toVariant(
    TextStyle source, {
    required MorphTypeScaleVariant variant,
    MorphTypeRole? role,
    MorphTypeStyleTokens? tokenOverrides,
    MorphVariableFontConfig? variableFont,
  }) {
    return const MorphTypeStyleConversion().toVariantFor(
      source,
      variant: variant,
      role: role,
      tokenOverrides: tokenOverrides,
      variableFont: variableFont,
    );
  }
}
