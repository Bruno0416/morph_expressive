import 'package:flutter/widgets.dart';

import '../../buttons/enums/morph_button_enums.dart';
import '../enums/morph_button_group_enums.dart';

/// Ambient group configuration for descendant buttons.
///
/// Inserted by `MorphButtonGroup`. Descendants read [maybeOf] / [of] for
/// [type], [shape], [size], [density], and [direction].
@immutable
class MorphButtonGroupScope extends InheritedWidget {
  /// Creates a scope with the group's shared configuration.
  const MorphButtonGroupScope({
    super.key,
    required super.child,
    required this.type,
    required this.shape,
    required this.size,
    required this.density,
    required this.direction,
  });

  /// Visual connection variant of the enclosing group.
  final MorphButtonGroupType type;

  /// Default corner strategy for actions in the group.
  final MorphButtonShape shape;

  /// Size token applied to every action.
  final MorphButtonSize size;

  /// Density level applied to container height.
  final MorphButtonGroupDensity density;

  /// Main layout axis of the group.
  final Axis direction;

  /// Whether [type] is [MorphButtonGroupType.connected].
  bool get isConnected => type == MorphButtonGroupType.connected;

  /// Nearest scope, or null if this context is outside a group.
  static MorphButtonGroupScope? maybeOf(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<MorphButtonGroupScope>();

  /// Nearest scope; throws if none is found.
  static MorphButtonGroupScope of(BuildContext context) {
    final scope = maybeOf(context);
    assert(
      scope != null,
      'MorphButtonGroupScope.of() called with no MorphButtonGroupScope ancestor.\n'
      'Ensure the widget is a descendant of MorphButtonGroup.',
    );
    return scope!;
  }

  @override
  bool updateShouldNotify(MorphButtonGroupScope old) =>
      type != old.type ||
      shape != old.shape ||
      size != old.size ||
      density != old.density ||
      direction != old.direction;
}
