// Derived from Material 3 Expressive by Paa Developments (MIT), modified
// in 2026 for Morph Expressive (naming, layout, styling and/or motion).
// Follows Material 3 Compose design/reference patterns; direct inclusion
// of Android Open Source Project Apache-2.0 code is not established here.
// See NOTICE for original copyright and third-party attribution.

import 'dart:math' as math;
import 'dart:ui' show lerpDouble;

import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:motor/motor.dart';

import '../../foundations/foundations.dart';
import 'components/morph_slider_centered_track.dart';
import 'components/morph_slider_dot_overlay.dart';
import 'components/morph_slider_thumb.dart';
import 'components/morph_slider_track.dart';
import 'components/morph_slider_value_indicator.dart';
import 'enums/morph_slider_enums.dart';
import 'models/morph_slider_dot_builder.dart';
import 'models/morph_slider_track_icons.dart';
import 'res/morph_slider_tokens.dart';
import 'styles/morph_slider_theme.dart';
import 'utils/morph_slider_math.dart';

export 'components/morph_slider_centered_track.dart';
export 'components/morph_slider_thumb.dart';
export 'components/morph_slider_track.dart';
export 'components/morph_slider_value_indicator.dart';
export 'enums/morph_slider_enums.dart';
export 'morph_range_slider.dart';
export 'models/morph_slider_dot_builder.dart';
export 'models/morph_slider_range.dart';
export 'models/morph_slider_range_labels.dart';
export 'models/morph_slider_track_icons.dart';
export 'res/morph_slider_tokens.dart';
export 'styles/morph_slider_theme.dart';
export 'utils/morph_slider_dot_geometry.dart';
export 'utils/morph_slider_dot_layout.dart';
export 'utils/morph_slider_math.dart';
export 'utils/morph_slider_track_paint_metrics.dart';

/// A Material 3 Expressive slider.
///
/// Mirrors Compose Material 3:
/// - [MorphSlider] → `Slider` + `SliderDefaults.Track`
/// - [MorphSlider.centered] → `Slider` + `SliderDefaults.CenteredTrack`
/// - [MorphSlider.wavy] → `Slider` with a wavy active value (linear track)
/// - [MorphSlider.vertical] → `VerticalSlider`
/// - [MorphSlider.verticalCentered] → `VerticalSlider` + `CenteredTrack`
///
/// Selects a single value from a continuous or, when `divisions` is set,
/// discrete range. Disable by setting `enabled` to `false` or passing a null
/// `onChanged`.

part 'components/morph_slider_track_icons_overlay.dart';
part 'components/morph_slider_build.dart';
part 'components/morph_slider_interaction.dart';

/// MorphSlider.

class MorphSlider extends StatefulWidget {
  /// Standard horizontal slider (active track from start → thumb).
  const MorphSlider({
    required this.value,
    required this.onChanged,
    this.min = 0,
    this.max = 1,
    this.divisions,
    this.onChangeEnd,
    this.label,
    this.semanticFormatterCallback,
    this.trackIcons,
    this.thumbBuilder,
    this.trackBuilder,
    this.trackThickness,
    this.cornerRadius,
    this.thumbLength,
    this.dotSize,
    this.dotSpacing,
    this.dotBuilder,
    this.enabled = true,
    this.focusNode,
    this.autofocus = false,
    this.haptic = MorphHapticFeedback.inherit,
    this.size = MorphSliderSize.xs,
    this.semanticLabel,
    this.icon,
    this.iconPosition = MorphSliderIconPosition.end,
    this.iconSize,
    this.iconEdgeInset,
    super.key,
  }) : axis = Axis.horizontal,
       trackKind = MorphSliderTrackKind.standard,
       topToBottom = true,
       wavy = false,
       amplitude = null,
       amplitudeForProgress = null,
       wavelength = null,
       waveSpeed = null,
       assert(max > min, 'max must be greater than min.'),
       assert(
         icon == null || divisions == null,
         'icon requires divisions to be null.',
       );

  /// Horizontal slider with a centered active track.
  const MorphSlider.centered({
    required this.value,
    required this.onChanged,
    this.min = 0,
    this.max = 1,
    this.divisions,
    this.onChangeEnd,
    this.label,
    this.semanticFormatterCallback,
    this.trackIcons,
    this.thumbBuilder,
    this.trackBuilder,
    this.trackThickness,
    this.cornerRadius,
    this.thumbLength,
    this.dotSize,
    this.dotSpacing,
    this.dotBuilder,
    this.enabled = true,
    this.focusNode,
    this.autofocus = false,
    this.haptic = MorphHapticFeedback.inherit,
    this.size = MorphSliderSize.xs,
    this.semanticLabel,
    super.key,
  }) : axis = Axis.horizontal,
       trackKind = MorphSliderTrackKind.centered,
       topToBottom = true,
       wavy = false,
       amplitude = null,
       amplitudeForProgress = null,
       wavelength = null,
       waveSpeed = null,
       icon = null,
       iconPosition = MorphSliderIconPosition.end,
       iconSize = null,
       iconEdgeInset = null,
       assert(max > min, 'max must be greater than min.');

  /// Horizontal slider whose active value is a traveling sine wave.
  ///
  /// Inactive track, thumb, gaps, ticks, and interaction match [MorphSlider];
  /// only the active value segment uses the linear-wavy progress recipe.
  const MorphSlider.wavy({
    required this.value,
    required this.onChanged,
    this.min = 0,
    this.max = 1,
    this.divisions,
    this.onChangeEnd,
    this.label,
    this.semanticFormatterCallback,
    this.trackIcons,
    this.thumbBuilder,
    this.trackBuilder,
    this.trackThickness,
    this.cornerRadius,
    this.thumbLength,
    this.dotSize,
    this.dotSpacing,
    this.dotBuilder,
    this.amplitude,
    this.amplitudeForProgress,
    this.wavelength,
    this.waveSpeed,
    this.enabled = true,
    this.focusNode,
    this.autofocus = false,
    this.haptic = MorphHapticFeedback.inherit,
    this.size = MorphSliderSize.xs,
    this.semanticLabel,
    this.icon,
    this.iconPosition = MorphSliderIconPosition.end,
    this.iconSize,
    this.iconEdgeInset,
    super.key,
  }) : axis = Axis.horizontal,
       trackKind = MorphSliderTrackKind.standard,
       topToBottom = true,
       wavy = true,
       assert(max > min, 'max must be greater than min.'),
       assert(
         icon == null || divisions == null,
         'icon requires divisions to be null.',
       );

  /// Horizontal centered slider with a wavy active value segment.
  const MorphSlider.wavyCentered({
    required this.value,
    required this.onChanged,
    this.min = 0,
    this.max = 1,
    this.divisions,
    this.onChangeEnd,
    this.label,
    this.semanticFormatterCallback,
    this.trackIcons,
    this.thumbBuilder,
    this.trackBuilder,
    this.trackThickness,
    this.cornerRadius,
    this.thumbLength,
    this.dotSize,
    this.dotSpacing,
    this.dotBuilder,
    this.amplitude,
    this.amplitudeForProgress,
    this.wavelength,
    this.waveSpeed,
    this.enabled = true,
    this.focusNode,
    this.autofocus = false,
    this.haptic = MorphHapticFeedback.inherit,
    this.size = MorphSliderSize.xs,
    this.semanticLabel,
    super.key,
  }) : axis = Axis.horizontal,
       trackKind = MorphSliderTrackKind.centered,
       topToBottom = true,
       wavy = true,
       icon = null,
       iconPosition = MorphSliderIconPosition.end,
       iconSize = null,
       iconEdgeInset = null,
       assert(max > min, 'max must be greater than min.');

  /// Vertical slider (Compose `VerticalSlider`).
  ///
  /// By default [topToBottom] is `false`: [min] is at the bottom and [max] at
  /// the top (slide up to increase).
  const MorphSlider.vertical({
    required this.value,
    required this.onChanged,
    this.min = 0,
    this.max = 1,
    this.divisions,
    this.onChangeEnd,
    this.label,
    this.semanticFormatterCallback,
    this.trackIcons,
    this.thumbBuilder,
    this.trackBuilder,
    this.trackThickness,
    this.cornerRadius,
    this.thumbLength,
    this.dotSize,
    this.dotSpacing,
    this.dotBuilder,
    this.topToBottom = false,
    this.enabled = true,
    this.focusNode,
    this.autofocus = false,
    this.haptic = MorphHapticFeedback.inherit,
    this.size = MorphSliderSize.xs,
    this.semanticLabel,
    this.icon,
    this.iconPosition = MorphSliderIconPosition.end,
    this.iconSize,
    this.iconEdgeInset,
    super.key,
  }) : axis = Axis.vertical,
       trackKind = MorphSliderTrackKind.standard,
       wavy = false,
       amplitude = null,
       amplitudeForProgress = null,
       wavelength = null,
       waveSpeed = null,
       assert(max > min, 'max must be greater than min.'),
       assert(
         icon == null || divisions == null,
         'icon requires divisions to be null.',
       );

  /// Vertical slider with a centered active track.
  ///
  /// By default [topToBottom] is `false`: [min] is at the bottom and [max] at
  /// the top (slide up to increase).
  const MorphSlider.verticalCentered({
    required this.value,
    required this.onChanged,
    this.min = 0,
    this.max = 1,
    this.divisions,
    this.onChangeEnd,
    this.label,
    this.semanticFormatterCallback,
    this.trackIcons,
    this.thumbBuilder,
    this.trackBuilder,
    this.trackThickness,
    this.cornerRadius,
    this.thumbLength,
    this.dotSize,
    this.dotSpacing,
    this.dotBuilder,
    this.topToBottom = false,
    this.enabled = true,
    this.focusNode,
    this.autofocus = false,
    this.haptic = MorphHapticFeedback.inherit,
    this.size = MorphSliderSize.xs,
    this.semanticLabel,
    super.key,
  }) : axis = Axis.vertical,
       trackKind = MorphSliderTrackKind.centered,
       wavy = false,
       amplitude = null,
       amplitudeForProgress = null,
       wavelength = null,
       waveSpeed = null,
       icon = null,
       iconPosition = MorphSliderIconPosition.end,
       iconSize = null,
       iconEdgeInset = null,
       assert(max > min, 'max must be greater than min.');

  /// Current value in [min]..[max].
  final double value;

  /// Called when the value changes. Null disables the slider.
  final ValueChanged<double>? onChanged;

  /// min.

  final double min;

  /// max.
  final double max;

  /// Discrete steps between [min] and [max] (Flutter Material [divisions]).
  final int? divisions;

  /// Called when the user finishes interacting.
  final ValueChanged<double>? onChangeEnd;

  /// Static value-indicator text. When null, a numeric label is derived.
  final String? label;

  /// Formats the semantic value announced to accessibility services.
  final String Function(double value)? semanticFormatterCallback;

  /// Optional inset icons for active / inactive track segments.
  final MorphSliderTrackIcons? trackIcons;

  /// Replaces the default [MorphSliderThumb].
  final Widget Function({
    required BuildContext context,
    required MorphSliderColors colors,
    required bool pressed,
  })?
  thumbBuilder;

  /// Replaces the default track painter widget.
  final Widget Function({
    required BuildContext context,
    required MorphSliderColors colors,
    required MorphSliderTheme theme,
    required double fraction,
    required List<double> tickFractions,
    required double handleThickness,
  })?
  trackBuilder;

  /// axis.

  final Axis axis;

  /// trackKind.
  final MorphSliderTrackKind trackKind;

  /// When [axis] is vertical, `true` maps the top edge to [min].
  ///
  /// Defaults to `false` on vertical constructors so [min] is at the bottom
  /// and sliding up increases the value.
  final bool topToBottom;

  /// When true, paints the active value as a traveling sine wave.
  final bool wavy;

  /// Fixed amplitude factor `0..1` for [wavy] tracks.
  final double? amplitude;

  /// Amplitude factor as a function of progress for [wavy] tracks.
  final double Function(double progress)? amplitudeForProgress;

  /// Wave length in logical pixels ([wavy] only).
  final double? wavelength;

  /// Wave travel speed in logical pixels per second ([wavy] only).
  final double? waveSpeed;

  /// Thickness of both active and inactive tracks. Defaults to theme track height.
  final double? trackThickness;

  /// Outer corner radius for active and inactive track ends.
  ///
  /// Defaults to [MorphSliderTheme.trackCornerRadius] (fixed; not based on thickness).
  final double? cornerRadius;

  /// Length of the thumb along its long axis. Defaults to theme handle height.
  final double? thumbLength;

  /// Diameter of stop/tick markers. Defaults to theme stop indicator size.
  final double? dotSize;

  /// Clear space between each track end and the outer edge of the end dots.
  ///
  /// Defaults to theme [MorphSliderTheme.stopIndicatorTrailingSpace].
  final double? dotSpacing;

  /// Custom stop/tick markers. When null, default circular dots are painted.
  final MorphSliderDotBuilder? dotBuilder;

  /// Whether the slider responds to user interaction.
  ///
  /// The slider is also disabled when [onChanged] is null.
  final bool enabled;

  /// Focus node for keyboard/traditional focus.
  final FocusNode? focusNode;

  /// Whether this slider should be focused initially.
  final bool autofocus;

  /// Haptic feedback intensity fired on discrete value changes.
  final MorphHapticFeedback haptic;

  /// Spec size. XS uses the ambient [MorphSliderTheme] geometry.
  final MorphSliderSize size;

  /// Accessibility name. Matches the adjacent text label when set.
  final String? semanticLabel;

  /// Optional icon rendered on the relocating track end.
  ///
  /// Mutually exclusive with [divisions]. When set, track end stop dots are
  /// not drawn.
  final Widget? icon;

  /// Resting edge for [icon] along the track.
  final MorphSliderIconPosition iconPosition;

  /// Size of [icon]. Defaults to 24 logical pixels when null.
  final double? iconSize;

  /// Clear space between the track edge and [icon]'s outer edge.
  ///
  /// Defaults to [MorphSliderTheme.iconEdgeInset] (8, matching morph_core's
  /// default track corner radius).
  final double? iconEdgeInset;

  @override
  State<MorphSlider> createState() => _MorphSliderState();
}

class _MorphSliderState extends State<MorphSlider> with TickerProviderStateMixin {
  bool _pressed = false;
  bool _hovered = false;
  bool _dragging = false;
  bool _isFocusedFromPointer = false;
  bool _iconDocked = false;
  bool _ownsFocusNode = false;
  late FocusNode _focusNode;
  late final AnimationController _waveController;
  late final SingleMotionController _dockController;
  final Stopwatch _hapticStopwatch = Stopwatch();

  bool get _enabled => widget.enabled && widget.onChanged != null;
  bool get _vertical => widget.axis == Axis.vertical;

  /// Keyboard focus chrome. Hidden as soon as pointer interaction starts.
  bool get _showFocusOutline {
    if (!MorphTheme.of(context).keyboardFocusIndicators) {
      return false;
    }
    if (!_focusNode.hasFocus) {
      return false;
    }
    if (!MorphFocusInteraction.instance.ringsAllowed) {
      return false;
    }
    if (_isFocusedFromPointer) {
      return false;
    }
    return FocusManager.instance.highlightMode ==
        FocusHighlightMode.traditional;
  }

  double get _fraction =>
      MorphSliderMath.fraction(widget.value, widget.min, widget.max);

  List<double> get _ticks => MorphSliderMath.tickFractions(widget.divisions);

  @override
  void initState() {
    super.initState();
    _attachFocusNode(widget.focusNode);
    _waveController = AnimationController(
      vsync: this,
      duration: MorphMotion.extraLong2,
    );
    _dockController = SingleMotionController(
      motion: MorphMotion.springMotion(MorphSliderTheme.defaults.dockSpring),
      vsync: this,
    )..addListener(_handleDockTick);
    MorphFocusInteraction.instance.addListener(_handleFocusInteraction);
    if (widget.wavy) {
      _waveController.repeat();
    }
  }

  void _attachFocusNode(FocusNode? external) {
    _focusNode = external ?? FocusNode();
    _ownsFocusNode = external == null;
    _focusNode.addListener(_handleFocusChange);
  }

  void _detachFocusNode() {
    _focusNode.removeListener(_handleFocusChange);
    if (_ownsFocusNode) {
      _focusNode.dispose();
    }
  }

  void _handleFocusChange() {
    if (!_focusNode.hasFocus) {
      _isFocusedFromPointer = false;
    }
    setState(() {});
  }

  void _handleFocusInteraction() {
    if (mounted) {
      setState(() {});
    }
  }

  void _handleDockTick() {
    if (mounted) {
      setState(() {});
    }
  }

  @override
  void didUpdateWidget(MorphSlider oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.focusNode != oldWidget.focusNode) {
      _detachFocusNode();
      _attachFocusNode(widget.focusNode);
    }
    if (widget.wavy) {
      if (!_waveController.isAnimating) {
        _waveController.repeat();
      }
    } else if (_waveController.isAnimating) {
      _waveController.stop();
    }
  }

  @override
  void dispose() {
    MorphFocusInteraction.instance.removeListener(_handleFocusInteraction);
    _dockController
      ..removeListener(_handleDockTick)
      ..dispose();
    _detachFocusNode();
    _waveController.dispose();
    super.dispose();
  }

  double _phase(double wavelength, double waveSpeed) {
    final Duration elapsed =
        _waveController.lastElapsedDuration ?? Duration.zero;
    final double seconds = elapsed.inMicroseconds / 1e6;
    if (wavelength <= 0) {
      return 0;
    }
    return seconds * waveSpeed / wavelength * 2 * math.pi;
  }

  double _amplitudeFactor(MorphSliderTheme theme) {
    if (widget.amplitudeForProgress != null) {
      return widget.amplitudeForProgress!(_fraction).clamp(0.0, 1.0);
    }
    if (widget.amplitude != null) {
      return widget.amplitude!.clamp(0.0, 1.0);
    }
    return theme.amplitudeForProgress(_fraction).clamp(0.0, 1.0);
  }

  @override
  Widget build(BuildContext context) {
    final _MorphSliderResolved resolved = _resolve(context);
    return MorphComponentTheme(
      builder: (BuildContext context) {
        return Semantics(
          slider: true,
          label: widget.semanticLabel,
          enabled: _enabled,
          value:
              widget.semanticFormatterCallback?.call(widget.value) ??
              resolved.indicatorLabel,
          child: LayoutBuilder(
            builder: (BuildContext context, BoxConstraints constraints) {
              return _buildLayout(context, constraints, resolved);
            },
          ),
        );
      },
    );
  }
}
