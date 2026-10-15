import 'package:flutter/widgets.dart';

import '../../../foundations/foundations.dart';
import '../../checkbox/morph_checkbox.dart';
import '../../icon_buttons/morph_icon_buttons.dart';
import '../controllers/morph_selection_controller.dart';
import '../styles/morph_selection_theme.dart';
import 'morph_selection_scope.dart';

/// Wraps an idle header widget and swaps to a contextual selection bar.
///
/// [idle] may be any widget (e.g. an app bar, or a column of header content).
/// Height is intrinsic — place this above the list body (see MorphSelection),
/// not in a scaffold app-bar slot, so arbitrary idle heights do not overflow.
class MorphSelectionAppBar extends StatefulWidget {
  /// Creates a selection app bar wrapper.
  const MorphSelectionAppBar({
    required this.idle,
    this.controller,
    this.itemCount,
    this.actions = const <Widget>[],
    this.selectAllLabel = 'Select all',
    this.showSelectAll = true,
    this.onClear,
    this.onAllSelected,
    this.theme,
    super.key,
  });

  /// Shown when nothing is selected. Any widget; height is intrinsic.
  final Widget idle;

  /// Selection controller. Optional under [MorphSelectionScope].
  final MorphSelectionController? controller;

  /// Item count for select-all. Optional under [MorphSelectionScope].
  final int? itemCount;

  /// Contextual action widgets (typically [MorphIconButton]s).
  final List<Widget> actions;

  /// Label beside the select-all checkbox.
  final String selectAllLabel;

  /// Whether to show the select-all row in selection mode.
  final bool showSelectAll;

  /// Called instead of [MorphSelectionController.clear] when close is pressed.
  final VoidCallback? onClear;

  /// Fired when select-all toggles (`true` = all selected).
  final ValueChanged<bool>? onAllSelected;

  /// Theme override.
  final MorphSelectionTheme? theme;

  /// Returns a copy with an injected controller and optional [itemCount].
  MorphSelectionAppBar copyWithWiring({
    MorphSelectionController? controller,
    int? itemCount,
    ValueChanged<bool>? onAllSelected,
  }) {
    return MorphSelectionAppBar(
      key: key,
      idle: idle,
      controller: controller ?? this.controller,
      itemCount: itemCount ?? this.itemCount,
      actions: actions,
      selectAllLabel: selectAllLabel,
      showSelectAll: showSelectAll,
      onClear: onClear,
      onAllSelected: onAllSelected ?? this.onAllSelected,
      theme: theme,
    );
  }

  @override
  State<MorphSelectionAppBar> createState() => _MorphSelectionAppBarState();
}

class _MorphSelectionAppBarState extends State<MorphSelectionAppBar> {
  MorphSelectionController? _listened;

  MorphSelectionController _resolveController(BuildContext context) {
    final MorphSelectionController? explicit = widget.controller;
    if (explicit != null) {
      return explicit;
    }
    final MorphSelectionScope? scope = MorphSelectionScope.maybeOf(context);
    assert(
      scope != null,
      'MorphSelectionAppBar requires a controller or an MorphSelectionScope ancestor.',
    );
    return scope!.controller;
  }

  int _resolveItemCount(BuildContext context) {
    if (widget.itemCount != null) {
      return widget.itemCount!;
    }
    final MorphSelectionScope? scope = MorphSelectionScope.maybeOf(context);
    assert(
      scope != null,
      'MorphSelectionAppBar requires itemCount or an MorphSelectionScope ancestor.',
    );
    return scope!.itemCount;
  }

  void _attach(MorphSelectionController controller) {
    if (_listened == controller) {
      return;
    }
    _listened?.removeListener(_onChanged);
    _listened = controller;
    _listened!.addListener(_onChanged);
  }

  void _onChanged() {
    if (mounted) {
      setState(() {});
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _attach(_resolveController(context));
  }

  @override
  void didUpdateWidget(MorphSelectionAppBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    _attach(_resolveController(context));
  }

  @override
  void dispose() {
    _listened?.removeListener(_onChanged);
    super.dispose();
  }

  MorphSelectionTheme _theme(BuildContext context) {
    return widget.theme ?? MorphTheme.of(context).selectionTheme;
  }

  void _clear(MorphSelectionController controller) {
    final VoidCallback? onClear = widget.onClear;
    if (onClear != null) {
      onClear();
    } else {
      controller.clear();
    }
  }

  void _toggleSelectAll(MorphSelectionController controller, int itemCount) {
    final bool? all = controller.allSelectedFor(itemCount);
    if (all ?? false) {
      controller.clear();
      widget.onAllSelected?.call(false);
    } else {
      controller.selectAll(itemCount);
      widget.onAllSelected?.call(true);
    }
  }

  /// Leading/trailing action slot width (MorphIconButton sm target).
  static const double _actionSlot = 48;

  Widget _buildContextualToolbar({
    required MorphThemeData theme,
    required Color foreground,
    required EdgeInsets appBarPad,
    required double titleGap,
    required MorphSelectionController controller,
  }) {
    // NavigationToolbar expands to max height — must be bounded (Column /
    // AnimatedSize pass infinite max height). Band matches the idle app bar;
    // overall header height still varies with select-all / idle content.
    return SizedBox(
      height: theme.appBarTheme.smallHeight,
      child: Padding(
        padding: appBarPad,
        child: NavigationToolbar(
          middleSpacing: titleGap,
          leading: MorphIconButton(
            variant: MorphIconButtonVariant.standard,
            icon: Icon(MorphIcons.close, color: foreground),
            onPressed: () => _clear(controller),
            tooltip: 'Clear selection',
            semanticLabel: 'Clear selection',
          ),
          centerMiddle: false,
          middle: Align(
            alignment: AlignmentDirectional.centerStart,
            child: Text(
              '${controller.selectedCount}',
              style: theme.typeScale.titleLarge.copyWith(color: foreground),
            ),
          ),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: widget.actions,
          ),
        ),
      ),
    );
  }

  Widget? _buildSelectAllRow({
    required MorphThemeData theme,
    required MorphSelectionTheme selectionTheme,
    required Color foreground,
    required EdgeInsets appBarPad,
    required double titleGap,
    required MorphSelectionController controller,
    required int itemCount,
  }) {
    if (!widget.showSelectAll) {
      return null;
    }
    // Match toolbar: same contentPadding + 48dp leading slot (like close /
    // trailing icon buttons) and titleGap before the label.
    return Padding(
      padding: EdgeInsets.only(
        left: appBarPad.left,
        right: appBarPad.right,
        bottom: appBarPad.bottom,
      ),
      child: SizedBox(
        height: selectionTheme.selectAllHeight,
        child: Row(
          children: <Widget>[
            SizedBox(
              width: _actionSlot,
              child: Center(
                child: MorphCheckbox(
                  tristate: true,
                  value: controller.allSelectedFor(itemCount),
                  onChanged: (_) => _toggleSelectAll(controller, itemCount),
                  semanticLabel: widget.selectAllLabel,
                ),
              ),
            ),
            SizedBox(width: titleGap),
            Expanded(
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () => _toggleSelectAll(controller, itemCount),
                child: Align(
                  alignment: AlignmentDirectional.centerStart,
                  child: Text(
                    widget.selectAllLabel,
                    style: theme.typeScale.bodyLarge.copyWith(
                      color: foreground,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContextual(BuildContext context) {
    final MorphThemeData theme = MorphTheme.of(context);
    final MorphColorScheme scheme = theme.colorScheme;
    final MorphSelectionTheme selectionTheme = _theme(context);
    final MorphSelectionController controller = _resolveController(context);
    final int itemCount = _resolveItemCount(context);
    final Color foreground = selectionTheme.contextualForeground(scheme);
    final EdgeInsets appBarPad = theme.appBarTheme.contentPadding.resolve(
      Directionality.of(context),
    );
    final double titleGap = theme.appBarTheme.titleGap;

    return ColoredBox(
      color: selectionTheme.contextualBackground(scheme),
      child: Padding(
        padding: EdgeInsets.only(top: MorphSafeArea.topOf(context)),
        child: IconTheme.merge(
          data: IconThemeData(color: foreground),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              _buildContextualToolbar(
                theme: theme,
                foreground: foreground,
                appBarPad: appBarPad,
                titleGap: titleGap,
                controller: controller,
              ),
              ?_buildSelectAllRow(
                theme: theme,
                selectionTheme: selectionTheme,
                foreground: foreground,
                appBarPad: appBarPad,
                titleGap: titleGap,
                controller: controller,
                itemCount: itemCount,
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final MorphSelectionController controller = _resolveController(context);
    _attach(controller);

    // AnimatedSize tracks the active child height. Switcher layout only sizes
    // to the current child; exiting children are overlayed so they do not
    // force a taller slot (avoids overflow when heights differ).
    return AnimatedSize(
      duration: MorphMotion.selectionFlip,
      reverseDuration: MorphMotion.selectionExit,
      curve: const Cubic(0.2, 0, 0, 1),
      alignment: Alignment.topCenter,
      child: AnimatedSwitcher(
        duration: MorphMotion.selectionFlip,
        reverseDuration: MorphMotion.selectionExit,
        switchInCurve: const Cubic(0.2, 0, 0, 1),
        switchOutCurve: const Cubic(0.4, 0, 1, 1),
        layoutBuilder: (Widget? currentChild, List<Widget> previousChildren) {
          return Stack(
            children: <Widget>[
              for (final Widget previous in previousChildren)
                Positioned(
                  top: 0,
                  left: 0,
                  right: 0,
                  child: IgnorePointer(child: previous),
                ),
              ?currentChild,
            ],
          );
        },
        transitionBuilder: (Widget child, Animation<double> animation) {
          final Animation<double> scale = Tween<double>(
            begin: 0.95,
            end: 1,
          ).animate(animation);
          return FadeTransition(
            opacity: animation,
            child: ScaleTransition(scale: scale, child: child),
          );
        },
        child: KeyedSubtree(
          key: ValueKey<bool>(controller.isSelectionMode),
          child: controller.isSelectionMode
              ? _buildContextual(context)
              : widget.idle,
        ),
      ),
    );
  }
}
