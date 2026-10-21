import 'package:flutter_test/flutter_test.dart';
import 'package:morph_expressive/morph_expressive.dart';
import 'package:material_ui/material_ui.dart' show EdgeInsets;

void main() {
  test('sliders keep the compact 4dp track and explicit customization', () {
    expect(const MorphSliderTheme().trackHeight, 4);
    expect(const MorphSliderTheme().copyWith(trackHeight: 12).trackHeight, 12);
    expect(
      const MorphSliderTheme().applyingSize(MorphSliderSize.xs).trackHeight,
      4,
    );
  });

  test('list items use 5dp spacing and 12.5% softer inside corners', () {
    expect(MorphListCardListTheme.defaultGap, 5);
    expect(MorphListCardListTheme.defaultOuterRadius, 16);
    expect(MorphListCardListTheme.defaultInnerRadius, 4.5);
  });

  test('connected selection and navigation have calm themeable springs', () {
    const group = MorphButtonGroupTheme();
    const nav = MorphNavigationBarTheme();
    expect(group.neighborSquishSpring, MorphMotion.connectedSelection);
    expect(nav.indicatorScaleSpring, MorphMotion.navigationSelection);
    expect(nav.indicatorFadeSpring, MorphMotion.navigationEffects);
    expect(group.neighborSquishSpring.stiffness, lessThan(700));
    expect(nav.indicatorScaleSpring.stiffness, lessThan(700));
  });

  test('split popup uses concentric radius and extra padding', () {
    const style = MorphSplitButtonTheme();
    expect(style.popupBorderRadius, 28);
    expect(style.popupPadding, const EdgeInsets.all(10));
  });
}
