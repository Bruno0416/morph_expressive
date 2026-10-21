import 'package:flutter_test/flutter_test.dart';
import 'package:morph_expressive/morph_components.dart';
import 'package:material_ui/material_ui.dart'
    show
        Center,
        Color,
        ColoredBox,
        Column,
        EditableText,
        Expanded,
        FocusNode,
        Offset,
        Rect,
        Scaffold,
        Size,
        SizedBox,
        TextEditingController,
        Widget;

void main() {
  testWidgets(
    'MorphTextField keeps a stable size when focus changes',
    _morphtextfieldKeepsAStableSizeWhenFocusChanges,
  );
  testWidgets(
    'MorphTextField grows for multi-line values',
    _morphtextfieldGrowsForMultiLineValues,
  );
  testWidgets(
    'MorphTextField centers the label until it floats',
    _morphtextfieldCentersTheLabelUntilItFloats,
  );
  testWidgets(
    'MorphTextField centers the input when there is no label',
    _morphtextfieldCentersTheInputWhenThereIsNoLabel,
  );
  testWidgets(
    'MorphTextField unfocuses on tap outside by default',
    _morphtextfieldUnfocusesOnTapOutsideByDefault,
  );
  testWidgets(
    'MorphSearchBar unfocuses on tap outside by default',
    _morphsearchbarUnfocusesOnTapOutsideByDefault,
  );
}

Future<void> _morphtextfieldKeepsAStableSizeWhenFocusChanges(
  WidgetTester tester,
) async {
  await tester.pumpWidget(
    MorphMaterialApp(
      data: MorphThemeData.light(seedColor: const Color(0xFF6750A4)),
      home: const Scaffold(
        body: Center(
          child: MorphTextField(
            label: 'Name',
            variant: MorphTextFieldVariant.outlined,
          ),
        ),
      ),
    ),
  );
  await tester.pumpAndSettle();

  final Finder field = find.byType(MorphTextField);
  final Size restingSize = tester.getSize(field);

  await tester.tap(field);
  await tester.pumpAndSettle();
  expect(tester.getSize(field), restingSize);

  await tester.tapAt(const Offset(20, 300));
  await tester.pumpAndSettle();
  expect(tester.getSize(field), restingSize);
}

Future<void> _morphtextfieldGrowsForMultiLineValues(WidgetTester tester) async {
  final controller = TextEditingController(
    text: 'A rather long value that has to wrap onto several separate lines.',
  );

  await tester.pumpWidget(
    MorphMaterialApp(
      data: MorphThemeData.light(seedColor: const Color(0xFF6750A4)),
      home: Scaffold(
        body: Column(
          children: <Widget>[
            const SizedBox(width: 200, child: MorphTextField(label: 'Single')),
            SizedBox(
              width: 200,
              child: MorphTextField(
                label: 'Multi',
                maxLines: 3,
                controller: controller,
              ),
            ),
          ],
        ),
      ),
    ),
  );
  await tester.pumpAndSettle();

  final double singleLine = tester
      .getSize(find.byType(MorphTextField).first)
      .height;
  final double multiLine = tester
      .getSize(find.byType(MorphTextField).last)
      .height;
  expect(multiLine, greaterThan(singleLine));
}

Future<void> _morphtextfieldCentersTheLabelUntilItFloats(
  WidgetTester tester,
) async {
  await tester.pumpWidget(
    MorphMaterialApp(
      data: MorphThemeData.light(seedColor: const Color(0xFF6750A4)),
      home: const Scaffold(
        body: Center(child: MorphTextField(label: 'Name')),
      ),
    ),
  );
  await tester.pumpAndSettle();

  final Rect field = tester.getRect(find.byType(MorphTextField));
  expect(
    tester.getRect(find.text('Name')).center.dy,
    closeTo(field.center.dy, 1),
  );

  await tester.tap(find.byType(MorphTextField));
  await tester.pumpAndSettle();
  expect(
    tester.getRect(find.text('Name')).center.dy,
    lessThan(field.center.dy - 4),
  );
}

Future<void> _morphtextfieldCentersTheInputWhenThereIsNoLabel(
  WidgetTester tester,
) async {
  final controller = TextEditingController(text: 'Value');
  addTearDown(controller.dispose);

  await tester.pumpWidget(
    MorphMaterialApp(
      data: MorphThemeData.light(seedColor: const Color(0xFF6750A4)),
      home: Scaffold(
        body: Center(child: MorphTextField(controller: controller)),
      ),
    ),
  );
  await tester.pumpAndSettle();

  final Rect field = tester.getRect(find.byType(MorphTextField));
  final Rect input = tester.getRect(find.byType(EditableText));
  expect(input.center.dy, closeTo(field.center.dy, 1));
}

Future<void> _morphtextfieldUnfocusesOnTapOutsideByDefault(
  WidgetTester tester,
) async {
  final focusNode = FocusNode();

  await tester.pumpWidget(
    MorphMaterialApp(
      data: MorphThemeData.light(seedColor: const Color(0xFF6750A4)),
      home: Scaffold(
        body: Column(
          children: <Widget>[
            MorphTextField(focusNode: focusNode, label: 'Name'),
            const Expanded(child: ColoredBox(color: Color(0xFFE0E0E0))),
          ],
        ),
      ),
    ),
  );

  focusNode.requestFocus();
  await tester.pump();
  expect(focusNode.hasFocus, isTrue);

  await tester.tapAt(const Offset(20, 300));
  await tester.pump();
  expect(focusNode.hasFocus, isFalse);
}

Future<void> _morphsearchbarUnfocusesOnTapOutsideByDefault(
  WidgetTester tester,
) async {
  final focusNode = FocusNode();

  await tester.pumpWidget(
    MorphMaterialApp(
      data: MorphThemeData.light(seedColor: const Color(0xFF6750A4)),
      home: Scaffold(
        body: Column(
          children: <Widget>[
            MorphSearchBar(focusNode: focusNode, hintText: 'Search'),
            const Expanded(child: ColoredBox(color: Color(0xFFE0E0E0))),
          ],
        ),
      ),
    ),
  );

  focusNode.requestFocus();
  await tester.pump();
  expect(focusNode.hasFocus, isTrue);

  await tester.tapAt(const Offset(20, 300));
  await tester.pump();
  expect(focusNode.hasFocus, isFalse);
}
