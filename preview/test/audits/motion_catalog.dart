import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:morph_expressive_preview/component_catalog.dart';
import 'package:morph_expressive_preview/main.directories.g.dart';
import 'package:morph_expressive_preview/widgetbook/addons/morph_scope_addon.dart';
import 'package:widgetbook/widgetbook.dart';

import '../widgetbook/support.dart';
import '../../../test/support/motion_component_owners.dart';

/// Explicit target for the audit runner, not a replacement for interaction tests.
///
/// Every public component family (the category names of
/// `component_catalog.dart`) is mounted through its Widgetbook use cases, inside
/// the same Morph scope as the catalog, with the selected platform flags. The
/// test names are the contract parsed by `tool/audit_reduced_motion.py`.
void main() => registerMotionCatalogTests(exclude: const {'carousel'});

/// Modal-only families must be opened: testing their launch button would
/// otherwise count a Buttons sample as a dialog/sheet test.
const _launchLabels = <String, String>{
  'dialogs': 'Open dialog',
  'time_pickers': 'Choose time',
  'bottom_sheets': 'Open bottom sheet',
  'side_sheets': 'Open side sheet',
  'snackbar': 'Show snackbar',
};

/// Use cases whose Widgetbook component is one of the family's public widgets.
List<WidgetbookUseCase> _useCasesOf(String family) {
  final names = {
    for (final entry in morphComponentCatalog)
      if (entry.category == family) entry.name,
  };
  final root = WidgetbookRoot(children: directories);
  return [
    for (final useCase in root.leaves.whereType<WidgetbookUseCase>())
      if (names.contains(useCase.parent?.name)) useCase,
  ];
}

void registerMotionCatalogTests({
  Set<String>? only,
  Set<String> exclude = const {},
}) {
  final families = morphComponentCatalog.map((entry) => entry.category).toSet()
    ..remove('foundation');
  if (only != null) families.retainAll(only);
  families.removeAll(exclude);
  for (final family in families.toList()..sort()) {
    final useCases = _useCasesOf(family);
    testWidgets(
      'motion catalog: $family mounts and survives preference changes',
      (tester) async {
        expect(
          useCases,
          isNotEmpty,
          reason: 'Family $family needs at least one Widgetbook use case.',
        );
        final dispatcher = tester.binding.platformDispatcher;
        final original = dispatcher.accessibilityFeatures;
        var mountedFamily = false;
        for (final useCase in useCases) {
          await openUseCase(tester, useCase.path, size: const Size(1440, 900));
          final target = find.byType(MorphScope);
          expect(target, findsOneWidget, reason: useCase.path);
          final launch = _launchLabels[family];
          if (launch != null) {
            final button = find.text(launch);
            if (button.evaluate().isNotEmpty) {
              await tester.ensureVisible(button.first);
              await tester.pump();
              await tester.tap(button.first);
              await tester.pump();
              await tester.pump(const Duration(milliseconds: 32));
            }
          }
          mountedFamily |= find
              .byWidgetPredicate(
                (widget) =>
                    motionComponentOwners[widget.runtimeType
                        .toString()
                        .split('<')
                        .first] ==
                    family,
              )
              .evaluate()
              .isNotEmpty;

          // Exercise the accessibility notification while the family is
          // mounted, including continuous loaders. Bounded pumps avoid hiding
          // ticker leaks behind pumpAndSettle (or hanging on intentional
          // progress animations).
          for (final reduced in [true, false, true]) {
            dispatcher.accessibilityFeaturesTestValue =
                FakeAccessibilityFeatures(
                  disableAnimations: reduced,
                  reduceMotion: reduced,
                );
            await tester.pump();
            await tester.pump(const Duration(milliseconds: 120));
            final query = MediaQuery.of(tester.element(target));
            expect(query.disableAnimations, reduced, reason: useCase.path);
            expect(dispatcher.accessibilityFeatures.reduceMotion, reduced);
            expect(tester.takeException(), isNull, reason: useCase.path);
          }
          dispatcher.accessibilityFeaturesTestValue = original;
          await tester.pumpWidget(const SizedBox.shrink());
          await tester.pump();
          expect(tester.takeException(), isNull, reason: useCase.path);
          // The teardown/unmount above must stop even the intentional
          // infinite loops.
          expect(
            tester.binding.transientCallbackCount,
            0,
            reason: useCase.path,
          );
        }
        expect(
          mountedFamily,
          isTrue,
          reason:
              'The actual $family component must be mounted, not only its '
              'launch button.',
        );
      },
    );
  }
}
