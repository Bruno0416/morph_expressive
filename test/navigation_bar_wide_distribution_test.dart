import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart'
    show Center, MaterialApp, Scaffold, SizedBox, Widget;
import 'package:morph_expressive/components/navigation_bar/components/morph_nav_bar_destination_button.dart';
import 'package:morph_expressive/morph_components.dart';

const _destinations = <MorphNavigationBarDestination>[
  MorphNavigationBarDestination(icon: MorphIcons.home, label: 'Home'),
  MorphNavigationBarDestination(icon: MorphIcons.search, label: 'Search'),
  MorphNavigationBarDestination(icon: MorphIcons.favorite, label: 'Saved'),
];

Widget _host({
  bool distributed = false,
  MorphNavBarLayout layout = MorphNavBarLayout.wide,
  int variant = 0,
}) {
  final bar = switch (variant) {
    1 => MorphNavigationBar.expressive(
      destinations: _destinations,
      autoLayout: false,
      layout: layout,
      distributeWideDestinations: distributed,
      safeArea: false,
    ),
    2 => MorphNavigationBar.morph(
      destinations: _destinations,
      autoLayout: false,
      layout: layout,
      distributeWideDestinations: distributed,
      safeArea: false,
    ),
    _ => MorphNavigationBar(
      destinations: _destinations,
      autoLayout: false,
      layout: layout,
      distributeWideDestinations: distributed,
      safeArea: false,
    ),
  };
  return MaterialApp(
    home: Scaffold(
      body: Center(child: SizedBox(width: 900, child: bar)),
    ),
  );
}

List<double> _centers(WidgetTester tester) => [
  for (var i = 0; i < _destinations.length; i++)
    tester.getCenter(find.byType(MorphNavBarDestinationButton).at(i)).dx,
];

void main() {
  testWidgets('wide destinations are grouped by default', (tester) async {
    await tester.pumpWidget(_host());
    await tester.pump();
    final centers = _centers(tester);
    expect(centers[1] - centers[0], lessThan(250));
    expect(centers[2] - centers[1], lessThan(250));
  });

  testWidgets('wide distribution spreads all three navbar variants', (
    tester,
  ) async {
    for (var variant = 0; variant < 3; variant++) {
      await tester.pumpWidget(_host(distributed: true, variant: variant));
      await tester.pump();
      final bar = tester.getRect(find.byType(MorphNavigationBar));
      final centers = _centers(tester);
      for (var i = 0; i < centers.length; i++) {
        expect(centers[i], closeTo(bar.left + bar.width * (i + 0.5) / 3, 2));
      }
    }
  });

  testWidgets('distribution does not change compact layout', (tester) async {
    await tester.pumpWidget(
      _host(layout: MorphNavBarLayout.compact, distributed: true),
    );
    await tester.pump();
    final bar = tester.getRect(find.byType(MorphNavigationBar));
    final centers = _centers(tester);
    expect(centers[1] - centers[0], closeTo(bar.width / 3, 2));
    expect(centers[2] - centers[1], closeTo(bar.width / 3, 2));
  });
}
