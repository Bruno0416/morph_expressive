import 'package:gap/gap.dart';
import 'package:material_ui/material_ui.dart'
    show
        Alignment,
        AppBar,
        Border,
        BorderRadius,
        BoxConstraints,
        BoxDecoration,
        BoxShape,
        BuildContext,
        Center,
        Color,
        Column,
        ConstrainedBox,
        Container,
        CrossAxisAlignment,
        DecoratedBox,
        EdgeInsets,
        Expanded,
        FontWeight,
        GestureDetector,
        GridView,
        HitTestBehavior,
        Icon,
        IgnorePointer,
        LinearGradient,
        MouseRegion,
        Padding,
        Positioned,
        Row,
        SafeArea,
        Scaffold,
        SingleChildScrollView,
        Size,
        SizedBox,
        Spacer,
        Stack,
        State,
        StatefulWidget,
        SystemMouseCursors,
        TapDownDetails,
        Text,
        TextOverflow,
        ValueKey,
        Widget;
import 'package:morph_expressive/morph_expressive.dart';

class DesktopContextMenuLab extends StatefulWidget {
  const DesktopContextMenuLab({super.key});

  @override
  State<DesktopContextMenuLab> createState() => _DesktopContextMenuLabState();
}

class _DesktopContextMenuLabState extends State<DesktopContextMenuLab> {
  String _lastEvent = 'Right-click a workspace to open a context menu.';
  String _lastSelection = 'No menu action selected yet.';
  int _openCount = 0;

  Future<void> _openContextMenu(
    BuildContext context,
    String target,
    TapDownDetails details,
  ) async {
    setState(() {
      _openCount += 1;
      _lastEvent =
          'Opened menu for $target at '
          '(${details.globalPosition.dx.toStringAsFixed(0)}, '
          '${details.globalPosition.dy.toStringAsFixed(0)}).';
    });

    final selection = await showMorphMenu<String>(
      context: context,
      anchor: details.globalPosition & const Size(1, 1),
      children: <MorphMenuNode>[
        MorphMenuEntry(
          label: 'Open $target',
          leading: Icon(FluentIcons.line.folder_open),
          value: 'open:$target',
        ),
        MorphMenuEntry(
          label: 'Rename $target',
          leading: Icon(FluentIcons.line.edit),
          value: 'rename:$target',
        ),
        MorphMenuSubmenu(
          label: 'Move $target to',
          leading: Icon(FluentIcons.line.folder_arrow_right),
          children: <MorphMenuNode>[
            MorphMenuEntry(label: 'Design', value: 'move:$target:design'),
            MorphMenuEntry(label: 'Product', value: 'move:$target:product'),
            MorphMenuEntry(label: 'Archive', value: 'move:$target:archive'),
          ],
        ),
        MorphMenuEntry(
          label: 'Delete $target',
          leading: Icon(FluentIcons.line.delete),
          isDestructive: true,
          value: 'delete:$target',
        ),
      ],
    );

    if (!mounted) {
      return;
    }

    setState(() {
      _lastSelection = selection == null
          ? 'Closed $target without selecting an action.'
          : 'Selected $selection';
    });
  }

  Widget _workspaceCard(
    BuildContext context, {
    required String id,
    required String title,
    required String description,
    required MorphColorScheme scheme,
  }) {
    final type = MorphTheme.of(context).typeScale;
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        key: ValueKey<String>('desktop-context-target-$id'),
        behavior: HitTestBehavior.opaque,
        onSecondaryTapDown: (details) =>
            _openContextMenu(context, title, details),
        onTap: () => setState(() {
          _lastEvent = 'Primary click on $title.';
        }),
        child: Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(22),
            border: Border.all(color: scheme.outlineVariant),
            color: scheme.surfaceContainerHigh,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Row(
                children: <Widget>[
                  Container(
                    height: 42,
                    width: 42,
                    decoration: BoxDecoration(
                      color: scheme.primaryContainer,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Icon(
                      FluentIcons.line.folder,
                      color: scheme.onPrimaryContainer,
                    ),
                  ),
                  const Gap(12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: type.titleMedium.copyWith(
                            color: scheme.onSurface,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const Gap(2),
                        Text(
                          'Target $id · secondary click test',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: type.bodySmall.copyWith(
                            color: scheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const Spacer(),
              Text(
                description,
                style: type.bodyMedium.copyWith(color: scheme.onSurfaceVariant),
              ),
              const Gap(10),
              Row(
                children: <Widget>[
                  Icon(
                    FluentIcons.line.cursor_click,
                    size: 18,
                    color: scheme.primary,
                  ),
                  const Gap(8),
                  Expanded(
                    child: Text(
                      'Right-click repeatedly here and then another card.',
                      style: type.bodySmall.copyWith(color: scheme.onSurface),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _checkRow(MorphColorScheme scheme, MorphTypeScale type, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Icon(FluentIcons.line.checkmark, size: 18, color: scheme.primary),
          const Gap(10),
          Expanded(
            child: Text(
              text,
              style: type.bodyMedium.copyWith(color: scheme.onSurfaceVariant),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = MorphTheme.of(context);
    final scheme = theme.colorScheme;
    final type = MorphTheme.of(context).typeScale;
    return Scaffold(
      backgroundColor: scheme.surface,
      appBar: AppBar(title: const Text('Desktop context menu preview')),
      body: Stack(
        children: <Widget>[
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: <Color>[
                    scheme.surface,
                    scheme.surfaceContainerLow,
                    scheme.surfaceContainerHigh,
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            top: -120,
            right: -80,
            child: IgnorePointer(
              child: Container(
                width: 260,
                height: 260,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: scheme.primary.withValues(alpha: 0.12),
                ),
              ),
            ),
          ),
          Positioned(
            left: -110,
            bottom: -120,
            child: IgnorePointer(
              child: Container(
                width: 280,
                height: 280,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: scheme.tertiary.withValues(alpha: 0.10),
                ),
              ),
            ),
          ),
          SafeArea(
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 1200),
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                Text(
                                  'Validate desktop replacement behavior',
                                  style: type.headlineSmall.copyWith(
                                    color: scheme.onSurface,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                const Gap(8),
                                Text(
                                  'Right-click Workspace A, then B, then C without clicking outside. '
                                  'The previously opened menu should be replaced immediately. '
                                  'Open a submenu and right-click another target to ensure it is dismissed cleanly.',
                                  style: type.bodyLarge.copyWith(
                                    color: scheme.onSurfaceVariant,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const Gap(16),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 14,
                              vertical: 12,
                            ),
                            decoration: BoxDecoration(
                              color: scheme.surfaceContainerHighest,
                              borderRadius: BorderRadius.circular(18),
                              border: Border.all(color: scheme.outlineVariant),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                Text(
                                  'Opens',
                                  style: type.labelMedium.copyWith(
                                    color: scheme.onSurfaceVariant,
                                  ),
                                ),
                                const Gap(4),
                                Text(
                                  '$_openCount',
                                  style: type.headlineSmall.copyWith(
                                    color: scheme.onSurface,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const Gap(20),
                      Expanded(
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: <Widget>[
                            Expanded(
                              flex: 3,
                              child: GridView.count(
                                crossAxisCount: 2,
                                mainAxisSpacing: 16,
                                crossAxisSpacing: 16,
                                childAspectRatio: 1.25,
                                children: <Widget>[
                                  _workspaceCard(
                                    context,
                                    id: 'A',
                                    title: 'Workspace A',
                                    description: 'Acts as the first target for rapid right-click replacement.',
                                    scheme: scheme,
                                  ),
                                  _workspaceCard(
                                    context,
                                    id: 'B',
                                    title: 'Workspace B',
                                    description: 'Use this one during the opening animation of another menu.',
                                    scheme: scheme,
                                  ),
                                  _workspaceCard(
                                    context,
                                    id: 'C',
                                    title: 'Workspace C',
                                    description: 'Open after a submenu is visible to validate clean replacement.',
                                    scheme: scheme,
                                  ),
                                  _workspaceCard(
                                    context,
                                    id: 'D',
                                    title: 'Workspace D',
                                    description: 'Use this target to confirm repeated clicks reposition a single menu.',
                                    scheme: scheme,
                                  ),
                                ],
                              ),
                            ),
                            const Gap(16),
                            SizedBox(
                              width: 320,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: <Widget>[
                                  Expanded(
                                    child: Container(
                                      padding: const EdgeInsets.all(18),
                                      decoration: BoxDecoration(
                                        color: scheme.surfaceContainer,
                                        borderRadius: BorderRadius.circular(22),
                                        border: Border.all(
                                          color: scheme.outlineVariant,
                                        ),
                                      ),
                                      child: SingleChildScrollView(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: <Widget>[
                                            Text(
                                              'Checklist',
                                              style: type.titleMedium.copyWith(
                                                color: scheme.onSurface,
                                                fontWeight: FontWeight.w700,
                                              ),
                                            ),
                                            const Gap(12),
                                            _checkRow(
                                              scheme,
                                              type,
                                              'A → B → C should replace the previous menu immediately.',
                                            ),
                                            _checkRow(
                                              scheme,
                                              type,
                                              'Right-clicking the same target again should reposition one active menu.',
                                            ),
                                            _checkRow(
                                              scheme,
                                              type,
                                              'Open "Move ... to" and right-click another card; the whole stack must disappear cleanly.',
                                            ),
                                            _checkRow(
                                              scheme,
                                              type,
                                              'Touch or primary click outside should dismiss, but not activate the target below until the next click.',
                                            ),
                                            const Gap(16),
                                            Text(
                                              'Last event',
                                              style: type.labelMedium.copyWith(
                                                color: scheme.onSurfaceVariant,
                                              ),
                                            ),
                                            const Gap(6),
                                            Text(
                                              _lastEvent,
                                              style: type.bodyMedium.copyWith(
                                                color: scheme.onSurface,
                                              ),
                                            ),
                                            const Gap(14),
                                            Text(
                                              'Last selection',
                                              style: type.labelMedium.copyWith(
                                                color: scheme.onSurfaceVariant,
                                              ),
                                            ),
                                            const Gap(6),
                                            Text(
                                              _lastSelection,
                                              style: type.bodyMedium.copyWith(
                                                color: scheme.onSurface,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                  const Gap(16),
                                  GestureDetector(
                                    key: const ValueKey<String>(
                                      'desktop-context-empty-zone',
                                    ),
                                    behavior: HitTestBehavior.opaque,
                                    onSecondaryTapDown: (details) {
                                      setState(() {
                                        _lastEvent =
                                            'Secondary click on empty area. '
                                            'Any open menu should close.';
                                      });
                                    },
                                    child: Container(
                                      height: 96,
                                      padding: const EdgeInsets.all(16),
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(22),
                                        border: Border.all(
                                          color: scheme.outlineVariant,
                                        ),
                                        color: scheme.surfaceContainerLow,
                                      ),
                                      child: Row(
                                        children: <Widget>[
                                          Icon(
                                            FluentIcons.line.cursor_click,
                                            color: scheme.primary,
                                          ),
                                          const Gap(12),
                                          Expanded(
                                            child: Text(
                                              'Right-click this empty area to ensure the currently opened menu closes without opening another one.',
                                              style: type.bodyMedium.copyWith(
                                                color: scheme.onSurfaceVariant,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
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
