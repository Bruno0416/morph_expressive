import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:morph_expressive/morph_components.dart';

final MorphThemeData _theme = MorphThemeData.light(
  seedColor: const Color(0xFF6750A4),
);

Widget _app(Widget child) => MorphMaterialApp(
  data: _theme,
  home: Scaffold(
    body: Column(
      children: <Widget>[
        child,
        const Expanded(child: ColoredBox(color: Color(0xFFE0E0E0))),
      ],
    ),
  ),
);

void main() {
  testWidgets('onUnfocus reports latest value once per focus loss', (
    WidgetTester tester,
  ) async {
    final node = FocusNode();
    final controller = TextEditingController(text: 'first');
    addTearDown(node.dispose);
    addTearDown(controller.dispose);
    final values = <String>[];

    await tester.pumpWidget(_app(MorphTextField(
      label: 'Email',
      focusNode: node,
      controller: controller,
      onUnfocus: values.add,
    )));
    await tester.pumpAndSettle();
    expect(values, isEmpty);

    node.requestFocus();
    await tester.pumpAndSettle();
    controller.text = 'after editing';
    await tester.pumpAndSettle();
    expect(values, isEmpty);

    node.unfocus();
    await tester.pumpAndSettle();
    expect(values, <String>['after editing']);

    node.unfocus();
    await tester.pumpAndSettle();
    expect(values, hasLength(1));

    node.requestFocus();
    await tester.pumpAndSettle();
    node.unfocus();
    await tester.pumpAndSettle();
    expect(values, <String>['after editing', 'after editing']);
  });

  testWidgets('onUnfocus fires on tap outside using internal FocusNode', (
    WidgetTester tester,
  ) async {
    final values = <String>[];
    await tester.pumpWidget(_app(MorphTextField(
      label: 'Name',
      onUnfocus: values.add,
    )));
    await tester.tap(find.byType(MorphTextField));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(EditableText), 'Ada');
    await tester.pumpAndSettle();

    await tester.tapAt(const Offset(20, 300));
    await tester.pumpAndSettle();
    expect(values, <String>['Ada']);
    await tester.tapAt(const Offset(20, 300));
    await tester.pumpAndSettle();
    expect(values, hasLength(1));
  });

  testWidgets('onUnfocus fires when focus transfers to another field', (
    WidgetTester tester,
  ) async {
    final firstNode = FocusNode();
    final secondNode = FocusNode();
    addTearDown(firstNode.dispose);
    addTearDown(secondNode.dispose);
    final values = <String>[];
    await tester.pumpWidget(_app(Column(children: <Widget>[
      MorphTextField(
        label: 'First',
        focusNode: firstNode,
        onUnfocus: values.add,
      ),
      MorphTextField(label: 'Second', focusNode: secondNode),
    ])));
    firstNode.requestFocus();
    await tester.pumpAndSettle();
    secondNode.requestFocus();
    await tester.pumpAndSettle();

    expect(firstNode.hasFocus, isFalse);
    expect(secondNode.hasFocus, isTrue);
    expect(values, <String>['']);
  });

  testWidgets('onUnfocus can trigger custom errorText validation', (
    WidgetTester tester,
  ) async {
    final node = FocusNode();
    addTearDown(node.dispose);
    String? error;
    await tester.pumpWidget(_app(StatefulBuilder(
      builder: (BuildContext context, StateSetter setFieldState) {
        return MorphTextField(
          label: 'Required',
          focusNode: node,
          errorText: error,
          onUnfocus: (String value) {
            setFieldState(() {
              error = value.trim().isEmpty ? 'Value is required' : null;
            });
          },
        );
      },
    )));
    node.requestFocus();
    await tester.pumpAndSettle();
    expect(find.text('Value is required'), findsNothing);

    node.unfocus();
    await tester.pumpAndSettle();
    expect(find.text('Value is required'), findsOneWidget);
    expect(tester.widget<MorphTextField>(find.byType(MorphTextField)).hasError,
        isTrue);

    node.requestFocus();
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(EditableText), 'Valid');
    node.unfocus();
    await tester.pumpAndSettle();
    expect(find.text('Value is required'), findsNothing);
  });

  testWidgets('expression-based errorText still updates while focused', (
    WidgetTester tester,
  ) async {
    String value = '';
    await tester.pumpWidget(_app(StatefulBuilder(
      builder: (BuildContext context, StateSetter setFieldState) {
        return MorphTextField(
          label: 'Email',
          onChanged: (String next) => setFieldState(() => value = next),
          errorText: value.isNotEmpty && !value.contains('@')
              ? 'Invalid email'
              : null,
        );
      },
    )));

    await tester.tap(find.byType(MorphTextField));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(EditableText), 'invalid');
    await tester.pumpAndSettle();
    expect(find.text('Invalid email'), findsOneWidget);

    await tester.enterText(find.byType(EditableText), 'valid@example.com');
    await tester.pumpAndSettle();
    expect(find.text('Invalid email'), findsNothing);
  });
}
