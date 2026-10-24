import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:morph_expressive_preview/component_catalog.dart';
import 'package:morph_expressive_preview/component_gallery.dart';
import 'package:morph_expressive/morph_expressive.dart';
import 'package:material_ui/material_ui.dart' show MaterialApp, Scaffold;

import '../showcase_scroll_helper.dart';
import '../../../test/support/motion_component_owners.dart';

/// Explicit target for the audit runner, not a replacement for interaction tests.
/// Every public gallery family is mounted with the selected platform flags.
void main() => registerMotionCatalogTests(exclude: const {'carousel'});

void registerMotionCatalogTests({
  Set<String>? only,
  Set<String> exclude = const {},
}) {
  final families = morphComponentCatalog.map((entry) => entry.category).toSet()
    ..remove('foundation');
  if (only != null) families.retainAll(only);
  families.removeAll(exclude);
  for (final family in families.toList()..sort()) {
    testWidgets(
      'motion catalog: $family mounts and survives preference changes',
      (tester) async {
        tester.view.physicalSize = const Size(1440, 900);
        tester.view.devicePixelRatio = 1;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);
        final theme = MorphThemeData.light(seedColor: const Color(0xFF6750A4));
        await tester.pumpWidget(
          MaterialApp(
            theme: theme.toThemeData(),
            builder: (context, child) => MorphTheme(data: theme, child: child!),
            home: Scaffold(
              body: MorphComponentGallery(
                seed: const Color(0xFF6750A4),
                onSeedChanged: (_) {},
                categories: {family},
              ),
            ),
          ),
        );
        addTearDown(() async {
          await tester.pumpWidget(const SizedBox.shrink());
          await tester.pump();
        });
        final target = await revealShowcaseCategory(tester, family);
        expect(target, findsOneWidget);
        // Modal-only families must be opened: testing their launch button
        // would otherwise count a Buttons sample as a dialog/sheet test.
        final launch = <String, String>{
          'dialogs': 'Open dialog',
          'time_pickers': 'Choose time',
          'bottom_sheets': 'Open bottom sheet',
          'side_sheets': 'Open side sheet',
          'snackbar': 'Show snackbar',
        }[family];
        if (launch != null) {
          final button = find.descendant(
            of: target,
            matching: find.text(launch),
          );
          await tester.ensureVisible(button);
          await tester.pump();
          await tester.tap(button);
          await tester.pump();
          await tester.pump(const Duration(milliseconds: 32));
        }
        expect(
          find.byWidgetPredicate(
            (widget) =>
                motionComponentOwners[widget.runtimeType
                    .toString()
                    .split('<')
                    .first] ==
                family,
          ),
          findsWidgets,
          reason:
              'The actual $family component must be mounted, not only its launch button.',
        );

        // Exercise the accessibility notification while the family is mounted,
        // including continuous loaders. Bounded pumps avoid hiding ticker leaks
        // behind pumpAndSettle (or hanging on intentional progress animations).
        final dispatcher = tester.binding.platformDispatcher;
        final original = dispatcher.accessibilityFeatures;
        for (final reduced in [true, false, true]) {
          dispatcher.accessibilityFeaturesTestValue = FakeAccessibilityFeatures(
            disableAnimations: reduced,
            reduceMotion: reduced,
          );
          await tester.pump();
          await tester.pump(const Duration(milliseconds: 120));
          final query = MediaQuery.of(tester.element(target));
          expect(query.disableAnimations, reduced);
          expect(dispatcher.accessibilityFeatures.reduceMotion, reduced);
          expect(tester.takeException(), isNull);
        }
        dispatcher.accessibilityFeaturesTestValue = original;
        await tester.pumpWidget(const SizedBox.shrink());
        await tester.pump();
        expect(tester.takeException(), isNull);
        // The teardown/unmount above must stop even the intentional infinite loops.
        expect(tester.binding.transientCallbackCount, 0);
      },
    );
  }
}
