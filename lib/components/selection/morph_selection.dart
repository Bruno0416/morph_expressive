import 'package:material_ui/material_ui.dart';

import '../../foundations/foundations.dart';
import 'components/morph_selection_app_bar.dart';
import 'components/morph_selection_scope.dart';
import 'controllers/morph_selection_controller.dart';

export 'components/morph_selection_app_bar.dart';
export 'components/morph_selection_flip.dart';
export 'components/morph_selection_leading.dart';
export 'components/morph_selection_scope.dart';
export 'controllers/morph_selection_controller.dart';
export 'styles/morph_selection_theme.dart';

/// Host widget that wires [MorphSelectionAppBar] and any list [body] to one
/// [MorphSelectionController].
///
/// Prefer wrapping the route with [PopScope] so system back clears selection
/// instead of popping:
///
/// ```dart
/// PopScope(
///   canPop: !controller.isSelectionMode,
///   onPopInvokedWithResult: (didPop, _) {
///     if (!didPop) controller.clear();
///   },
///   child: MorphSelection(
///     controller: controller,
///     itemCount: items.length,
///     appBar: MorphSelectionAppBar(...),
///     body: MorphList.scrollable(...),
///   ),
/// )
/// ```
class MorphSelection extends StatefulWidget {
  /// Creates a selection host.
  const MorphSelection({
    required this.appBar,
    required this.body,
    required this.itemCount,
    this.controller,
    this.scaffold = true,
    this.backgroundColor,
    this.selectedColor,
    this.resizeToAvoidBottomInset,
    super.key,
  });

  /// Idle / contextual app bar wrapper.
  final MorphSelectionAppBar appBar;

  /// Any list body (card list, dismissible list, etc.).
  final Widget body;

  /// Item count for select-all / [MorphSelectionScope].
  final int itemCount;

  /// Optional external controller. When null, one is owned internally.
  final MorphSelectionController? controller;

  /// When true (default), builds a scaffold whose body is header + list.
  /// The selection header is not placed in the scaffold app-bar slot so idle
  /// can be any intrinsic-height widget. Set false to embed under a host scaffold.
  final bool scaffold;

  /// Scaffold background color when [scaffold] is true.
  final Color? backgroundColor;

  /// Fill used for selected list items. Overrides the selection theme highlight.
  final Color? selectedColor;

  /// Forwarded to [Scaffold.resizeToAvoidBottomInset].
  final bool? resizeToAvoidBottomInset;

  @override
  State<MorphSelection> createState() => _MorphSelectionState();
}

class _MorphSelectionState extends State<MorphSelection> {
  MorphSelectionController? _owned;
  late MorphSelectionController _controller;

  @override
  void initState() {
    super.initState();
    _bindController();
  }

  @override
  void didUpdateWidget(MorphSelection oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.controller != widget.controller) {
      _bindController();
      setState(() {});
    }
  }

  void _bindController() {
    final MorphSelectionController? external = widget.controller;
    if (external != null) {
      if (_owned != null) {
        _owned!.dispose();
        _owned = null;
      }
      _controller = external;
    } else if (_owned == null) {
      _owned = MorphSelectionController();
      _controller = _owned!;
    } else {
      _controller = _owned!;
    }
  }

  @override
  void dispose() {
    _owned?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final MorphSelectionAppBar wiredBar = widget.appBar.copyWithWiring(
      controller: _controller,
      itemCount: widget.appBar.itemCount ?? widget.itemCount,
    );

    return ListenableBuilder(
      listenable: _controller,
      builder: (BuildContext context, Widget? _) {
        final Widget content = Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            wiredBar,
            Expanded(child: widget.body),
          ],
        );
        Widget hosted = MorphSelectionScope(
          controller: _controller,
          itemCount: widget.itemCount,
          child: widget.scaffold
              ? Scaffold(
                  backgroundColor: widget.backgroundColor,
                  resizeToAvoidBottomInset: widget.resizeToAvoidBottomInset,
                  body: content,
                )
              : content,
        );
        final Color? selectedColor = widget.selectedColor;
        if (selectedColor != null) {
          final MorphThemeData theme = MorphTheme.of(context);
          hosted = MorphTheme(
            data: theme.copyWith(
              selectionTheme: theme.selectionTheme.copyWith(
                highlightColor: selectedColor,
              ),
            ),
            child: hosted,
          );
        }
        return hosted;
      },
    );
  }
}
