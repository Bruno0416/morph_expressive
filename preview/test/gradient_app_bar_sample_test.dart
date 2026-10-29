import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/painting.dart' show BoxDecoration, LinearGradient;
import 'package:flutter/widgets.dart'
    show BackdropFilter, DecoratedBox, MediaQuery, ValueKey, Widget;
import 'package:material_ui/material_ui.dart'
    show ListView, MaterialApp, Scaffold, SizedBox;
import 'package:morph_expressive/morph_expressive.dart';
import 'package:morph_expressive_preview/main.dart';

void main() {
  testWidgets('native lab opens a real scrolling glass AppBar preview', (
    tester,
  ) async {
    await tester.pumpWidget(const MorphPreviewApp(mobileLab: true));
    await tester.tap(
      find.byKey(const ValueKey('open_gradient_app_bar_sample')),
    );
    await tester.pumpAndSettle();
    expect(find.text('Gradient glass'), findsOneWidget);
    expect(find.byType(MorphPageIndicator), findsOneWidget);
    expect(find.byType(BackdropFilter), findsAtLeastNWidgets(7));
    expect(find.byType(MorphNavigationBarHost), findsOneWidget);
    expect(
      tester
          .widget<MorphRefreshIndicator>(find.byType(MorphRefreshIndicator))
          .edgeOffset,
      greaterThan(0),
    );
    expect(find.text('Home'), findsOneWidget);
    expect(find.textContaining('Pull to refresh'), findsOneWidget);

    // The tint is linear from the bottom to 50%, then accelerates
    // exponentially to 90%. The join is continuous and has matching slopes.
    final tints = tester
        .widgetList<DecoratedBox>(find.byType(DecoratedBox))
        .map((widget) => widget.decoration)
        .whereType<BoxDecoration>()
        .map((decoration) => decoration.gradient)
        .whereType<LinearGradient>()
        .where((gradient) => gradient.colors.length == 65);
    expect(tints, hasLength(1));
    final tint = tints.single;
    expect(tint.colors.first.a, closeTo(0.90, 0.001));
    expect(tint.colors.last.a, 0);
    expect(tint.stops!.first, 0);
    expect(tint.stops!.last, 1);
    for (var i = 1; i < tint.colors.length; i++) {
      expect(tint.colors[i].a, lessThanOrEqualTo(tint.colors[i - 1].a));
    }
    expect(tint.colors[63].a, lessThan(0.08));
    final midpoint = tint.colors[32].a;
    expect(midpoint, inInclusiveRange(0.23, 0.29));
    // 25% and 12.5% height are exact fractions of the linear midpoint.
    expect(tint.colors[48].a, closeTo(midpoint / 2, 0.0001));
    expect(tint.colors[56].a, closeTo(midpoint / 4, 0.0001));
    // At 75%, the accelerated upper half is darker than a linear extension.
    expect(tint.colors[16].a, greaterThan(midpoint * 1.5));
    // Adjacent samples around the midpoint must have almost equal slopes.
    expect(
      tint.colors[31].a - midpoint,
      closeTo(midpoint - tint.colors[33].a, 0.003),
    );
    expect(tester.takeException(), isNull);
  });

  testWidgets('refresh overlay is below a glass app bar only when extended', (
    tester,
  ) async {
    final glassBar = MorphAppBar.frosted(titleText: 'Glass');
    const plainBar = MorphAppBar.top(titleText: 'Plain');

    Widget scene({
      required MorphAppBar appBar,
      required bool extendBehind,
      double? edgeOffset,
    }) => MaterialApp(
      home: Scaffold(
        appBar: appBar,
        extendBodyBehindAppBar: extendBehind,
        body: MorphNavigationBarHost(
          refreshIndicatorEdgeOffset: edgeOffset,
          onRefresh: () async {},
          bar: MorphNavigationBar.morph(
            floating: true,
            selectedIndex: 0,
            destinations: const [
              MorphNavigationBarDestination(
                icon: MorphIcons.home,
                label: 'Home',
              ),
              MorphNavigationBarDestination(
                icon: MorphIcons.search,
                label: 'Search',
              ),
            ],
          ),
          body: (context, controller, padding) => ListView(
            controller: controller,
            padding: padding,
            children: const [SizedBox(height: 500)],
          ),
        ),
      ),
    );

    double offset() => tester
        .widget<MorphRefreshIndicator>(find.byType(MorphRefreshIndicator))
        .edgeOffset;

    await tester.pumpWidget(scene(appBar: glassBar, extendBehind: true));
    await tester.pumpAndSettle();
    final padding = MediaQuery.paddingOf(tester.element(find.byType(Scaffold)))
        .top;
    expect(offset(), closeTo(glassBar.preferredSize.height + padding, 0.01));
    expect(offset(), greaterThan(0));

    await tester.pumpWidget(scene(appBar: glassBar, extendBehind: false));
    await tester.pumpAndSettle();
    expect(offset(), 0);

    await tester.pumpWidget(scene(appBar: plainBar, extendBehind: true));
    await tester.pumpAndSettle();
    expect(offset(), 0);

    await tester.pumpWidget(
      scene(appBar: glassBar, extendBehind: true, edgeOffset: 42),
    );
    await tester.pumpAndSettle();
    expect(offset(), 42);
    expect(tester.takeException(), isNull);
  });
}
