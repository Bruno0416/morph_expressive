// Derived from Material 3 Expressive by Paa Developments (MIT), modified
// in 2026 for Morph Expressive (naming, layout, styling and/or motion).
// Follows Material 3 Compose design/reference patterns; direct inclusion
// of Android Open Source Project Apache-2.0 code is not established here.
// See NOTICE for original copyright and third-party attribution.

import 'package:flutter/widgets.dart';
import 'package:morph_expressive/components/toolbars/morph_toolbars.dart'
    show MorphToolbar;
import 'package:morph_expressive/morph_components.dart' show MorphToolbar;

import '../../../foundations/foundations.dart';
import '../../icon_buttons/enums/morph_icon_button_enums.dart';
import '../enums/morph_toolbar_enums.dart';
import '../models/morph_toolbar_item.dart';
import '../utils/morph_toolbar_item_layout.dart';
import 'morph_toolbar_icon_button.dart';
import 'morph_toolbar_overflow_menu.dart';

/// Inline and overflow actions for [MorphToolbar].
///
/// Used for docked bars and non-expanding floating layouts. Expand-trigger
/// styling is ignored here — all actions render as standard icon buttons.
class MorphToolbarActionsRow extends StatelessWidget {
  /// MorphToolbarActionsRow.
  const MorphToolbarActionsRow({
    required this.actions,
    required this.maxInline,
    required this.overflowIcon,
    required this.iconButtonSize,
    required this.overflowTextStyle,
    required this.destructiveColor,
    required this.availableExtent,
    this.gap = 0,
    this.opticalInset = 0,
    this.axis = Axis.horizontal,
    this.expand = false,
    this.mainAxisAlignment = MainAxisAlignment.start,
    this.pillActiveSpring = true,
    this.flexibleDockedGap = false,
    this.compact = false,
    this.contentAlignment = MorphToolbarContentAlignment.even,
    this.preferredGap = 32,
    this.minGap = 4,
    this.centeredGap = 8,
    this.slotExtent = 48,
    this.shape = MorphIconButtonShapeVariant.round,
    this.colorStyle = MorphToolbarColorStyle.standard,
    super.key,
  });

  /// actions.

  final List<MorphToolbarItem> actions;

  /// maxInline.
  final int maxInline;

  /// overflowIcon.
  final Widget overflowIcon;

  /// iconButtonSize.
  final MorphIconButtonSize iconButtonSize;

  /// overflowTextStyle.
  final TextStyle overflowTextStyle;

  /// destructiveColor.
  final Color destructiveColor;

  /// Remaining cross-axis size after bar content padding.
  final double availableExtent;

  /// Space between consecutive inline items (actions, widgets, overflow).
  final double gap;

  /// Icon-button target overhang; applied to widget slots for optical parity.
  final double opticalInset;

  /// axis.
  final Axis axis;

  /// When true, the row fills the cross-axis parent's main-axis extent.
  final bool expand;

  /// mainAxisAlignment.
  final MainAxisAlignment mainAxisAlignment;

  /// When false, reserves a fixed pill width for labeled selection (widest
  /// labeled action + icon-only neighbors) and distributes leftover space
  /// evenly between actions.
  final bool pillActiveSpring;

  /// Docked icons-only: gap prefers [preferredGap] and shrinks to [minGap].
  final bool flexibleDockedGap;

  /// Window is below the compact breakpoint, so alignment stays even.
  final bool compact;

  /// contentAlignment.
  final MorphToolbarContentAlignment contentAlignment;

  /// preferredGap.
  final double preferredGap;

  /// minGap.
  final double minGap;

  /// centeredGap.
  final double centeredGap;

  /// Laid-out width of one icon action, used to clamp the docked gap.
  final double slotExtent;

  /// shape.
  final MorphIconButtonShapeVariant shape;

  /// colorStyle.
  final MorphToolbarColorStyle colorStyle;

  @override
  Widget build(BuildContext context) {
    if (actions.isEmpty) {
      return const SizedBox.shrink();
    }

    final Widget? fittedDockedRow = _maybeBuildFittedDockedRow();
    if (fittedDockedRow != null) {
      return fittedDockedRow;
    }

    final partitioned = MorphToolbarItemLayout.partitionInline(
      items: actions,
      maxInline: maxInline,
    );
    final List<MorphToolbarItem> inline = partitioned.inline;
    final List<MorphToolbarAction> overflow = partitioned.overflow;
    final List<Widget> slots = _buildInlineSlots(inline, overflow);

    // Fixed-pill selection keeps theme [gap] inside the reserved width and
    // distributes leftover space evenly between slots (no trailing dead zone).
    final double? reservedWidth = _reservedSelectionWidth(
      context: context,
      inline: inline,
      hasOverflow: overflow.isNotEmpty,
    );
    final evenlySpace = reservedWidth != null;
    final List<Widget> children = _applyInlineGaps(slots, evenlySpace);

    if (flexibleDockedGap && reservedWidth == null && axis == Axis.horizontal) {
      return LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) {
          return _dockedRow(slots, constraints.maxWidth);
        },
      );
    }

    final Widget content = _buildAlignedContent(children, evenlySpace);
    if (reservedWidth == null) {
      return content;
    }
    return SizedBox(width: reservedWidth, child: content);
  }

  /// Fast path for icon-only docked rows: fits inline actions to the
  /// available width instead of laying out with a fixed [maxInline].
  Widget? _maybeBuildFittedDockedRow() {
    final bool iconsOnly = actions.every(
      (MorphToolbarItem item) => item is MorphToolbarAction,
    );
    if (!(flexibleDockedGap &&
        iconsOnly &&
        pillActiveSpring &&
        axis == Axis.horizontal)) {
      return null;
    }
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        return _fittedDockedRow(constraints.maxWidth);
      },
    );
  }

  List<Widget> _buildInlineSlots(
    List<MorphToolbarItem> inline,
    List<MorphToolbarAction> overflow,
  ) {
    return <Widget>[
      for (final MorphToolbarItem item in inline)
        _buildSlot(
          item: item,
          availableExtent: availableExtent,
          opticalInset: opticalInset,
          iconButtonSize: iconButtonSize,
          expandWidgets: expand,
        ),
      if (overflow.isNotEmpty)
        MorphToolbarOverflowMenu(
          actions: overflow,
          icon: overflowIcon,
          iconButtonSize: iconButtonSize,
          textStyle: overflowTextStyle,
          destructiveColor: destructiveColor,
          shape: shape,
        ),
    ];
  }

  List<Widget> _applyInlineGaps(List<Widget> slots, bool evenlySpace) {
    final bool insertGaps =
        gap > 0 &&
        !evenlySpace &&
        mainAxisAlignment != MainAxisAlignment.spaceBetween;
    return insertGaps
        ? MorphToolbarItemLayout.withGaps(slots, gap: gap, axis: axis)
        : slots;
  }

  Widget _buildAlignedContent(List<Widget> children, bool evenlySpace) {
    final MainAxisAlignment alignment = evenlySpace
        ? MainAxisAlignment.spaceBetween
        : mainAxisAlignment;
    final MainAxisSize mainAxisSize = expand || evenlySpace
        ? MainAxisSize.max
        : MainAxisSize.min;
    if (axis == Axis.vertical) {
      return Column(
        mainAxisSize: mainAxisSize,
        mainAxisAlignment: alignment,
        children: children,
      );
    }
    return Row(
      mainAxisSize: mainAxisSize,
      mainAxisAlignment: alignment,
      children: children,
    );
  }

  double? _reservedSelectionWidth({
    required BuildContext context,
    required List<MorphToolbarItem> inline,
    required bool hasOverflow,
  }) {
    if (pillActiveSpring) {
      return null;
    }
    final theme = MorphTheme.of(context);
    final iconTheme = theme.iconButtonTheme;
    final Size visual = iconTheme.visual(
      iconButtonSize,
      MorphIconButtonWidth.defaultWidth,
    );
    final Size target = iconTheme.target(
      iconButtonSize,
      MorphIconButtonWidth.defaultWidth,
    );
    final double iconSlot = visual.width > target.width
        ? visual.width
        : target.width;
    return MorphToolbarItemLayout.reservedLabeledSelectionExtent(
      inline: inline,
      axis: axis,
      iconVisualExtent: visual.width,
      iconSlotExtent: iconSlot,
      labelStyle: theme.typeScale.labelLarge.copyWith(
        fontWeight: FontWeight.w600,
      ),
      textScaler: MediaQuery.textScalerOf(context),
      // Minimum inter-action space; leftover width is shared via spaceBetween.
      gap: gap,
      labelGap: MorphToolbarIconButton.labelGap,
      includeOverflowSlot: hasOverflow,
    );
  }

  /// Builds one inline slot; flexes [MorphToolbarWidget]s when [expandWidgets].
  Widget _buildSlot({
    required MorphToolbarItem item,
    required double availableExtent,
    required double opticalInset,
    required MorphIconButtonSize iconButtonSize,
    required bool expandWidgets,
  }) {
    final Widget built = MorphToolbarItemLayout.buildItem(
      item: item,
      availableExtent: availableExtent,
      axis: axis,
      opticalInset: opticalInset,
      buildAction: (MorphToolbarAction action) => MorphToolbarIconButton(
        action: action,
        size: iconButtonSize,
        shape: shape,
        colorStyle: colorStyle,
        pillActiveSpring: pillActiveSpring,
      ),
    );
    if (expandWidgets && item is MorphToolbarWidget) {
      return Expanded(child: built);
    }
    return built;
  }

  Widget _fittedDockedRow(double available) {
    final int actionCount = actions.length;
    var inlineActions = maxInline < actionCount ? maxInline : actionCount;
    while (inlineActions > 0) {
      final bool needsOverflow = inlineActions < actionCount;
      final int slots = inlineActions + (needsOverflow ? 1 : 0);
      final double minWidth = slots * slotExtent + (slots - 1) * minGap;
      if (minWidth <= available + 0.5) {
        break;
      }
      inlineActions--;
    }
    final partitioned = MorphToolbarItemLayout.partitionInline(
      items: actions,
      maxInline: inlineActions,
    );
    final slots = <Widget>[
      for (final MorphToolbarItem item in partitioned.inline)
        _buildSlot(
          item: item,
          availableExtent: availableExtent,
          opticalInset: opticalInset,
          iconButtonSize: iconButtonSize,
          expandWidgets: false,
        ),
      if (partitioned.overflow.isNotEmpty)
        MorphToolbarOverflowMenu(
          actions: partitioned.overflow,
          icon: overflowIcon,
          iconButtonSize: iconButtonSize,
          textStyle: overflowTextStyle,
          destructiveColor: destructiveColor,
          shape: shape,
        ),
    ];
    return _dockedRow(slots, available);
  }

  Widget _dockedRow(List<Widget> slots, double available) {
    final MorphToolbarContentAlignment alignment = compact
        ? MorphToolbarContentAlignment.even
        : contentAlignment;
    switch (alignment) {
      case MorphToolbarContentAlignment.even:
        final double gap = MorphToolbarItemLayout.dockedGap(
          available: available,
          slotExtent: slotExtent,
          slotCount: slots.length,
          preferredGap: preferredGap,
          minGap: minGap,
        );
        return Row(
          children: MorphToolbarItemLayout.withGaps(
            slots,
            gap: gap,
            axis: Axis.horizontal,
          ),
        );
      case MorphToolbarContentAlignment.centered:
        return Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: MorphToolbarItemLayout.withGaps(
            slots,
            gap: centeredGap,
            axis: Axis.horizontal,
          ),
        );
      case MorphToolbarContentAlignment.edges:
        final int split = (slots.length / 2).ceil();
        final List<Widget> leading = slots.sublist(0, split);
        final List<Widget> trailing = slots.sublist(split);
        return Row(
          children: <Widget>[
            ...MorphToolbarItemLayout.withGaps(
              leading,
              gap: preferredGap,
              axis: Axis.horizontal,
            ),
            if (trailing.isNotEmpty) const Spacer(),
            ...MorphToolbarItemLayout.withGaps(
              trailing,
              gap: preferredGap,
              axis: Axis.horizontal,
            ),
          ],
        );
    }
  }
}
