import 'dart:ui' as ui;

import 'package:flutter/foundation.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart' show Scaffold;
import 'package:morph_expressive/components/navigation_rail/components/morph_nav_selection_indicator.dart';
import 'package:morph_expressive/components/text_fields/components/morph_text_field_label.dart';
import 'package:morph_expressive/morph_expressive.dart';

import '../support/motion_audit_binding.dart';

const _capture = ValueKey('motion-contract-capture');
const _options = <MorphChipToggleOption<String>>[
  MorphChipToggleOption(value: 'A', label: 'Alpha'),
  MorphChipToggleOption(value: 'B', label: 'Beta'),
  MorphChipToggleOption(value: 'C', label: 'Gamma'),
];
const _iconA = SizedBox(
  width: 24,
  height: 24,
  child: ColoredBox(color: Color(0xFFCC2266)),
);
const _iconB = SizedBox(
  width: 24,
  height: 24,
  child: ColoredBox(color: Color(0xFF2288CC)),
);

bool get _reduced =>
    motionAuditProfile == 'reduced' || motionAuditProfile == 'reduce-only';

Widget _host(Widget child) => MorphMaterialApp(
  data: MorphThemeData.light(seedColor: const Color(0xFF6750A4)),
  home: Scaffold(
    body: Center(
      child: RepaintBoundary(
        key: _capture,
        child: SizedBox(width: 360, height: 240, child: Center(child: child)),
      ),
    ),
  ),
);

Future<Uint8List> _pixels(WidgetTester tester) async {
  final boundary = tester.renderObject<RenderRepaintBoundary>(
    find.byKey(_capture),
  );
  final result = await tester.runAsync(() async {
    final image = await boundary.toImage(pixelRatio: 1);
    try {
      final data = await image.toByteData(format: ui.ImageByteFormat.rawRgba);
      if (data == null) throw StateError('Could not read contract pixels');
      return Uint8List.fromList(
        data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes),
      );
    } finally {
      image.dispose();
    }
  });
  if (result == null) throw StateError('Motion contract capture failed');
  return result;
}

/// Pure controlled state changes avoid pointer ripple and caret noise.
/// The 112ms budget allows a short bounded feedback effect, but rejects an
/// unchanged 220–340ms spatial transfer under the reduced-motion profile.
void _finite(String name, Widget Function(bool target) builder) {
  testWidgets('motion contract: $name', (tester) async {
    var target = false;
    late StateSetter update;
    await tester.pumpWidget(
      _host(
        StatefulBuilder(
          builder: (context, setState) {
            update = setState;
            return builder(target);
          },
        ),
      ),
    );
    await tester.pumpAndSettle();
    final before = await _pixels(tester);
    update(() => target = true);
    await tester.pump();
    await tester.pump();
    for (var i = 0; i < 2; i++) {
      await tester.pump(const Duration(milliseconds: 16));
    }
    final early = await _pixels(tester);
    for (var i = 0; i < 5; i++) {
      await tester.pump(const Duration(milliseconds: 16));
    }
    final at112ms = await _pixels(tester);
    await tester.pumpAndSettle();
    final end = await _pixels(tester);
    expect(
      listEquals(before, end),
      isFalse,
      reason: 'Positive control: the requested selection must change visible output.',
    );
    if (_reduced) {
      expect(
        listEquals(at112ms, end),
        isTrue,
        reason:
            '$name continues a decorative selection transition beyond the reduced-motion budget.',
      );
    } else {
      // Some selections are intentionally instantaneous. Record that outcome
      // rather than requiring every widget to acquire an unnecessary animation.
      debugPrint(
        'MORPH_CONTRACT_OBSERVATION $name intermediate=${!listEquals(early, end)}',
      );
    }
    expect(tester.takeException(), isNull);
  });
}

void main() {
  _finite(
    'checkbox selection',
    (value) => MorphCheckbox(value: value, onChanged: (_) {}),
  );
  _finite(
    'switch position and thumb size',
    (value) => MorphSwitch(value: value, onChanged: (_) {}),
  );
  _finite(
    'radio selection',
    (value) => MorphRadio(
      value: 'B',
      groupValue: value ? 'B' : 'A',
      onChanged: (_) {},
    ),
  );
  _finite(
    'standard filter chip',
    (value) => MorphChip(
      label: 'Filter',
      type: MorphChipType.filter,
      selected: value,
      onPressed: () {},
    ),
  );
  _finite(
    'button selection',
    (value) => MorphButton(
      label: const Text('Action'),
      isSelected: value,
      onPressed: () {},
    ),
  );
  _finite(
    'icon button selection',
    (value) => MorphIconButton(
      icon: _iconA,
      selectedIcon: _iconB,
      isSelected: value,
      onPressed: () {},
    ),
  );
  _finite(
    'connected button group selection',
    (value) => MorphButtonGroup(
      actions: const [
        MorphButtonGroupAction(label: Text('Alpha')),
        MorphButtonGroupAction(label: Text('Beta')),
      ],
      selectedIndex: value ? 1 : 0,
      onSelectedIndexChanged: (_) {},
    ),
  );
  _finite(
    'segmented button selection',
    (value) => MorphSegmentedButton<String>(
      segments: const [
        MorphSegment(value: 'A', label: 'Alpha'),
        MorphSegment(value: 'B', label: 'Beta'),
      ],
      selected: {value ? 'B' : 'A'},
      onSelectionChanged: (_) {},
    ),
  );
  _finite(
    'animated segmented toggle transfer',
    (value) => MorphSegmentedToggle<String>(
      options: const [
        MorphSegmentedToggleOption(value: 'A', label: 'Alpha'),
        MorphSegmentedToggleOption(value: 'B', label: 'Beta'),
      ],
      selected: value ? 'B' : 'A',
      onChanged: (_) {},
    ),
  );
  _finite(
    'animated single chip transfer',
    (value) => MorphChipToggle<String>(
      options: _options,
      selected: value ? 'C' : 'A',
      onChanged: (_) {},
    ),
  );
  _finite(
    'animated multiple chip transfer',
    (value) => MorphChipToggle<String>(
      options: _options,
      multiSelection: true,
      selectedValues: value ? {'A', 'C'} : {'A'},
      onSelectionChanged: (_) {},
    ),
  );
  _finite(
    'multiple chip first selection bloom',
    (value) => MorphChipToggle<String>(
      options: _options,
      multiSelection: true,
      selectedValues: value ? {'B'} : {},
      onSelectionChanged: (_) {},
    ),
  );
  _finite(
    'selection flip',
    (value) => MorphSelectionFlip(
      selected: value,
      selectedChild: _iconB,
      child: _iconA,
    ),
  );
  _finite(
    'navigation rail selection indicator',
    (value) => MorphSelectionIndicator(
      selected: value,
      child: const SizedBox(
        width: 100,
        height: 40,
        child: ColoredBox(color: Color(0xFF6750A4)),
      ),
    ),
  );
  _finite(
    'navigation bar selection',
    (value) => MorphNavigationBar(
      destinations: const [
        MorphNavigationBarDestination(label: 'Alpha', icon: _iconA),
        MorphNavigationBarDestination(label: 'Beta', icon: _iconB),
      ],
      selectedIndex: value ? 1 : 0,
      onDestinationSelected: (_) {},
      safeArea: false,
    ),
  );
  _finite(
    'navigation drawer selection',
    (value) => MorphNavigationDrawer(
      destinations: const [
        MorphNavigationDestination(label: 'Alpha'),
        MorphNavigationDestination(label: 'Beta'),
      ],
      selectedIndex: value ? 1 : 0,
      onDestinationSelected: (_) {},
    ),
  );
  _finite(
    'primary tab indicator',
    (value) => MorphTabs(
      tabs: const [
        MorphTab(label: 'Alpha'),
        MorphTab(label: 'Beta'),
      ],
      selectedIndex: value ? 1 : 0,
      onTabSelected: (_) {},
    ),
  );
  _finite(
    'secondary tab indicator',
    (value) => MorphTabs(
      variant: MorphTabsVariant.secondary,
      tabs: const [
        MorphTab(label: 'Alpha'),
        MorphTab(label: 'Beta'),
      ],
      selectedIndex: value ? 1 : 0,
      onTabSelected: (_) {},
    ),
  );

  for (final entry in <String, Widget>{
    'linear indeterminate progress': const MorphProgressIndicator.linear(),
    'circular indeterminate progress': const MorphProgressIndicator.circular(),
    'linear indeterminate wave': const MorphProgressIndicator.linearWavy(),
    'circular indeterminate wave': const MorphProgressIndicator.circularWavy(),
    'expressive loading': const MorphLoadingIndicator(),
    'slider wave': MorphSlider.wavy(value: 0.5, onChanged: (_) {}),
    'range slider wave': MorphRangeSlider.wavy(
      values: const MorphSliderRange(0.2, 0.8),
      onChanged: (_) {},
    ),
    'linear determinate wave': const MorphProgressIndicator.linearWavy(
      value: 0.5,
    ),
    'circular determinate wave': const MorphProgressIndicator.circularWavy(
      value: 0.5,
    ),
  }.entries) {
    testWidgets(
      'motion contract: ${entry.key} has no ornamental motion when reduced',
      (tester) async {
        await tester.pumpWidget(_host(entry.value));
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 200));
        final first = await _pixels(tester);
        await tester.pump(const Duration(milliseconds: 160));
        final last = await _pixels(tester);
        expect(
          listEquals(first, last),
          _reduced,
          reason: 'Reduced motion keeps a static indicator or wave; normal mode continues its animation.',
        );
        expect(tester.takeException(), isNull);
      },
    );
  }

  for (final variant in MorphTextFieldVariant.values) {
    if (_reduced) {
      testWidgets(
        'motion contract: enabling reduced motion stops active ${variant.name} label',
        (tester) async {
          final dispatcher = tester.binding.platformDispatcher;
          final original = dispatcher.accessibilityFeatures;
          dispatcher.accessibilityFeaturesTestValue =
              const FakeAccessibilityFeatures();
          final node = FocusNode();
          addTearDown(node.dispose);
          try {
            await tester.pumpWidget(
              _host(
                MorphTextField(
                  label: 'Email',
                  focusNode: node,
                  variant: variant,
                ),
              ),
            );
            await tester.pumpAndSettle();
            double progress() => tester
                .widget<MorphTextFieldLabel>(find.byType(MorphTextFieldLabel))
                .progress;
            node.requestFocus();
            await tester.pump();
            await tester.pump();
            await tester.pump(const Duration(milliseconds: 32));
            expect(
              progress(),
              inExclusiveRange(0, 1),
              reason: 'Positive control: motion must already be running.',
            );
            dispatcher.accessibilityFeaturesTestValue =
                const FakeAccessibilityFeatures(
                  disableAnimations: true,
                  reduceMotion: true,
                );
            await tester.pump();
            await tester.pump();
            expect(
              progress(),
              1,
              reason: 'A changed accessibility preference should finish an already-running label animation.',
            );
          } finally {
            dispatcher.accessibilityFeaturesTestValue = original;
          }
        },
      );
    }

    testWidgets(
      'motion contract: ${variant.name} text field label and reverse',
      (tester) async {
        final node = FocusNode();
        addTearDown(node.dispose);
        await tester.pumpWidget(
          _host(
            MorphTextField(label: 'Email', focusNode: node, variant: variant),
          ),
        );
        await tester.pumpAndSettle();
        double progress() => tester
            .widget<MorphTextFieldLabel>(find.byType(MorphTextFieldLabel))
            .progress;
        expect(progress(), 0);
        node.requestFocus();
        await tester.pump();
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 40));
        final forward = progress();
        await tester.pumpAndSettle();
        expect(progress(), closeTo(1, 0.001));
        node.unfocus();
        await tester.pump();
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 40));
        final reverse = progress();
        await tester.pumpAndSettle();
        expect(progress(), closeTo(0, 0.001));
        if (_reduced) {
          expect(
            forward,
            1,
            reason: 'Reduced motion should snap the label on focus.',
          );
          expect(
            reverse,
            0,
            reason: 'Reduced motion should snap the label on blur.',
          );
        } else {
          expect(forward, inExclusiveRange(0, 1));
          expect(reverse, inExclusiveRange(0, 1));
        }
        expect(tester.takeException(), isNull);
      },
    );
  }
}
