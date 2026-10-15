import 'package:flutter/widgets.dart';

/// A role in the Material 3 type scale.
enum MorphTypeRole {
  /// Largest display role.
  displayLarge,

  /// Medium display role.
  displayMedium,

  /// Smallest display role.
  displaySmall,

  /// Largest headline role.
  headlineLarge,

  /// Medium headline role.
  headlineMedium,

  /// Smallest headline role.
  headlineSmall,

  /// Largest title role.
  titleLarge,

  /// Medium title role.
  titleMedium,

  /// Smallest title role.
  titleSmall,

  /// Largest body role.
  bodyLarge,

  /// Medium body role.
  bodyMedium,

  /// Smallest body role.
  bodySmall,

  /// Largest label role.
  labelLarge,

  /// Medium label role.
  labelMedium,

  /// Smallest label role.
  labelSmall,
}

/// Per-property tokens for one M3 type scale role.
@immutable
class MorphTypeStyleTokens {
  /// Creates tokens for one type scale role.
  const MorphTypeStyleTokens({
    required this.fontSize,
    required this.lineHeight,
    required this.letterSpacing,
    required this.fontWeight,
  });

  /// Type size in logical pixels.
  final double fontSize;

  /// Absolute line height in logical pixels.
  final double lineHeight;

  /// Letter spacing (tracking) in logical pixels.
  final double letterSpacing;

  /// Font weight for this role.
  final FontWeight fontWeight;

  /// Reads geometry tokens from a [TextStyle].
  factory MorphTypeStyleTokens.fromTextStyle(TextStyle style) {
    final double size = style.fontSize ?? 14;
    final double lineHeight = style.height == null
        ? size * 1.2
        : style.height! * size;
    return MorphTypeStyleTokens(
      fontSize: size,
      lineHeight: lineHeight,
      letterSpacing: style.letterSpacing ?? 0,
      fontWeight: style.fontWeight ?? FontWeight.w400,
    );
  }

  /// Returns a copy with the given fields replaced.
  MorphTypeStyleTokens copyWith({
    double? fontSize,
    double? lineHeight,
    double? letterSpacing,
    FontWeight? fontWeight,
  }) {
    return MorphTypeStyleTokens(
      fontSize: fontSize ?? this.fontSize,
      lineHeight: lineHeight ?? this.lineHeight,
      letterSpacing: letterSpacing ?? this.letterSpacing,
      fontWeight: fontWeight ?? this.fontWeight,
    );
  }

  /// Applies M3 emphasized weight bump (+100 or +200 per role group rules).
  MorphTypeStyleTokens toEmphasized() {
    final FontWeight next = switch (fontWeight) {
      FontWeight.w400 => FontWeight.w500,
      FontWeight.w500 => FontWeight.w700,
      _ => fontWeight,
    };
    return copyWith(fontWeight: next);
  }

  /// Builds a [TextStyle] from these tokens.
  TextStyle toTextStyle({String? fontFamily}) {
    return TextStyle(
      fontFamily: fontFamily,
      fontSize: fontSize,
      height: lineHeight / fontSize,
      letterSpacing: letterSpacing,
      fontWeight: fontWeight,
      textBaseline: TextBaseline.alphabetic,
      leadingDistribution: TextLeadingDistribution.even,
    );
  }
}

/// Canonical M3 type scale token tables (material_ui gen_defaults v38.2.31).
abstract final class MorphTypeScaleTokens {
  /// `md.sys.typescale.*` baseline tokens.
  static const Map<MorphTypeRole, MorphTypeStyleTokens> baseline =
      <MorphTypeRole, MorphTypeStyleTokens>{
        MorphTypeRole.displayLarge: MorphTypeStyleTokens(
          fontSize: 57,
          lineHeight: 64,
          letterSpacing: -0.25,
          fontWeight: FontWeight.w400,
        ),
        MorphTypeRole.displayMedium: MorphTypeStyleTokens(
          fontSize: 45,
          lineHeight: 52,
          letterSpacing: 0,
          fontWeight: FontWeight.w400,
        ),
        MorphTypeRole.displaySmall: MorphTypeStyleTokens(
          fontSize: 36,
          lineHeight: 44,
          letterSpacing: 0,
          fontWeight: FontWeight.w400,
        ),
        MorphTypeRole.headlineLarge: MorphTypeStyleTokens(
          fontSize: 32,
          lineHeight: 40,
          letterSpacing: 0,
          fontWeight: FontWeight.w400,
        ),
        MorphTypeRole.headlineMedium: MorphTypeStyleTokens(
          fontSize: 28,
          lineHeight: 36,
          letterSpacing: 0,
          fontWeight: FontWeight.w400,
        ),
        MorphTypeRole.headlineSmall: MorphTypeStyleTokens(
          fontSize: 24,
          lineHeight: 32,
          letterSpacing: 0,
          fontWeight: FontWeight.w400,
        ),
        MorphTypeRole.titleLarge: MorphTypeStyleTokens(
          fontSize: 22,
          lineHeight: 28,
          letterSpacing: 0,
          fontWeight: FontWeight.w400,
        ),
        MorphTypeRole.titleMedium: MorphTypeStyleTokens(
          fontSize: 16,
          lineHeight: 24,
          letterSpacing: 0.15,
          fontWeight: FontWeight.w500,
        ),
        MorphTypeRole.titleSmall: MorphTypeStyleTokens(
          fontSize: 14,
          lineHeight: 20,
          letterSpacing: 0.1,
          fontWeight: FontWeight.w500,
        ),
        MorphTypeRole.bodyLarge: MorphTypeStyleTokens(
          fontSize: 16,
          lineHeight: 24,
          letterSpacing: 0.5,
          fontWeight: FontWeight.w400,
        ),
        MorphTypeRole.bodyMedium: MorphTypeStyleTokens(
          fontSize: 14,
          lineHeight: 20,
          letterSpacing: 0.25,
          fontWeight: FontWeight.w400,
        ),
        MorphTypeRole.bodySmall: MorphTypeStyleTokens(
          fontSize: 12,
          lineHeight: 16,
          letterSpacing: 0.4,
          fontWeight: FontWeight.w400,
        ),
        MorphTypeRole.labelLarge: MorphTypeStyleTokens(
          fontSize: 14,
          lineHeight: 20,
          letterSpacing: 0.1,
          fontWeight: FontWeight.w500,
        ),
        MorphTypeRole.labelMedium: MorphTypeStyleTokens(
          fontSize: 12,
          lineHeight: 16,
          letterSpacing: 0.5,
          fontWeight: FontWeight.w500,
        ),
        MorphTypeRole.labelSmall: MorphTypeStyleTokens(
          fontSize: 11,
          lineHeight: 16,
          letterSpacing: 0.5,
          fontWeight: FontWeight.w500,
        ),
      };

  /// `md.sys.typescale.emphasized.*` tokens.
  static const Map<MorphTypeRole, MorphTypeStyleTokens> emphasized =
      <MorphTypeRole, MorphTypeStyleTokens>{
        MorphTypeRole.displayLarge: MorphTypeStyleTokens(
          fontSize: 57,
          lineHeight: 64,
          letterSpacing: -0.25,
          fontWeight: FontWeight.w500,
        ),
        MorphTypeRole.displayMedium: MorphTypeStyleTokens(
          fontSize: 45,
          lineHeight: 52,
          letterSpacing: 0,
          fontWeight: FontWeight.w500,
        ),
        MorphTypeRole.displaySmall: MorphTypeStyleTokens(
          fontSize: 36,
          lineHeight: 44,
          letterSpacing: 0,
          fontWeight: FontWeight.w500,
        ),
        MorphTypeRole.headlineLarge: MorphTypeStyleTokens(
          fontSize: 32,
          lineHeight: 40,
          letterSpacing: 0,
          fontWeight: FontWeight.w500,
        ),
        MorphTypeRole.headlineMedium: MorphTypeStyleTokens(
          fontSize: 28,
          lineHeight: 36,
          letterSpacing: 0,
          fontWeight: FontWeight.w500,
        ),
        MorphTypeRole.headlineSmall: MorphTypeStyleTokens(
          fontSize: 24,
          lineHeight: 32,
          letterSpacing: 0,
          fontWeight: FontWeight.w500,
        ),
        MorphTypeRole.titleLarge: MorphTypeStyleTokens(
          fontSize: 22,
          lineHeight: 28,
          letterSpacing: 0,
          fontWeight: FontWeight.w500,
        ),
        MorphTypeRole.titleMedium: MorphTypeStyleTokens(
          fontSize: 16,
          lineHeight: 24,
          letterSpacing: 0.15,
          fontWeight: FontWeight.w700,
        ),
        MorphTypeRole.titleSmall: MorphTypeStyleTokens(
          fontSize: 14,
          lineHeight: 20,
          letterSpacing: 0.1,
          fontWeight: FontWeight.w700,
        ),
        MorphTypeRole.bodyLarge: MorphTypeStyleTokens(
          fontSize: 16,
          lineHeight: 24,
          letterSpacing: 0.5,
          fontWeight: FontWeight.w500,
        ),
        MorphTypeRole.bodyMedium: MorphTypeStyleTokens(
          fontSize: 14,
          lineHeight: 20,
          letterSpacing: 0.25,
          fontWeight: FontWeight.w500,
        ),
        MorphTypeRole.bodySmall: MorphTypeStyleTokens(
          fontSize: 12,
          lineHeight: 16,
          letterSpacing: 0.4,
          fontWeight: FontWeight.w500,
        ),
        MorphTypeRole.labelLarge: MorphTypeStyleTokens(
          fontSize: 14,
          lineHeight: 20,
          letterSpacing: 0.1,
          fontWeight: FontWeight.w700,
        ),
        MorphTypeRole.labelMedium: MorphTypeStyleTokens(
          fontSize: 12,
          lineHeight: 16,
          letterSpacing: 0.5,
          fontWeight: FontWeight.w700,
        ),
        MorphTypeRole.labelSmall: MorphTypeStyleTokens(
          fontSize: 11,
          lineHeight: 16,
          letterSpacing: 0.5,
          fontWeight: FontWeight.w700,
        ),
      };

  /// `md.sys.typescale.variable.*` tokens (tracking zero).
  static const Map<MorphTypeRole, MorphTypeStyleTokens> variableBaseline =
      <MorphTypeRole, MorphTypeStyleTokens>{
        MorphTypeRole.displayLarge: MorphTypeStyleTokens(
          fontSize: 57,
          lineHeight: 64,
          letterSpacing: 0,
          fontWeight: FontWeight.w400,
        ),
        MorphTypeRole.displayMedium: MorphTypeStyleTokens(
          fontSize: 45,
          lineHeight: 52,
          letterSpacing: 0,
          fontWeight: FontWeight.w400,
        ),
        MorphTypeRole.displaySmall: MorphTypeStyleTokens(
          fontSize: 36,
          lineHeight: 44,
          letterSpacing: 0,
          fontWeight: FontWeight.w400,
        ),
        MorphTypeRole.headlineLarge: MorphTypeStyleTokens(
          fontSize: 32,
          lineHeight: 40,
          letterSpacing: 0,
          fontWeight: FontWeight.w400,
        ),
        MorphTypeRole.headlineMedium: MorphTypeStyleTokens(
          fontSize: 28,
          lineHeight: 36,
          letterSpacing: 0,
          fontWeight: FontWeight.w400,
        ),
        MorphTypeRole.headlineSmall: MorphTypeStyleTokens(
          fontSize: 24,
          lineHeight: 32,
          letterSpacing: 0,
          fontWeight: FontWeight.w400,
        ),
        MorphTypeRole.titleLarge: MorphTypeStyleTokens(
          fontSize: 22,
          lineHeight: 28,
          letterSpacing: 0,
          fontWeight: FontWeight.w400,
        ),
        MorphTypeRole.titleMedium: MorphTypeStyleTokens(
          fontSize: 16,
          lineHeight: 24,
          letterSpacing: 0,
          fontWeight: FontWeight.w500,
        ),
        MorphTypeRole.titleSmall: MorphTypeStyleTokens(
          fontSize: 14,
          lineHeight: 20,
          letterSpacing: 0,
          fontWeight: FontWeight.w500,
        ),
        MorphTypeRole.bodyLarge: MorphTypeStyleTokens(
          fontSize: 16,
          lineHeight: 24,
          letterSpacing: 0,
          fontWeight: FontWeight.w400,
        ),
        MorphTypeRole.bodyMedium: MorphTypeStyleTokens(
          fontSize: 14,
          lineHeight: 20,
          letterSpacing: 0,
          fontWeight: FontWeight.w400,
        ),
        MorphTypeRole.bodySmall: MorphTypeStyleTokens(
          fontSize: 12,
          lineHeight: 16,
          letterSpacing: 0,
          fontWeight: FontWeight.w400,
        ),
        MorphTypeRole.labelLarge: MorphTypeStyleTokens(
          fontSize: 14,
          lineHeight: 20,
          letterSpacing: 0,
          fontWeight: FontWeight.w500,
        ),
        MorphTypeRole.labelMedium: MorphTypeStyleTokens(
          fontSize: 12,
          lineHeight: 16,
          letterSpacing: 0,
          fontWeight: FontWeight.w500,
        ),
        MorphTypeRole.labelSmall: MorphTypeStyleTokens(
          fontSize: 11,
          lineHeight: 16,
          letterSpacing: 0,
          fontWeight: FontWeight.w500,
        ),
      };

  /// `md.sys.typescale.variable.emphasized.*` tokens (tracking zero).
  static const Map<MorphTypeRole, MorphTypeStyleTokens> variableEmphasized =
      <MorphTypeRole, MorphTypeStyleTokens>{
        MorphTypeRole.displayLarge: MorphTypeStyleTokens(
          fontSize: 57,
          lineHeight: 64,
          letterSpacing: 0,
          fontWeight: FontWeight.w500,
        ),
        MorphTypeRole.displayMedium: MorphTypeStyleTokens(
          fontSize: 45,
          lineHeight: 52,
          letterSpacing: 0,
          fontWeight: FontWeight.w500,
        ),
        MorphTypeRole.displaySmall: MorphTypeStyleTokens(
          fontSize: 36,
          lineHeight: 44,
          letterSpacing: 0,
          fontWeight: FontWeight.w500,
        ),
        MorphTypeRole.headlineLarge: MorphTypeStyleTokens(
          fontSize: 32,
          lineHeight: 40,
          letterSpacing: 0,
          fontWeight: FontWeight.w500,
        ),
        MorphTypeRole.headlineMedium: MorphTypeStyleTokens(
          fontSize: 28,
          lineHeight: 36,
          letterSpacing: 0,
          fontWeight: FontWeight.w500,
        ),
        MorphTypeRole.headlineSmall: MorphTypeStyleTokens(
          fontSize: 24,
          lineHeight: 32,
          letterSpacing: 0,
          fontWeight: FontWeight.w500,
        ),
        MorphTypeRole.titleLarge: MorphTypeStyleTokens(
          fontSize: 22,
          lineHeight: 28,
          letterSpacing: 0,
          fontWeight: FontWeight.w500,
        ),
        MorphTypeRole.titleMedium: MorphTypeStyleTokens(
          fontSize: 16,
          lineHeight: 24,
          letterSpacing: 0,
          fontWeight: FontWeight.w700,
        ),
        MorphTypeRole.titleSmall: MorphTypeStyleTokens(
          fontSize: 14,
          lineHeight: 20,
          letterSpacing: 0,
          fontWeight: FontWeight.w700,
        ),
        MorphTypeRole.bodyLarge: MorphTypeStyleTokens(
          fontSize: 16,
          lineHeight: 24,
          letterSpacing: 0,
          fontWeight: FontWeight.w500,
        ),
        MorphTypeRole.bodyMedium: MorphTypeStyleTokens(
          fontSize: 14,
          lineHeight: 20,
          letterSpacing: 0,
          fontWeight: FontWeight.w500,
        ),
        MorphTypeRole.bodySmall: MorphTypeStyleTokens(
          fontSize: 12,
          lineHeight: 16,
          letterSpacing: 0,
          fontWeight: FontWeight.w500,
        ),
        MorphTypeRole.labelLarge: MorphTypeStyleTokens(
          fontSize: 14,
          lineHeight: 20,
          letterSpacing: 0,
          fontWeight: FontWeight.w700,
        ),
        MorphTypeRole.labelMedium: MorphTypeStyleTokens(
          fontSize: 12,
          lineHeight: 16,
          letterSpacing: 0,
          fontWeight: FontWeight.w700,
        ),
        MorphTypeRole.labelSmall: MorphTypeStyleTokens(
          fontSize: 11,
          lineHeight: 16,
          letterSpacing: 0,
          fontWeight: FontWeight.w700,
        ),
      };
}

/// Whether the role belongs to the brand typeface group (display/headline/title).
extension MorphTypeRoleX on MorphTypeRole {
  /// True for display, headline, and title roles.
  bool get isBrandRole {
    switch (this) {
      case MorphTypeRole.displayLarge:
      case MorphTypeRole.displayMedium:
      case MorphTypeRole.displaySmall:
      case MorphTypeRole.headlineLarge:
      case MorphTypeRole.headlineMedium:
      case MorphTypeRole.headlineSmall:
      case MorphTypeRole.titleLarge:
      case MorphTypeRole.titleMedium:
      case MorphTypeRole.titleSmall:
        return true;
      case MorphTypeRole.bodyLarge:
      case MorphTypeRole.bodyMedium:
      case MorphTypeRole.bodySmall:
      case MorphTypeRole.labelLarge:
      case MorphTypeRole.labelMedium:
      case MorphTypeRole.labelSmall:
        return false;
    }
  }
}
