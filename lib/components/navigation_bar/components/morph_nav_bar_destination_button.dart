import 'dart:ui' show SemanticsRole;

import 'package:flutter/widgets.dart' show Transform, Offset, Opacity;
import 'package:motor/motor.dart';

import 'package:material_ui/material_ui.dart'
    show
        Alignment,
        Border,
        BorderRadius,
        BorderSide,
        BoxDecoration,
        BuildContext,
        Builder,
        Center,
        ClipRRect,
        Color,
        ColoredBox,
        Column,
        DecoratedBox,
        EdgeInsets,
        Flexible,
        FocusNode,
        IconTheme,
        IconThemeData,
        IgnorePointer,
        InkWell,
        MainAxisAlignment,
        MediaQuery,
        NoSplash,
        Padding,
        OverflowBox,
        Positioned,
        Row,
        Semantics,
        SizedBox,
        Stack,
        StackFit,
        StatelessWidget,
        SystemMouseCursors,
        Text,
        TextAlign,
        TextOverflow,
        TextStyle,
        VoidCallback,
        Widget,
        WidgetStatePropertyAll;

import '../../../foundations/foundations.dart';
import '../../navigation_rail/components/morph_sliding_indicator.dart';
import '../../navigation_rail/components/morph_nav_icon_scale.dart';
import '../../navigation_rail/components/morph_nav_selection_indicator.dart';
import '../enums/morph_nav_bar_enums.dart';
import '../models/morph_navigation_bar_destination.dart';
import '../styles/morph_navigation_bar_theme.dart';

/// Single destination cell inside the Morph navigation bar.
///
/// The active pill springs on the horizontal axis. Keyboard focus draws an
/// inset ring. Space or Enter selects.
class MorphNavBarDestinationButton extends StatelessWidget {
  /// MorphNavBarDestinationButton.
  const MorphNavBarDestinationButton({
    this.motion = MorphNavigationMotion.standard,
    this.expressive = false,
    this.topIndicatorWidth = 40,
    this.topIndicatorHeight = 4,
    required this.destination,
    required this.selected,
    required this.selectedColor,
    required this.activeLabelColor,
    required this.unselectedColor,
    required this.labelStyle,
    required this.iconSize,
    required this.labelBehavior,
    required this.iconBehavior,
    required this.layout,
    required this.indicatorStyle,
    required this.indicatorWidth,
    required this.indicatorHeight,
    required this.indicatorRadius,
    required this.contentPadding,
    required this.iconLabelGap,
    required this.labelMaxLines,
    required this.labelOverflow,
    required this.underlineThickness,
    required this.underlineColor,
    required this.indicatorColor,
    required this.onTap,
    this.wideDestinationWidth,
    this.horizontalInset = 0,
    this.focusNode,
    this.skipTraversal = false,
    this.haptic = MorphHapticFeedback.inherit,
    super.key,
  });

  /// destination.
  final MorphNavigationBarDestination destination;

  /// selected.
  final bool selected;

  /// Active icon color.
  final Color selectedColor;

  /// Active label color.
  final Color activeLabelColor;

  /// Inactive icon and label color.
  final Color unselectedColor;

  /// labelStyle.
  final TextStyle labelStyle;

  /// iconSize.
  final double iconSize;

  /// labelBehavior.
  final MorphNavBarLabelBehavior labelBehavior;

  /// iconBehavior.
  final MorphNavBarIconBehavior iconBehavior;

  /// layout.
  final MorphNavBarLayout layout;

  /// indicatorStyle.
  final MorphNavBarIndicatorStyle indicatorStyle;

  /// indicatorWidth.
  final double indicatorWidth;

  /// indicatorHeight.
  final double indicatorHeight;

  /// Pill corner radius.
  final double indicatorRadius;

  /// Padding inside the destination, above and below the content.
  final EdgeInsets contentPadding;

  /// Gap between the icon and the label.
  final double iconLabelGap;

  /// labelMaxLines.
  final int labelMaxLines;

  /// labelOverflow.
  final TextOverflow labelOverflow;

  /// Chip width in horizontal layout.
  final double? wideDestinationWidth;

  /// Leading and trailing inset inside a horizontal pill.
  final double horizontalInset;

  /// underlineThickness.
  final double underlineThickness;

  /// underlineColor.
  final Color underlineColor;

  /// indicatorColor.
  final Color indicatorColor;

  /// onTap.
  final VoidCallback onTap;

  /// Focus node owned by the bar.
  final FocusNode? focusNode;

  /// When true, Tab skips this destination.
  final bool skipTraversal;

  /// Haptic intensity on tap. Defaults to [MorphHapticFeedback.inherit].
  final MorphHapticFeedback haptic;

  bool get _showLabel {
    if (!destination.hasLabel) {
      return false;
    }
    return switch (labelBehavior) {
      MorphNavBarLabelBehavior.alwaysShow => true,
      MorphNavBarLabelBehavior.onlySelected => selected,
      MorphNavBarLabelBehavior.alwaysHide => false,
    };
  }

  bool get _showIcon {
    if (!destination.hasIcon) {
      return false;
    }
    return switch (iconBehavior) {
      MorphNavBarIconBehavior.alwaysShow => true,
      MorphNavBarIconBehavior.onlySelected => selected,
      MorphNavBarIconBehavior.alwaysHide => false,
    };
  }

  bool get _pill => indicatorStyle == MorphNavBarIndicatorStyle.pill;

  bool get _underlined =>
      indicatorStyle == MorphNavBarIndicatorStyle.underline && selected;

  bool get _wide => layout == MorphNavBarLayout.wide;

  final bool expressive;
  final double topIndicatorWidth;
  final double topIndicatorHeight;

  /// Selection choreography used by the owning navigation widget.
  final MorphNavigationMotion motion;

  @override
  Widget build(BuildContext context) {
    final MorphNavigationBarTheme theme = MorphTheme.of(context)
        .navigationBarTheme;
    return Semantics(
      role: SemanticsRole.tab,
      selected: selected,
      label: destination.resolvedSemanticLabel,
      onTap: onTap,
      child: MorphTappable(
        focusNode: focusNode,
        skipTraversal: skipTraversal,
        focusOverlay: false,
        materialInk: true,
        semanticButton: false,
        excludeSemantics: true,
        haptic: haptic,
        onTap: onTap,
        builder: (BuildContext context, MorphInteractionState state) {
          return Builder(
            builder: (BuildContext inkContext) {
              final MorphTappableInkScope? ink = MorphTappableInkScope.maybeOf(
                inkContext,
              );
              return InkWell(
                enableFeedback: false,
                onTap: ink?.onTap,
                onLongPress: ink?.onLongPress,
                onHover: ink?.onHover,
                mouseCursor: ink?.mouseCursor ?? SystemMouseCursors.click,
                canRequestFocus: false,
                splashFactory: NoSplash.splashFactory,
                splashColor: const Color(0x00000000),
                highlightColor: const Color(0x00000000),
                overlayColor: const WidgetStatePropertyAll<Color>(
                  Color(0x00000000),
                ),
                child: Stack(
                  fit: StackFit.expand,
                  children: <Widget>[
                    _body(inkContext, state, theme),
                    if (state.focused) _ring(inkContext, theme),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }

  Widget _body(
    BuildContext context,
    MorphInteractionState state,
    MorphNavigationBarTheme theme,
  ) {
    if (expressive) return _expressiveContent(context, theme);
    Widget child = Padding(
      padding: contentPadding,
      child: _wide
          ? _wideContent(context, state, theme)
          : _verticalContent(context, state, theme),
    );
    if (_underlined) {
      child = DecoratedBox(
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: underlineColor,
              width: underlineThickness,
            ),
          ),
        ),
        child: child,
      );
    }
    return child;
  }

  Widget _expressiveContent(
    BuildContext context,
    MorphNavigationBarTheme theme,
  ) {
    final hasLabel =
        destination.hasLabel &&
        labelBehavior != MorphNavBarLabelBehavior.alwaysHide;
    final scaledLabelHeight =
        MediaQuery.textScalerOf(context)
            .scale(labelStyle.fontSize ?? theme.labelFontSize) *
        (labelStyle.height ?? theme.labelLineHeight / theme.labelFontSize);
    final alwaysLabel = labelBehavior == MorphNavBarLabelBehavior.alwaysShow;
    return Stack(
      alignment: Alignment.center,
      children: [
        if (indicatorStyle != MorphNavBarIndicatorStyle.none)
          Positioned(
            top: 0,
            width: topIndicatorWidth,
            height: topIndicatorHeight,
            child: MorphIndicatorTarget(
              selected: selected,
              decoration: BoxDecoration(
                color: indicatorColor,
                borderRadius: BorderRadius.circular(topIndicatorHeight / 2),
              ),
            ),
          ),
        SingleMotionBuilder(
          motion: MorphMotion.springMotion(theme.indicatorScaleSpring),
          value: selected ? 1.0 : 0.0,
          active: !MorphMotion.reduceMotionOf(context),
          builder: (context, value, child) {
            final t = value.clamp(0.0, 1.0);
            final labelVisible = alwaysLabel ? 1.0 : t;
            return Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (_showIcon)
                  Transform.translate(
                    offset: Offset(0, hasLabel ? -3 * labelVisible : 0),
                    child: _icon(selected ? selectedColor : unselectedColor),
                  ),
                if (hasLabel)
                  SizedBox(
                    height: (scaledLabelHeight + 4) * labelVisible,
                    child: OverflowBox(
                      alignment: Alignment.topCenter,
                      minHeight: scaledLabelHeight + 4,
                      maxHeight: scaledLabelHeight + 4,
                      child: Opacity(
                        opacity: labelVisible,
                        child: _label(
                          selected ? activeLabelColor : unselectedColor,
                          theme,
                        ),
                      ),
                    ),
                  ),
              ],
            );
          },
        ),
      ],
    );
  }

  Widget _verticalContent(
    BuildContext context,
    MorphInteractionState state,
    MorphNavigationBarTheme theme,
  ) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        if (_showIcon)
          SizedBox(
            width: indicatorWidth,
            height: indicatorHeight,
            child: _indicatorStack(
              context,
              state,
              theme,
              icon: _icon(selected ? selectedColor : unselectedColor),
            ),
          ),
        if (_showLabel) ...<Widget>[
          if (_showIcon) SizedBox(height: iconLabelGap),
          _label(selected ? activeLabelColor : unselectedColor, theme),
        ],
      ],
    );
  }

  Widget _wideContent(
    BuildContext context,
    MorphInteractionState state,
    MorphNavigationBarTheme theme,
  ) {
    final Color iconColor = selected ? selectedColor : unselectedColor;
    final Color labelColor = selected ? activeLabelColor : unselectedColor;
    return Center(
      child: SizedBox(
        width: wideDestinationWidth,
        height: indicatorHeight,
        child: _indicatorStack(
          context,
          state,
          theme,
          icon: Padding(
            padding: EdgeInsets.symmetric(horizontal: horizontalInset),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                if (_showIcon) _icon(iconColor),
                if (_showIcon && _showLabel) SizedBox(width: iconLabelGap),
                if (_showLabel) Flexible(child: _label(labelColor, theme)),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _indicatorStack(
    BuildContext context,
    MorphInteractionState state,
    MorphNavigationBarTheme theme, {
    required Widget icon,
  }) {
    final bool reduced = _pill && !selected && _interacting(state);
    final Color? overlay = _layerOpacity(state, theme) > 0
        ? theme
              .stateLayerColor(MorphTheme.of(context).colorScheme)
              .withValues(alpha: _layerOpacity(state, theme))
        : null;
    return Stack(
      alignment: Alignment.center,
      children: <Widget>[
        if (_pill)
          Positioned.fill(
            child: motion == MorphNavigationMotion.morph
                ? MorphIndicatorTarget(
                    selected: selected,
                    decoration: BoxDecoration(
                      color: indicatorColor,
                      borderRadius: BorderRadius.circular(indicatorRadius),
                    ),
                  )
                : MorphSelectionIndicator(
                    selected: selected,
                    scaleSpring: theme.indicatorScaleSpring,
                    fadeSpring: theme.indicatorFadeSpring,
                    child: _pillFill(selected ? overlay : null),
                  ),
          ),
        if (reduced ||
            (_pill &&
                selected &&
                motion == MorphNavigationMotion.morph &&
                overlay != null))
          Positioned.fill(
            child: _pillFill(
              overlay,
              stateOnly: motion == MorphNavigationMotion.morph,
            ),
          ),
        icon,
      ],
    );
  }

  /// Indicator color clipped to the pill, with the state fill inside that clip.
  Widget _pillFill(Color? overlay, {bool stateOnly = false}) {
    final radius = BorderRadius.circular(indicatorRadius);
    return DecoratedBox(
      decoration: BoxDecoration(
        color: stateOnly ? null : indicatorColor,
        borderRadius: radius,
      ),
      child: ClipRRect(
        borderRadius: radius,
        child: overlay == null
            ? const SizedBox.expand()
            : ColoredBox(color: overlay, child: const SizedBox.expand()),
      ),
    );
  }

  bool _interacting(MorphInteractionState state) {
    return state.hovered || state.focused || state.pressed;
  }

  double _layerOpacity(
    MorphInteractionState state,
    MorphNavigationBarTheme theme,
  ) {
    if (state.pressed) {
      return theme.pressedOpacity;
    }
    if (state.focused) {
      return theme.focusOpacity;
    }
    if (state.hovered) {
      return theme.hoverOpacity;
    }
    return 0;
  }

  Widget _ring(BuildContext context, MorphNavigationBarTheme theme) {
    return Positioned.fill(
      child: IgnorePointer(
        child: Padding(
          padding: EdgeInsets.all(theme.focusRingInset),
          child: DecoratedBox(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(indicatorRadius),
              border: Border.all(
                color: theme.focusRingColor(MorphTheme.of(context).colorScheme),
                width: theme.focusRingThickness,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _icon(Color color) {
    return MorphNavIconScale(
      selected: selected,
      child: IconTheme.merge(
        data: IconThemeData(color: color, size: iconSize),
        child: destination.buildIcon(selected: selected),
      ),
    );
  }

  Widget _label(Color color, MorphNavigationBarTheme theme) {
    return Text(
      destination.label!,
      maxLines: labelMaxLines,
      overflow: labelOverflow,
      textAlign: TextAlign.center,
      style: labelStyle.copyWith(
        color: color,
        fontWeight: selected
            ? theme.activeLabelWeight
            : theme.inactiveLabelWeight,
      ),
    );
  }
}
