import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:morph_expressive/components/dropdown_menus/morph_dropdown_menus.dart'
    show MorphDropdownMenu;
import 'package:morph_expressive/morph_components.dart' show MorphDropdownMenu;
import 'package:material_ui/material_ui.dart';

import '../enums/morph_dropdown_expand_direction.dart';

/// MorphDropdownPanelStyle.

@immutable
class MorphDropdownPanelStyle with Diagnosticable {
  /// Background color of the dropdown panel.
  final Color? backgroundColor;

  /// Elevation of the dropdown panel.
  final double elevation;

  /// Maximum height of the dropdown panel.
  final double maxHeight;

  /// Gap between the field and the dropdown panel.
  final double marginTop;

  /// Text shown when search yields no matches. Ignored when `emptyBuilder` is not null.
  final String noItemsFoundText;

  /// An optional header widget shown above the items.
  final Widget? header;

  /// An optional footer widget shown below the items.
  final Widget? footer;

  /// Padding applied around the item list inside the dropdown panel.
  ///
  /// Defaults to `EdgeInsets.all(8)`.
  final EdgeInsetsGeometry contentPadding;

  /// The direction in which the dropdown expands.
  ///
  /// Defaults to [MorphDropdownExpandDirection.auto], which automatically determines
  /// the direction based on available screen space.
  final MorphDropdownExpandDirection expandDirection;

  /// Radius applied to the dropdown panel container.
  ///
  /// When set, overrides the widget-level [MorphDropdownMenu.containerRadius].
  final double? containerRadius;

  /// Creates a [MorphDropdownPanelStyle].
  const MorphDropdownPanelStyle({
    this.backgroundColor,
    this.elevation = 3,
    this.maxHeight = 350,
    this.marginTop = 4,
    this.noItemsFoundText = 'No items found',
    this.header,
    this.footer,
    this.contentPadding = const EdgeInsets.all(8),
    this.expandDirection = MorphDropdownExpandDirection.auto,
    this.containerRadius,
  });

  /// Creates a copy of this style with the given fields replaced.
  MorphDropdownPanelStyle copyWith({
    Color? backgroundColor,
    double? elevation,
    double? maxHeight,
    double? marginTop,
    String? noItemsFoundText,
    Widget? header,
    Widget? footer,
    EdgeInsetsGeometry? contentPadding,
    MorphDropdownExpandDirection? expandDirection,
    double? containerRadius,
  }) {
    return MorphDropdownPanelStyle(
      backgroundColor: backgroundColor ?? this.backgroundColor,
      elevation: elevation ?? this.elevation,
      maxHeight: maxHeight ?? this.maxHeight,
      marginTop: marginTop ?? this.marginTop,
      noItemsFoundText: noItemsFoundText ?? this.noItemsFoundText,
      header: header ?? this.header,
      footer: footer ?? this.footer,
      contentPadding: contentPadding ?? this.contentPadding,
      expandDirection: expandDirection ?? this.expandDirection,
      containerRadius: containerRadius ?? this.containerRadius,
    );
  }

  /// Linearly interpolate between two dropdown styles.
  static MorphDropdownPanelStyle lerp(
    MorphDropdownPanelStyle? a,
    MorphDropdownPanelStyle? b,
    double t,
  ) {
    if (a == null && b == null) {
      return const MorphDropdownPanelStyle();
    }
    return MorphDropdownPanelStyle(
      backgroundColor: Color.lerp(a?.backgroundColor, b?.backgroundColor, t),
      elevation: lerpDouble(a?.elevation, b?.elevation, t) ?? 3,
      maxHeight: lerpDouble(a?.maxHeight, b?.maxHeight, t) ?? 350,
      marginTop: lerpDouble(a?.marginTop, b?.marginTop, t) ?? 4,
      noItemsFoundText: t < 0.5
          ? (a?.noItemsFoundText ?? 'No items found')
          : (b?.noItemsFoundText ?? 'No items found'),
      header: t < 0.5 ? a?.header : b?.header,
      footer: t < 0.5 ? a?.footer : b?.footer,
      contentPadding:
          EdgeInsetsGeometry.lerp(a?.contentPadding, b?.contentPadding, t) ??
          const EdgeInsets.all(8),
      expandDirection: t < 0.5
          ? (a?.expandDirection ?? MorphDropdownExpandDirection.auto)
          : (b?.expandDirection ?? MorphDropdownExpandDirection.auto),
      containerRadius: lerpDouble(a?.containerRadius, b?.containerRadius, t),
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MorphDropdownPanelStyle &&
          backgroundColor == other.backgroundColor &&
          elevation == other.elevation &&
          maxHeight == other.maxHeight &&
          marginTop == other.marginTop &&
          noItemsFoundText == other.noItemsFoundText &&
          header == other.header &&
          footer == other.footer &&
          contentPadding == other.contentPadding &&
          expandDirection == other.expandDirection &&
          containerRadius == other.containerRadius;

  @override
  int get hashCode => Object.hash(
    backgroundColor,
    elevation,
    maxHeight,
    marginTop,
    noItemsFoundText,
    header,
    footer,
    contentPadding,
    expandDirection,
    containerRadius,
  );

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties
      ..add(ColorProperty('backgroundColor', backgroundColor))
      ..add(DoubleProperty('elevation', elevation))
      ..add(DoubleProperty('maxHeight', maxHeight))
      ..add(DoubleProperty('marginTop', marginTop))
      ..add(
        DiagnosticsProperty<EdgeInsetsGeometry>(
          'contentPadding',
          contentPadding,
        ),
      )
      ..add(
        EnumProperty<MorphDropdownExpandDirection>(
          'expandDirection',
          expandDirection,
        ),
      )
      ..add(DoubleProperty('containerRadius', containerRadius));
  }
}
