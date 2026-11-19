import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart' show Size;
import 'package:morph_expressive_preview/main.dart';
import 'package:morph_expressive_preview/main.directories.g.dart';
import 'package:morph_expressive_preview/widgetbook/addons/morph_scope_addon.dart';
import 'package:widgetbook/widgetbook.dart';

/// Every leaf use case of the generated catalog, in navigation order.
List<WidgetbookUseCase> allUseCases() {
  final root = WidgetbookRoot(children: directories);
  return root.leaves.whereType<WidgetbookUseCase>().toList();
}

/// Route that opens [path] in preview mode with the given Morph settings.
String routeFor(
  String path, {
  String mode = 'Light',
  String seed = 'Violet',
  Map<String, String> extra = const {},
}) {
  return Uri(
    path: '/',
    queryParameters: {
      'path': path,
      'preview': '',
      'morph': '{mode:$mode,seed:$seed}',
      ...extra,
    },
  ).toString();
}

/// Opens one use case in a fixed-size window through the real Widgetbook app.
Future<WidgetbookState> openUseCase(
  WidgetTester tester,
  String path, {
  Size size = const Size(1280, 800),
  String mode = 'Light',
  String seed = 'Violet',
  Map<String, String> extra = const {},
}) async {
  tester.view
    ..physicalSize = size
    ..devicePixelRatio = 1;
  addTearDown(tester.view.reset);
  await tester.pumpWidget(
    MorphWidgetbookApp(
      initialRoute: routeFor(path, mode: mode, seed: seed, extra: extra),
    ),
  );
  for (var i = 0; i < 4; i++) {
    await tester.pump(const Duration(milliseconds: 200));
  }
  return stateOf(tester);
}

/// Widgetbook state, read from inside the rendered use case.
WidgetbookState stateOf(WidgetTester tester) =>
    WidgetbookState.of(tester.element(find.byType(MorphScope)));
