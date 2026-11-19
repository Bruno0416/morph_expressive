import 'package:material_ui/material_ui.dart'
    show
        BorderRadius,
        BuildContext,
        CircleAvatar,
        Column,
        EdgeInsets,
        Expanded,
        Icon,
        IconButton,
        Padding,
        Size,
        SizedBox,
        State,
        StatefulWidget,
        Text,
        Widget;
import 'package:morph_expressive/morph_expressive.dart';
import 'package:widgetbook/widgetbook.dart';
import 'package:widgetbook_annotation/widgetbook_annotation.dart' as widgetbook;

import '../../utilities/demo.dart';
import '../../utilities/knobs.dart';
import '../../utilities/stage.dart';

const _path = '[Surfaces & Content]/Lists';

@widgetbook.UseCase(name: 'Playground', type: MorphList, path: _path)
Widget listPlaygroundUseCase(BuildContext context) {
  final variant = enumKnob<MorphCardType>(
    context,
    label: 'row type',
    values: MorphCardType.values,
    initial: MorphCardType.filled,
  );
  final count = context.knobs.int.slider(
    label: 'rows',
    initialValue: 5,
    min: 1,
    max: 12,
  );
  final gap = context.knobs.double.slider(
    label: 'gap',
    initialValue: 2,
    min: 0,
    max: 16,
  );
  final outerRadius = context.knobs.double.slider(
    label: 'outer radius',
    initialValue: 24,
    min: 0,
    max: 40,
  );
  final leading = enumKnob<_Leading>(
    context,
    label: 'leading',
    values: _Leading.values,
  );
  final swipe = context.knobs.boolean(label: 'swipe actions');
  final selection = context.knobs.boolean(label: 'selection');
  final reorder = context.knobs.boolean(label: 'reorder');
  final dividers = context.knobs.boolean(label: 'dividers');
  final large = context.knobs.boolean(label: 'large leading');
  return _ListHarness(
    key: resetKey([count, reorder, selection]),
    variant: variant,
    count: count,
    gap: gap,
    outerRadius: outerRadius,
    leading: leading,
    swipe: swipe,
    selection: selection,
    reorder: reorder,
    dividers: dividers,
    large: large,
  );
}

enum _Leading { none, icon, avatar, image, video }

class _ListHarness extends StatefulWidget {
  const _ListHarness({
    super.key,
    required this.variant,
    required this.count,
    required this.gap,
    required this.outerRadius,
    required this.leading,
    required this.swipe,
    required this.selection,
    required this.reorder,
    required this.dividers,
    required this.large,
  });

  final MorphCardType variant;
  final int count;
  final double gap;
  final double outerRadius;
  final _Leading leading;
  final bool swipe;
  final bool selection;
  final bool reorder;
  final bool dividers;
  final bool large;

  @override
  State<_ListHarness> createState() => _ListHarnessState();
}

class _ListHarnessState extends State<_ListHarness> {
  String _last = 'None';
  late final List<int> _order = [for (var i = 0; i < widget.count; i++) i];

  Widget? _leading(int index) => switch (widget.leading) {
    _Leading.none => null,
    _Leading.icon => Icon(FluentIcons.line.heart),
    _Leading.avatar => MorphListAvatar(label: '${index + 1}'),
    _Leading.image => MorphListImage(child: DemoImage(index: index)),
    _Leading.video => MorphListVideo(
      large: widget.large,
      child: DemoImage(index: index),
    ),
  };

  @override
  Widget build(BuildContext context) {
    final scheme = MorphTheme.of(context).colorScheme;
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(12),
          child: DemoReadout('Last action: $_last'),
        ),
        Expanded(
          child: MorphList.scrollable(
            itemCount: _order.length,
            variant: widget.variant,
            gap: widget.gap,
            outerRadius: widget.outerRadius,
            selection: widget.selection,
            reorder: widget.reorder,
            onReorder: (from, to) => setState(() {
              final item = _order.removeAt(from);
              _order.insert(to > from ? to - 1 : to, item);
            }),
            itemBuilder: (context, index) {
              final n = _order[index] + 1;
              return MorphListItem(
                headline: 'Item $n',
                supportingText: 'Supporting text for row $n',
                overline: index == 0 ? 'Overline' : null,
                trailingText: index.isEven ? '${n}m' : null,
                leading: _leading(index),
                largeLeading: widget.large,
                showDivider: widget.dividers,
                onTap: () => setState(() => _last = 'Tapped $n'),
                swipe: widget.swipe
                    ? MorphListItemSwipe(
                        mode: MorphListSwipeMode.reveal,
                        leading: [
                          MorphListSwipeAction(
                            icon: Icon(FluentIcons.line.star),
                            tooltip: 'Favorite',
                            onPressed: () =>
                                setState(() => _last = 'Favorited $n'),
                          ),
                        ],
                        trailing: [
                          MorphListSwipeAction(
                            icon: const Icon(MorphIcons.delete),
                            tooltip: 'Delete',
                            backgroundColor: scheme.error,
                            foregroundColor: scheme.onError,
                            onPressed: () =>
                                setState(() => _last = 'Deleted $n'),
                          ),
                        ],
                      )
                    : null,
              );
            },
          ),
        ),
      ],
    );
  }
}

@widgetbook.UseCase(
  name: 'Expandable rows',
  type: MorphExpandableItem,
  path: _path,
)
Widget expandableListUseCase(BuildContext context) {
  final multiple = context.knobs.boolean(label: 'allow multiple expanded');
  return Stage(
    children: [
      MorphList(
        key: resetKey([multiple]),
        itemCount: 4,
        allowMultipleExpanded: multiple,
        initiallyExpanded: const {0},
        itemBuilder: (context, index) => MorphListItem(
          headline: 'Expandable ${index + 1}',
          supportingText: 'Tap to reveal the body',
          leading: Icon(FluentIcons.line.info),
          expanded: MorphExpandableExpanded.content(
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text('Details for row ${index + 1}.'),
            ),
          ),
        ),
      ),
    ],
  );
}

@widgetbook.UseCase(
  name: 'Building blocks',
  type: MorphListRowSurface,
  path: _path,
)
Widget listBlocksUseCase(BuildContext context) {
  return const _ListBlocks();
}

class _ListBlocks extends StatefulWidget {
  const _ListBlocks();

  @override
  State<_ListBlocks> createState() => _ListBlocksState();
}

class _ListBlocksState extends State<_ListBlocks> {
  Size _size = Size.zero;
  String _activated = 'None';

  @override
  Widget build(BuildContext context) {
    return Stage(
      children: [
        StageSection(
          title: 'MorphListRowSurface',
          child: SizedBox(
            width: 360,
            child: MorphListRowSurface(
              radius: BorderRadius.circular(20),
              onTap: () {},
              padding: const EdgeInsets.all(16),
              child: const Text('A bare row surface'),
            ),
          ),
        ),
        StageSection(
          title: 'MorphMeasureSize',
          note: 'Reports its child size: $_size',
          child: MorphMeasureSize(
            onChange: (size) {
              if (size != _size) setState(() => _size = size);
            },
            child: const Padding(
              padding: EdgeInsets.all(16),
              child: Text('Measured child'),
            ),
          ),
        ),
        StageSection(
          title: 'MorphListKeyboardGroup and MorphListKeyTarget',
          note:
              'Arrow keys move between targets; Enter activates ($_activated).',
          child: SizedBox(
            width: 360,
            child: MorphListKeyboardGroup(
              itemCount: 3,
              semanticsLabel: 'Keyboard list',
              child: Column(
                children: [
                  for (var i = 0; i < 3; i++)
                    MorphListKeyTarget(
                      index: i,
                      onActivate: () =>
                          setState(() => _activated = 'row ${i + 1}'),
                      child: MorphListItem(
                        headline: 'Keyboard row ${i + 1}',
                        onTap: () =>
                            setState(() => _activated = 'row ${i + 1}'),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

@widgetbook.UseCase(name: 'Selection mode', type: MorphSelection, path: _path)
Widget selectionModeUseCase(BuildContext context) {
  final count = context.knobs.int.slider(
    label: 'rows',
    initialValue: 6,
    min: 2,
    max: 20,
  );
  return MorphSelection(
    key: resetKey([count]),
    itemCount: count,
    scaffold: false,
    appBar: MorphSelectionAppBar(
      idle: const Padding(
        padding: EdgeInsets.symmetric(horizontal: 18, vertical: 20),
        child: Text('Select rows below'),
      ),
      actions: [
        IconButton(
          tooltip: 'Delete',
          onPressed: () {},
          icon: const Icon(MorphIcons.delete),
        ),
      ],
    ),
    body: Padding(
      padding: const EdgeInsets.all(12),
      child: MorphList.scrollable(
        itemCount: count,
        selection: true,
        itemBuilder: (_, i) =>
            MorphListItem(headline: 'Selectable item ${i + 1}'),
      ),
    ),
  );
}

@widgetbook.UseCase(
  name: 'Selection flip',
  type: MorphSelectionFlip,
  path: _path,
)
Widget selectionFlipUseCase(BuildContext context) {
  return const _FlipHarness();
}

class _FlipHarness extends StatefulWidget {
  const _FlipHarness();

  @override
  State<_FlipHarness> createState() => _FlipHarnessState();
}

class _FlipHarnessState extends State<_FlipHarness> {
  bool _selected = false;

  @override
  Widget build(BuildContext context) {
    final scheme = MorphTheme.of(context).colorScheme;
    return Stage(
      children: [
        StageSection(
          title: 'MorphSelectionFlip',
          child: MorphSelectionFlip(
            selected: _selected,
            onTap: () => setState(() => _selected = !_selected),
            selectedChild: CircleAvatar(
              backgroundColor: scheme.primary,
              child: Icon(
                FluentIcons.filled.checkmark,
                color: scheme.onPrimary,
              ),
            ),
            child: const CircleAvatar(child: Text('A')),
          ),
        ),
        StageSection(
          title: 'MorphSelectionLeading',
          child: MorphSelectionLeading(
            selected: _selected,
            onTap: () => setState(() => _selected = !_selected),
            selectedChild: Icon(FluentIcons.filled.checkmark),
            child: Icon(FluentIcons.line.person),
          ),
        ),
        DemoReadout('Selected: $_selected'),
      ],
    );
  }
}
