import 'dart:ui' show CheckedState;

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:morph_expressive/morph_expressive.dart';
import 'package:material_ui/material_ui.dart';

Widget _host(Widget child) {
  return MorphMaterialApp(
    data: MorphThemeData.light(seedColor: const Color(0xFF6750A4)),
    home: Scaffold(body: Center(child: child)),
  );
}

void main() {
  _registerCheckboxThemeTests();
  _registerCheckboxInteractionTests();
}

void _registerCheckboxThemeTests() {
  test(
    'theme defaults match the checkbox spec',
    _themeDefaultsMatchTheCheckboxSpec,
  );
  testWidgets(
    'control is a 48dp target with a 16dp Fluent mark and 2dp corners',
    _controlIsA48dpTargetWithAn18dpIconAnd2dpCorners,
  );
  testWidgets('unselected outline is 2dp', _unselectedOutlineIs2dp);
  testWidgets(
    'disabled selected icon uses surface',
    _disabledSelectedIconUsesSurface,
  );
}

void _registerCheckboxInteractionTests() {
  testWidgets(
    'tapping the control or the label toggles once',
    _tappingTheControlOrTheLabelTogglesOnce,
  );
  testWidgets(
    'semantics expose checkbox checked, mixed, and the label',
    _semanticsExposeCheckboxCheckedMixedAndTheLabel,
  );
  testWidgets(
    'pointer tap clears the focus ring',
    _pointerTapClearsTheFocusRing,
  );
}

void _themeDefaultsMatchTheCheckboxSpec() {
  const theme = MorphCheckboxTheme.defaults;
  final scheme = MorphThemeData.light().colorScheme;
  _expectCheckboxThemeMetrics(theme, scheme);
  _expectCheckboxThemeColors(theme, scheme);
}

void _expectCheckboxThemeMetrics(
  MorphCheckboxTheme theme,
  MorphColorScheme scheme,
) {
  expect(theme.boxSize, 18);
  expect(theme.markSize, 16);
  expect(theme.hitSize, 40);
  expect(theme.targetSize, 48);
  expect(theme.borderWidth, 2);
  expect(theme.selectedOutlineWidth, 0);
  expect(theme.borderRadius, const BorderRadius.all(Radius.circular(2)));
  expect(theme.disabledOpacity, 0.38);
  expect(theme.hoverStateLayerOpacity, 0.08);
  expect(theme.focusStateLayerOpacity, 0.1);
  expect(theme.pressedStateLayerOpacity, 0.1);
  expect(theme.focusIndicatorThickness, 3);
  expect(theme.focusIndicatorOffset, 2);
  expect(theme.resolveFocusIndicatorColor(scheme), scheme.secondary);
}

void _expectCheckboxThemeColors(MorphCheckboxTheme theme, MorphColorScheme scheme) {
  expect(
    theme.borderColor(scheme, enabled: true, active: false, error: false),
    scheme.onSurfaceVariant,
  );
  expect(
    theme.borderColor(
      scheme,
      enabled: true,
      active: false,
      error: false,
      hovered: true,
    ),
    scheme.onSurface,
  );
  expect(
    theme.stateLayerColor(scheme, active: false, error: false, pressed: true),
    scheme.primary,
  );
  expect(
    theme.stateLayerColor(scheme, active: true, error: false, pressed: true),
    scheme.onSurface,
  );
  expect(
    theme.stateLayerColor(scheme, active: true, error: false),
    scheme.primary,
  );
  expect(
    theme.fillColor(scheme, enabled: true, active: true, error: true),
    scheme.error,
  );
  expect(theme.markColor(scheme, error: false), scheme.onPrimary);
  expect(theme.markColor(scheme, error: true), scheme.onError);
  expect(theme.markColor(scheme, error: false, enabled: false), scheme.surface);
  expect(theme.outlineWidth(active: true), 0);
  expect(theme.outlineWidth(active: false), 2);
  expect(theme.checkIconPadding, EdgeInsets.zero);
}

Future<void> _controlIsA48dpTargetWithAn18dpIconAnd2dpCorners(
  WidgetTester tester,
) async {
  await tester.pumpWidget(_host(MorphCheckbox(value: true, onChanged: (_) {})));

  expect(tester.getSize(find.byType(MorphCheckbox)), const Size(48, 48));

  final Icon icon = tester.widget(find.byIcon(FluentIcons.filled.checkmark));
  expect(icon.size, 16);

  final box = tester.widget<AnimatedContainer>(find.byType(AnimatedContainer));
  final decoration = box.decoration! as BoxDecoration;
  expect(decoration.borderRadius, const BorderRadius.all(Radius.circular(2)));
  final border = decoration.border! as Border;
  expect(border.top.width, 0);

  final MorphFocusRing ring = tester.widget(find.byType(MorphFocusRing));
  expect(ring.width, 3);
  expect(ring.gap, 2);

  final Container layer = tester.widget(_circleLayer());
  expect(tester.getSize(find.byWidget(layer)), const Size(40, 40));
}

Finder _circleLayer() {
  return find.byWidgetPredicate(_isCircleLayer);
}

bool _isCircleLayer(Widget widget) {
  return widget is Container &&
      widget.decoration is BoxDecoration &&
      (widget.decoration! as BoxDecoration).shape == BoxShape.circle;
}

Future<void> _unselectedOutlineIs2dp(WidgetTester tester) async {
  await tester.pumpWidget(_host(MorphCheckbox(value: false, onChanged: (_) {})));

  final box = tester.widget<AnimatedContainer>(find.byType(AnimatedContainer));
  final decoration = box.decoration! as BoxDecoration;
  final border = decoration.border! as Border;
  expect(border.top.width, 2);
}

Future<void> _disabledSelectedIconUsesSurface(WidgetTester tester) async {
  final Color surface = MorphThemeData.light(seedColor: const Color(0xFF6750A4))
      .colorScheme
      .surface;

  await tester.pumpWidget(
    _host(const MorphCheckbox(value: true, onChanged: null)),
  );

  final Icon icon = tester.widget(find.byIcon(FluentIcons.filled.checkmark));
  expect(icon.color, surface);
}

Future<void> _tappingTheControlOrTheLabelTogglesOnce(
  WidgetTester tester,
) async {
  var value = false;
  var taps = 0;

  Widget checkbox() {
    return _host(
      MorphCheckbox(
        value: value,
        label: const Text('Pickles'),
        onChanged: (bool? next) {
          taps += 1;
          value = next ?? false;
        },
      ),
    );
  }

  await tester.pumpWidget(checkbox());
  await tester.tap(find.byType(MorphCheckbox));
  await tester.pumpWidget(checkbox());
  expect(taps, 1);
  expect(value, isTrue);

  await tester.tap(find.text('Pickles'));
  await tester.pumpWidget(checkbox());
  expect(taps, 2);
  expect(value, isFalse);
}

Future<void> _semanticsExposeCheckboxCheckedMixedAndTheLabel(
  WidgetTester tester,
) async {
  await tester.pumpWidget(
    _host(
      MorphCheckbox(value: true, label: const Text('Pickles'), onChanged: (_) {}),
    ),
  );

  final checked = tester.getSemantics(find.byType(MorphTappable));
  expect(checked.flagsCollection.isChecked, CheckedState.isTrue);
  expect(checked.label, contains('Pickles'));
  expect(checked.flagsCollection.isButton, isFalse);

  await tester.pumpWidget(
    _host(MorphCheckbox(value: null, tristate: true, onChanged: (_) {})),
  );
  final mixed = tester.getSemantics(find.byType(MorphTappable));
  expect(mixed.flagsCollection.isChecked, CheckedState.mixed);
}

Future<void> _pointerTapClearsTheFocusRing(WidgetTester tester) async {
  await tester.pumpWidget(
    MorphMaterialApp(
      data: MorphThemeData.light(seedColor: const Color(0xFF6750A4)),
      home: const Scaffold(
        body: Column(
          children: <Widget>[
            MorphCheckbox(value: false, onChanged: _noop),
            Expanded(child: SizedBox.expand()),
          ],
        ),
      ),
    ),
  );
  await tester.pumpAndSettle();
  MorphFocusInteraction.resetForTest();
  FocusManager.instance.highlightStrategy =
      FocusHighlightStrategy.alwaysTraditional;
  addTearDown(_resetFocusHighlight);

  await tester.sendKeyDownEvent(LogicalKeyboardKey.tab);
  await tester.sendKeyUpEvent(LogicalKeyboardKey.tab);
  await tester.pump();
  expect(_ringVisible(tester), isTrue);

  await tester.tap(find.byType(MorphCheckbox));
  await tester.pump();
  await tester.pumpAndSettle();
  expect(_ringVisible(tester), isFalse);

  await tester.sendKeyDownEvent(LogicalKeyboardKey.tab);
  await tester.sendKeyUpEvent(LogicalKeyboardKey.tab);
  await tester.pump();
  expect(_ringVisible(tester), isTrue);

  await tester.tapAt(const Offset(24, 520));
  await tester.pump();
  await tester.pumpAndSettle();
  expect(_ringVisible(tester), isFalse);
}

void _resetFocusHighlight() {
  MorphFocusInteraction.resetForTest();
  FocusManager.instance.highlightStrategy = FocusHighlightStrategy.automatic;
}

void _noop(bool? _) {}

bool _ringVisible(WidgetTester tester) {
  return tester
      .widgetList<MorphFocusRing>(find.byType(MorphFocusRing))
      .any((MorphFocusRing ring) => ring.focused);
}
