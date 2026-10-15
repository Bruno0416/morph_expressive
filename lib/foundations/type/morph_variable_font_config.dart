import 'package:flutter/widgets.dart';

import 'morph_type_style_tokens.dart';
import 'morph_variable_font_axes.dart';

/// Configuration for per-role variable-font axis resolution.
///
/// When set on theme `copyWith` or the material app shell, axes are computed
/// independently for each type scale role.
///
/// Merge order for each role:
/// 1. Auto `wght` / `opsz` from [TextStyle] when enabled and not explicitly set
/// 2. [global] axis overrides
/// 3. [brand] or [body] group overrides (by role group)
/// 4. Legacy [rond] / [bodyRond] when `ROND` is still unset
/// 5. [emphasizedGrad] on emphasized scales when `GRAD` is unset
/// 6. [extraVariations] last (wins on tag conflicts)
@immutable
class MorphVariableFontConfig {
  /// Creates a variable-font configuration.
  const MorphVariableFontConfig({
    this.enableOpsz = true,
    this.syncWghtToWeight = true,
    this.rond = 0,
    this.bodyRond = 0,
    this.emphasizedGrad = 50,
    this.extraVariations = const <FontVariation>[],
    this.global,
    this.brand,
    this.body,
  });

  /// Maps each role's `fontSize` to the `opsz` axis when not explicitly set.
  final bool enableOpsz;

  /// Maps each role's `fontWeight` to the `wght` axis when not explicitly set.
  final bool syncWghtToWeight;

  /// Corner roundness (`ROND`) for display, headline, and title roles.
  final double rond;

  /// Corner roundness (`ROND`) for body and label roles.
  final double bodyRond;

  /// Grade bump (`GRAD`) applied on the emphasized scale only.
  final double emphasizedGrad;

  /// Additional axes merged last (user values win on tag conflicts).
  final List<FontVariation> extraVariations;

  /// Global axis overrides applied before group overrides.
  final MorphVariableFontAxes? global;

  /// Overrides for display, headline, and title roles.
  final MorphVariableFontAxes? brand;

  /// Overrides for body and label roles.
  final MorphVariableFontAxes? body;

  /// Returns a copy with the given fields replaced.
  MorphVariableFontConfig copyWith({
    bool? enableOpsz,
    bool? syncWghtToWeight,
    double? rond,
    double? bodyRond,
    double? emphasizedGrad,
    List<FontVariation>? extraVariations,
    MorphVariableFontAxes? global,
    MorphVariableFontAxes? brand,
    MorphVariableFontAxes? body,
  }) {
    return MorphVariableFontConfig(
      enableOpsz: enableOpsz ?? this.enableOpsz,
      syncWghtToWeight: syncWghtToWeight ?? this.syncWghtToWeight,
      rond: rond ?? this.rond,
      bodyRond: bodyRond ?? this.bodyRond,
      emphasizedGrad: emphasizedGrad ?? this.emphasizedGrad,
      extraVariations: extraVariations ?? this.extraVariations,
      global: global ?? this.global,
      brand: brand ?? this.brand,
      body: body ?? this.body,
    );
  }

  /// Whether any layer sets `wght` explicitly for [role].
  bool _hasExplicitWght(MorphTypeRole role) {
    if (global?.wght != null) {
      return true;
    }
    final MorphVariableFontAxes? group = role.isBrandRole ? brand : body;
    return group?.wght != null;
  }

  /// Whether any layer sets `opsz` explicitly for [role].
  bool _hasExplicitOpsz(MorphTypeRole role) {
    if (global?.opsz != null) {
      return true;
    }
    final MorphVariableFontAxes? group = role.isBrandRole ? brand : body;
    return group?.opsz != null;
  }

  /// Resolves variable-font axes for one [role] and resolved [style].
  List<FontVariation> resolveForRole(
    MorphTypeRole role,
    TextStyle style, {
    required bool isEmphasizedScale,
  }) {
    final axes = <String, double>{};

    if (syncWghtToWeight &&
        !_hasExplicitWght(role) &&
        style.fontWeight != null) {
      axes['wght'] = style.fontWeight!.value.toDouble();
    }
    if (enableOpsz && !_hasExplicitOpsz(role) && style.fontSize != null) {
      axes['opsz'] = style.fontSize!;
    }

    _applyAxes(axes, global);
    _applyAxes(axes, role.isBrandRole ? brand : body);

    if (!axes.containsKey('ROND')) {
      final double roundness = role.isBrandRole ? rond : bodyRond;
      if (roundness != 0) {
        axes['ROND'] = roundness;
      }
    }
    if (isEmphasizedScale && emphasizedGrad != 0 && !axes.containsKey('GRAD')) {
      axes['GRAD'] = emphasizedGrad;
    }

    for (final FontVariation variation in extraVariations) {
      axes[variation.axis] = variation.value;
    }

    return axes.entries
        .map((MapEntry<String, double> e) => FontVariation(e.key, e.value))
        .toList();
  }

  static void _applyAxes(
    Map<String, double> target,
    MorphVariableFontAxes? source,
  ) {
    if (source == null) {
      return;
    }
    for (final FontVariation variation in source.toVariations()) {
      target[variation.axis] = variation.value;
    }
  }
}
