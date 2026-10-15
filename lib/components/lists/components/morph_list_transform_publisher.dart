import 'package:flutter/widgets.dart';

import 'morph_list_transform_scope.dart';

/// Publishes [destination] to the enclosing list row surface.
class MorphListTransformPublisher extends StatelessWidget {
  /// Creates a publisher.
  const MorphListTransformPublisher({
    required this.child,
    this.destination,
    super.key,
  });

  /// Full-screen surface. Null leaves the row's current tap behavior.
  final Widget? destination;

  /// Row content.
  final Widget child;

  @override
  Widget build(BuildContext context) {
    MorphListTransformScope.maybeOf(context)?.publish(destination);
    return child;
  }
}
