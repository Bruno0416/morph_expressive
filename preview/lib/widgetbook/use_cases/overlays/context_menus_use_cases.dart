import 'package:material_ui/material_ui.dart'
    show
        Align,
        EdgeInsets,
        MainAxisSize,
        Padding,
        Positioned,
        BuildContext,
        Builder,
        Center,
        LayoutBuilder,
        SingleChildScrollView,
        Column,
        CrossAxisAlignment,
        FocusNode,
        GestureDetector,
        Icon,
        MouseRegion,
        SizedBox,
        Stack,
        State,
        StatefulWidget,
        StatelessWidget,
        TapDownDetails,
        Text,
        ValueChanged,
        ValueKey,
        Widget;
import 'package:morph_expressive/morph_expressive.dart';
import 'package:widgetbook/widgetbook.dart';
import 'package:widgetbook_annotation/widgetbook_annotation.dart' as widgetbook;

import '../../../desktop_context_menu_lab.dart';
import '../../utilities/context_menu_lab.dart';
import '../../utilities/demo.dart' show DemoReadout;
import '../../utilities/density_lab.dart';
import '../../utilities/stage.dart';

const _path = '[Overlays]/Context menus';

const _mouseHint =
    'Right-click (secondary button) the surface. Click an item or press '
    'Escape to close, then open it again.';

List<MorphMenuNode> _simple() => <MorphMenuNode>[
  const MorphMenuEntry(label: 'Open', value: 'open'),
  const MorphMenuEntry(label: 'Rename', value: 'rename'),
  const MorphMenuEntry(label: 'Share', value: 'share'),
  const MorphMenuEntry(label: 'Delete', value: 'delete'),
];

List<MorphMenuNode> _iconActions() => <MorphMenuNode>[
  MorphMenuEntry(
    label: 'Open',
    value: 'open',
    leading: Icon(FluentIcons.line.open),
  ),
  MorphMenuEntry(
    label: 'Edit',
    value: 'edit',
    leading: Icon(FluentIcons.line.edit),
  ),
  MorphMenuEntry(
    label: 'Copy link',
    value: 'copy-link',
    leading: Icon(FluentIcons.line.link),
  ),
  MorphMenuEntry(
    label: 'Share',
    value: 'share',
    leading: Icon(FluentIcons.line.share),
  ),
  const MorphMenuDivider(),
  MorphMenuEntry(
    label: 'Delete',
    value: 'delete',
    isDestructive: true,
    leading: Icon(FluentIcons.line.delete),
  ),
];

List<MorphMenuNode> _shortcuts() => <MorphMenuNode>[
  MorphMenuEntry(
    label: 'Undo',
    value: 'undo',
    leading: Icon(FluentIcons.line.arrow_undo),
    trailingText: 'Ctrl+Z',
  ),
  MorphMenuEntry(
    label: 'Redo',
    value: 'redo',
    leading: Icon(FluentIcons.line.arrow_redo),
    trailingText: 'Ctrl+Shift+Z',
  ),
  const MorphMenuDivider(),
  MorphMenuEntry(
    label: 'Cut',
    value: 'cut',
    leading: Icon(FluentIcons.line.cut),
    trailingText: 'Ctrl+X',
  ),
  MorphMenuEntry(
    label: 'Copy',
    value: 'copy',
    leading: Icon(FluentIcons.line.copy),
    trailingText: 'Ctrl+C',
  ),
  MorphMenuEntry(
    label: 'Paste',
    value: 'paste',
    leading: Icon(FluentIcons.line.clipboard_paste),
    trailingText: 'Ctrl+V',
  ),
  const MorphMenuEntry(
    label: 'Select all',
    value: 'select-all',
    trailingText: 'Ctrl+A',
  ),
];

List<MorphMenuNode> _longLabels() => <MorphMenuNode>[
  const MorphMenuEntry(label: 'Short', value: 'short'),
  const MorphMenuEntry(
    label: 'A considerably longer label that has to be handled gracefully',
    value: 'long',
    trailingText: 'Ctrl+Alt+Shift+L',
  ),
  const MorphMenuEntry(
    label: 'Antidisestablishmentarianism_without_any_spaces_at_all',
    value: 'unbroken',
  ),
  const MorphMenuEntry(label: 'Another normal entry', value: 'normal'),
];

List<MorphMenuNode> _destructive() => <MorphMenuNode>[
  const MorphMenuEntry(label: 'Open', value: 'open'),
  const MorphMenuEntry(
    label: 'Rename (disabled)',
    value: 'rename',
    enabled: false,
  ),
  const MorphMenuEntry(
    label: 'Move to (disabled)',
    value: 'move',
    enabled: false,
    trailingText: 'Ctrl+M',
  ),
  const MorphMenuDivider(),
  MorphMenuEntry(
    label: 'Move to trash',
    value: 'trash',
    isDestructive: true,
    leading: Icon(FluentIcons.line.delete),
  ),
  const MorphMenuEntry(
    label: 'Delete forever (disabled)',
    value: 'delete-forever',
    isDestructive: true,
    enabled: false,
  ),
];

List<MorphMenuNode> _grouped() => <MorphMenuNode>[
  MorphMenuGroup(
    label: 'Clipboard',
    children: const [
      MorphMenuEntry(label: 'Cut', value: 'cut', trailingText: 'Ctrl+X'),
      MorphMenuEntry(label: 'Copy', value: 'copy', trailingText: 'Ctrl+C'),
      MorphMenuEntry(label: 'Paste', value: 'paste', trailingText: 'Ctrl+V'),
    ],
  ),
  const MorphMenuDivider(),
  MorphMenuGroup(
    label: 'Arrange',
    children: const [
      MorphMenuEntry(label: 'Bring to front', value: 'front'),
      MorphMenuEntry(label: 'Send to back', value: 'back'),
    ],
  ),
  const MorphMenuDivider(),
  const MorphMenuEntry(label: 'Properties', value: 'properties'),
];

List<MorphMenuNode> _nested() => <MorphMenuNode>[
  const MorphMenuEntry(label: 'Open', value: 'open'),
  MorphMenuSubmenu(
    label: 'Open with',
    leading: Icon(FluentIcons.line.open),
    children: const [
      MorphMenuEntry(label: 'Editor', value: 'with:editor'),
      MorphMenuEntry(label: 'Viewer', value: 'with:viewer'),
      MorphMenuSubmenu(
        label: 'Other apps',
        children: [
          MorphMenuEntry(label: 'Browser', value: 'with:browser'),
          MorphMenuEntry(label: 'Terminal', value: 'with:terminal'),
          MorphMenuEntry(
            label: 'Disabled app',
            value: 'with:disabled',
            enabled: false,
          ),
        ],
      ),
    ],
  ),
  MorphMenuSubmenu(
    label: 'Move to',
    leading: Icon(FluentIcons.line.folder_arrow_right),
    children: const [
      MorphMenuEntry(label: 'Design', value: 'move:design'),
      MorphMenuEntry(label: 'Product', value: 'move:product'),
      MorphMenuEntry(label: 'Archive', value: 'move:archive'),
    ],
  ),
  const MorphMenuDivider(),
  MorphMenuEntry(
    label: 'Delete',
    value: 'delete',
    isDestructive: true,
    leading: Icon(FluentIcons.line.delete),
  ),
];

List<MorphMenuNode> _large() => <MorphMenuNode>[
  for (var i = 1; i <= 40; i++)
    MorphMenuEntry(
      label: 'Menu item $i',
      value: 'item-$i',
      trailingText: i % 5 == 0 ? 'Ctrl+$i' : null,
    ),
];

Widget _region(
  List<MorphMenuNode> Function() items,
  ValueChanged<String> report, {
  required Widget child,
  FocusNode? focusNode,
  MorphDensity? density,
}) => MorphContextMenuRegion<String>(
  focusNode: focusNode,
  density: density,
  children: items(),
  onSelected: report,
  child: child,
);

Widget _simpleLab(
  List<MorphMenuNode> Function() items, {
  String title = 'Context surface',
  double width = 320,
}) => ContextLabHost(
  instructions:
      '$_mouseHint Click the surface to focus it, then Shift+F10 or '
      'the Menu key opens the menu at the surface.',
  builder: (context, report) => FocusableContextRegion(
    title: title,
    items: items,
    report: report,
    width: width,
  ),
);

@widgetbook.UseCase(name: 'Simple', type: MorphContextMenuRegion, path: _path)
Widget contextMenuSimpleUseCase(BuildContext context) =>
    StageCenter(child: _simpleLab(_simple));

@widgetbook.UseCase(
  name: 'Icon actions',
  type: MorphContextMenuRegion,
  path: _path,
)
Widget contextMenuIconsUseCase(BuildContext context) =>
    StageCenter(child: _simpleLab(_iconActions, title: 'File'));

@widgetbook.UseCase(
  name: 'Text + shortcuts',
  type: MorphContextMenuRegion,
  path: _path,
)
Widget contextMenuShortcutsUseCase(BuildContext context) =>
    StageCenter(child: _simpleLab(_shortcuts, title: 'Editor'));

@widgetbook.UseCase(
  name: 'Long labels',
  type: MorphContextMenuRegion,
  path: _path,
)
Widget contextMenuLongLabelsUseCase(BuildContext context) =>
    StageCenter(child: _simpleLab(_longLabels, title: 'Long labels'));

@widgetbook.UseCase(
  name: 'Destructive & disabled',
  type: MorphContextMenuRegion,
  path: _path,
)
Widget contextMenuDestructiveUseCase(BuildContext context) =>
    StageCenter(child: _simpleLab(_destructive, title: 'Item'));

@widgetbook.UseCase(
  name: 'Checkable',
  type: MorphContextMenuRegion,
  path: _path,
)
Widget contextMenuCheckableUseCase(BuildContext context) =>
    const StageCenter(child: _CheckableLab());

class _CheckableLab extends StatefulWidget {
  const _CheckableLab();

  @override
  State<_CheckableLab> createState() => _CheckableLabState();
}

class _CheckableLabState extends State<_CheckableLab> {
  bool _wrap = true;
  bool _ruler = false;
  String _sort = 'name';

  @override
  Widget build(BuildContext context) {
    return ContextLabHost(
      instructions:
          '$_mouseHint Toggle rows keep their state between openings; '
          'wrap: $_wrap, ruler: $_ruler, sort: $_sort.',
      builder: (context, report) => MorphContextMenuRegion<String>(
        menuBuilder: (context) => <MorphMenuNode>[
          MorphMenuToggleable(
            label: 'Word wrap',
            checked: _wrap,
            onChanged: (v) {
              setState(() => _wrap = v);
              report('wrap = $v');
            },
          ),
          MorphMenuToggleable(
            label: 'Show ruler',
            checked: _ruler,
            trailingText: 'Ctrl+R',
            onChanged: (v) {
              setState(() => _ruler = v);
              report('ruler = $v');
            },
          ),
          const MorphMenuDivider(),
          MorphMenuSelectable(
            label: 'Sort by name',
            value: 'name',
            selected: _sort == 'name',
          ),
          MorphMenuSelectable(
            label: 'Sort by date',
            value: 'date',
            selected: _sort == 'date',
          ),
          MorphMenuSelectable(
            label: 'Sort by size',
            value: 'size',
            selected: _sort == 'size',
          ),
        ],
        onSelected: (value) {
          setState(() => _sort = value);
          report('sort = $value');
        },
        child: const ContextTarget(
          key: ValueKey<String>('context-target'),
          title: 'Checkable',
          width: 320,
          height: 140,
        ),
      ),
    );
  }
}

@widgetbook.UseCase(name: 'Grouped', type: MorphContextMenuRegion, path: _path)
Widget contextMenuGroupedUseCase(BuildContext context) =>
    StageCenter(child: _simpleLab(_grouped, title: 'Grouped'));

@widgetbook.UseCase(
  name: 'Nested submenu',
  type: MorphContextMenuRegion,
  path: _path,
)
Widget contextMenuNestedUseCase(BuildContext context) => StageCenter(
  child: ContextLabHost(
    instructions:
        '$_mouseHint Hover (or press the right arrow on) "Open with" and '
        '"Move to" to open submenus; "Other apps" nests one level deeper.',
    builder: (context, report) => _region(
      _nested,
      report,
      child: const ContextTarget(
        key: ValueKey<String>('context-target'),
        title: 'Nested submenus',
        width: 320,
        height: 140,
      ),
    ),
  ),
);

@widgetbook.UseCase(
  name: 'Large menu with scroll',
  type: MorphContextMenuRegion,
  path: _path,
)
Widget contextMenuLargeUseCase(BuildContext context) =>
    StageCenter(child: _simpleLab(_large, title: '40 items (scrolls)'));

@widgetbook.UseCase(
  name: 'Near viewport edge',
  type: MorphContextMenuRegion,
  path: _path,
)
Widget contextMenuEdgeUseCase(BuildContext context) {
  final tall = context.knobs.boolean(label: 'tall menu (14 items)');
  return _EdgeLab(tall: tall);
}

List<MorphMenuNode> _tall() => <MorphMenuNode>[
  for (var i = 1; i <= 14; i++)
    MorphMenuEntry(label: 'Tall menu item $i', value: 'tall-$i'),
];

class _EdgeLab extends StatefulWidget {
  const _EdgeLab({required this.tall});

  final bool tall;

  @override
  State<_EdgeLab> createState() => _EdgeLabState();
}

class _EdgeLabState extends State<_EdgeLab> {
  String _last = 'none yet';
  int _count = 0;

  void _report(String value) => setState(() {
    _last = value;
    _count++;
  });

  @override
  Widget build(BuildContext context) {
    const inset = 8.0;
    Widget target(String id) => _region(
      widget.tall ? _tall : _nested,
      _report,
      child: ContextTarget(
        key: ValueKey<String>('context-corner-$id'),
        title: id,
        width: 150,
        height: 120,
        hint: 'Right-click',
      ),
    );
    return SizedBox.expand(
      child: Stack(
        children: [
          Positioned(left: inset, top: inset, child: target('top-left')),
          Positioned(right: inset, top: inset, child: target('top-right')),
          Positioned(left: inset, bottom: inset, child: target('bottom-left')),
          Positioned(
            right: inset,
            bottom: inset,
            child: target('bottom-right'),
          ),
          Positioned(
            right: inset,
            top: 0,
            bottom: 0,
            child: Align(child: target('far-right')),
          ),
          Positioned.fill(
            child: LayoutBuilder(
              builder: (context, box) => Padding(
                padding: EdgeInsets.fromLTRB(
                  box.maxWidth > 700 ? 190 : 8,
                  box.maxWidth > 700 ? 0 : 140,
                  box.maxWidth > 700 ? 190 : 8,
                  box.maxWidth > 700 ? 0 : 140,
                ),
                child: Center(
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        DemoReadout(
                          'Right-click each target, which sits flush to the '
                          'canvas edge. The menu opens with its top-left at '
                          'the pointer and flips left or above only when it '
                          'would leave the viewport; a tall menu scrolls. '
                          'The menu lives in the window overlay, so the '
                          'right flip triggers at the browser window edge: '
                          'collapse the Widgetbook panels or use a narrow '
                          'viewport.',
                        ),
                        const SizedBox(height: 12),
                        DemoReadout(
                          'Last action: $_last · selections: $_count',
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

@widgetbook.UseCase(
  name: 'Keyboard navigation',
  type: MorphContextMenuRegion,
  path: _path,
)
Widget contextMenuKeyboardUseCase(BuildContext context) =>
    const StageCenter(child: _KeyboardLab());

class _KeyboardLab extends StatefulWidget {
  const _KeyboardLab();

  @override
  State<_KeyboardLab> createState() => _KeyboardLabState();
}

class _KeyboardLabState extends State<_KeyboardLab> {
  final FocusNode _node = FocusNode(debugLabel: 'context-lab-target');

  @override
  void dispose() {
    _node.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ContextLabHost(
      instructions:
          'Click the surface (or Tab to it) to focus it, then press '
          'Shift+F10 or the Menu key: the menu opens at the focused widget '
          'and autofocuses the first row. Use Up / Down / Home / End, Right '
          'to enter a submenu, Left to leave, Enter to choose and Escape to '
          'close: focus returns to the surface.',
      builder: (context, report) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GestureDetector(
            onTap: _node.requestFocus,
            child: _region(
              _nested,
              report,
              focusNode: _node,
              child: FocusableContextTarget(
                key: const ValueKey<String>('context-keyboard-target'),
                node: _node,
                title: 'Focusable surface',
                hint: 'Focus, then Shift+F10',
              ),
            ),
          ),
          const SizedBox(height: 16),
          _region(
            _shortcuts,
            report,
            child: MorphButton.tonal(
              key: const ValueKey<String>('context-keyboard-button'),
              onPressed: () => report('button pressed'),
              label: const Text('Button inside a region'),
            ),
          ),
        ],
      ),
    );
  }
}

@widgetbook.UseCase(
  name: 'Hover interactions',
  type: MorphContextMenuRegion,
  path: _path,
)
Widget contextMenuHoverUseCase(BuildContext context) =>
    const StageCenter(child: _HoverLab());

class _HoverLab extends StatefulWidget {
  const _HoverLab();

  @override
  State<_HoverLab> createState() => _HoverLabState();
}

class _HoverLabState extends State<_HoverLab> {
  bool _hovering = false;

  @override
  Widget build(BuildContext context) {
    return ContextLabHost(
      instructions:
          'Hover rows to highlight them, hover "Open with" / "Move to" to '
          'open its submenu after a short delay, and move the pointer '
          'diagonally toward an open submenu without it closing. '
          'Surface hover: ${_hovering ? 'pointer is over the surface' : 'outside'}.',
      builder: (context, report) => MouseRegion(
        onEnter: (_) => setState(() => _hovering = true),
        onExit: (_) => setState(() => _hovering = false),
        child: _region(
          _nested,
          report,
          child: ContextTarget(
            key: const ValueKey<String>('context-target'),
            title: 'Hover surface',
            width: 320,
            height: 140,
            highlighted: _hovering,
          ),
        ),
      ),
    );
  }
}

@widgetbook.UseCase(
  name: 'Density compare',
  type: MorphContextMenuRegion,
  path: _path,
)
Widget contextMenuDensityUseCase(BuildContext context) => Stage(
  children: [
    ContextLabHost(
      instructions:
          'Each column is a real nested MorphTheme with its own density, and '
          'the region inherits it: the menu opens with that column\'s row '
          'height even though it lives in the window overlay. $_mouseHint',
      builder: (context, report) => DensityColumns(
        width: 260,
        builder: (context, density) => _region(
          _shortcuts,
          report,
          child: ContextTarget(
            key: ValueKey<String>('context-density-${density.name}'),
            title: densityLabels[density]!,
            width: 240,
            height: 120,
          ),
        ),
      ),
    ),
  ],
);

@widgetbook.UseCase(
  name: 'Standard vs desktop presentation',
  type: MorphContextMenuRegion,
  path: _path,
)
Widget contextMenuPresentationUseCase(BuildContext context) =>
    const Stage(children: [_PresentationLab()]);

class _PresentationLab extends StatelessWidget {
  const _PresentationLab();

  @override
  Widget build(BuildContext context) {
    return ContextLabHost(
      instructions:
          'Both surfaces open the same items through the real API: the '
          'left one with MorphMenuPresentation.desktop (compact rows, '
          'content-fitted width, top-left at the pointer), the right one '
          'with MorphMenuPresentation.standard (expressive 48 px rows).',
      builder: (context, report) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          StageWrap(
            spacing: 24,
            children: [
              StageCell(
                caption: 'desktop presentation',
                child: _region(
                  _shortcuts,
                  report,
                  child: const ContextTarget(
                    key: ValueKey<String>('context-presentation-desktop'),
                    title: 'Desktop',
                    width: 280,
                    height: 140,
                  ),
                ),
              ),
              StageCell(
                caption: 'standard presentation',
                child: Builder(
                  builder: (context) => GestureDetector(
                    onSecondaryTapDown: (TapDownDetails details) async {
                      final value = await showMorphContextMenu<String>(
                        context: context,
                        position: details.globalPosition,
                        presentation: MorphMenuPresentation.standard,
                        children: _shortcuts(),
                      );
                      if (value != null) report(value);
                    },
                    child: const ContextTarget(
                      key: ValueKey<String>('context-presentation-standard'),
                      title: 'Standard',
                      width: 280,
                      height: 140,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

@widgetbook.UseCase(
  name: 'Desktop context menu lab',
  type: MorphMenuPopup,
  path: _path,
)
Widget contextMenuDesktopLabUseCase(BuildContext context) =>
    const DesktopContextMenuLab();
