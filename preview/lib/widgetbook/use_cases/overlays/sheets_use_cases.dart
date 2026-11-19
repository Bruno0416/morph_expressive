import 'package:material_ui/material_ui.dart'
    show
        BuildContext,
        Builder,
        Center,
        Colors,
        Column,
        CrossAxisAlignment,
        EdgeInsets,
        Icon,
        MainAxisSize,
        Navigator,
        Padding,
        Scaffold,
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

@widgetbook.UseCase(
  name: 'Modal',
  type: MorphBottomSheet,
  path: '[Overlays]/Bottom sheets',
)
Widget bottomSheetModalUseCase(BuildContext context) {
  final handle = context.knobs.boolean(
    label: 'drag handle',
    initialValue: true,
  );
  final drag = context.knobs.boolean(label: 'enable drag', initialValue: true);
  final dismissible = context.knobs.boolean(
    label: 'dismissible',
    initialValue: true,
  );
  final fullScreen = context.knobs.boolean(label: 'expand to full screen');
  final initial = enumKnob<MorphBottomSheetValue>(
    context,
    label: 'initial value',
    values: MorphBottomSheetValue.values,
    initial: MorphBottomSheetValue.collapsed,
  );
  return Stage(
    children: [
      MorphButton.filled(
        icon: Icon(FluentIcons.line.arrow_up),
        label: const Text('Open bottom sheet'),
        onPressed: () => MorphBottomSheet.show<void>(
          context,
          useRootNavigator: false,
          showDragHandle: handle,
          enableDrag: drag,
          isDismissible: dismissible,
          expandToFullScreen: fullScreen,
          fullScreenTitle: 'Expanded sheet',
          initialValue: initial,
          builder: (sheetContext) => Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Morph bottom sheet',
                  style: MorphTheme.of(sheetContext).textTheme.titleLarge,
                ),
                const SizedBox(height: 12),
                const Text('Drag down or press Close to dismiss.'),
                const SizedBox(height: 20),
                MorphButton.filled(
                  onPressed: () => Navigator.of(sheetContext).pop(),
                  label: const Text('Close'),
                ),
              ],
            ),
          ),
        ),
      ),
    ],
  );
}

@widgetbook.UseCase(
  name: 'Standard (persistent)',
  type: MorphBottomSheet,
  path: '[Overlays]/Bottom sheets',
)
Widget bottomSheetStandardUseCase(BuildContext context) {
  final handle = context.knobs.boolean(
    label: 'drag handle',
    initialValue: true,
  );
  final fullScreen = context.knobs.boolean(label: 'expand to full screen');
  return Scaffold(
    backgroundColor: Colors.transparent,
    body: const Center(child: DemoReadout('Drag the sheet at the bottom')),
    bottomSheet: MorphBottomSheet.standard(
      key: resetKey([handle, fullScreen]),
      showDragHandle: handle,
      expandToFullScreen: fullScreen,
      fullScreenTitle: 'Expanded',
      initialValue: MorphBottomSheetValue.preview,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            for (var i = 0; i < 4; i++)
              MorphListItem(headline: 'Sheet row ${i + 1}'),
          ],
        ),
      ),
    ),
  );
}

@widgetbook.UseCase(
  name: 'Modal',
  type: MorphSideSheet,
  path: '[Overlays]/Side sheets',
)
Widget sideSheetModalUseCase(BuildContext context) {
  final edge = enumKnob<MorphSideSheetEdge>(
    context,
    label: 'edge',
    values: MorphSideSheetEdge.values,
    initial: MorphSideSheetEdge.end,
  );
  final detached = context.knobs.boolean(label: 'detached');
  final scrollable = context.knobs.boolean(label: 'scrollable');
  final close = context.knobs.boolean(
    label: 'close button',
    initialValue: true,
  );
  final divider = context.knobs.boolean(label: 'divider');
  final width = context.knobs.double.slider(
    label: 'width',
    initialValue: 360,
    min: 240,
    max: 520,
  );
  return Stage(
    children: [
      MorphButton.filled(
        label: const Text('Open side sheet'),
        onPressed: () => MorphSideSheet.show<void>(
          context,
          useRootNavigator: false,
          title: 'Morph side sheet',
          edge: edge,
          detached: detached,
          scrollable: scrollable,
          showCloseButton: close,
          showDivider: divider,
          width: width,
          actions: [
            Builder(
              builder: (sheetContext) => MorphButton.filled(
                onPressed: () => Navigator.of(sheetContext).pop(),
                label: const Text('Save'),
              ),
            ),
          ],
          body: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                for (var i = 0; i < (scrollable ? 30 : 4); i++)
                  Text('Secondary content line ${i + 1}'),
              ],
            ),
          ),
        ),
      ),
    ],
  );
}

@widgetbook.UseCase(
  name: 'Layout',
  type: MorphSideSheetLayout,
  path: '[Overlays]/Side sheets',
)
Widget sideSheetLayoutUseCase(BuildContext context) {
  final mode = enumKnob<MorphSideSheetLayoutMode>(
    context,
    label: 'mode',
    values: MorphSideSheetLayoutMode.values,
  );
  return _SideSheetLayoutHarness(key: resetKey([mode]), mode: mode);
}

class _SideSheetLayoutHarness extends StatefulWidget {
  const _SideSheetLayoutHarness({super.key, required this.mode});

  final MorphSideSheetLayoutMode mode;

  @override
  State<_SideSheetLayoutHarness> createState() =>
      _SideSheetLayoutHarnessState();
}

class _SideSheetLayoutHarnessState extends State<_SideSheetLayoutHarness> {
  final MorphSideSheetController _controller = MorphSideSheetController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MorphSideSheetLayout(
      controller: _controller,
      mode: widget.mode,
      initiallyOpen: true,
      body: Center(
        child: MorphButton.tonal(
          onPressed: () =>
              _controller.isOpen ? _controller.close() : _controller.open(),
          label: const Text('Toggle side sheet'),
        ),
      ),
      sheet: MorphSideSheet(
        title: 'Inline sheet',
        onClose: () => _controller.close(),
        body: const Padding(
          padding: EdgeInsets.all(20),
          child: Text('Docked beside the content on wide windows.'),
        ),
      ),
    );
  }
}
