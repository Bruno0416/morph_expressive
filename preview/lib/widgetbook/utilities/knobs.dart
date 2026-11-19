import 'package:material_ui/material_ui.dart' show BuildContext, Key, ValueKey;
import 'package:morph_expressive/morph_expressive.dart';
import 'package:widgetbook/widgetbook.dart';

const _defaultVariantLabel = 'default (null)';

/// Dropdown over every value of an enum, labelled with the value name.
T enumKnob<T extends Enum>(
  BuildContext context, {
  required String label,
  required List<T> values,
  T? initial,
}) {
  return context.knobs.object.dropdown<T>(
    label: label,
    options: values,
    initialOption: initial ?? values.first,
    labelBuilder: (value) => value.name,
  );
}

/// `MorphVariant?` knob where "default (null)" keeps the canonical pairing.
MorphVariant? variantKnob(BuildContext context, {String label = 'variant'}) {
  final choice = context.knobs.object.dropdown<String>(
    label: label,
    options: [
      _defaultVariantLabel,
      for (final v in MorphVariant.values) v.name,
    ],
    initialOption: _defaultVariantLabel,
  );
  if (choice == _defaultVariantLabel) return null;
  return MorphVariant.values.byName(choice);
}

/// `MorphSurface` knob (solid / frosted).
MorphSurface surfaceKnob(BuildContext context, {String label = 'surface'}) =>
    enumKnob<MorphSurface>(
      context,
      label: label,
      values: MorphSurface.values,
      initial: MorphSurface.solid,
    );

/// Key that changes whenever any of [values] changes; use it on a stateful
/// harness so it resets (controllers, timers, selection) on knob changes.
Key resetKey(Iterable<Object?> values) => ValueKey<int>(Object.hashAll(values));

/// Size knob for the button family (the sizes are static constants).
MorphButtonSize buttonSizeKnob(
  BuildContext context, {
  String label = 'size',
  MorphButtonSize initial = MorphButtonSize.sm,
}) => context.knobs.object.dropdown<MorphButtonSize>(
  label: label,
  options: const [
    MorphButtonSize.xs,
    MorphButtonSize.sm,
    MorphButtonSize.md,
    MorphButtonSize.lg,
    MorphButtonSize.xl,
  ],
  initialOption: initial,
  labelBuilder: (size) => size.name,
);
