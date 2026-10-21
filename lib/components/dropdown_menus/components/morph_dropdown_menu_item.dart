import 'package:material_ui/material_ui.dart'
    show
        BorderRadius,
        BorderRadiusTween,
        BuildContext,
        Color,
        Expanded,
        Icon,
        Radius,
        Row,
        State,
        StatefulWidget,
        Text,
        TweenAnimationBuilder,
        VoidCallback,
        Widget;

import '../../../foundations/foundations.dart';
import '../../cards/morph_cards.dart';
import '../models/morph_dropdown_item.dart';
import '../styles/morph_dropdown_item_style.dart';
import '../styles/morph_dropdown_menu_theme.dart';

/// Internal widget for a single dropdown menu item.
/// Handles hover/press interactions and snappy radius morphing.
class MorphDropdownMenuItemWidget<T> extends StatefulWidget {
  /// item.
  final MorphDropdownItem<T> item;

  /// index.
  final int index;

  /// total.
  final int total;

  /// style.
  final MorphDropdownItemStyle style;

  /// onTap.
  final VoidCallback onTap;

  /// MorphDropdownMenuItemWidget.

  const MorphDropdownMenuItemWidget({
    super.key,
    required this.item,
    required this.index,
    required this.total,
    required this.style,
    required this.onTap,
  });

  @override
  State<MorphDropdownMenuItemWidget<T>> createState() =>
      _MorphDropdownMenuItemWidgetState<T>();
}

class _MorphDropdownMenuItemWidgetState<T>
    extends State<MorphDropdownMenuItemWidget<T>> {
  bool _isHovered = false;
  bool _isPressed = false;
  bool _lastSelected = false;

  @override
  void initState() {
    super.initState();
    _lastSelected = widget.item.selected;
  }

  BorderRadius _calculateBaseRadius(double currentRadius) {
    final id = widget.style;
    final isFirst = widget.index == 0;
    final isLast = widget.index == widget.total - 1;
    final isSingle = widget.total == 1;

    final outerR = id.outerRadius ?? 12.0;

    if (widget.item.selected) {
      return BorderRadius.circular(currentRadius);
    } else if (isSingle) {
      return BorderRadius.circular(outerR);
    } else if (isFirst) {
      return BorderRadius.vertical(
        top: Radius.circular(outerR),
        bottom: Radius.circular(currentRadius),
      );
    } else if (isLast) {
      return BorderRadius.vertical(
        top: Radius.circular(currentRadius),
        bottom: Radius.circular(outerR),
      );
    } else {
      return BorderRadius.circular(currentRadius);
    }
  }

  BorderRadius _buildEffectiveRadius() {
    final id = widget.style;

    // 1. Determine the "dynamic" radius (Selected vs Hover vs Pressed vs Inner)
    double targetR = id.innerRadius;

    if (widget.item.selected) {
      targetR = id.selectedBorderRadius ?? id.outerRadius ?? 12.0;
    }

    if (_isPressed) {
      targetR = id.pressedRadius;
    } else if (_isHovered) {
      targetR = id.hoverRadius;
    }

    // 2. Apply this dynamic radius to the correct corners, PRESERVING outerRadius
    return _calculateBaseRadius(targetR);
  }

  Color _resolveBackgroundColor(
    MorphColorScheme scheme,
    MorphDropdownMenuTheme menuTheme,
  ) {
    final id = widget.style;
    final item = widget.item;
    if (item.disabled) {
      return id.disabledBackgroundColor ??
          scheme.onSurface.withValues(alpha: 0.04);
    }
    if (item.selected) {
      return id.selectedBackgroundColor ??
          menuTheme.itemSelectedBackgroundColor(scheme);
    }
    return id.backgroundColor ?? menuTheme.itemBackgroundColor(scheme);
  }

  Color _resolveTextColor(
    MorphColorScheme scheme,
    MorphDropdownMenuTheme menuTheme,
  ) {
    final id = widget.style;
    final item = widget.item;
    if (item.disabled) {
      return id.disabledTextColor ?? scheme.onSurface.withValues(alpha: 0.38);
    }
    if (item.selected) {
      return id.selectedTextColor ??
          menuTheme.itemSelectedForegroundColor(scheme);
    }
    return id.textColor ?? menuTheme.itemForegroundColor(scheme);
  }

  Widget _buildItemContent(
    MorphThemeData morphTheme,
    MorphColorScheme scheme,
    MorphDropdownMenuTheme menuTheme,
    Color textColor,
  ) {
    final id = widget.style;
    final item = widget.item;
    return Row(
      children: [
        Expanded(
          child: Text(
            item.label,
            style:
                (item.selected ? id.selectedTextStyle : id.textStyle) ??
                menuTheme
                    .itemTextStyle(morphTheme.typeScale, scheme)
                    .copyWith(color: textColor),
          ),
        ),
        if (item.selected)
          id.selectedIcon ??
              Icon(
                MorphIcons.check_rounded,
                color: textColor,
                size: (morphTheme.resolvedIconTheme.size ?? 20) + 2,
              ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final morphTheme = MorphTheme.of(context);
    final scheme = morphTheme.colorScheme;
    final menuTheme = morphTheme.dropdownMenuTheme;
    final id = widget.style;
    final item = widget.item;

    final bgColor = _resolveBackgroundColor(scheme, menuTheme);
    final textColor = _resolveTextColor(scheme, menuTheme);
    final content = _buildItemContent(morphTheme, scheme, menuTheme, textColor);

    final selectionChanged = _lastSelected != item.selected;
    _lastSelected = item.selected;
    final duration = selectionChanged
        ? const Duration(milliseconds: 20)
        : const Duration(milliseconds: 40);

    return TweenAnimationBuilder<BorderRadius?>(
      duration: duration,
      curve: MorphMotion.enter,
      tween: BorderRadiusTween(
        begin: _buildEffectiveRadius(),
        end: _buildEffectiveRadius(),
      ),
      builder: (context, animatedRadius, child) {
        return MorphCard(
          variant: MorphCardVariant.filled,
          borderRadius: animatedRadius ?? _buildEffectiveRadius(),
          color: bgColor,
          elevation: 0,
          padding: id.itemPadding,
          width: double.infinity,
          onPressed: item.disabled ? null : widget.onTap,
          mouseCursor: id.mouseCursor,
          onStateChanged: (state) {
            if (_isHovered != state.hovered || _isPressed != state.pressed) {
              setState(() {
                _isHovered = state.hovered;
                _isPressed = state.pressed;
              });
            }
          },
          child: child,
        );
      },
      child: content,
    );
  }
}
