import 'package:material_ui/material_ui.dart'
    show
        BuildContext,
        Column,
        EdgeInsets,
        Icon,
        MainAxisSize,
        Padding,
        SizedBox,
        State,
        StatefulWidget,
        Text,
        Widget;
import 'package:morph_expressive/morph_expressive.dart';
import 'package:widgetbook/widgetbook.dart';
import 'package:widgetbook_annotation/widgetbook_annotation.dart' as widgetbook;

import '../../../desktop_context_menu_lab.dart';
import '../../utilities/demo.dart';
import '../../utilities/knobs.dart';
import '../../utilities/stage.dart';

const _menusPath = '[Overlays]/Menus';

@widgetbook.UseCase(name: 'Playground', type: MorphMenu, path: _menusPath)
Widget menuPlaygroundUseCase(BuildContext context) {
  final position = enumKnob<MorphMenuAnchorPosition>(
    context,
    label: 'position',
    values: MorphMenuAnchorPosition.values,
  );
  final colorStyle = enumKnob<MorphMenuColorStyle>(
    context,
    label: 'color style',
    values: MorphMenuColorStyle.values,
  );
  final variant = enumKnob<MorphMenuVariant>(
    context,
    label: 'variant',
    values: MorphMenuVariant.values,
  );
  final selection = enumKnob<MorphMenuSelectionMode>(
    context,
    label: 'selection mode',
    values: MorphMenuSelectionMode.values,
  );
  final motion = enumKnob<MorphDropdownMotionStyle>(
    context,
    label: 'motion style',
    values: MorphDropdownMotionStyle.values,
  );
  final closeOnSelect = context.knobs.boolean(
    label: 'close on select',
    initialValue: true,
  );
  return _MenuHarness(
    position: position,
    colorStyle: colorStyle,
    variant: variant,
    selection: selection,
    motion: motion,
    closeOnSelect: closeOnSelect,
  );
}

class _MenuHarness extends StatefulWidget {
  const _MenuHarness({
    required this.position,
    required this.colorStyle,
    required this.variant,
    required this.selection,
    required this.motion,
    required this.closeOnSelect,
  });

  final MorphMenuAnchorPosition position;
  final MorphMenuColorStyle colorStyle;
  final MorphMenuVariant variant;
  final MorphMenuSelectionMode selection;
  final MorphDropdownMotionStyle motion;
  final bool closeOnSelect;

  @override
  State<_MenuHarness> createState() => _MenuHarnessState();
}

class _MenuHarnessState extends State<_MenuHarness> {
  String _last = 'None';

  @override
  Widget build(BuildContext context) {
    return StageCenter(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          MorphMenu.entries(
            position: widget.position,
            colorStyle: widget.colorStyle,
            variant: widget.variant,
            selectionMode: widget.selection,
            motionStyle: widget.motion,
            closeOnSelect: widget.closeOnSelect,
            onSelected: (value) => setState(() => _last = '$value'),
            anchorBuilder: (context, open) => MorphButton.filled(
              onPressed: open,
              label: const Text('Open menu'),
            ),
            entries: [
              MorphMenuEntry(
                label: 'Edit',
                value: 'edit',
                leading: Icon(FluentIcons.line.settings),
                trailingText: 'Ctrl+E',
                supportingText: 'Change the item',
              ),
              MorphMenuEntry(
                label: 'Favorite',
                value: 'favorite',
                leading: Icon(FluentIcons.line.heart),
                badge: const Text('New'),
              ),
              const MorphMenuEntry(
                label: 'Disabled',
                value: 'disabled',
                enabled: false,
              ),
              MorphMenuEntry(
                label: 'Delete',
                value: 'delete',
                isDestructive: true,
                leading: const Icon(MorphIcons.delete),
              ),
            ],
          ),
          const SizedBox(height: 16),
          DemoReadout('Last selection: $_last'),
        ],
      ),
    );
  }
}

@widgetbook.UseCase(
  name: 'Nodes: groups, toggles, submenus',
  type: MorphMenuItem,
  path: _menusPath,
)
Widget menuChildrenUseCase(BuildContext context) {
  return _MenuChildren();
}

class _MenuChildren extends StatefulWidget {
  @override
  State<_MenuChildren> createState() => _MenuChildrenState();
}

class _MenuChildrenState extends State<_MenuChildren> {
  String _last = 'None';
  bool _wrap = true;

  @override
  Widget build(BuildContext context) {
    return StageCenter(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          MorphMenu(
            anchorBuilder: (context, open) => MorphButton.tonal(
              onPressed: open,
              label: const Text('Menu from nodes'),
            ),
            onSelected: (value) => setState(() => _last = '$value'),
            children: [
              const MorphMenuEntry(label: 'Cut', value: 'cut'),
              const MorphMenuEntry(label: 'Copy', value: 'copy'),
              const MorphMenuDivider(),
              MorphMenuToggleable(
                label: 'Word wrap',
                checked: _wrap,
                onChanged: (value) => setState(() => _wrap = value),
              ),
              MorphMenuGroup(
                label: 'Sort by',
                children: const [
                  MorphMenuSelectable(
                    label: 'Name',
                    value: 'name',
                    selected: true,
                  ),
                  MorphMenuSelectable(label: 'Date', value: 'date'),
                ],
              ),
              const MorphMenuSubmenu(
                label: 'More',
                children: [
                  MorphMenuEntry(label: 'Archive', value: 'archive'),
                  MorphMenuEntry(label: 'Move', value: 'move'),
                ],
              ),
              MorphMenuEntry(
                label: 'Delete',
                value: 'delete',
                isDestructive: true,
                leading: const Icon(MorphIcons.delete),
              ),
            ],
          ),
          const SizedBox(height: 16),
          DemoReadout('Last: $_last · word wrap: $_wrap'),
          const SizedBox(height: 24),
          const StageSection(
            title: 'Rendered rows',
            note:
                'MorphMenuItem and MorphMenuDividerWidget are the rows menus '
                'render; here they are shown standalone.',
            child: SizedBox(
              width: 260,
              child: Column(
                children: [
                  MorphMenuItem(label: 'Standalone item', onTap: _noop),
                  MorphMenuDividerWidget(),
                  MorphMenuItem(
                    label: 'Destructive item',
                    isDestructive: true,
                    onTap: _noop,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

void _noop() {}

@widgetbook.UseCase(
  name: 'Desktop context menu lab',
  type: MorphMenuPopup,
  path: _menusPath,
)
Widget desktopContextMenuLabUseCase(BuildContext context) =>
    const DesktopContextMenuLab();

enum _TooltipKind { plain, rich, persistent }

@widgetbook.UseCase(
  name: 'Playground',
  type: MorphTooltip,
  path: '[Overlays]/Tooltips',
)
Widget tooltipPlaygroundUseCase(BuildContext context) {
  final kind = enumKnob<_TooltipKind>(
    context,
    label: 'kind',
    values: _TooltipKind.values,
  );
  final placement = enumKnob<MorphTooltipPlacement>(
    context,
    label: 'placement',
    values: MorphTooltipPlacement.values,
  );
  final message = context.knobs.string(
    label: 'message',
    initialValue: 'Tooltip message',
  );
  final title = context.knobs.string(
    label: 'rich title',
    initialValue: 'Rich tooltip',
  );
  final icon = iconKnob(context, initial: 'info');
  return StageCenter(
    child: MorphTooltip(
      key: resetKey([kind, placement]),
      message: kind == _TooltipKind.plain ? message : null,
      richTitle: kind == _TooltipKind.plain ? null : title,
      richMessage: kind == _TooltipKind.plain ? null : message,
      persistent: kind == _TooltipKind.persistent,
      preferredPlacement: placement,
      actions: kind == _TooltipKind.persistent
          ? [MorphButton.text(onPressed: () {}, child: const Text('Got it'))]
          : const [],
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Icon(icon, size: 36),
      ),
    ),
  );
}
