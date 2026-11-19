import 'package:material_ui/material_ui.dart'
    show
        AlwaysScrollableScrollPhysics,
        BuildContext,
        ListView,
        State,
        StatefulWidget,
        Text,
        Widget;
import 'package:morph_expressive/morph_expressive.dart';
import 'package:widgetbook/widgetbook.dart';
import 'package:widgetbook_annotation/widgetbook_annotation.dart' as widgetbook;

import '../../../operation_loading_lab.dart';
import '../../utilities/demo.dart';
import '../../utilities/knobs.dart';
import '../../utilities/stage.dart';

enum _RefreshKind { standard, contained, material, adaptive, noSpinner }

@widgetbook.UseCase(
  name: 'Playground',
  type: MorphRefreshIndicator,
  path: '[Feedback]/Refresh indicator',
)
Widget refreshIndicatorUseCase(BuildContext context) {
  final kind = enumKnob<_RefreshKind>(
    context,
    label: 'constructor',
    values: _RefreshKind.values,
  );
  final trigger = enumKnob<MorphRefreshTriggerMode>(
    context,
    label: 'trigger mode',
    values: MorphRefreshTriggerMode.values,
    initial: MorphRefreshTriggerMode.onEdge,
  );
  final delay = context.knobs.int.slider(
    label: 'refresh duration (ms)',
    initialValue: 1200,
    min: 200,
    max: 4000,
  );
  return _RefreshHarness(
    key: resetKey([kind]),
    kind: kind,
    trigger: trigger,
    delay: Duration(milliseconds: delay),
  );
}

class _RefreshHarness extends StatefulWidget {
  const _RefreshHarness({
    super.key,
    required this.kind,
    required this.trigger,
    required this.delay,
  });

  final _RefreshKind kind;
  final MorphRefreshTriggerMode trigger;
  final Duration delay;

  @override
  State<_RefreshHarness> createState() => _RefreshHarnessState();
}

class _RefreshHarnessState extends State<_RefreshHarness> {
  int _refreshes = 0;

  Future<void> _refresh() async {
    await Future<void>.delayed(widget.delay);
    if (mounted) setState(() => _refreshes++);
  }

  @override
  Widget build(BuildContext context) {
    final list = ListView.builder(
      physics: const AlwaysScrollableScrollPhysics(),
      itemCount: 20,
      itemBuilder: (_, i) => MorphListItem(
        headline: 'Pull to refresh (${i + 1})',
        supportingText: 'Refreshed $_refreshes times',
      ),
    );
    final indicator = switch (widget.kind) {
      _RefreshKind.standard => MorphRefreshIndicator(
        onRefresh: _refresh,
        triggerMode: widget.trigger,
        child: list,
      ),
      _RefreshKind.contained => MorphRefreshIndicator.contained(
        onRefresh: _refresh,
        triggerMode: widget.trigger,
        child: list,
      ),
      _RefreshKind.material => MorphRefreshIndicator.material(
        onRefresh: _refresh,
        triggerMode: widget.trigger,
        child: list,
      ),
      _RefreshKind.adaptive => MorphRefreshIndicator.adaptive(
        onRefresh: _refresh,
        triggerMode: widget.trigger,
        child: list,
      ),
      _RefreshKind.noSpinner => MorphRefreshIndicator.noSpinner(
        onRefresh: _refresh,
        triggerMode: widget.trigger,
        child: list,
      ),
    };
    return indicator;
  }
}

@widgetbook.UseCase(
  name: 'Playground',
  type: MorphSnackbar,
  path: '[Feedback]/Snackbar',
)
Widget snackbarUseCase(BuildContext context) {
  final message = context.knobs.string(
    label: 'message',
    initialValue: 'Saved successfully',
  );
  final action = context.knobs.string(
    label: 'action label',
    initialValue: 'Undo',
  );
  final close = context.knobs.boolean(label: 'close button');
  final swipe = context.knobs.boolean(label: 'swipe dismissible');
  final seconds = context.knobs.int.slider(
    label: 'duration (s, 0 = default)',
    initialValue: 0,
    min: 0,
    max: 10,
  );
  return _SnackbarHarness(
    message: message,
    action: action,
    close: close,
    swipe: swipe,
    duration: seconds == 0 ? null : Duration(seconds: seconds),
  );
}

class _SnackbarHarness extends StatefulWidget {
  const _SnackbarHarness({
    required this.message,
    required this.action,
    required this.close,
    required this.swipe,
    required this.duration,
  });

  final String message;
  final String action;
  final bool close;
  final bool swipe;
  final Duration? duration;

  @override
  State<_SnackbarHarness> createState() => _SnackbarHarnessState();
}

class _SnackbarHarnessState extends State<_SnackbarHarness> {
  String _log = 'No action yet';

  @override
  Widget build(BuildContext context) {
    return Stage(
      children: [
        MorphButton.filled(
          label: const Text('Show snackbar'),
          onPressed: () => MorphSnackbar.show(
            context,
            message: widget.message,
            actionLabel: widget.action.isEmpty ? null : widget.action,
            onAction: () => setState(() => _log = 'Action pressed'),
            showCloseButton: widget.close,
            swipeDismissible: widget.swipe,
            duration: widget.duration,
            onClose: () => setState(() => _log = 'Closed'),
          ),
        ),
        DemoReadout(_log),
      ],
    );
  }
}

@widgetbook.UseCase(
  name: 'Operation and skeleton lab',
  type: MorphSkeletonGroup,
  path: '[Feedback]/Skeleton',
)
Widget operationLabUseCase(BuildContext context) => const OperationLoadingLab();
