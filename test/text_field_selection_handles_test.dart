import 'package:flutter/gestures.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:morph_expressive/morph_components.dart';
import 'package:material_ui/material_ui.dart'
    show
        Center,
        EditableText,
        EditableTextState,
        Scaffold,
        SizedBox,
        TargetPlatform,
        TextEditingController,
        Widget;

final TargetPlatformVariant _touch = TargetPlatformVariant.only(
  TargetPlatform.android,
)..values.add(TargetPlatform.iOS);

void main() {
  testWidgets(
    'MorphTextField shows selection handles after a long press',
    _longPressShowsHandles,
    variant: _touch,
  );
  testWidgets(
    'MorphTextField shows the caret handle after a tap on text',
    _tapShowsHandle,
    variant: _touch,
  );
  testWidgets(
    'MorphTextField hides handles for a mouse click',
    _mouseHidesHandles,
    variant: _touch,
  );
}

Widget _host(TextEditingController controller) {
  return MorphMaterialApp(
    data: MorphThemeData.light(),
    home: Scaffold(
      body: Center(
        child: SizedBox(
          width: 320,
          child: MorphTextField(controller: controller, label: 'Label'),
        ),
      ),
    ),
  );
}

bool _handlesVisible(WidgetTester tester) {
  final EditableTextState state = tester.state<EditableTextState>(
    find.byType(EditableText),
  );
  return state.selectionOverlay?.handlesAreVisible ?? false;
}

Future<void> _longPressShowsHandles(WidgetTester tester) async {
  final controller = TextEditingController(text: 'hello world');
  addTearDown(controller.dispose);
  await tester.pumpWidget(_host(controller));
  await tester.longPress(find.byType(EditableText));
  await tester.pumpAndSettle();
  expect(controller.selection.isCollapsed, isFalse);
  expect(_handlesVisible(tester), isTrue);
}

Future<void> _tapShowsHandle(WidgetTester tester) async {
  final controller = TextEditingController(text: 'hello world');
  addTearDown(controller.dispose);
  await tester.pumpWidget(_host(controller));
  await tester.tap(find.byType(EditableText));
  await tester.pumpAndSettle();
  expect(_handlesVisible(tester), isTrue);
}

Future<void> _mouseHidesHandles(WidgetTester tester) async {
  final controller = TextEditingController(text: 'hello world');
  addTearDown(controller.dispose);
  await tester.pumpWidget(_host(controller));
  await tester.tap(find.byType(EditableText), kind: PointerDeviceKind.mouse);
  await tester.pumpAndSettle();
  expect(_handlesVisible(tester), isFalse);
}
