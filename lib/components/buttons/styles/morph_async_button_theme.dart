import 'package:flutter/foundation.dart';

import '../../../foundations/theme/morph_theme_extension.dart';
import '../components/morph_operation_glyph.dart';
import '../morph_operation_state.dart';
import 'morph_button_decoration.dart';

/// Operation timing is independent of the button's 90/160 ms press profile.
@immutable
class MorphAsyncButtonTheme extends MorphThemeExtension<MorphAsyncButtonTheme> {
  const MorphAsyncButtonTheme({
    this.transitionDuration = const Duration(milliseconds: 280),
    this.decorations = const {},
    this.iconTransition = MorphOperationIconTransition.defaults,
  });
  static const defaults = MorphAsyncButtonTheme();
  final Duration transitionDuration;
  final Map<MorphOperationState, MorphButtonDecoration> decorations;

  /// Status glyph entry (loading → success etc.); widget value takes priority.
  final MorphOperationIconTransition iconTransition;
  @override
  MorphAsyncButtonTheme copyWith({
    Duration? transitionDuration,
    Map<MorphOperationState, MorphButtonDecoration>? decorations,
    MorphOperationIconTransition? iconTransition,
  }) => MorphAsyncButtonTheme(
    iconTransition: iconTransition ?? this.iconTransition,
    transitionDuration: transitionDuration ?? this.transitionDuration,
    decorations: decorations ?? this.decorations,
  );
  @override
  MorphAsyncButtonTheme lerp(MorphAsyncButtonTheme? other, double t) =>
      other == null
      ? this
      : MorphAsyncButtonTheme(
          transitionDuration: Duration(
            microseconds:
                (transitionDuration.inMicroseconds +
                        (other.transitionDuration.inMicroseconds -
                                transitionDuration.inMicroseconds) *
                            t)
                    .round(),
          ),
          decorations: t < .5 ? decorations : other.decorations,
          iconTransition: t < .5 ? iconTransition : other.iconTransition,
        );
  @override
  bool operator ==(Object other) =>
      other is MorphAsyncButtonTheme &&
      transitionDuration == other.transitionDuration &&
      iconTransition == other.iconTransition &&
      mapEquals(decorations, other.decorations);
  @override
  int get hashCode => Object.hash(
    transitionDuration,
    iconTransition,
    Object.hashAllUnordered(
      decorations.entries.map((e) => Object.hash(e.key, e.value)),
    ),
  );
}
