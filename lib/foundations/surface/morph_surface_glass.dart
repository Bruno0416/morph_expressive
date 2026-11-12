import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

/// Reusable frosted-glass configuration for Morph floating surfaces.
///
/// A single immutable configuration drives the backdrop blur, tint,
/// transparency and border of dropdown panels, menus, dialogs, sheets,
/// tooltips and any other floating surface that exposes a `glass` parameter.
///
/// Resolution rules:
/// - A widget with an explicit [glass] uses its own configuration.
/// - When the widget parameter is null, the surface inherits
///   [MorphThemeData.floatingSurfaceGlass].
/// - When both are null the surface keeps its original opaque appearance.
/// - [MorphSurfaceGlass.disabled] overrides an active global configuration.
@immutable
class MorphSurfaceGlass with Diagnosticable {
  /// Creates a frosted surface configuration.
  ///
  /// [blurX] and [blurY] are Gaussian blur sigmas in logical pixels; setting
  /// both to zero disables only the blur while keeping the tint and border.
  /// [tint] defaults to each surface's own semantic background color, never a
  /// forced gray, white or black, and [tintOpacity] fades it independently of
  /// the blur. A border is painted only when [borderColor] is set and
  /// [borderWidth] is greater than zero.
  const MorphSurfaceGlass({
    this.enabled = true,
    this.blurX = 12,
    this.blurY = 12,
    this.tint,
    this.tintOpacity = 0.65,
    this.borderColor,
    this.borderWidth = 0,
    this.blendMode = BlendMode.srcOver,
    this.opaqueInHighContrast = true,
    this.webBackdropBlur = true,
    this.boundedBlur = false,
  }) : assert(blurX >= 0, 'blurX must be >= 0'),
       assert(blurY >= 0, 'blurY must be >= 0'),
       assert(
         tintOpacity >= 0 && tintOpacity <= 1,
         'tintOpacity must be between 0 and 1',
       ),
       assert(borderWidth >= 0, 'borderWidth must be >= 0');

  /// A configuration that forces the classic opaque surface on one widget,
  /// overriding any active [MorphThemeData.floatingSurfaceGlass].
  const MorphSurfaceGlass.disabled()
    : enabled = false,
      blurX = 0,
      blurY = 0,
      tint = null,
      tintOpacity = 0,
      borderColor = null,
      borderWidth = 0,
      blendMode = BlendMode.srcOver,
      opaqueInHighContrast = true,
      webBackdropBlur = true,
      boundedBlur = false;

  /// When false the host surface renders its original opaque appearance and
  /// pays no backdrop-filter cost.
  final bool enabled;

  /// Gaussian blur strength on each axis, in logical pixels.
  ///
  /// Zero on both axes keeps the tint and border but mounts no
  /// [BackdropFilter]. Larger values are more expensive over moving content.
  final double blurX;
  final double blurY;

  /// Tint painted over the blurred backdrop. Null derives it from the host
  /// surface's semantic background color.
  final Color? tint;

  /// Opacity applied to the tint. Zero removes the tint layer without
  /// disabling the blur; one makes the frosted surface fully opaque.
  final double tintOpacity;

  /// Optional hairline painted along the inside of the surface outline.
  final Color? borderColor;
  final double borderWidth;

  /// Blend mode used when the backdrop filter samples the layer behind.
  final BlendMode blendMode;

  /// Falls back to an opaque surface under the system high-contrast
  /// accessibility preference.
  final bool opaqueInHighContrast;

  /// Whether Flutter Web uses a real backdrop blur. Set false to paint the
  /// tint and border without resampling the backdrop on web; native targets
  /// keep using real blur.
  final bool webBackdropBlur;

  /// Opt into Flutter's layout-aware bounded Gaussian backdrop sampling.
  ///
  /// This restricts sampling at the surface boundary, changing edge colors.
  /// It is an experimental quality/performance choice, NOT a guaranteed
  /// speed-up. Defaults to false so existing frosted surfaces look identical.
  final bool boundedBlur;

  /// Whether a real backdrop filter should be mounted for the current
  /// platform and blur strengths.
  bool get wantsBlur =>
      enabled && (blurX > 0 || blurY > 0) && (!kIsWeb || webBackdropBlur);

  /// Returns a copy with the given fields replaced.
  MorphSurfaceGlass copyWith({
    bool? enabled,
    double? blurX,
    double? blurY,
    Color? tint,
    double? tintOpacity,
    Color? borderColor,
    double? borderWidth,
    BlendMode? blendMode,
    bool? opaqueInHighContrast,
    bool? webBackdropBlur,
    bool? boundedBlur,
  }) {
    return MorphSurfaceGlass(
      enabled: enabled ?? this.enabled,
      blurX: blurX ?? this.blurX,
      blurY: blurY ?? this.blurY,
      tint: tint ?? this.tint,
      tintOpacity: tintOpacity ?? this.tintOpacity,
      borderColor: borderColor ?? this.borderColor,
      borderWidth: borderWidth ?? this.borderWidth,
      blendMode: blendMode ?? this.blendMode,
      opaqueInHighContrast: opaqueInHighContrast ?? this.opaqueInHighContrast,
      webBackdropBlur: webBackdropBlur ?? this.webBackdropBlur,
      boundedBlur: boundedBlur ?? this.boundedBlur,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is MorphSurfaceGlass &&
        other.enabled == enabled &&
        other.blurX == blurX &&
        other.blurY == blurY &&
        other.tint == tint &&
        other.tintOpacity == tintOpacity &&
        other.borderColor == borderColor &&
        other.borderWidth == borderWidth &&
        other.blendMode == blendMode &&
        other.opaqueInHighContrast == opaqueInHighContrast &&
        other.webBackdropBlur == webBackdropBlur &&
        other.boundedBlur == boundedBlur;
  }

  @override
  int get hashCode => Object.hash(
    enabled,
    blurX,
    blurY,
    tint,
    tintOpacity,
    borderColor,
    borderWidth,
    blendMode,
    opaqueInHighContrast,
    webBackdropBlur,
    boundedBlur,
  );

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties
      ..add(FlagProperty('enabled', value: enabled, ifFalse: 'disabled'))
      ..add(DoubleProperty('blurX', blurX))
      ..add(DoubleProperty('blurY', blurY))
      ..add(ColorProperty('tint', tint))
      ..add(DoubleProperty('tintOpacity', tintOpacity))
      ..add(ColorProperty('borderColor', borderColor))
      ..add(DoubleProperty('borderWidth', borderWidth))
      ..add(DiagnosticsProperty<BlendMode>('blendMode', blendMode))
      ..add(
        FlagProperty(
          'opaqueInHighContrast',
          value: opaqueInHighContrast,
          ifFalse: 'keep blur in high contrast',
        ),
      )
      ..add(
        FlagProperty(
          'webBackdropBlur',
          value: webBackdropBlur,
          ifFalse: 'no backdrop blur on web',
        ),
      )
      ..add(FlagProperty('boundedBlur', value: boundedBlur, ifTrue: 'bounded'));
  }
}
