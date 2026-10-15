import 'package:flutter/widgets.dart';

import '../../buttons/morph_buttons.dart';

/// Text button for dialog-built actions.
///
/// Styling comes from the action [morphDialogActionScope], the same as for
/// buttons callers pass in, so every dialog action matches.
MorphButton morphDialogTextAction({
  required String label,
  required VoidCallback? onPressed,
}) {
  return MorphButton(
    style: MorphButtonStyle.text,
    onPressed: onPressed,
    child: Text(label),
  );
}

/// Applies the dialog action tokens to text buttons in [child].
///
/// [color] drives the label and hover layer; [overlay] maps states to it.
Widget morphDialogActionScope({
  required Color color,
  required TextStyle textStyle,
  required Color? Function(Color color, Set<WidgetState> states) overlay,
  required Widget child,
}) {
  return MorphButtonDecorationScope(
    styles: const <MorphButtonStyle>{MorphButtonStyle.text},
    decoration: MorphButtonDecoration(
      foregroundColor: WidgetStateProperty.resolveWith(
        (Set<WidgetState> states) =>
            states.contains(WidgetState.disabled) ? null : color,
      ),
      overlayColor: WidgetStateProperty.resolveWith(
        (Set<WidgetState> states) => overlay(color, states),
      ),
      textStyle: textStyle,
    ),
    child: child,
  );
}
