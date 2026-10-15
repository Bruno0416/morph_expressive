import 'package:flutter/widgets.dart';

import '../styles/morph_expandable_style.dart';

/// How expanded content under an expandable row is presented.
enum MorphExpandableExpandedType {
  /// A nested list widget rendered as sibling cards below the header.
  ///
  /// Typically a card-backed list so selection/reorder use the list's own
  /// implementation. A configurable top gap separates the header card from the
  /// nested list.
  list,

  /// A single freeform widget inside the expanded header body.
  content,

  /// A full-screen container transform. The row stays collapsed in place.
  transform,
}

/// Expanded content for an expandable list item.
///
/// Use [MorphExpandableExpanded.list] for a nested list widget (e.g. a
/// card-backed list), or [MorphExpandableExpanded.content] for freeform body
/// content.
@immutable
class MorphExpandableExpanded {
  /// Nested list expansion (sibling cards below the header).
  ///
  /// Pass a list widget such as a card-backed list so selection and reorder
  /// come from that list. [topGap] defaults to the expandable style gap when
  /// null.
  const MorphExpandableExpanded.list(this.child, {this.topGap})
    : type = MorphExpandableExpandedType.list;

  /// Single freeform expanded child inside the header card.
  const MorphExpandableExpanded.content(this.child)
    : type = MorphExpandableExpandedType.content,
      topGap = null;

  /// Full-screen morph. [child] is the destination surface.
  const MorphExpandableExpanded.transform(this.child)
    : type = MorphExpandableExpandedType.transform,
      topGap = null;

  /// Presentation kind.
  final MorphExpandableExpandedType type;

  /// Expanded child — a list widget for [MorphExpandableExpandedType.list], or
  /// freeform for [MorphExpandableExpandedType.content].
  final Widget child;

  /// Gap between the parent header card and the nested list.
  ///
  /// Only used when [type] is [MorphExpandableExpandedType.list]. When null,
  /// the expandable style's [MorphExpandableStyle.gap] is used.
  final double? topGap;

  /// Whether this is a nested-list expansion.
  bool get isList => type == MorphExpandableExpandedType.list;

  /// Whether this is a freeform content expansion.
  bool get isContent => type == MorphExpandableExpandedType.content;

  /// Whether a tap opens a full-screen container transform.
  bool get isTransform => type == MorphExpandableExpandedType.transform;
}
