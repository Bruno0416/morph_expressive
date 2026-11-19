import 'package:material_ui/material_ui.dart'
    show
        BuildContext,
        Column,
        Icon,
        IconData,
        MainAxisSize,
        SizedBox,
        State,
        StatefulWidget,
        Text,
        VoidCallback,
        Widget;
import 'package:morph_expressive/morph_expressive.dart';
import 'package:widgetbook/widgetbook.dart';
import 'package:widgetbook_annotation/widgetbook_annotation.dart' as widgetbook;

import '../../utilities/demo.dart';
import '../../utilities/knobs.dart';
import '../../utilities/stage.dart';

const _path = '[Actions]/Buttons';

/// Builds a [MorphButton] through the named constructor for [style].
Widget _buttonOfType(
  MorphButtonStyle style, {
  required VoidCallback? onPressed,
  required String label,
  IconData? icon,
  MorphVariant? variant,
  MorphSurface surface = MorphSurface.solid,
  MorphButtonSize size = MorphButtonSize.sm,
  MorphButtonShape shape = MorphButtonShape.round,
  bool enabled = true,
  bool? isSelected,
  IconData? selectedIcon,
  String? selectedLabel,
  bool iconFactory = false,
}) {
  if (iconFactory && icon != null) {
    // The `.icon` factory: icon + label for any style.
    return MorphButton.icon(
      onPressed: onPressed,
      icon: Icon(icon),
      label: Text(label),
      selectedIcon: selectedIcon == null ? null : Icon(selectedIcon),
      selectedLabel: selectedLabel == null ? null : Text(selectedLabel),
      isSelected: isSelected,
      style: style,
      variant: variant,
      surface: surface,
      size: size,
      shape: shape,
      enabled: enabled,
    );
  }
  final iconWidget = icon == null ? null : Icon(icon);
  final selectedIconWidget = selectedIcon == null ? null : Icon(selectedIcon);
  final labelWidget = Text(label);
  final selectedLabelWidget = selectedLabel == null
      ? null
      : Text(selectedLabel);
  return switch (style) {
    MorphButtonStyle.filled => MorphButton.filled(
      onPressed: onPressed,
      icon: iconWidget,
      label: labelWidget,
      selectedIcon: selectedIconWidget,
      selectedLabel: selectedLabelWidget,
      isSelected: isSelected,
      variant: variant,
      surface: surface,
      size: size,
      shape: shape,
      enabled: enabled,
    ),
    MorphButtonStyle.tonal => MorphButton.tonal(
      onPressed: onPressed,
      icon: iconWidget,
      label: labelWidget,
      selectedIcon: selectedIconWidget,
      selectedLabel: selectedLabelWidget,
      isSelected: isSelected,
      variant: variant,
      surface: surface,
      size: size,
      shape: shape,
      enabled: enabled,
    ),
    MorphButtonStyle.elevated => MorphButton.elevated(
      onPressed: onPressed,
      icon: iconWidget,
      label: labelWidget,
      selectedIcon: selectedIconWidget,
      selectedLabel: selectedLabelWidget,
      isSelected: isSelected,
      variant: variant,
      surface: surface,
      size: size,
      shape: shape,
      enabled: enabled,
    ),
    MorphButtonStyle.outlined => MorphButton.outlined(
      onPressed: onPressed,
      icon: iconWidget,
      label: labelWidget,
      selectedIcon: selectedIconWidget,
      selectedLabel: selectedLabelWidget,
      isSelected: isSelected,
      variant: variant,
      surface: surface,
      size: size,
      shape: shape,
      enabled: enabled,
    ),
    MorphButtonStyle.text => MorphButton.text(
      onPressed: onPressed,
      variant: variant,
      surface: surface,
      size: size,
      shape: shape,
      enabled: enabled,
      child: Text(label),
    ),
  };
}

@widgetbook.UseCase(name: 'Matrix', type: MorphButton, path: _path)
Widget buttonMatrixUseCase(BuildContext context) {
  final surface = surfaceKnob(context);
  final size = buttonSizeKnob(context, initial: MorphButtonSize.sm);
  final shape = enumKnob<MorphButtonShape>(
    context,
    label: 'shape',
    values: MorphButtonShape.values,
  );
  final enabled = context.knobs.boolean(label: 'enabled', initialValue: true);
  final withIcon = context.knobs.boolean(label: 'with icon');
  final iconFactory = context.knobs.boolean(
    label: 'MorphButton.icon factory (needs icon)',
  );
  final label = context.knobs.string(label: 'label', initialValue: 'Action');
  final icon = iconKnob(context);
  final variants = <MorphVariant?>[null, ...MorphVariant.values];
  return Stage(
    children: [
      for (final style in MorphButtonStyle.values)
        StageSection(
          title: 'MorphButton.${style.name}',
          note: 'Columns: default (null) and every MorphVariant.',
          child: StageWrap(
            spacing: 14,
            runSpacing: 14,
            children: [
              for (final variant in variants)
                StageCell(
                  caption: variant?.name ?? 'default',
                  child: _buttonOfType(
                    style,
                    onPressed: () {},
                    label: label,
                    icon: withIcon ? icon : null,
                    iconFactory: iconFactory,
                    variant: variant,
                    surface: surface,
                    size: size,
                    shape: shape,
                    enabled: enabled,
                  ),
                ),
            ],
          ),
        ),
    ],
  );
}

@widgetbook.UseCase(name: 'Playground', type: MorphButton, path: _path)
Widget buttonPlaygroundUseCase(BuildContext context) {
  final style = enumKnob<MorphButtonStyle>(
    context,
    label: 'type',
    values: MorphButtonStyle.values,
  );
  final variant = variantKnob(context);
  final surface = surfaceKnob(context);
  final size = buttonSizeKnob(context, initial: MorphButtonSize.md);
  final shape = enumKnob<MorphButtonShape>(
    context,
    label: 'shape',
    values: MorphButtonShape.values,
  );
  final enabled = context.knobs.boolean(label: 'enabled', initialValue: true);
  final toggle = context.knobs.boolean(label: 'toggle (selectable)');
  final withIcon = context.knobs.boolean(
    label: 'with icon',
    initialValue: true,
  );
  final iconFactory = context.knobs.boolean(
    label: 'MorphButton.icon factory (needs icon)',
  );
  final label = context.knobs.string(label: 'label', initialValue: 'Button');
  final icon = iconKnob(context);
  return _ButtonPlayground(
    key: resetKey([style, variant, surface, size, shape, toggle]),
    iconFactory: iconFactory,
    style: style,
    variant: variant,
    surface: surface,
    size: size,
    shape: shape,
    enabled: enabled,
    toggle: toggle,
    label: label,
    icon: withIcon ? icon : null,
  );
}

class _ButtonPlayground extends StatefulWidget {
  const _ButtonPlayground({
    super.key,
    required this.style,
    required this.variant,
    required this.surface,
    required this.size,
    required this.shape,
    required this.enabled,
    required this.toggle,
    required this.label,
    required this.icon,
    required this.iconFactory,
  });

  final bool iconFactory;
  final MorphButtonStyle style;
  final MorphVariant? variant;
  final MorphSurface surface;
  final MorphButtonSize size;
  final MorphButtonShape shape;
  final bool enabled;
  final bool toggle;
  final String label;
  final IconData? icon;

  @override
  State<_ButtonPlayground> createState() => _ButtonPlaygroundState();
}

class _ButtonPlaygroundState extends State<_ButtonPlayground> {
  int _presses = 0;
  bool _selected = false;

  @override
  Widget build(BuildContext context) {
    final onPressed = widget.enabled
        ? () => setState(() {
            _presses++;
            if (widget.toggle) _selected = !_selected;
          })
        : null;
    return StageCenter(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buttonOfType(
            widget.style,
            onPressed: onPressed,
            label: widget.label,
            icon: widget.icon,
            iconFactory: widget.iconFactory,
            variant: widget.variant,
            surface: widget.surface,
            size: widget.size,
            shape: widget.shape,
            enabled: widget.enabled,
            isSelected: widget.toggle ? _selected : null,
            selectedIcon: widget.toggle && widget.icon != null
                ? FluentIcons.filled.checkmark
                : null,
            selectedLabel: widget.toggle ? '${widget.label} (on)' : null,
          ),
          const SizedBox(height: 16),
          DemoReadout(
            'Pressed $_presses times'
            '${widget.toggle ? ' · selected: $_selected' : ''}',
          ),
        ],
      ),
    );
  }
}
