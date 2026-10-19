import 'package:flutter/widgets.dart';

import '../../foundations/foundations.dart';
import '../buttons/utils/morph_button_gradient_layer.dart';
import 'components/morph_segment_divider.dart';
import 'enums/morph_segmented_button_enums.dart';
import 'models/morph_segment.dart';
import 'styles/morph_segmented_button_theme.dart';

export 'enums/morph_segmented_button_enums.dart';
export 'models/morph_segment.dart';
export 'styles/morph_segmented_button_theme.dart';

/// A Material 3 Expressive segmented button.
///
/// Presents 2–5 connected [MorphSegment]s for selecting options, switching views
/// or sorting. Supports single or multiple selection and shows a check icon on
/// selected segments when [showSelectedIcon] is true.
class MorphSegmentedButton<T> extends StatefulWidget {
  /// Creates a segmented button.
  const MorphSegmentedButton({
    required this.segments,
    required this.selected,
    required this.onSelectionChanged,
    this.multiSelect = false,
    this.showSelectedIcon = true,
    this.density = MorphSegmentedButtonDensity.regular,
    this.enabled = true,
    this.semanticLabel,
    super.key,
  }) : assert(
         segments.length >= 2 && segments.length <= 5,
         'A segmented button needs 2–5 segments.',
       );

  /// Segments rendered in reading order (2–5).
  final List<MorphSegment<T>> segments;

  /// Currently selected values.
  final Set<T> selected;

  /// Called when selection changes.
  final ValueChanged<Set<T>> onSelectionChanged;

  /// When true, multiple segments may be selected (including none).
  final bool multiSelect;

  /// When true, selected segments show a checkmark (replacing the category icon).
  final bool showSelectedIcon;

  /// Density level that shrinks container height (−4dp per step).
  final MorphSegmentedButtonDensity density;

  /// When false, the whole group is disabled.
  final bool enabled;

  /// Optional accessibility label for the group.
  final String? semanticLabel;

  @override
  State<MorphSegmentedButton<T>> createState() =>
      _MorphSegmentedButtonState<T>();

  void _handleTap(T value) {
    if (multiSelect) {
      final next = Set<T>.of(selected);
      if (next.contains(value)) {
        next.remove(value);
      } else {
        next.add(value);
      }
      onSelectionChanged(next);
      return;
    }
    // Single-select: select only; never clear by re-tapping.
    if (selected.contains(value)) {
      return;
    }
    onSelectionChanged(<T>{value});
  }

  bool _isSegmentEnabled(int index) => enabled && segments[index].enabled;
}

class _MorphSegmentedButtonState<T> extends State<MorphSegmentedButton<T>> {
  /// Segment row. Dividers sample their gradient across this box.
  final GlobalKey _rowKey = GlobalKey();

  /// Segment currently showing a keyboard focus ring, if any.
  final ValueNotifier<int?> _focusedIndex = ValueNotifier<int?>(null);

  late List<FocusNode> _focusNodes;

  @override
  void dispose() {
    MorphFocusInteraction.instance.removeListener(_onFocusInteractionChanged);
    _focusedIndex.dispose();
    for (final FocusNode node in _focusNodes) {
      node.dispose();
    }
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _focusNodes = _createFocusNodes(widget.segments.length);
    MorphFocusInteraction.instance.addListener(_onFocusInteractionChanged);
  }

  @override
  void didUpdateWidget(covariant MorphSegmentedButton<T> oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.segments.length != widget.segments.length) {
      for (final FocusNode node in _focusNodes) {
        node.dispose();
      }
      _focusNodes = _createFocusNodes(widget.segments.length);
      _focusedIndex.value = null;
    }
  }

  List<FocusNode> _createFocusNodes(int count) {
    return List<FocusNode>.generate(
      count,
      (int i) => FocusNode(debugLabel: 'MorphSegmentedButton<$T>[$i]'),
    );
  }

  void _onTapOutside(PointerDownEvent event) {
    MorphFocusInteraction.instance.notePointerInteraction();
    _focusedIndex.value = null;
    for (final FocusNode node in _focusNodes) {
      if (node.hasFocus) {
        node.unfocus();
      }
    }
  }

  void _onFocusInteractionChanged() {
    if (!MorphFocusInteraction.instance.ringsAllowed &&
        _focusedIndex.value != null) {
      _focusedIndex.value = null;
    }
  }

  void _handleSegmentFocus(int index, {required bool focused}) {
    if (focused && MorphFocusInteraction.instance.ringsAllowed) {
      _focusedIndex.value = index;
    } else if (_focusedIndex.value == index) {
      _focusedIndex.value = null;
    }
  }

  int get _firstEnabledIndex {
    for (var i = 0; i < widget.segments.length; i++) {
      if (widget._isSegmentEnabled(i)) {
        return i;
      }
    }
    return 0;
  }

  @override
  Widget build(BuildContext context) {
    return MorphComponentTheme(builder: _buildButton);
  }

  Widget _buildButton(BuildContext context) {
    final theme = MorphTheme.of(context);
    final segmentedButtonTheme = theme.segmentedButtonTheme;
    final scheme = theme.colorScheme;
    final visualHeight = segmentedButtonTheme.heightFor(widget.density);
    final layoutHeight = segmentedButtonTheme.layoutHeightFor(widget.density);
    final borderRadius = segmentedButtonTheme.borderRadiusFor(widget.density);
    final pad = (layoutHeight - visualHeight) / 2;
    final groupEnabled = widget.enabled;

    final Widget visualBand = _visualBand(
      segmentedButtonTheme: segmentedButtonTheme,
      scheme: scheme,
      visualHeight: visualHeight,
      borderRadius: borderRadius,
      groupEnabled: groupEnabled,
    );

    Widget ring = SizedBox(
      height: layoutHeight,
      child: Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.center,
        children: <Widget>[
          Positioned(
            left: 0,
            right: 0,
            top: pad,
            height: visualHeight,
            child: visualBand,
          ),
          Positioned.fill(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: _buildSegmentHitTargets(
                context,
                segmentedButtonTheme,
                visualHeight,
                layoutHeight,
              ),
            ),
          ),
          Positioned(
            left: 0,
            right: 0,
            top: pad,
            height: visualHeight,
            child: _buildFocusRingOverlay(segmentedButtonTheme),
          ),
        ],
      ),
    );

    final double? maxWidth = segmentedButtonTheme.maxWidth;
    if (maxWidth != null) {
      ring = ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxWidth),
        child: ring,
      );
    }

    return Semantics(
      container: true,
      explicitChildNodes: true,
      label: widget.semanticLabel,
      child: TapRegion(onTapOutside: _onTapOutside, child: ring),
    );
  }

  Widget _visualBand({
    required MorphSegmentedButtonTheme segmentedButtonTheme,
    required MorphColorScheme scheme,
    required double visualHeight,
    required BorderRadius borderRadius,
    required bool groupEnabled,
  }) {
    final Color outlineColor = segmentedButtonTheme.outline(
      scheme,
      enabled: groupEnabled,
    );
    final Gradient? outlineGradient = segmentedButtonTheme.outlineGradient;
    Widget visualBand = ClipRRect(
      borderRadius: borderRadius,
      child: Row(
        key: _rowKey,
        mainAxisSize: MainAxisSize.min,
        children: _buildSegmentFills(context, segmentedButtonTheme),
      ),
    );
    visualBand = Container(
      height: visualHeight,
      decoration: BoxDecoration(
        borderRadius: borderRadius,
        border: outlineGradient == null
            ? Border.all(
                color: outlineColor,
                width: segmentedButtonTheme.borderWidth,
              )
            : null,
      ),
      child: visualBand,
    );
    if (outlineGradient != null && groupEnabled) {
      visualBand = morphGradientOutlineLayer(
        clipRadius: borderRadius,
        gradient: outlineGradient,
        width: segmentedButtonTheme.borderWidth,
        child: visualBand,
      );
    }
    return visualBand;
  }

  /// Selected fills and dividers (non-interactive paint layer).
  List<Widget> _buildSegmentFills(
    BuildContext context,
    MorphSegmentedButtonTheme segmentedButtonTheme,
  ) {
    final theme = MorphTheme.of(context);
    final children = <Widget>[];
    for (var i = 0; i < widget.segments.length; i++) {
      if (i > 0) {
        children.add(
          MorphSegmentDivider(
            hostKey: _rowKey,
            width: segmentedButtonTheme.borderWidth,
            color: segmentedButtonTheme.divider(
              theme.colorScheme,
              enabled: widget.enabled,
            ),
            gradient: widget.enabled
                ? segmentedButtonTheme.dividerGradient
                : null,
          ),
        );
      }
      final segment = widget.segments[i];
      final selected = widget.selected.contains(segment.value);
      final Gradient? gradient = selected
          ? segmentedButtonTheme.selectedBackgroundGradient
          : segmentedButtonTheme.unselectedBackgroundGradient;
      final Color? solidBg = segmentedButtonTheme.backgroundColor(
        theme.colorScheme,
        selected: selected,
      );
      children.add(
        Flexible(
          child: ColoredBox(
            color: gradient == null
                ? (solidBg ?? const Color(0x00000000))
                : const Color(0x00000000),
            child: gradient == null
                ? const SizedBox.expand()
                : DecoratedBox(
                    decoration: BoxDecoration(gradient: gradient),
                    child: const SizedBox.expand(),
                  ),
          ),
        ),
      );
    }
    return children;
  }

  List<Widget> _buildSegmentHitTargets(
    BuildContext context,
    MorphSegmentedButtonTheme segmentedButtonTheme,
    double visualHeight,
    double layoutHeight,
  ) {
    final children = <Widget>[];
    final firstEnabled = _firstEnabledIndex;
    for (var i = 0; i < widget.segments.length; i++) {
      if (i > 0) {
        children.add(SizedBox(width: segmentedButtonTheme.borderWidth));
      }
      children.add(
        Flexible(
          child: _MorphSegmentTile<T>(
            segmentedButtonTheme: segmentedButtonTheme,
            index: i,
            parent: widget,
            visualHeight: visualHeight,
            layoutHeight: layoutHeight,
            segmentRadius: _segmentRadius(
              segmentedButtonTheme,
              i,
              Directionality.of(context),
            ),
            focusNode: _focusNodes[i],
            autofocus: i == firstEnabled && widget._isSegmentEnabled(i),
            onFocusChanged: (bool focused) =>
                _handleSegmentFocus(i, focused: focused),
          ),
        ),
      );
    }
    return children;
  }

  /// Mirrors the segment row's flex structure so the ring of the focused
  /// segment lines up with it without measuring anything.
  Widget _buildFocusRingOverlay(
    MorphSegmentedButtonTheme segmentedButtonTheme,
  ) {
    return IgnorePointer(
      child: ValueListenableBuilder<int?>(
        valueListenable: _focusedIndex,
        builder: (BuildContext context, int? focusedIndex, _) {
          if (focusedIndex == null) {
            return const SizedBox.shrink();
          }
          final TextDirection direction = Directionality.of(context);
          final scheme = MorphTheme.of(context).colorScheme;
          final slots = <Widget>[];
          for (var i = 0; i < widget.segments.length; i++) {
            if (i > 0) {
              slots.add(SizedBox(width: segmentedButtonTheme.borderWidth));
            }
            slots.add(
              Flexible(
                child: i == focusedIndex
                    ? MorphFocusRing(
                        focused: true,
                        radius: _segmentRadius(
                          segmentedButtonTheme,
                          i,
                          direction,
                        ),
                        color: segmentedButtonTheme.focusColor(scheme),
                        width: segmentedButtonTheme.focusIndicatorWidth,
                        gap: segmentedButtonTheme.focusIndicatorGap,
                        child: const SizedBox.expand(),
                      )
                    : const SizedBox.expand(),
              ),
            );
          }
          return Row(children: slots);
        },
      ),
    );
  }

  /// Outer corners are rounded only where the segment meets the group edge.
  BorderRadius _segmentRadius(
    MorphSegmentedButtonTheme segmentedButtonTheme,
    int index,
    TextDirection direction,
  ) {
    final Radius outer = segmentedButtonTheme
        .borderRadiusFor(widget.density)
        .topLeft;
    return BorderRadiusDirectional.horizontal(
      start: index == 0 ? outer : Radius.zero,
      end: index == widget.segments.length - 1 ? outer : Radius.zero,
    ).resolve(direction);
  }
}

class _MorphSegmentTile<T> extends StatelessWidget {
  const _MorphSegmentTile({
    required this.segmentedButtonTheme,
    required this.index,
    required this.parent,
    required this.visualHeight,
    required this.layoutHeight,
    required this.segmentRadius,
    required this.focusNode,
    required this.autofocus,
    required this.onFocusChanged,
  });

  final MorphSegmentedButtonTheme segmentedButtonTheme;
  final int index;
  final MorphSegmentedButton<T> parent;
  final double visualHeight;
  final double layoutHeight;
  final BorderRadius segmentRadius;
  final FocusNode focusNode;
  final bool autofocus;

  /// Reports keyboard focus so the group can paint the ring above its clip.
  final ValueChanged<bool> onFocusChanged;

  @override
  Widget build(BuildContext context) {
    final MorphSegment<T> segment = parent.segments[index];
    final bool isSelected = parent.selected.contains(segment.value);
    final bool enabled = parent._isSegmentEnabled(index);
    final bool multi = parent.multiSelect;
    final ShapeBorder segmentShape = RoundedRectangleBorder(
      borderRadius: segmentRadius,
    );

    return Semantics(
      selected: isSelected,
      checked: multi ? isSelected : null,
      inMutuallyExclusiveGroup: multi ? null : true,
      enabled: enabled,
      button: true,
      child: MorphTappable(
        onTap: enabled ? () => parent._handleTap(segment.value) : null,
        enabled: enabled,
        focusNode: focusNode,
        autofocus: autofocus,
        semanticLabel: segment.resolvedSemanticLabel,
        semanticButton: false,
        excludeSemantics: true,
        materialInk: true,
        onStateChanged: (MorphInteractionState state) =>
            onFocusChanged(state.focused),
        builder: (BuildContext context, MorphInteractionState state) {
          final resolvedScheme = MorphTheme.of(context).colorScheme;
          final Gradient? fgGradient = isSelected
              ? segmentedButtonTheme.selectedForegroundGradient
              : segmentedButtonTheme.unselectedForegroundGradient;
          final resolvedForeground = !enabled
              ? segmentedButtonTheme.foregroundColor(
                  resolvedScheme,
                  selected: isSelected,
                  enabled: false,
                )
              : fgGradient != null
              ? morphGradientForegroundSourceColor
              : segmentedButtonTheme.foregroundColor(
                  resolvedScheme,
                  selected: isSelected,
                  enabled: true,
                );
          return SizedBox(
            width: double.infinity,
            height: layoutHeight,
            child: Center(
              child: ClipRRect(
                borderRadius: segmentRadius,
                child: SizedBox(
                  width: double.infinity,
                  height: visualHeight,
                  child: MorphStateLayerOverlay(
                    state: enabled ? state : const MorphInteractionState(),
                    color: resolvedForeground,
                    shape: segmentShape,
                    alignment: Alignment.center,
                    child: Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal:
                            segmentedButtonTheme.segmentHorizontalPadding,
                      ),
                      child: _wrapForeground(
                        segmentedButtonTheme,
                        isSelected,
                        enabled,
                        _buildLabel(
                          context,
                          segment,
                          resolvedForeground,
                          isSelected,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildLabel(
    BuildContext context,
    MorphSegment<T> segment,
    Color foreground,
    bool selected,
  ) {
    final theme = MorphTheme.of(context);
    final Widget? leading = _resolveLeading(segment, foreground, selected);
    final children = <Widget>[
      if (leading != null) ...<Widget>[
        leading,
        SizedBox(width: segmentedButtonTheme.iconLabelGap),
      ],
      if (segment.label != null)
        Flexible(
          child: Text(
            segment.label!,
            style: theme.typeScale.labelLarge.copyWith(color: foreground),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
          ),
        ),
    ];
    return Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: children,
    );
  }

  Widget _wrapForeground(
    MorphSegmentedButtonTheme theme,
    bool selected,
    bool enabled,
    Widget child,
  ) {
    if (!enabled) {
      return child;
    }
    final Gradient? gradient = selected
        ? theme.selectedForegroundGradient
        : theme.unselectedForegroundGradient;
    if (gradient == null) {
      return child;
    }
    return ShaderMask(
      blendMode: BlendMode.srcIn,
      shaderCallback: (Rect bounds) => gradient.createShader(bounds),
      child: child,
    );
  }

  Widget? _resolveLeading(MorphSegment<T> segment, Color foreground, bool sel) {
    if (sel && parent.showSelectedIcon) {
      return Icon(
        MorphIcons.check,
        size: segmentedButtonTheme.iconSize,
        color: foreground,
      );
    }
    if (segment.icon != null) {
      return IconTheme.merge(
        data: IconThemeData(
          color: foreground,
          size: segmentedButtonTheme.iconSize,
        ),
        child: segment.icon!,
      );
    }
    return null;
  }
}
