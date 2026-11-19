import 'package:flutter/widgets.dart';

import '../../../foundations/foundations.dart';
import '../models/morph_menu_node.dart';
import '../styles/morph_menu_theme.dart';

/// Content-fitted geometry of a desktop-presentation menu surface.
///
/// The desktop menu is one surface (groups become labelled sections separated
/// by dividers) sized to its content between the theme's min and max width.
/// Measuring up front (instead of intrinsic layout) keeps the scrollable body
/// cheap and lets the placer flip and clamp with the real size.
@immutable
class MorphMenuDesktopLayout {
  /// Creates a layout result.
  const MorphMenuDesktopLayout({
    required this.nodes,
    required this.surfaceSize,
    required this.reserveLeading,
    required this.reserveTrailing,
  });

  /// Children flattened into one surface (dividers between top-level groups).
  final List<MorphMenuNode> nodes;

  /// Size of the visible surface (without the shadow margin).
  final Size surfaceSize;

  /// Whether rows without a leading widget still reserve the leading slot.
  final bool reserveLeading;

  /// Whether every row reserves the fixed trailing (chevron) slot.
  final bool reserveTrailing;

  /// Flattens top-level surfaces into one list separated by dividers.
  static List<MorphMenuNode> flatten(List<MorphMenuNode> children) {
    final List<MorphMenuGroup> surfaces = morphMenuPartitionSurfaces(children);
    final nodes = <MorphMenuNode>[];
    for (var i = 0; i < surfaces.length; i++) {
      if (i > 0) {
        nodes.add(const MorphMenuDivider());
      }
      final MorphMenuGroup surface = surfaces[i];
      if (surface.label != null) {
        nodes.add(
          MorphMenuGroup(label: surface.label, children: surface.children),
        );
      } else {
        nodes.addAll(surface.children);
      }
    }
    return nodes;
  }

  /// Measures [children] for [theme] (already resolved with desktop metrics).
  static MorphMenuDesktopLayout compute({
    required List<MorphMenuNode> children,
    required MorphMenuTheme theme,
    required MorphTypeScale type,
    required TextScaler textScaler,
    required TextDirection textDirection,
  }) {
    final List<MorphMenuNode> nodes = flatten(children);
    final _Measure measure = _Measure(
      theme: theme,
      type: type,
      textScaler: textScaler,
      textDirection: textDirection,
    )..visitTop(nodes);
    final bool reserveLeading = measure.anyLeading;
    final bool reserveTrailing = measure.anySubmenu;

    final double inset = theme.stateLayerInset;
    final double hPad = theme.entryHorizontalPadding;
    final double chrome = inset * 2 + hPad * 2;
    final double leadingW = reserveLeading ? theme.iconSize + theme.iconGap : 0;
    final double trailingW = reserveTrailing
        ? theme.iconGap + theme.iconSize
        : 0;
    double width = 0;
    for (final _RowWidth row in measure.rows) {
      final double w =
          chrome +
          (row.isLabel ? 0 : leadingW + trailingW) +
          row.content +
          (row.hasShortcut ? theme.resolvedShortcutGap : 0) +
          row.shortcut +
          (row.hasTrailing && !reserveTrailing
              ? theme.iconGap + theme.iconSize
              : 0);
      if (w > width) {
        width = w;
      }
    }
    width = width.ceilToDouble().clamp(theme.minWidth, theme.maxWidth);

    final double gaps = measure.widgets > 1
        ? (measure.widgets - 1) * theme.itemGap
        : 0;
    final double height = theme.verticalPadding * 2 + measure.height + gaps;
    return MorphMenuDesktopLayout(
      nodes: nodes,
      surfaceSize: Size(width, height),
      reserveLeading: reserveLeading,
      reserveTrailing: reserveTrailing,
    );
  }
}

class _RowWidth {
  const _RowWidth({
    required this.content,
    this.shortcut = 0,
    this.hasShortcut = false,
    this.hasTrailing = false,
    this.isLabel = false,
  });

  final double content;
  final double shortcut;
  final bool hasShortcut;
  final bool hasTrailing;
  final bool isLabel;
}

class _Measure {
  _Measure({
    required this.theme,
    required this.type,
    required this.textScaler,
    required this.textDirection,
  });

  final MorphMenuTheme theme;
  final MorphTypeScale type;
  final TextScaler textScaler;
  final TextDirection textDirection;

  final List<_RowWidth> rows = <_RowWidth>[];
  double height = 0;
  int widgets = 0;
  bool anyLeading = false;
  bool anySubmenu = false;

  Size _text(String text, TextStyle style) {
    final TextPainter painter = TextPainter(
      text: TextSpan(text: text, style: style),
      textDirection: textDirection,
      textScaler: textScaler,
      maxLines: 1,
    )..layout();
    final Size size = painter.size;
    painter.dispose();
    return size;
  }

  void visitTop(List<MorphMenuNode> nodes) {
    for (var i = 0; i < nodes.length; i++) {
      if (i > 0 && nodes[i] is MorphMenuGroup) {
        widgets += 1; // The group spacing box.
      }
      visit(nodes[i]);
    }
  }

  void visit(MorphMenuNode node) {
    switch (node) {
      case MorphMenuDivider():
        widgets += 1;
        height += theme.dividerThickness + theme.dividerVerticalPadding * 2;
      case MorphMenuGroup(:final label, :final children):
        if (label != null) {
          widgets += 1;
          height += theme.groupLabelHeight;
          rows.add(
            _RowWidth(
              content:
                  _text(label, type.labelLarge).width -
                  theme.entryHorizontalPadding * 2 +
                  theme.groupLabelHorizontalPadding * 2,
              isLabel: true,
            ),
          );
        }
        children.forEach(visit);
      case MorphMenuEntry():
        _leaf(
          label: node.label,
          supporting: node.supportingText,
          shortcut: node.trailingText,
          hasLeading: node.leading != null,
          hasTrailing: node.trailing != null,
        );
      case MorphMenuSelectable():
        _leaf(
          label: node.label,
          supporting: node.supportingText,
          shortcut: node.trailingText,
          hasLeading: true,
          hasTrailing: node.trailing != null,
        );
      case MorphMenuToggleable():
        _leaf(
          label: node.label,
          supporting: node.supportingText,
          shortcut: node.trailingText,
          hasLeading: true,
          hasTrailing: node.trailing != null,
        );
      case MorphMenuSubmenu():
        anySubmenu = true;
        _leaf(
          label: node.label,
          hasLeading: node.leading != null,
          hasTrailing: false,
        );
      case MorphMenuWidget():
        widgets += 1;
        height += theme.entryHeight;
    }
  }

  void _leaf({
    required String label,
    required bool hasLeading,
    required bool hasTrailing,
    String? supporting,
    String? shortcut,
  }) {
    anyLeading = anyLeading || hasLeading;
    widgets += 1;
    final Size labelSize = _text(label, type.labelLarge);
    double content = labelSize.width;
    double textHeight = labelSize.height;
    if (supporting != null) {
      final Size support = _text(supporting, type.bodySmall);
      content = content > support.width ? content : support.width;
      textHeight += support.height;
    }
    final double rowHeight = textHeight + theme.entryVerticalPadding * 2;
    height += rowHeight > theme.entryHeight ? rowHeight : theme.entryHeight;
    rows.add(
      _RowWidth(
        content: content,
        shortcut: shortcut == null ? 0 : _text(shortcut, type.labelLarge).width,
        hasShortcut: shortcut != null,
        hasTrailing: hasTrailing,
      ),
    );
  }
}
