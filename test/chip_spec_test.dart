import 'dart:ui' show CheckedState;

import 'package:flutter/rendering.dart' show RenderParagraph;
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:morph_expressive/morph_components.dart';
import 'package:material_ui/material_ui.dart';

Widget _host(Widget child) {
  return MorphMaterialApp(
    data: MorphThemeData.light(seedColor: const Color(0xFF6750A4)),
    home: Scaffold(body: Center(child: child)),
  );
}

void main() {
  _registerChipThemeTests();
  _registerChipLayoutTests();
  _registerChipInteractionTests();
}

void _registerChipThemeTests() {
  test('theme defaults match the chip spec', _themeDefaultsMatchTheChipSpec);
}

void _registerChipLayoutTests() {
  testWidgets(
    'chips shrink-wrap so a wrap can place them side by side',
    _chipsShrinkWrapSoAWrapCanPlaceThemSideBySide,
  );
  testWidgets(
    'text chip is 32 tall with 16 padding',
    _textChipIs32TallWith16Padding,
  );
  testWidgets(
    'long labels truncate with an ellipsis inside a bounded wrap',
    _longLabelsTruncateWithAnEllipsisInsideABoundedWrap,
  );
  testWidgets(
    'long labels keep their intrinsic width in an unbounded scroll',
    _longLabelsKeepTheirIntrinsicWidthInAnUnboundedScroll,
  );
  testWidgets(
    'input chip with both actions is at least 88 wide',
    _inputChipWithBothActionsIsAtLeast88Wide,
  );
  testWidgets(
    'filter chip uses checkbox semantics',
    _filterChipUsesCheckboxSemantics,
  );
}

void _registerChipInteractionTests() {
  testWidgets('space toggles a filter chip', _spaceTogglesAFilterChip);
  testWidgets(
    'arrows move focus inside a chip group',
    _arrowsMoveFocusInsideAChipGroup,
  );
  testWidgets(
    'arrows inside a list do not scroll',
    _arrowsInsideAListDoNotScroll,
  );
  testWidgets(
    'backspace removes a focused input chip',
    _backspaceRemovesAFocusedInputChip,
  );
  testWidgets(
    'dragging raises the chip to level 4',
    _draggingRaisesTheChipToLevel4,
  );
  testWidgets(
    'pointer tap clears the focus ring',
    _pointerTapClearsTheFocusRing,
  );
}

void _themeDefaultsMatchTheChipSpec() {
  const theme = MorphChipTheme.defaults;
  final scheme = MorphThemeData.light(seedColor: const Color(0xFF6750A4))
      .colorScheme;
  _expectChipThemeMetrics(theme, scheme);
  _expectChipThemeAssistAndFilter(theme, scheme);
  _expectChipThemeRemainingColors(theme, scheme);
}

void _expectChipThemeMetrics(MorphChipTheme theme, MorphColorScheme scheme) {
  expect(theme.height, 32);
  expect(theme.cornerRadius, theme.height / 2);
  expect(theme.iconSize, 18);
  expect(theme.labelStartPadding, 16);
  expect(theme.endPadding, 16);
  expect(theme.iconStartPadding, 8);
  expect(theme.trailingEndPadding, 8);
  expect(theme.inputStartPadding, 12);
  expect(theme.avatarStartPadding, 4);
  expect(theme.avatarSize, 24);
  expect(theme.avatarRadius, 12);
  expect(theme.outlineWidth, 1);
  expect(theme.focusIndicatorThickness, 3);
  expect(theme.focusIndicatorOffset, 2);
  expect(theme.hoverStateLayerOpacity, 0.08);
  expect(theme.focusStateLayerOpacity, 0.1);
  expect(theme.pressedStateLayerOpacity, 0.1);
  expect(theme.draggedStateLayerOpacity, 0.16);
  expect(theme.disabledContainerOpacity, 0.12);
  expect(theme.disabledContentOpacity, 0.38);
  expect(theme.elevatedElevation, MorphElevation.level1);
  expect(theme.draggedElevation, MorphElevation.level4);
  expect(theme.removeTargetSize, 48);
  expect(theme.minWidth, 88);
  expect(theme.resolveFocusIndicatorColor(scheme), scheme.secondary);
}

void _expectChipThemeAssistAndFilter(
  MorphChipTheme theme,
  MorphColorScheme scheme,
) {
  expect(
    theme.labelColor(
      scheme,
      enabled: true,
      selected: false,
      type: MorphChipType.assist,
    ),
    scheme.onSurface,
  );
  expect(
    theme.leadingIconColor(
      scheme,
      enabled: true,
      selected: false,
      type: MorphChipType.assist,
    ),
    scheme.primary,
  );
  expect(
    theme.outlineColor(
      scheme,
      enabled: true,
      focused: false,
      type: MorphChipType.assist,
    ),
    scheme.outlineVariant,
  );
  expect(
    theme.containerColor(
      scheme,
      enabled: true,
      selected: true,
      elevated: false,
      type: MorphChipType.filter,
    ),
    scheme.secondaryContainer,
  );
  expect(
    theme.labelColor(
      scheme,
      enabled: true,
      selected: false,
      type: MorphChipType.filter,
    ),
    scheme.onSurfaceVariant,
  );
  expect(
    theme.labelColor(
      scheme,
      enabled: true,
      selected: true,
      type: MorphChipType.filter,
    ),
    scheme.onSecondaryContainer,
  );
}

void _expectChipThemeRemainingColors(
  MorphChipTheme theme,
  MorphColorScheme scheme,
) {
  expect(
    theme.stateLayerColor(scheme, selected: false, type: MorphChipType.filter),
    scheme.onSurfaceVariant,
  );
  expect(
    theme.stateLayerColor(scheme, selected: true, type: MorphChipType.filter),
    scheme.onSecondaryContainer,
  );
  expect(
    theme.containerColor(
      scheme,
      enabled: true,
      selected: false,
      elevated: true,
      type: MorphChipType.suggestion,
    ),
    scheme.surfaceContainerLow,
  );
  expect(
    theme.labelColor(
      scheme,
      enabled: false,
      selected: false,
      type: MorphChipType.assist,
    ),
    MorphColorUtils.withOpacity(scheme.onSurface, 0.38),
  );
  expect(
    theme.resolvedOutlineWidth(
      type: MorphChipType.filter,
      selected: true,
      elevated: false,
    ),
    0,
  );
  expect(theme.elevation(elevated: true, dragged: false), MorphElevation.level1);
  expect(theme.elevation(elevated: true, dragged: true), MorphElevation.level4);
}

Future<void> _chipsShrinkWrapSoAWrapCanPlaceThemSideBySide(
  WidgetTester tester,
) async {
  await tester.pumpWidget(
    _host(
      const SizedBox(
        width: 400,
        child: Wrap(
          spacing: 8,
          children: <Widget>[
            MorphChip(label: 'One', onPressed: _noop),
            MorphChip(label: 'Two', onPressed: _noop),
          ],
        ),
      ),
    ),
  );

  final double first = tester.getSize(find.byType(MorphChip).first).width;
  final double second = tester.getSize(find.byType(MorphChip).at(1)).width;
  expect(first, lessThan(200));
  expect(second, lessThan(200));
  expect(
    tester.getTopLeft(find.byType(MorphChip).at(1)).dx,
    greaterThan(tester.getTopLeft(find.byType(MorphChip).first).dx + first),
  );
}

Future<void> _textChipIs32TallWith16Padding(WidgetTester tester) async {
  await tester.pumpWidget(_host(MorphChip(label: 'Assist', onPressed: () {})));

  expect(tester.getSize(find.byType(MorphChip)).height, 32);
  final padding = tester.widgetList<Padding>(find.byType(Padding)).firstWhere((
    Padding box,
  ) {
    final insets = box.padding.resolve(TextDirection.ltr);
    return insets.left == 16 && insets.right == 16;
  });
  expect(
    padding.padding.resolve(TextDirection.ltr),
    const EdgeInsets.only(left: 16, right: 16),
  );

  final ring = tester.widget<MorphFocusRing>(find.byType(MorphFocusRing));
  expect(ring.width, 3);
  expect(ring.gap, 2);
}

Future<void> _longLabelsTruncateWithAnEllipsisInsideABoundedWrap(
  WidgetTester tester,
) async {
  const label = 'A very long chip label that should truncate with an ellipsis';
  await tester.pumpWidget(
    _host(
      const SizedBox(
        width: 200,
        child: Wrap(
          children: <Widget>[MorphChip(label: label, onPressed: _noop)],
        ),
      ),
    ),
  );

  expect(tester.takeException(), isNull);
  final paragraph = tester.renderObject<RenderParagraph>(find.text(label));
  expect(
    paragraph.size.width,
    lessThan(paragraph.getMaxIntrinsicWidth(double.infinity)),
  );
  expect(tester.getSize(find.byType(MorphChip)).width, lessThanOrEqualTo(200));
}

Future<void> _longLabelsKeepTheirIntrinsicWidthInAnUnboundedScroll(
  WidgetTester tester,
) async {
  const label = 'A very long chip label that should truncate with an ellipsis';
  await tester.pumpWidget(
    _host(
      const SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: <Widget>[MorphChip(label: label, onPressed: _noop)],
        ),
      ),
    ),
  );

  expect(tester.takeException(), isNull);
  final paragraph = tester.renderObject<RenderParagraph>(find.text(label));
  expect(paragraph.size.width, paragraph.getMaxIntrinsicWidth(double.infinity));
}

Future<void> _inputChipWithBothActionsIsAtLeast88Wide(
  WidgetTester tester,
) async {
  await tester.pumpWidget(
    _host(
      MorphChip(
        label: 'A',
        type: MorphChipType.input,
        onPressed: () {},
        onDeleted: () {},
      ),
    ),
  );

  expect(tester.getSize(find.byType(MorphChip)).height, 32);
  expect(tester.getSize(find.byType(MorphChip)).width, greaterThanOrEqualTo(88));
  expect(
    tester.getSize(
      find.byWidgetPredicate(
        (Widget widget) =>
            widget is SizedBox && widget.width == 48 && widget.height == 48,
      ),
    ),
    const Size(48, 48),
  );
  expect(
    find.byWidgetPredicate(
      (Widget widget) =>
          widget is Semantics && widget.properties.label == 'Remove A',
    ),
    findsOneWidget,
  );
}

Future<void> _filterChipUsesCheckboxSemantics(WidgetTester tester) async {
  await tester.pumpWidget(
    _host(
      MorphChip(
        label: 'News',
        type: MorphChipType.filter,
        selected: true,
        onPressed: () {},
      ),
    ),
  );

  final semantics = tester.getSemantics(find.byType(MorphTappable));
  expect(semantics.flagsCollection.isChecked, CheckedState.isTrue);
  expect(semantics.flagsCollection.isButton, isFalse);
  expect(semantics.label, 'News');
}

Future<void> _spaceTogglesAFilterChip(WidgetTester tester) async {
  var selected = false;
  await tester.pumpWidget(
    _host(
      MorphChip(
        label: 'News',
        type: MorphChipType.filter,
        onPressed: () => selected = !selected,
      ),
    ),
  );

  await tester.sendKeyDownEvent(LogicalKeyboardKey.tab);
  await tester.sendKeyUpEvent(LogicalKeyboardKey.tab);
  await tester.pump();
  await tester.sendKeyDownEvent(LogicalKeyboardKey.space);
  await tester.sendKeyUpEvent(LogicalKeyboardKey.space);
  await tester.pump(const Duration(milliseconds: 150));
  expect(selected, isTrue);
}

Future<void> _arrowsMoveFocusInsideAChipGroup(WidgetTester tester) async {
  await tester.pumpWidget(
    _host(
      MorphChipGroup(
        child: Column(
          children: <Widget>[
            for (final String label in <String>['One', 'Two', 'Three'])
              MorphChip(label: label, onPressed: () {}),
          ],
        ),
      ),
    ),
  );
  await tester.pumpAndSettle();
  _traditionalFocus();

  await tester.sendKeyDownEvent(LogicalKeyboardKey.tab);
  await tester.sendKeyUpEvent(LogicalKeyboardKey.tab);
  await tester.pump();
  expect(_focusedLabels(tester), <String>['One']);

  await tester.sendKeyDownEvent(LogicalKeyboardKey.arrowDown);
  await tester.sendKeyUpEvent(LogicalKeyboardKey.arrowDown);
  await tester.pump();
  expect(_focusedLabels(tester), <String>['Two']);
}

Future<void> _arrowsInsideAListDoNotScroll(WidgetTester tester) async {
  await tester.pumpWidget(
    MorphMaterialApp(
      data: MorphThemeData.light(seedColor: const Color(0xFF6750A4)),
      home: Scaffold(
        body: ListView(
          children: <Widget>[
            MorphChipGroup(
              child: Column(
                children: <Widget>[
                  for (final String label in <String>['One', 'Two', 'Three'])
                    MorphChip(label: label, onPressed: () {}),
                ],
              ),
            ),
            const SizedBox(height: 1200),
          ],
        ),
      ),
    ),
  );
  await tester.pumpAndSettle();
  _traditionalFocus();

  await tester.sendKeyDownEvent(LogicalKeyboardKey.tab);
  await tester.sendKeyUpEvent(LogicalKeyboardKey.tab);
  await tester.pump();
  await tester.sendKeyDownEvent(LogicalKeyboardKey.arrowDown);
  await tester.sendKeyUpEvent(LogicalKeyboardKey.arrowDown);
  await tester.pump();

  expect(_focusedLabels(tester), <String>['Two']);
  expect(tester.getTopLeft(find.text('One')).dy, greaterThan(0));
}

Future<void> _backspaceRemovesAFocusedInputChip(WidgetTester tester) async {
  var deleted = 0;
  await tester.pumpWidget(
    _host(
      MorphChipGroup(
        child: MorphChip(
          label: 'Tag',
          type: MorphChipType.input,
          onDeleted: () => deleted++,
        ),
      ),
    ),
  );

  await tester.sendKeyDownEvent(LogicalKeyboardKey.tab);
  await tester.sendKeyUpEvent(LogicalKeyboardKey.tab);
  await tester.pump();
  await tester.sendKeyDownEvent(LogicalKeyboardKey.backspace);
  await tester.sendKeyUpEvent(LogicalKeyboardKey.backspace);
  await tester.pump();
  expect(deleted, 1);
}

Future<void> _draggingRaisesTheChipToLevel4(WidgetTester tester) async {
  final scheme = MorphThemeData.light(seedColor: const Color(0xFF6750A4))
      .colorScheme;
  await tester.pumpWidget(_host(MorphChip(label: 'Drag', onPressed: () {})));

  final gesture = await tester.startGesture(
    tester.getCenter(find.byType(MorphChip)),
  );
  await gesture.moveBy(const Offset(40, 0));
  await tester.pump();

  final decorated = tester
      .widgetList<DecoratedBox>(find.byType(DecoratedBox))
      .firstWhere(
        (DecoratedBox box) =>
            box.decoration is BoxDecoration &&
            (box.decoration as BoxDecoration).boxShadow != null,
      );
  expect(
    (decorated.decoration as BoxDecoration).boxShadow,
    MorphElevation.shadows(MorphElevation.level4, shadowColor: scheme.shadow),
  );
  await gesture.up();
}

Future<void> _pointerTapClearsTheFocusRing(WidgetTester tester) async {
  await tester.pumpWidget(
    MorphMaterialApp(
      data: MorphThemeData.light(seedColor: const Color(0xFF6750A4)),
      home: const Scaffold(
        body: Column(
          children: <Widget>[
            MorphChip(label: 'Chip', onPressed: _noop),
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
  addTearDown(() {
    MorphFocusInteraction.resetForTest();
    FocusManager.instance.highlightStrategy = FocusHighlightStrategy.automatic;
  });

  await tester.sendKeyDownEvent(LogicalKeyboardKey.tab);
  await tester.sendKeyUpEvent(LogicalKeyboardKey.tab);
  await tester.pump();
  expect(_ringVisible(tester), isTrue);

  await tester.tap(find.byType(MorphChip));
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

void _noop() {}

void _traditionalFocus() {
  MorphFocusInteraction.resetForTest();
  FocusManager.instance.highlightStrategy =
      FocusHighlightStrategy.alwaysTraditional;
  addTearDown(() {
    MorphFocusInteraction.resetForTest();
    FocusManager.instance.highlightStrategy = FocusHighlightStrategy.automatic;
  });
}

bool _ringVisible(WidgetTester tester) {
  return tester
      .widgetList<MorphFocusRing>(find.byType(MorphFocusRing))
      .any((MorphFocusRing ring) => ring.focused);
}

List<String> _focusedLabels(WidgetTester tester) {
  return tester
      .widgetList<MorphFocusRing>(find.byType(MorphFocusRing))
      .where((MorphFocusRing ring) => ring.focused)
      .map((MorphFocusRing ring) {
        final text = find.descendant(
          of: find.byWidget(ring),
          matching: find.byType(Text),
        );
        return tester.widget<Text>(text).data!;
      })
      .toList();
}
