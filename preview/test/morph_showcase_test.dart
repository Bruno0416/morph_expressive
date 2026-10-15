import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:morph_expressive/morph_expressive.dart';
import 'package:morph_expressive_preview/main.dart';

import 'showcase_scroll_helper.dart';

void main() {
  testWidgets('All opens the continuous component showcase', (tester) async {
    tester.view.physicalSize = const Size(1440, 900);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(const MorphPreviewApp());
    expect(find.byKey(const ValueKey('morph_showcase_scroll')), findsOneWidget);
    expect(find.byKey(const ValueKey('group_buttons')), findsOneWidget);
    expect(find.byKey(const ValueKey('category_buttons')), findsNothing);
    expect(find.byType(ListView), findsWidgets);
  });

  testWidgets('Segmented category displays the Morph elastic toggle', (tester) async {
    tester.view.physicalSize = const Size(1440, 900);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(const MorphPreviewApp());
    await revealShowcaseCategory(tester, 'segmented_buttons');
    expect(find.byType(MorphSegmentedToggle<String>), findsOneWidget);
    await tester.tap(find.text('TV Shows'));
    await tester.pump();
    expect(tester.widget<MorphSegmentedToggle<String>>(
      find.byType(MorphSegmentedToggle<String>)).selected, 'TV Shows');
  });

  testWidgets('Showcase distributes categories in two columns on desktop', (tester) async {
    tester.view.physicalSize = const Size(1600, 900);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(const MorphPreviewApp());
    final buttons = find.byKey(const ValueKey('showcase_buttons'));
    final icons = find.byKey(const ValueKey('showcase_icon_buttons'));
    expect(buttons, findsOneWidget);
    expect(icons, findsOneWidget);
    expect(tester.getTopLeft(buttons).dx,
        isNot(tester.getTopLeft(icons).dx));
  });

  testWidgets('Showcase stays one column on mobile widths', (tester) async {
    tester.view.physicalSize = const Size(430, 900);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(const MorphPreviewApp());
    final buttons = find.byKey(const ValueKey('showcase_buttons'));
    final icons = find.byKey(const ValueKey('showcase_icon_buttons'));
    expect(buttons, findsOneWidget);
    expect(icons, findsOneWidget);
    expect(tester.getTopLeft(buttons).dx,
        closeTo(tester.getTopLeft(icons).dx, 0.01));
  });

  testWidgets('Preview brand fits a compact app bar', (tester) async {
    tester.view.physicalSize = const Size(430, 900);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(const MorphPreviewApp());

    expect(
      find.descendant(
        of: find.byType(AppBar),
        matching: find.text('Morph Expressive'),
      ),
      findsOneWidget,
    );
    expect(tester.takeException(), isNull);
  });

  testWidgets('Filled search field uses one centered placeholder', (tester) async {
    tester.view.physicalSize = const Size(1440, 900);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(const MorphPreviewApp());
    final target = await revealShowcaseCategory(tester, 'text_fields');
    final filled = find.descendant(
      of: target, matching: find.byType(MorphTextField),
    ).first;
    final field = tester.widget<MorphTextField>(filled);
    expect(field.variant, MorphTextFieldVariant.filled);
    expect(field.label, isNull);
    expect(field.placeholder, 'Search for a movie');
    expect(field.leading, isNotNull);
    final leading = find.descendant(
      of: filled, matching: find.byIcon(MorphIcons.search),
    );
    final editable = find.descendant(
      of: filled, matching: find.byType(EditableText),
    );
    expect((tester.getCenter(leading).dy - tester.getCenter(editable).dy).abs(),
        lessThan(6));
  });

}
