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
        VoidCallback,
        Widget;
import 'package:morph_expressive/morph_expressive.dart';
import 'package:widgetbook/widgetbook.dart';
import 'package:widgetbook_annotation/widgetbook_annotation.dart' as widgetbook;

import '../../utilities/demo.dart';
import '../../utilities/knobs.dart';
import '../../utilities/stage.dart';

const _path = '[Actions]/Icon Buttons';

Widget _iconButtonOfType(
  MorphIconButtonType type, {
  required IconData icon,
  required VoidCallback? onPressed,
  MorphVariant? variant,
  MorphIconButtonSize size = MorphIconButtonSize.sm,
  MorphIconButtonShapeVariant shape = MorphIconButtonShapeVariant.round,
  MorphIconButtonWidth width = MorphIconButtonWidth.defaultWidth,
  bool? isSelected,
  IconData? selectedIcon,
}) {
  final selectedWidget = selectedIcon == null ? null : Icon(selectedIcon);
  final tooltip = '${type.name} icon button';
  return switch (type) {
    MorphIconButtonType.standard => MorphIconButton.standard(
      icon: Icon(icon),
      selectedIcon: selectedWidget,
      isSelected: isSelected,
      onPressed: onPressed,
      tooltip: tooltip,
      variant: variant,
      size: size,
      shape: shape,
      width: width,
    ),
    MorphIconButtonType.filled => MorphIconButton.filled(
      icon: Icon(icon),
      selectedIcon: selectedWidget,
      isSelected: isSelected,
      onPressed: onPressed,
      tooltip: tooltip,
      variant: variant,
      size: size,
      shape: shape,
      width: width,
    ),
    MorphIconButtonType.tonal => MorphIconButton.tonal(
      icon: Icon(icon),
      selectedIcon: selectedWidget,
      isSelected: isSelected,
      onPressed: onPressed,
      tooltip: tooltip,
      variant: variant,
      size: size,
      shape: shape,
      width: width,
    ),
    MorphIconButtonType.outlined => MorphIconButton.outlined(
      icon: Icon(icon),
      selectedIcon: selectedWidget,
      isSelected: isSelected,
      onPressed: onPressed,
      tooltip: tooltip,
      variant: variant,
      size: size,
      shape: shape,
      width: width,
    ),
  };
}

@widgetbook.UseCase(name: 'Matrix', type: MorphIconButton, path: _path)
Widget iconButtonMatrixUseCase(BuildContext context) {
  final size = enumKnob<MorphIconButtonSize>(
    context,
    label: 'size',
    values: MorphIconButtonSize.values,
    initial: MorphIconButtonSize.sm,
  );
  final shape = enumKnob<MorphIconButtonShapeVariant>(
    context,
    label: 'shape',
    values: MorphIconButtonShapeVariant.values,
  );
  final enabled = context.knobs.boolean(label: 'enabled', initialValue: true);
  final icon = iconKnob(context, initial: 'heart');
  final variants = <MorphVariant?>[null, ...MorphVariant.values];
  return Stage(
    children: [
      for (final type in MorphIconButtonType.values)
        StageSection(
          title: 'MorphIconButton.${type.name}',
          note: 'Columns: default (null) and every MorphVariant.',
          child: StageWrap(
            spacing: 14,
            runSpacing: 14,
            children: [
              for (final variant in variants)
                StageCell(
                  caption: variant?.name ?? 'default',
                  child: _iconButtonOfType(
                    type,
                    icon: icon,
                    onPressed: enabled ? () {} : null,
                    variant: variant,
                    size: size,
                    shape: shape,
                  ),
                ),
            ],
          ),
        ),
    ],
  );
}

@widgetbook.UseCase(name: 'Playground', type: MorphIconButton, path: _path)
Widget iconButtonPlaygroundUseCase(BuildContext context) {
  final type = enumKnob<MorphIconButtonType>(
    context,
    label: 'type',
    values: MorphIconButtonType.values,
  );
  final variant = variantKnob(context);
  final size = enumKnob<MorphIconButtonSize>(
    context,
    label: 'size',
    values: MorphIconButtonSize.values,
    initial: MorphIconButtonSize.md,
  );
  final shape = enumKnob<MorphIconButtonShapeVariant>(
    context,
    label: 'shape',
    values: MorphIconButtonShapeVariant.values,
  );
  final width = enumKnob<MorphIconButtonWidth>(
    context,
    label: 'width',
    values: MorphIconButtonWidth.values,
  );
  final enabled = context.knobs.boolean(label: 'enabled', initialValue: true);
  final toggle = context.knobs.boolean(label: 'toggle (selectable)');
  final icon = iconKnob(context, initial: 'heart');
  return _IconButtonPlayground(
    key: resetKey([type, variant, size, shape, width, toggle]),
    type: type,
    variant: variant,
    size: size,
    shape: shape,
    width: width,
    enabled: enabled,
    toggle: toggle,
    icon: icon,
  );
}

class _IconButtonPlayground extends StatefulWidget {
  const _IconButtonPlayground({
    super.key,
    required this.type,
    required this.variant,
    required this.size,
    required this.shape,
    required this.width,
    required this.enabled,
    required this.toggle,
    required this.icon,
  });

  final MorphIconButtonType type;
  final MorphVariant? variant;
  final MorphIconButtonSize size;
  final MorphIconButtonShapeVariant shape;
  final MorphIconButtonWidth width;
  final bool enabled;
  final bool toggle;
  final IconData icon;

  @override
  State<_IconButtonPlayground> createState() => _IconButtonPlaygroundState();
}

class _IconButtonPlaygroundState extends State<_IconButtonPlayground> {
  int _presses = 0;
  bool _selected = false;

  @override
  Widget build(BuildContext context) {
    return StageCenter(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _iconButtonOfType(
            widget.type,
            icon: widget.icon,
            onPressed: widget.enabled
                ? () => setState(() {
                    _presses++;
                    if (widget.toggle) _selected = !_selected;
                  })
                : null,
            variant: widget.variant,
            size: widget.size,
            shape: widget.shape,
            width: widget.width,
            isSelected: widget.toggle ? _selected : null,
            selectedIcon: widget.toggle ? FluentIcons.filled.heart : null,
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
