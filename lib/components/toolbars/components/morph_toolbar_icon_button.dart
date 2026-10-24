import 'package:flutter/widgets.dart';
import 'package:morph_expressive/morph_components.dart'
    show MorphTheme, MorphToolbar;
import 'package:motor/motor.dart';

import '../../../foundations/interaction/morph_motion_controller.dart';
import '../../../foundations/foundations.dart';
import '../../icon_buttons/morph_icon_buttons.dart';
import '../enums/morph_toolbar_enums.dart';
import '../models/morph_toolbar_item.dart';
import '../styles/morph_toolbar_theme.dart';

/// Inline icon action for [MorphToolbar] — thin adapter over [MorphIconButton].
///
/// When [MorphToolbarAction.label] is set, the label lives **inside** the button
/// pill. Width springs between the icon-button visual size (inactive, icon
/// only) and the natural icon+label width (active). Layout width follows the
/// spring so the parent toolbar pill grows/shrinks in sync — unless the parent
/// reserves a fixed selection width (`pillActiveSpring: false`).
class MorphToolbarIconButton extends StatefulWidget {
  /// MorphToolbarIconButton.
  const MorphToolbarIconButton({
    required this.action,
    required this.size,
    this.onPressed,
    this.variant,
    this.shape = MorphIconButtonShapeVariant.round,
    this.colorStyle = MorphToolbarColorStyle.standard,
    this.pillActiveSpring = true,
    super.key,
  });

  /// Gap between the icon and label inside an expanded action.
  static const double labelGap = 6;

  /// action.
  final MorphToolbarAction action;

  /// size.
  final MorphIconButtonSize size;

  /// Overrides [MorphToolbarAction.onPressed] when set (e.g. expand trigger).
  final VoidCallback? onPressed;

  /// Defaults to filled for an expand trigger, tonal when selected, else
  /// standard.
  final MorphIconButtonVariant? variant;

  /// Round on a floating toolbar. Docked actions may be square.
  final MorphIconButtonShapeVariant shape;

  /// Selects the tonal colors for an active action.
  final MorphToolbarColorStyle colorStyle;

  /// Reserved for parent [MorphToolbar.pillActiveSpring]; labeled width always
  /// follows the morph spring so padding and animation stay correct.
  final bool pillActiveSpring;

  @override
  State<MorphToolbarIconButton> createState() => _MorphToolbarIconButtonState();
}

class _MorphToolbarIconButtonState extends State<MorphToolbarIconButton>
    with SingleTickerProviderStateMixin {
  late final SingleMotionController _labelCtrl;

  SpringMotion _labelMotion(MorphSpring spring) =>
      MorphMotion.springMotion(spring);

  bool get _hasLabel {
    final String? label = widget.action.label;
    return label != null && label.isNotEmpty;
  }

  bool get _showLabeled => _hasLabel && widget.action.active;

  @override
  void initState() {
    super.initState();
    _labelCtrl = MorphMotionController(
      motion: _labelMotion(MorphToolbarTheme.defaults.labelSpring),
      vsync: this,
      initialValue: _showLabeled ? 1 : 0,
    );
  }

  @override
  void didUpdateWidget(covariant MorphToolbarIconButton oldWidget) {
    super.didUpdateWidget(oldWidget);
    final bool wasLabeled =
        oldWidget.action.active &&
        oldWidget.action.label != null &&
        oldWidget.action.label!.isNotEmpty;
    if (wasLabeled != _showLabeled) {
      final spring = MorphTheme.of(context).toolbarTheme.labelSpring;
      _labelCtrl
        ..motion = _labelMotion(spring)
        ..animateTo(_showLabeled ? 1 : 0);
    }
  }

  @override
  void dispose() {
    _labelCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_hasLabel) {
      return _buildIconButton(icon: Icon(widget.action.icon));
    }
    return AnimatedBuilder(
      animation: _labelCtrl,
      builder: (BuildContext context, Widget? child) {
        return _buildLabeled(context, progress: _labelCtrl.value);
      },
    );
  }

  MorphIconButtonVariant get _resolvedVariant =>
      widget.variant ??
      (widget.action.isExpandTrigger
          ? MorphIconButtonVariant.filled
          : widget.action.active
          ? MorphIconButtonVariant.tonal
          : MorphIconButtonVariant.standard);

  VoidCallback? get _resolvedOnPressed => widget.action.enabled
      ? (widget.onPressed ?? widget.action.onPressed)
      : null;

  Widget _buildIconButton({required Widget icon, Size? visualSize}) {
    Widget button = MorphIconButton(
      icon: icon,
      onPressed: _resolvedOnPressed,
      tooltip: widget.action.tooltip ?? widget.action.label,
      semanticLabel: widget.action.semanticLabel,
      size: widget.size,
      shape: widget.shape,
      variant: _resolvedVariant,
      visualSize: visualSize,
    );
    if (!widget.action.active || widget.action.isExpandTrigger) {
      return button;
    }
    final MorphThemeData theme = MorphTheme.of(context);
    final MorphToolbarColors colors = theme.toolbarTheme.colors(
      theme.colorScheme,
      widget.colorStyle,
    );
    final Color? selectedBackground = colors.selectedContainer;
    final Color? selectedForeground = colors.selectedContent;
    if (selectedBackground == null || selectedForeground == null) {
      return button;
    }
    return MorphTheme(
      data: theme.copyWith(
        colorScheme: theme.colorScheme.copyWith(
          secondaryContainer: selectedBackground,
          onSecondaryContainer: selectedForeground,
        ),
      ),
      child: button,
    );
  }

  Widget _buildLabeled(BuildContext context, {required double progress}) {
    final MorphThemeData theme = MorphTheme.of(context);
    final MorphIconButtonTheme iconTheme = theme.iconButtonTheme;
    final Size visual = iconTheme.visual(
      widget.size,
      MorphIconButtonWidth.defaultWidth,
    );
    final double iconPx = iconTheme.iconSize(widget.size);
    final double t = progress.clamp(0.0, 1.0);
    final TextStyle labelStyle = theme.typeScale.labelLarge.copyWith(
      fontWeight: FontWeight.w600,
    );
    final double labelWidth = _measureLabelWidth(
      widget.action.label!,
      labelStyle,
      MediaQuery.textScalerOf(context),
    );
    final expandedWidth =
        visual.width + MorphToolbarIconButton.labelGap + labelWidth;
    final sprungWidth = visual.width + (expandedWidth - visual.width) * t;

    return _buildIconButton(
      icon: _buildLabeledRow(
        iconPx: iconPx,
        labelStyle: labelStyle,
        progress: t,
      ),
      visualSize: Size(sprungWidth, visual.height),
    );
  }

  Widget _buildLabeledRow({
    required double iconPx,
    required TextStyle labelStyle,
    required double progress,
  }) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Icon(widget.action.icon, size: iconPx),
        if (progress > 0.01)
          ClipRect(
            child: Align(
              alignment: AlignmentDirectional.centerStart,
              widthFactor: progress,
              child: Opacity(
                opacity: progress,
                child: Padding(
                  padding: const EdgeInsetsDirectional.only(
                    start: MorphToolbarIconButton.labelGap,
                  ),
                  child: Builder(
                    builder: (BuildContext context) {
                      return Text(
                        widget.action.label!,
                        style: labelStyle.copyWith(
                          color: IconTheme.of(context).color,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.clip,
                        softWrap: false,
                      );
                    },
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }

  double _measureLabelWidth(
    String label,
    TextStyle style,
    TextScaler textScaler,
  ) {
    final painter = TextPainter(
      text: TextSpan(text: label, style: style),
      maxLines: 1,
      textDirection: TextDirection.ltr,
      textScaler: textScaler,
    )..layout();
    return painter.width;
  }
}
