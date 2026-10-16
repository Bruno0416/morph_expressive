import 'dart:ui' show SemanticsRole;

import 'package:flutter/gestures.dart';
import 'package:flutter/rendering.dart' show SemanticsNode;
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:morph_expressive/components/text_fields/components/morph_text_field_container_painter.dart';
import 'package:morph_expressive/morph_components.dart';
import 'package:material_ui/material_ui.dart';

import 'focus_ring_test_support.dart';

final MorphThemeData _theme = MorphThemeData.light(
  seedColor: const Color(0xFF6750A4),
);

MorphColorScheme get _scheme => _theme.colorScheme;

Widget _app(Widget child) {
  return MorphMaterialApp(
    data: _theme,
    home: Scaffold(
      body: Align(
        alignment: Alignment.topLeft,
        child: SizedBox(width: 320, child: child),
      ),
    ),
  );
}

MorphTextFieldContainerPainter _painter(WidgetTester tester) {
  return tester
      .widgetList<CustomPaint>(find.byType(CustomPaint))
      .map((CustomPaint p) => p.painter)
      .whereType<MorphTextFieldContainerPainter>()
      .first;
}

Rect _container(WidgetTester tester) => tester.getRect(
  find
      .byWidgetPredicate(
        (Widget w) =>
            w is CustomPaint && w.painter is MorphTextFieldContainerPainter,
      )
      .first,
);

void main() {
  setUp(setUpFocusRingTests);
  tearDown(tearDownFocusRingTests);
  testWidgets('filled measurements match the spec', _filledMeasurements);
  testWidgets('outlined notch and 2dp focus outline', _outlinedNotch);
  testWidgets('filled label exits only on focus or populated', _filledExternalLabel);
  testWidgets('filled label shifts diagonally and respects theme style',
      _filledDiagonalLabel);
  test('color roles resolve per state', _colorRoles);
  testWidgets('hover darkens the filled indicator', _hoverState);
  testWidgets('counter limits input and is labelled', _counter);
  testWidgets('error text is an alert with an error icon', _errorAlert);
  testWidgets('disabled fields are skipped by Tab', _disabledSkipped);
  testWidgets('focus ring is secondary 3dp and hides on tap', _focusRing);
  testWidgets('clear and password toggles', _clearAndPassword);
  testWidgets('density removes 4dp per step', _density);
  testWidgets('required label and affix labels', _requiredAndAffixes);
  testWidgets('null maxLines grows without a limit', _unlimitedLines);
  testWidgets('icons and affixes follow slot alignment', _slotAlignment);
}

Future<void> _filledMeasurements(WidgetTester tester) async {
  final controller = TextEditingController(text: 'Input');
  addTearDown(controller.dispose);
  await tester.pumpWidget(
    _app(
      MorphTextField(
        controller: controller,
        label: 'Label',
        leading: const Icon(MorphIcons.search),
        trailing: const Icon(MorphIcons.mic),
      ),
    ),
  );
  await tester.pumpAndSettle();

  final Rect box = _container(tester);
  expect(box.height, 56);
  final Rect leading = tester.getRect(find.byIcon(MorphIcons.search));
  expect(leading.left - box.left, 12);
  expect(leading.width, 24);
  final Rect trailing = tester.getRect(find.byIcon(MorphIcons.mic));
  expect(box.right - trailing.right, 12);
  final Rect input = tester.getRect(find.byType(EditableText));
  expect(input.left - leading.right, 16);
  expect(trailing.left - input.right, 16);
  expect(input.center.dy, closeTo(box.center.dy, 0.5));
  expect(tester.getRect(find.text('Label')).bottom,
      lessThanOrEqualTo(box.top));
  expect(tester.getRect(find.text('Label')).left, closeTo(box.left, 0.5));
  expect(_painter(tester).strokeWidth, 0);
  expect(_painter(tester).strokeColor, _scheme.onSurfaceVariant);
}

Future<void> _filledExternalLabel(WidgetTester tester) async {
  final controller = TextEditingController();
  final node = FocusNode();
  addTearDown(controller.dispose);
  addTearDown(node.dispose);
  await tester.pumpWidget(_app(MorphTextField(
    label: 'Email',
    placeholder: 'name@example.com',
    controller: controller,
    focusNode: node,
  )));
  await tester.pumpAndSettle();
  Rect box = _container(tester);
  expect(tester.getRect(find.text('Email')).center.dy,
      closeTo(box.center.dy, 0.5));
  expect(find.text('name@example.com'), findsNothing);

  node.requestFocus();
  await tester.pumpAndSettle();
  box = _container(tester);
  expect(tester.getRect(find.text('Email')).bottom,
      lessThanOrEqualTo(box.top));
  expect(find.text('name@example.com'), findsOneWidget);
  expect(tester.getRect(find.byType(EditableText)).center.dy,
      closeTo(box.center.dy, 0.5));

  controller.text = 'user@example.com';
  await tester.pumpAndSettle();
  node.unfocus();
  await tester.pumpAndSettle();
  expect(tester.getRect(find.text('Email')).bottom,
      lessThanOrEqualTo(_container(tester).top));
  expect(find.text('name@example.com'), findsNothing);

  controller.clear();
  await tester.pumpAndSettle();
  box = _container(tester);
  expect(tester.getRect(find.text('Email')).center.dy,
      closeTo(box.center.dy, 0.5));
}

Future<void> _filledDiagonalLabel(WidgetTester tester) async {
  final node = FocusNode();
  addTearDown(node.dispose);
  await tester.pumpWidget(_app(
    MorphTextField(
      label: 'Email',
      leading: const Icon(MorphIcons.search),
      focusNode: node,
    ),
  ));
  await tester.pumpAndSettle();
  final Rect initial = tester.getRect(find.text('Email'));
  final Rect box = _container(tester);
  expect(initial.left, greaterThan(box.left + 20));

  node.requestFocus();
  await tester.pumpAndSettle();
  final Rect floated = tester.getRect(find.text('Email'));
  expect(floated.left, closeTo(_container(tester).left, 0.5));
  expect(floated.top, lessThan(initial.top));
  expect(floated.bottom, lessThanOrEqualTo(_container(tester).top));
  final Text label = tester.widget<Text>(find.text('Email'));
  expect(label.style!.color, _scheme.onSurface);
  expect(label.style!.fontSize, (_theme.typeScale.bodyMedium.fontSize ?? 14) + 1);

  final custom = _theme.copyWith(
    textFieldTheme: _theme.textFieldTheme.copyWith(
      floatingLabelTextStyle: const TextStyle(fontSize: 19),
    ),
  );
  final populated = TextEditingController(text: 'value');
  addTearDown(populated.dispose);
  await tester.pumpWidget(MorphMaterialApp(
    data: custom,
    home: Scaffold(body: SizedBox(
      width: 320,
      child: MorphTextField(
        label: 'Email',
        controller: populated,
        floatingLabelTextStyle: const TextStyle(fontSize: 21),
      ),
    )),
  ));
  await tester.pumpAndSettle();
  // Per-widget override wins over the theme's floatingLabelTextStyle.
  expect(tester.widget<Text>(find.text('Email')).style!.fontSize, 21);
}

Future<void> _outlinedNotch(WidgetTester tester) async {
  await tester.pumpWidget(
    _app(
      const MorphTextField(label: 'Label', variant: MorphTextFieldVariant.outlined),
    ),
  );
  await tester.pumpAndSettle();
  expect(_container(tester).height, 56);
  expect(_painter(tester).notchWidth, 0);
  expect(_painter(tester).strokeColor, _scheme.outline);
  expect(_painter(tester).strokeWidth, 2);

  await tester.tap(find.byType(MorphTextField));
  await tester.pumpAndSettle();
  final MorphTextFieldContainerPainter painter = _painter(tester);
  expect(painter.strokeWidth, 2);
  expect(painter.strokeColor, _scheme.primary);
  // The notch must clear the rounded top-left corner and the label.
  final Rect label = tester.getRect(find.text('Label'));
  expect(painter.notchStart,
      greaterThanOrEqualTo(painter.shape.topLeft.x));
  expect(painter.notchWidth, closeTo(label.width + 8, 0.5));
  expect(label.center.dy, closeTo(_container(tester).top, 0.5));
}

void _colorRoles() {
  const theme = MorphTextFieldTheme.defaults;
  MorphTextFieldColors filled(MorphTextFieldStates s) => theme.resolveColors(
    _scheme,
    variant: MorphTextFieldVariant.filled,
    states: s,
  );
  MorphTextFieldColors outlined(MorphTextFieldStates s) => theme.resolveColors(
    _scheme,
    variant: MorphTextFieldVariant.outlined,
    states: s,
  );
  final MorphTextFieldColors enabled = filled(const MorphTextFieldStates());
  expect(enabled.container, _scheme.surfaceContainerHighest);
  expect(enabled.stroke, _scheme.onSurfaceVariant);
  expect(enabled.strokeWidth, 0); // Morph filled: no underline at rest.
  expect(enabled.label, _scheme.onSurfaceVariant);
  expect(enabled.inputText, _scheme.onSurface);
  expect(enabled.caret, _scheme.primary);
  expect(enabled.focusRing, _scheme.secondary);
  final focus = filled(const MorphTextFieldStates(focused: true));
  expect(focus.label, _scheme.onSurface);
  expect(focus.strokeWidth, 0); // Morph filled: no underline on focus.
  final customFocus = theme.copyWith(focusActiveIndicatorWidth: 2).resolveColors(
    _scheme,
    variant: MorphTextFieldVariant.filled,
    states: const MorphTextFieldStates(focused: true),
  );
  expect(customFocus.strokeWidth, 2); // Still configurable by the consumer.
  final errorHover = filled(
    const MorphTextFieldStates(error: true, hovered: true),
  );
  expect(errorHover.stroke, _scheme.onErrorContainer);
  expect(errorHover.trailingIcon, _scheme.onErrorContainer);
  expect(errorHover.supportingText, _scheme.error);
  expect(errorHover.leadingIcon, _scheme.onSurfaceVariant);
  final errorFocus = filled(
    const MorphTextFieldStates(error: true, hovered: true, focused: true),
  );
  expect(errorFocus.label, _scheme.error);
  expect(errorFocus.caret, _scheme.error);
  expect(errorFocus.focusRing, _scheme.error);
  final disabled = filled(const MorphTextFieldStates(enabled: false));
  expect(disabled.container.a, closeTo(0.04, 0.01));
  expect(disabled.stroke.a, closeTo(0.38, 0.01));
  final outlinedResting = outlined(const MorphTextFieldStates());
  final outlinedFocused = outlined(const MorphTextFieldStates(focused: true));
  expect(outlinedResting.strokeWidth, 2);
  expect(outlinedFocused.strokeWidth, 2);
  final customOutline = theme.copyWith(
    outlineWidth: 1,
    focusOutlineWidth: 3,
  );
  expect(customOutline.strokeWidthFor(
    MorphTextFieldVariant.outlined,
    const MorphTextFieldStates(),
  ), 1);
  expect(customOutline.strokeWidthFor(
    MorphTextFieldVariant.outlined,
    const MorphTextFieldStates(focused: true),
  ), 3);
  final outlinedHover = outlined(const MorphTextFieldStates(hovered: true));
  expect(outlinedHover.label, _scheme.onSurface);
  expect(outlinedHover.stroke, _scheme.onSurface);
  expect(outlinedHover.stateLayer.a, 0);
  final outlinedDisabled = outlined(const MorphTextFieldStates(enabled: false));
  expect(outlinedDisabled.stroke.a, closeTo(0.12, 0.01));
}

Future<void> _hoverState(WidgetTester tester) async {
  await tester.pumpWidget(_app(const MorphTextField(label: 'Label')));
  await tester.pumpAndSettle();
  final TestGesture mouse = await tester.createGesture(
    kind: PointerDeviceKind.mouse,
  );
  addTearDown(mouse.removePointer);
  await mouse.addPointer(location: _container(tester).center);
  await tester.pumpAndSettle();
  final MorphTextFieldContainerPainter painter = _painter(tester);
  expect(painter.strokeColor, _scheme.onSurface);
  expect(painter.stateLayerColor.a, closeTo(0.08, 0.01));
}

Future<void> _counter(WidgetTester tester) async {
  final SemanticsHandle semantics = tester.ensureSemantics();
  await tester.pumpWidget(_app(const MorphTextField(label: 'Bio', maxLength: 5)));
  await tester.enterText(find.byType(EditableText), 'Hello world');
  await tester.pumpAndSettle();
  expect(find.text('5/5'), findsOneWidget);
  expect(
    find.bySemanticsLabel('Character count, 5 of 5 characters entered'),
    findsOneWidget,
  );
  semantics.dispose();
}

Future<void> _errorAlert(WidgetTester tester) async {
  final SemanticsHandle semantics = tester.ensureSemantics();
  await tester.pumpWidget(
    _app(
      const MorphTextField(
        label: 'ZIP code',
        supportingText: 'Five digits',
        errorText: 'Not a valid ZIP code',
      ),
    ),
  );
  await tester.pumpAndSettle();
  expect(find.text('Five digits'), findsNothing);
  final SemanticsNode alert = tester.getSemantics(
    find.bySemanticsLabel('Not a valid ZIP code').last,
  );
  expect(alert.getSemanticsData().role, SemanticsRole.alert);
  expect(find.byIcon(MorphIcons.error), findsOneWidget);
  expect(find.bySemanticsLabel('Error'), findsOneWidget);
  semantics.dispose();
}

Future<void> _disabledSkipped(WidgetTester tester) async {
  final first = FocusNode();
  final second = FocusNode();
  addTearDown(first.dispose);
  addTearDown(second.dispose);
  await tester.pumpWidget(
    _app(
      Column(
        children: <Widget>[
          MorphTextField(focusNode: first, label: 'Off', enabled: false),
          MorphTextField(focusNode: second, label: 'On'),
        ],
      ),
    ),
  );
  await tester.sendKeyEvent(LogicalKeyboardKey.tab);
  await tester.pumpAndSettle();
  expect(first.hasFocus, isFalse);
  expect(second.hasFocus, isTrue);
}

Future<void> _focusRing(WidgetTester tester) async {
  final node = FocusNode();
  addTearDown(node.dispose);
  await tester.pumpWidget(_app(MorphTextField(focusNode: node, label: 'Name')));
  MorphFocusInteraction.instance.noteKeyboardHighlight();
  node.requestFocus();
  await tester.pumpAndSettle();
  MorphFocusRing ring() => tester.widget<MorphFocusRing>(find.byType(MorphFocusRing));
  expect(ring().focused, isTrue);
  expect(ring().width, 3);
  expect(ring().gap, 2);
  expect(ring().color, _scheme.secondary);

  await tester.tap(find.byType(MorphTextField));
  await tester.pumpAndSettle();
  expect(node.hasFocus, isTrue);
  expect(ring().focused, isFalse);
}

Future<void> _clearAndPassword(WidgetTester tester) async {
  final controller = TextEditingController();
  addTearDown(controller.dispose);
  await tester.pumpWidget(
    _app(
      Column(
        children: <Widget>[
          MorphTextField(controller: controller, showClearButton: true),
          const MorphTextField(obscureText: true, showPasswordToggle: true),
        ],
      ),
    ),
  );
  expect(find.byIcon(MorphIcons.cancel), findsNothing);
  await tester.enterText(find.byType(EditableText).first, 'abc');
  await tester.pumpAndSettle();
  await tester.tap(find.byIcon(MorphIcons.cancel));
  await tester.pumpAndSettle();
  expect(controller.text, isEmpty);
  expect(find.byIcon(MorphIcons.cancel), findsNothing);

  EditableText password() =>
      tester.widget<EditableText>(find.byType(EditableText).last);
  expect(password().obscureText, isTrue);
  await tester.tap(find.byIcon(MorphIcons.visibility));
  await tester.pumpAndSettle();
  expect(password().obscureText, isFalse);
  expect(find.byIcon(MorphIcons.visibility_off), findsOneWidget);
}

Future<void> _density(WidgetTester tester) async {
  await tester.pumpWidget(
    _app(const MorphTextField(label: 'Dense', density: -2)),
  );
  await tester.pumpAndSettle();
  expect(_container(tester).height, 48);
}

Future<void> _requiredAndAffixes(WidgetTester tester) async {
  final SemanticsHandle semantics = tester.ensureSemantics();
  final controller = TextEditingController(text: '20');
  addTearDown(controller.dispose);
  await tester.pumpWidget(
    _app(
      MorphTextField(
        controller: controller,
        label: 'Price',
        isRequired: true,
        prefixText: '€',
        prefixSemanticsLabel: 'Euro',
      ),
    ),
  );
  await tester.pumpAndSettle();
  expect(find.text('Price*'), findsOneWidget);
  expect(find.bySemanticsLabel('Price*'), findsOneWidget);
  expect(find.bySemanticsLabel('Euro'), findsOneWidget);
  semantics.dispose();
}

Widget _multiLine(
  TextEditingController controller, {
  int? maxLines,
  MorphTextFieldSlotAlignment? icons,
  MorphTextFieldSlotAlignment? affixes,
}) {
  return _app(
    MorphTextField(
      controller: controller,
      label: 'Notes',
      leading: const Icon(MorphIcons.search),
      prefixText: '>',
      maxLines: maxLines,
      iconAlignment: icons,
      affixAlignment: affixes,
    ),
  );
}

TextEditingController _longText() {
  final controller = TextEditingController(
    text: List<String>.filled(12, 'wrapping words').join(' '),
  );
  addTearDown(controller.dispose);
  return controller;
}

Future<void> _unlimitedLines(WidgetTester tester) async {
  final TextEditingController controller = _longText();
  await tester.pumpWidget(_multiLine(controller));
  await tester.pumpAndSettle();
  expect(tester.widget<EditableText>(find.byType(EditableText)).maxLines, null);
  expect(_container(tester).height, greaterThan(56 + 24 * 3));
}

Future<void> _slotAlignment(WidgetTester tester) async {
  final TextEditingController controller = _longText();
  Future<(Rect, Rect, Rect, Rect)> layout(
    MorphTextFieldSlotAlignment alignment,
  ) async {
    await tester.pumpWidget(
      _multiLine(controller, icons: alignment, affixes: alignment),
    );
    await tester.pumpAndSettle();
    return (
      _container(tester),
      tester.getRect(find.byIcon(MorphIcons.search)),
      tester.getRect(find.text('>')),
      tester.getRect(find.byType(EditableText)),
    );
  }

  var (box, icon, prefix, input) = await layout(
    MorphTextFieldSlotAlignment.firstLine,
  );
  // Same spot as a single-line field: icon centered in the first 56dp.
  expect(icon.center.dy, closeTo(box.top + 28, 0.5));
  expect(prefix.top, closeTo(input.top, 0.5));

  (box, icon, prefix, input) = await layout(MorphTextFieldSlotAlignment.center);
  expect(icon.center.dy, closeTo(box.center.dy, 0.5));
  expect(prefix.center.dy, closeTo(input.center.dy, 0.5));

  (box, icon, prefix, input) = await layout(MorphTextFieldSlotAlignment.bottom);
  expect(icon.center.dy, closeTo(box.bottom - 28, 0.5));
  expect(prefix.bottom, closeTo(input.bottom, 0.5));
}
