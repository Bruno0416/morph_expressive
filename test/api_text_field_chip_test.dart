import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:morph_expressive/morph_expressive.dart';

import 'helpers/api_test_helpers.dart';

MorphTextField _field(
  MorphTextFieldVariant variant, {
  Key? key,
  TextEditingController? controller,
  ValueChanged<String>? onChanged,
  String? errorText,
  bool enabled = true,
}) {
  return switch (variant) {
    MorphTextFieldVariant.filled => MorphTextField.filled(
      key: key,
      controller: controller,
      label: 'Name',
      onChanged: onChanged,
      errorText: errorText,
      enabled: enabled,
      supportingText: 'Help',
    ),
    MorphTextFieldVariant.outlined => MorphTextField.outlined(
      key: key,
      controller: controller,
      label: 'Name',
      onChanged: onChanged,
      errorText: errorText,
      enabled: enabled,
      supportingText: 'Help',
    ),
  };
}

MorphChip _chip(
  MorphChipType type, {
  Key? key,
  VoidCallback? onPressed,
  VoidCallback? onDeleted,
  bool selected = false,
}) {
  return switch (type) {
    MorphChipType.assist => MorphChip.assist(
      key: key,
      label: 'Chip',
      onPressed: onPressed,
      onDeleted: onDeleted,
      selected: selected,
    ),
    MorphChipType.filter => MorphChip.filter(
      key: key,
      label: 'Chip',
      onPressed: onPressed,
      onDeleted: onDeleted,
      selected: selected,
    ),
    MorphChipType.input => MorphChip.input(
      key: key,
      label: 'Chip',
      onPressed: onPressed,
      onDeleted: onDeleted,
      selected: selected,
    ),
    MorphChipType.suggestion => MorphChip.suggestion(
      key: key,
      label: 'Chip',
      onPressed: onPressed,
      onDeleted: onDeleted,
      selected: selected,
    ),
  };
}

void main() {
  group('MorphTextField named constructors', () {
    for (final MorphTextFieldVariant variant in MorphTextFieldVariant.values) {
      testWidgets('MorphTextField.${variant.name} selects the variant', (
        tester,
      ) async {
        await tester.pumpWidget(apiHost(_field(variant)));
        expect(
          tester.widget<MorphTextField>(find.byType(MorphTextField)).variant,
          variant,
        );
        expect(find.text('Name'), findsOneWidget);
        expect(find.text('Help'), findsOneWidget);
        expect(tester.takeException(), isNull);
      });
    }

    testWidgets('named constructors build the same widget as the base', (
      tester,
    ) async {
      for (final MorphTextFieldVariant variant
          in MorphTextFieldVariant.values) {
        await tester.pumpWidget(apiHost(_field(variant)));
        final Size named = tester.getSize(find.byType(MorphTextField));
        await tester.pumpWidget(
          apiHost(
            MorphTextField(
              variant: variant,
              label: 'Name',
              supportingText: 'Help',
            ),
          ),
        );
        expect(tester.getSize(find.byType(MorphTextField)), named);
      }
    });

    testWidgets('the base constructor keeps filled as default', (tester) async {
      await tester.pumpWidget(apiHost(const MorphTextField(label: 'Name')));
      expect(
        tester.widget<MorphTextField>(find.byType(MorphTextField)).variant,
        MorphTextFieldVariant.filled,
      );
    });

    testWidgets('typing reports onChanged and honors the controller', (
      tester,
    ) async {
      final TextEditingController controller = TextEditingController();
      addTearDown(controller.dispose);
      final List<String> changes = <String>[];
      await tester.pumpWidget(
        apiHost(
          _field(
            MorphTextFieldVariant.outlined,
            controller: controller,
            onChanged: changes.add,
          ),
        ),
      );
      await tester.enterText(find.byType(EditableText), 'Ada');
      await tester.pump();
      expect(changes.last, 'Ada');
      expect(controller.text, 'Ada');
    });

    testWidgets('disabled fields ignore input and show errors', (tester) async {
      final List<String> changes = <String>[];
      await tester.pumpWidget(
        apiHost(
          _field(
            MorphTextFieldVariant.filled,
            enabled: false,
            onChanged: changes.add,
          ),
        ),
      );
      await tester.tap(find.byType(MorphTextField), warnIfMissed: false);
      await tester.pump();
      expect(changes, isEmpty);

      await tester.pumpWidget(
        apiHost(_field(MorphTextFieldVariant.outlined, errorText: 'Required')),
      );
      expect(find.text('Required'), findsOneWidget);
    });

    testWidgets('switching variant on rebuild is stable and keeps keys', (
      tester,
    ) async {
      const Key key = ValueKey<String>('field');
      final TextEditingController controller = TextEditingController(
        text: 'kept',
      );
      addTearDown(controller.dispose);
      for (final MorphTextFieldVariant variant in <MorphTextFieldVariant>[
        MorphTextFieldVariant.filled,
        MorphTextFieldVariant.outlined,
        MorphTextFieldVariant.filled,
      ]) {
        await tester.pumpWidget(
          apiHost(_field(variant, key: key, controller: controller)),
        );
        await tester.pumpAndSettle();
        expect(find.byKey(key), findsOneWidget);
        expect(tester.takeException(), isNull);
      }
      expect(controller.text, 'kept');
    });
  });

  group('MorphChip named constructors', () {
    for (final MorphChipType type in MorphChipType.values) {
      testWidgets('MorphChip.${type.name} selects the type', (tester) async {
        int taps = 0;
        await tester.pumpWidget(apiHost(_chip(type, onPressed: () => taps++)));
        expect(tester.widget<MorphChip>(find.byType(MorphChip)).type, type);
        await tester.tap(find.byType(MorphChip));
        await tester.pump();
        expect(taps, 1);
      });

      testWidgets('MorphChip.${type.name} equals the base constructor', (
        tester,
      ) async {
        await tester.pumpWidget(apiHost(_chip(type, onPressed: () {})));
        final MorphChip named = tester.widget(find.byType(MorphChip));
        final Size namedSize = tester.getSize(find.byType(MorphChip));
        await tester.pumpWidget(
          apiHost(MorphChip(label: 'Chip', type: type, onPressed: () {})),
        );
        final MorphChip base = tester.widget(find.byType(MorphChip));
        expect(base.type, named.type);
        expect(base.selected, named.selected);
        expect(base.elevated, named.elevated);
        expect(tester.getSize(find.byType(MorphChip)), namedSize);
      });
    }

    testWidgets('the base constructor keeps assist as default', (tester) async {
      await tester.pumpWidget(
        apiHost(MorphChip(label: 'Chip', onPressed: () {})),
      );
      expect(
        tester.widget<MorphChip>(find.byType(MorphChip)).type,
        MorphChipType.assist,
      );
    });

    testWidgets('disabled chips do not fire and keys are preserved', (
      tester,
    ) async {
      const Key key = ValueKey<String>('chip');
      await tester.pumpWidget(apiHost(_chip(MorphChipType.filter, key: key)));
      expect(find.byKey(key), findsOneWidget);
      await tester.tap(find.byKey(key), warnIfMissed: false);
      await tester.pump();
      expect(tester.takeException(), isNull);
    });

    testWidgets('input chips expose onDeleted and rebuild across types', (
      tester,
    ) async {
      int deleted = 0;
      for (final MorphChipType type in MorphChipType.values) {
        await tester.pumpWidget(
          apiHost(
            _chip(
              type,
              onPressed: () {},
              onDeleted: () => deleted++,
              selected: type == MorphChipType.filter,
            ),
          ),
        );
        await tester.pump(const Duration(milliseconds: 50));
        expect(tester.takeException(), isNull);
      }
      expect(deleted, 0);
    });
  });
}
