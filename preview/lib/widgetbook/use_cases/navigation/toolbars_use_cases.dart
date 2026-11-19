import 'package:material_ui/material_ui.dart'
    show BuildContext, IconData, State, StatefulWidget, Widget;
import 'package:morph_expressive/morph_expressive.dart';
import 'package:widgetbook/widgetbook.dart';
import 'package:widgetbook_annotation/widgetbook_annotation.dart' as widgetbook;

import '../../utilities/demo.dart';
import '../../utilities/knobs.dart';
import '../../utilities/stage.dart';

const _path = '[Navigation]/Toolbars';

enum _ToolbarKind { standard, floating, docked }

List<MorphToolbarAction> _actions(int count, void Function(String) onTap) {
  final all = <(String, IconData)>[
    ('Share', FluentIcons.line.mail),
    ('Like', FluentIcons.line.heart),
    ('Star', FluentIcons.line.star),
    ('Settings', FluentIcons.line.settings),
    ('Info', FluentIcons.line.info),
    ('Bookmark', FluentIcons.line.bookmark),
  ];
  return [
    for (var i = 0; i < count; i++)
      MorphToolbarAction(
        icon: all[i].$2,
        label: all[i].$1,
        tooltip: all[i].$1,
        onPressed: () => onTap(all[i].$1),
      ),
  ];
}

@widgetbook.UseCase(name: 'Playground', type: MorphToolbar, path: _path)
Widget toolbarPlaygroundUseCase(BuildContext context) {
  final kind = enumKnob<_ToolbarKind>(
    context,
    label: 'constructor',
    values: _ToolbarKind.values,
  );
  final size = enumKnob<MorphToolbarSize>(
    context,
    label: 'size',
    values: MorphToolbarSize.values,
    initial: MorphToolbarSize.medium,
  );
  final colorStyle = enumKnob<MorphToolbarColorStyle>(
    context,
    label: 'color style',
    values: MorphToolbarColorStyle.values,
  );
  final actions = context.knobs.int.slider(
    label: 'actions',
    initialValue: 5,
    min: 1,
    max: 6,
  );
  final inline = context.knobs.int.slider(
    label: 'max inline actions',
    initialValue: 3,
    min: 1,
    max: 6,
  );
  final title = context.knobs.string(label: 'title', initialValue: 'Toolbar');
  final fab = context.knobs.boolean(label: 'FAB');
  final center = context.knobs.boolean(label: 'center title');
  return _ToolbarHarness(
    key: resetKey([kind]),
    kind: kind,
    size: size,
    colorStyle: colorStyle,
    actions: actions,
    inline: inline,
    title: title,
    fab: fab,
    center: center,
  );
}

class _ToolbarHarness extends StatefulWidget {
  const _ToolbarHarness({
    super.key,
    required this.kind,
    required this.size,
    required this.colorStyle,
    required this.actions,
    required this.inline,
    required this.title,
    required this.fab,
    required this.center,
  });

  final _ToolbarKind kind;
  final MorphToolbarSize size;
  final MorphToolbarColorStyle colorStyle;
  final int actions;
  final int inline;
  final String title;
  final bool fab;
  final bool center;

  @override
  State<_ToolbarHarness> createState() => _ToolbarHarnessState();
}

class _ToolbarHarnessState extends State<_ToolbarHarness> {
  String _last = 'None';

  @override
  Widget build(BuildContext context) {
    final actions = _actions(widget.actions, (a) => setState(() => _last = a));
    final toolbar = switch (widget.kind) {
      _ToolbarKind.standard => MorphToolbar(
        titleText: widget.title,
        actions: actions,
        maxInlineActions: widget.inline,
        size: widget.size,
        colorStyle: widget.colorStyle,
        centerTitle: widget.center,
        onFabPressed: widget.fab ? () => setState(() => _last = 'FAB') : null,
      ),
      _ToolbarKind.floating => MorphToolbar.floating(
        titleText: widget.title,
        actions: actions,
        maxInlineActions: widget.inline,
        size: widget.size,
        colorStyle: widget.colorStyle,
        centerTitle: widget.center,
        onFabPressed: widget.fab ? () => setState(() => _last = 'FAB') : null,
      ),
      _ToolbarKind.docked => MorphToolbar.docked(
        titleText: widget.title,
        actions: actions,
        maxInlineActions: widget.inline,
        size: widget.size,
        colorStyle: widget.colorStyle,
        centerTitle: widget.center,
        safeArea: false,
      ),
    };
    return Stage(children: [toolbar, DemoReadout('Last action: $_last')]);
  }
}
