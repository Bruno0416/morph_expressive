import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart'
    show MaterialApp, Scaffold, StatefulBuilder, StateSetter, Icon;
import 'package:morph_expressive/morph_expressive.dart';
import 'package:morph_expressive/components/navigation_rail/components/morph_sliding_indicator.dart';

void main() {
  for (final drawer in [true, false]) {
    testWidgets(
      'modal navigation captures local motion policy and updated selection, drawer=$drawer',
      (tester) async {
        final controller = MorphNavigationDrawerController(isOpen: true);
        addTearDown(controller.dispose);
        var reduce = false;
        var selected = 0;
        late StateSetter update;
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: StatefulBuilder(
                builder: (context, setState) {
                  update = setState;
                  return MorphMotionScope(
                    reduceMotion: reduce,
                    child: drawer
                        ? MorphNavigationDrawer.morph(
                            type: MorphNavigationDrawerType.modal,
                            controller: controller,
                            selectedIndex: selected,
                            onDestinationSelected: (_) {},
                            destinations: const [
                              MorphNavigationDestination(
                                icon: Icon(MorphIcons.home),
                                label: 'Home',
                              ),
                              MorphNavigationDestination(
                                icon: Icon(MorphIcons.search),
                                label: 'Search',
                              ),
                            ],
                          )
                        : MorphNavigationRail.morph(
                            type: MorphNavigationRailType.alwaysExpand,
                            modality: MorphNavigationRailModality.modal,
                            selectedIndex: selected,
                            onDestinationSelected: (_) {},
                            sections: const [
                              MorphNavigationRailSection(
                                destinations: [
                                  MorphNavigationRailDestination(
                                    icon: Icon(MorphIcons.home),
                                    label: 'Home',
                                  ),
                                  MorphNavigationRailDestination(
                                    icon: Icon(MorphIcons.search),
                                    label: 'Search',
                                  ),
                                ],
                              ),
                            ],
                          ),
                  );
                },
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();
        final finder = find.byType(MorphSlidingIndicator);
        expect(finder, findsOneWidget);
        final render = tester.renderObject<RenderMorphSlidingIndicator>(finder);
        final first = render.indicatorRect!;
        update(() {
          reduce = true;
          selected = 1;
        });
        await tester.pump();
        await tester.pump();
        await tester.pumpAndSettle();
        expect(MorphMotion.reduceMotionOf(tester.element(finder)), isTrue);
        expect(render.indicatorRect!.top, greaterThan(first.top));
        final snap = render.indicatorRect;
        await tester.pump(const Duration(seconds: 1));
        expect(render.indicatorRect, snap);
        expect(tester.takeException(), isNull);
      },
    );
  }
}
