import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:material_ui/material_ui.dart'
    show
        BorderRadius,
        Color,
        ColorProperty,
        EdgeInsets,
        EdgeInsetsGeometry,
        MouseCursor,
        TextStyle,
        Widget,
        immutable;

/// MorphDropdownSearchStyle.

@immutable
class MorphDropdownSearchStyle with Diagnosticable {
  /// Hint text shown in the search field.
  final String hintText;

  /// Search field hint style.
  final TextStyle? hintStyle;

  /// Search field text style.
  final TextStyle? textStyle;

  /// Fill color for the search field.
  final Color? fillColor;

  /// Whether the search field is filled.
  final bool filled;

  /// Whether to auto-focus the search field when the dropdown opens.
  final bool autofocus;

  /// Whether to show a clear‐search icon.
  final bool showClearIcon;

  /// Icono inicial personalizado del buscador.
  ///
  /// Cuando es null, se utiliza el icono Fluent predeterminado.
  final Widget? searchIcon;

  /// Custom clear icon widget for the search field.
  final Widget? clearIcon;

  /// The debounce duration in milliseconds for search input.
  ///
  /// When set to a value greater than 0, search callbacks will
  /// only fire after the user stops typing for this duration.
  /// Defaults to 0 (no debounce).
  final int searchDebounceMs;

  /// Border radius of the search field.
  ///
  /// When null, falls back to the panel container radius.
  final BorderRadius? borderRadius;

  /// Content padding inside the search text field.
  ///
  /// Defaults to `EdgeInsets.symmetric(horizontal: 12, vertical: 8)`.
  final EdgeInsetsGeometry contentPadding;

  /// Altura minima del buscador. Por defecto 52dp.
  final double minHeight;

  /// Outer margin (padding around the search field container).
  ///
  /// Defaults to `EdgeInsets.fromLTRB(8, 8, 8, 4)`.
  final EdgeInsetsGeometry margin;

  /// Ajusta automaticamente los margenes horizontales al padding del panel.
  ///
  /// Si es false, se respeta [margin] de forma completa.
  final bool alignWithPanelPadding;

  /// Mouse cursor when hovering over the search field.
  final MouseCursor? mouseCursor;

  /// Creates a [MorphDropdownSearchStyle].
  const MorphDropdownSearchStyle({
    this.hintText = 'Search…',
    this.hintStyle,
    this.textStyle,
    this.fillColor,
    this.filled = true,
    this.autofocus = false,
    this.showClearIcon = true,
    this.clearIcon,
    this.searchIcon,
    this.searchDebounceMs = 0,
    this.minHeight = 52,
    this.borderRadius,
    this.contentPadding = const EdgeInsets.symmetric(
      horizontal: 12,
      vertical: 8,
    ),
    this.margin = const EdgeInsets.fromLTRB(8, 8, 8, 4),
    this.alignWithPanelPadding = true,
    this.mouseCursor,
  });

  /// Creates a copy of this style with the given fields replaced.
  MorphDropdownSearchStyle copyWith({
    String? hintText,
    TextStyle? hintStyle,
    TextStyle? textStyle,
    Color? fillColor,
    bool? filled,
    bool? autofocus,
    bool? showClearIcon,
    Widget? clearIcon,
    Widget? searchIcon,
    int? searchDebounceMs,
    double? minHeight,
    BorderRadius? borderRadius,
    EdgeInsetsGeometry? contentPadding,
    EdgeInsetsGeometry? margin,
    MouseCursor? mouseCursor,
    bool? alignWithPanelPadding,
  }) {
    return MorphDropdownSearchStyle(
      hintText: hintText ?? this.hintText,
      hintStyle: hintStyle ?? this.hintStyle,
      textStyle: textStyle ?? this.textStyle,
      fillColor: fillColor ?? this.fillColor,
      filled: filled ?? this.filled,
      autofocus: autofocus ?? this.autofocus,
      showClearIcon: showClearIcon ?? this.showClearIcon,
      clearIcon: clearIcon ?? this.clearIcon,
      searchIcon: searchIcon ?? this.searchIcon,
      searchDebounceMs: searchDebounceMs ?? this.searchDebounceMs,
      minHeight: minHeight ?? this.minHeight,
      borderRadius: borderRadius ?? this.borderRadius,
      contentPadding: contentPadding ?? this.contentPadding,
      margin: margin ?? this.margin,
      mouseCursor: mouseCursor ?? this.mouseCursor,
      alignWithPanelPadding:
          alignWithPanelPadding ?? this.alignWithPanelPadding,
    );
  }

  /// Linearly interpolate between two search styles.
  static MorphDropdownSearchStyle lerp(
    MorphDropdownSearchStyle? a,
    MorphDropdownSearchStyle? b,
    double t,
  ) {
    if (a == null && b == null) {
      return const MorphDropdownSearchStyle();
    }
    return MorphDropdownSearchStyle(
      hintText: t < 0.5
          ? (a?.hintText ?? 'Search…')
          : (b?.hintText ?? 'Search…'),
      hintStyle: TextStyle.lerp(a?.hintStyle, b?.hintStyle, t),
      textStyle: TextStyle.lerp(a?.textStyle, b?.textStyle, t),
      fillColor: Color.lerp(a?.fillColor, b?.fillColor, t),
      filled: t < 0.5 ? (a?.filled ?? true) : (b?.filled ?? true),
      autofocus: t < 0.5 ? (a?.autofocus ?? false) : (b?.autofocus ?? false),
      showClearIcon: t < 0.5
          ? (a?.showClearIcon ?? true)
          : (b?.showClearIcon ?? true),
      clearIcon: t < 0.5 ? a?.clearIcon : b?.clearIcon,
      searchIcon: t < 0.5 ? a?.searchIcon : b?.searchIcon,
      searchDebounceMs:
          lerpDouble(
            a?.searchDebounceMs.toDouble(),
            b?.searchDebounceMs.toDouble(),
            t,
          )?.round() ??
          0,
      minHeight: lerpDouble(a?.minHeight, b?.minHeight, t) ?? 48,
      borderRadius: BorderRadius.lerp(a?.borderRadius, b?.borderRadius, t),
      contentPadding:
          EdgeInsetsGeometry.lerp(a?.contentPadding, b?.contentPadding, t) ??
          const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      margin:
          EdgeInsetsGeometry.lerp(a?.margin, b?.margin, t) ??
          const EdgeInsets.fromLTRB(8, 8, 8, 4),
      mouseCursor: t < 0.5 ? a?.mouseCursor : b?.mouseCursor,
      alignWithPanelPadding: t < 0.5
          ? (a?.alignWithPanelPadding ?? true)
          : (b?.alignWithPanelPadding ?? true),
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MorphDropdownSearchStyle &&
          hintText == other.hintText &&
          hintStyle == other.hintStyle &&
          textStyle == other.textStyle &&
          fillColor == other.fillColor &&
          filled == other.filled &&
          autofocus == other.autofocus &&
          showClearIcon == other.showClearIcon &&
          clearIcon == other.clearIcon &&
          searchIcon == other.searchIcon &&
          searchDebounceMs == other.searchDebounceMs &&
          minHeight == other.minHeight &&
          borderRadius == other.borderRadius &&
          contentPadding == other.contentPadding &&
          margin == other.margin &&
          mouseCursor == other.mouseCursor &&
          alignWithPanelPadding == other.alignWithPanelPadding;

  @override
  int get hashCode => Object.hash(
    hintText,
    hintStyle,
    textStyle,
    fillColor,
    filled,
    autofocus,
    showClearIcon,
    clearIcon,
    searchIcon,
    searchDebounceMs,
    minHeight,
    borderRadius,
    contentPadding,
    margin,
    mouseCursor,
    alignWithPanelPadding,
  );

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties
      ..add(StringProperty('hintText', hintText))
      ..add(ColorProperty('fillColor', fillColor))
      ..add(DiagnosticsProperty<BorderRadius>('borderRadius', borderRadius));
  }
}
