import 'package:flutter/widgets.dart';

import '../../../foundations/foundations.dart';
import '../../icon_buttons/morph_icon_buttons.dart';
import '../styles/morph_side_sheet_theme.dart';

/// Back or close icon button of a side sheet.
///
/// Uses the sheet action tokens: on surface variant at rest, primary icon
/// and state layer while hovered (0.08), focused (0.1) or pressed (0.1).
class MorphSideSheetIconAction extends StatefulWidget {
  /// MorphSideSheetIconAction.
  const MorphSideSheetIconAction({
    required this.theme,
    required this.icon,
    required this.label,
    required this.onPressed,
    this.autofocus = false,
    super.key,
  });

  /// Resolved sheet theme.
  final MorphSideSheetTheme theme;

  /// Glyph.
  final Widget icon;

  /// Tooltip and semantics label.
  final String label;

  /// Called on tap, Space or Enter.
  final VoidCallback onPressed;

  /// Whether to take focus when first built.
  final bool autofocus;

  @override
  State<MorphSideSheetIconAction> createState() => _MorphSideSheetIconActionState();
}

class _MorphSideSheetIconActionState extends State<MorphSideSheetIconAction> {
  final WidgetStatesController _states = WidgetStatesController();

  @override
  void dispose() {
    _states.dispose();
    super.dispose();
  }

  // Focus only counts while keyboard rings are allowed, so a pointer tap
  // never leaves a tinted layer behind.
  bool _focused(Set<WidgetState> states) =>
      states.contains(WidgetState.focused) &&
      MorphFocusInteraction.instance.ringsAllowed;

  Color? _overlay(Set<WidgetState> states, Color layer) {
    final MorphSideSheetActionStyle a = widget.theme.action;
    if (states.contains(WidgetState.disabled)) {
      return null;
    }
    if (states.contains(WidgetState.pressed)) {
      return layer.withValues(alpha: a.pressedOpacity);
    }
    if (_focused(states)) {
      return layer.withValues(alpha: a.focusOpacity);
    }
    if (states.contains(WidgetState.hovered)) {
      return layer.withValues(alpha: a.hoverOpacity);
    }
    return const Color(0x00000000);
  }

  @override
  Widget build(BuildContext context) {
    final MorphColorScheme scheme = MorphTheme.of(context).colorScheme;
    final MorphSideSheetActionStyle a = widget.theme.action;
    final Color rest = widget.theme.iconColor(scheme);
    final Color active = a.activeColor ?? scheme.primary;
    final Color layer = a.stateLayerColor ?? scheme.primary;
    return ListenableBuilder(
      listenable: Listenable.merge(<Listenable>[
        _states,
        MorphFocusInteraction.instance,
      ]),
      builder: (BuildContext context, _) {
        final Set<WidgetState> s = _states.value;
        final bool on =
            s.contains(WidgetState.hovered) ||
            s.contains(WidgetState.pressed) ||
            _focused(s);
        return MorphIconButton(
          variant: MorphIconButtonVariant.standard,
          icon: widget.icon,
          onPressed: widget.onPressed,
          tooltip: widget.label,
          semanticLabel: widget.label,
          autofocus: widget.autofocus,
          statesController: _states,
          decoration: MorphIconButtonDecoration(
            foregroundColor: WidgetStatePropertyAll<Color?>(on ? active : rest),
            overlayColor: WidgetStateProperty.resolveWith(
              (Set<WidgetState> states) => _overlay(states, layer),
            ),
          ),
        );
      },
    );
  }
}
