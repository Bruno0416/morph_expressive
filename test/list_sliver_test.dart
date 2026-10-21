import 'package:flutter_test/flutter_test.dart';
import 'package:morph_expressive/morph_components.dart';
import 'package:material_ui/material_ui.dart'
    show
        BuildContext,
        CustomScrollView,
        EdgeInsets,
        Scaffold,
        SliverPadding,
        Text,
        Widget;

Widget _host(Widget sliver) {
  return MorphMaterialApp(
    data: MorphThemeData.light(),
    home: Scaffold(body: CustomScrollView(slivers: <Widget>[sliver])),
  );
}

MorphListItem _item(BuildContext context, int index) {
  return MorphListItem(headline: 'Row $index', onTap: () {});
}

void main() {
  testWidgets('MorphList.sliver lays out in a CustomScrollView', _plain);
  testWidgets('MorphList.sliver applies margin as sliver padding', _margin);
  testWidgets('MorphList.sliver works with selection', _selection);
  testWidgets('MorphList.sliver shows emptyBuilder', _empty);
}

Future<void> _plain(WidgetTester tester) async {
  await tester.pumpWidget(
    _host(
      const SliverPadding(
        padding: EdgeInsets.all(16),
        sliver: MorphList.sliver(
          variant: MorphCardVariant.filled,
          itemCount: 30,
          itemBuilder: _item,
        ),
      ),
    ),
  );
  expect(tester.takeException(), isNull);
  expect(find.text('Row 0'), findsOneWidget);
}

Future<void> _margin(WidgetTester tester) async {
  await tester.pumpWidget(
    _host(
      const MorphList.sliver(
        margin: EdgeInsets.symmetric(horizontal: 16),
        itemCount: 3,
        itemBuilder: _item,
      ),
    ),
  );
  expect(tester.takeException(), isNull);
  expect(find.byType(SliverPadding), findsOneWidget);
}

Future<void> _selection(WidgetTester tester) async {
  await tester.pumpWidget(
    _host(
      const MorphList.sliver(selection: true, itemCount: 3, itemBuilder: _item),
    ),
  );
  expect(tester.takeException(), isNull);
  expect(find.text('Row 2'), findsOneWidget);
}

Future<void> _empty(WidgetTester tester) async {
  await tester.pumpWidget(
    _host(
      const MorphList.sliver(
        itemCount: 0,
        itemBuilder: _item,
        emptyBuilder: Text('Nothing here'),
      ),
    ),
  );
  expect(tester.takeException(), isNull);
  expect(find.text('Nothing here'), findsOneWidget);
}
