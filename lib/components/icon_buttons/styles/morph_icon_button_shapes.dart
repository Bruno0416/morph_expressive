import 'package:material_ui/material_ui.dart';

import '../enums/morph_icon_button_enums.dart';
import 'morph_icon_button_theme.dart';

/// Shape resolution helpers: resting/pressed radii and toggle behavior.
class MorphIconButtonShapes {
  const MorphIconButtonShapes._();

  /// restVariant.

  static MorphIconButtonShapeVariant restVariant({
    required bool isToggle,
    required bool isSelected,
    required MorphIconButtonShapeVariant baseVariant,
  }) {
    if (isToggle && isSelected) {
      return baseVariant == MorphIconButtonShapeVariant.round
          ? MorphIconButtonShapeVariant.square
          : MorphIconButtonShapeVariant.round;
    }
    return baseVariant;
  }

  /// restingRadius.

  static double restingRadius({
    required MorphIconButtonTheme theme,
    required MorphIconButtonSize size,
    required MorphIconButtonShapeVariant variant,
  }) {
    return switch (variant) {
      MorphIconButtonShapeVariant.round => theme.radiusRestRound(size),
      MorphIconButtonShapeVariant.square => theme.radiusRestSquare(size),
    };
  }

  /// Effective corner radius for the given material states.
  ///
  /// Pressed uses [MorphIconButtonTheme.radiusPressed]; hover keeps resting
  /// (spec morphs only on press).
  static double effectiveRadius({
    required MorphIconButtonTheme theme,
    required MorphIconButtonSize size,
    required MorphIconButtonShapeVariant baseVariant,
    required bool isToggle,
    required bool isSelected,
    required Set<WidgetState> states,
  }) {
    final variant = restVariant(
      isToggle: isToggle,
      isSelected: isSelected,
      baseVariant: baseVariant,
    );

    if (states.contains(WidgetState.pressed)) {
      return theme.radiusPressed(size);
    }
    return restingRadius(theme: theme, size: size, variant: variant);
  }
}
