import 'package:material_ui/material_ui.dart'
    show
        Alignment,
        BuildContext,
        EdgeInsets,
        Icon,
        Navigator,
        Padding,
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

const _path = '[Overlays]/Dialogs';

enum _DialogKind { basic, adaptive, fullScreen }

@widgetbook.UseCase(name: 'Playground', type: MorphDialog, path: _path)
Widget dialogPlaygroundUseCase(BuildContext context) {
  final kind = enumKnob<_DialogKind>(
    context,
    label: 'dialog',
    values: _DialogKind.values,
  );
  final position = enumKnob<MorphDialogPosition>(
    context,
    label: 'position',
    values: MorphDialogPosition.values,
  );
  final title = context.knobs.string(
    label: 'title',
    initialValue: 'Morph dialog',
  );
  final body = context.knobs.string(
    label: 'content',
    initialValue: 'A customizable Material 3 Expressive dialog.',
  );
  final icon = context.knobs.boolean(label: 'icon');
  final dividers = context.knobs.boolean(label: 'dividers');
  final dismissible = context.knobs.boolean(
    label: 'barrier dismissible',
    initialValue: true,
  );
  return _DialogHarness(
    kind: kind,
    position: position,
    title: title,
    body: body,
    icon: icon,
    dividers: dividers,
    dismissible: dismissible,
  );
}

class _DialogHarness extends StatefulWidget {
  const _DialogHarness({
    required this.kind,
    required this.position,
    required this.title,
    required this.body,
    required this.icon,
    required this.dividers,
    required this.dismissible,
  });

  final _DialogKind kind;
  final MorphDialogPosition position;
  final String title;
  final String body;
  final bool icon;
  final bool dividers;
  final bool dismissible;

  @override
  State<_DialogHarness> createState() => _DialogHarnessState();
}

class _DialogHarnessState extends State<_DialogHarness> {
  String _result = 'Dialog not opened yet';

  Future<void> _open() async {
    // Morph dialogs are pushed on the root navigator.
    final navigator = Navigator.of(context, rootNavigator: true);
    Object? result;
    switch (widget.kind) {
      case _DialogKind.basic:
        result = await MorphDialog.show<String>(
          context,
          position: widget.position,
          barrierDismissible: widget.dismissible,
          dialog: MorphDialog(
            title: widget.title,
            icon: widget.icon ? Icon(FluentIcons.line.info) : null,
            content: Text(widget.body),
            topDivider: widget.dividers,
            bottomDivider: widget.dividers,
            actions: [
              MorphButton.text(
                onPressed: () => navigator.pop('cancel'),
                child: const Text('Cancel'),
              ),
              MorphButton.text(
                onPressed: () => navigator.pop('confirm'),
                child: const Text('Confirm'),
              ),
            ],
          ),
        );
      case _DialogKind.adaptive:
        result = await MorphDialog.show<String>(
          context,
          position: widget.position,
          barrierDismissible: widget.dismissible,
          dialog: MorphAdaptiveDialog(
            title: widget.title,
            icon: widget.icon ? Icon(FluentIcons.line.info) : null,
            position: widget.position,
            content: Text(widget.body),
            confirmLabel: 'Done',
            onConfirm: () => navigator.pop('confirm'),
          ),
        );
      case _DialogKind.fullScreen:
        result = await MorphDialog.showFullScreen<String>(
          context,
          title: widget.title,
          confirmLabel: 'Save',
          onConfirm: () => navigator.pop('save'),
          body: Padding(
            padding: const EdgeInsets.all(20),
            child: Text(widget.body),
          ),
        );
    }
    if (mounted) setState(() => _result = 'Result: $result');
  }

  @override
  Widget build(BuildContext context) {
    return Stage(
      children: [
        MorphButton.filled(
          icon: Icon(FluentIcons.line.info),
          label: const Text('Open dialog'),
          onPressed: _open,
        ),
        DemoReadout(_result),
      ],
    );
  }
}

@widgetbook.UseCase(name: 'Dialog inset', type: MorphDialogInset, path: _path)
Widget dialogInsetUseCase(BuildContext context) {
  final alignment = context.knobs.object.dropdown<Alignment>(
    label: 'alignment',
    options: const [
      Alignment.center,
      Alignment.topCenter,
      Alignment.bottomCenter,
    ],
    labelBuilder: (a) => a.toString(),
  );
  return MorphDialogInset(
    padding: const EdgeInsets.all(24),
    alignment: alignment,
    child: const MorphDialog(
      title: 'Embedded dialog',
      content: Text('MorphDialogInset keeps this clear of edges and insets.'),
    ),
  );
}
