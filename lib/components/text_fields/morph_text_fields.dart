import 'dart:ui' show lerpDouble;

import 'package:flutter/foundation.dart' show defaultTargetPlatform;
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:material_ui/material_ui.dart' show AdaptiveTextSelectionToolbar;
import 'package:motor/motor.dart';

import '../../foundations/foundations.dart';
import 'components/morph_text_field_affordance.dart';
import 'components/morph_text_field_container_painter.dart';
import 'components/morph_text_field_label.dart';
import 'components/morph_text_field_selection_builder.dart';
import 'components/morph_text_field_supporting_row.dart';
import 'enums/morph_text_field_slot_alignment.dart';
import 'enums/morph_text_field_variant.dart';
import 'models/morph_text_field_colors.dart';
import 'models/morph_text_field_states.dart';
import 'styles/morph_text_field_theme.dart';
import 'utils/morph_text_field_autofill_client.dart';
import 'utils/morph_text_field_selection_controls.dart';

export 'enums/morph_text_field_slot_alignment.dart';
export 'enums/morph_text_field_variant.dart';
export 'models/morph_text_field_colors.dart';
export 'models/morph_text_field_states.dart';
export 'styles/morph_text_field_color_theme.dart';
export 'styles/morph_text_field_theme.dart';

part 'components/morph_text_field_build.dart';

/// Builds the character counter label for assistive tech.
typedef MorphTextFieldCounterLabelBuilder = String Function(
  int count,
  int maxLength,
);

/// Default counter label: "Character count, N of M characters entered".
String morphTextFieldCounterLabel(int count, int maxLength) =>
    'Character count, $count of $maxLength characters entered';

/// Default context menu: the platform adaptive selection toolbar.
Widget morphDefaultTextFieldContextMenuBuilder(
  BuildContext context,
  EditableTextState editableTextState,
) {
  return AdaptiveTextSelectionToolbar.editableText(
    editableTextState: editableTextState,
  );
}

/// A Material 3 Expressive text field.
///
/// Comes in the filled and outlined variants. The label rests in the middle of
/// an empty field and springs to the top when the field is focused or
/// populated. Supports leading and trailing icons, prefix and suffix text, a
/// placeholder, supporting or error text, a character counter, single-line,
/// multi-line and text-area input, read-only and required fields, hover,
/// focus, error and disabled states, and a keyboard focus ring.
class MorphTextField extends StatefulWidget {
  /// MorphTextField.
  const MorphTextField({
    this.controller,
    this.focusNode,
    this.label,
    this.supportingText,
    this.errorText,
    this.leading,
    this.trailing,
    this.variant = MorphTextFieldVariant.filled,
    this.obscureText = false,
    this.enabled = true,
    this.keyboardType,
    this.textInputAction,
    this.inputFormatters,
    this.onChanged,
    this.onSubmitted,
    this.onTapOutside,
    this.maxLines = 1,
    this.minLines,
    this.readOnly = false,
    this.autofocus = false,
    this.isRequired = false,
    this.prefixText,
    this.suffixText,
    this.prefixSemanticsLabel,
    this.suffixSemanticsLabel,
    this.placeholder,
    this.maxLength,
    this.showCounter,
    this.counterSemanticsLabelBuilder = morphTextFieldCounterLabel,
    this.supportingTextOnFocusOnly = false,
    this.showErrorIcon = true,
    this.showClearButton = false,
    this.showPasswordToggle = false,
    this.clearButtonSemanticsLabel = 'Clear',
    this.showPasswordSemanticsLabel = 'Show password',
    this.hidePasswordSemanticsLabel = 'Hide password',
    this.errorIconSemanticsLabel = 'Error',
    this.mouseCursor,
    this.contextMenuBuilder = morphDefaultTextFieldContextMenuBuilder,
    this.textCapitalization = TextCapitalization.none,
    this.textAlign = TextAlign.start,
    this.density,
    this.iconAlignment,
    this.affixAlignment,
    this.theme,
    this.onTap,
    this.onEditingComplete,
    super.key,
  }) : assert(
         !obscureText || maxLines == 1,
         'Obscured text fields cannot be multi-line.',
       ),
       assert(
         !showPasswordToggle || maxLines == 1,
         'The password toggle needs a single-line field.',
       );

  /// controller.
  final TextEditingController? controller;

  /// focusNode.
  final FocusNode? focusNode;

  /// Label text. It is also the field's accessibility label.
  final String? label;

  /// Supporting text below the field.
  final String? supportingText;

  /// Error text. Replaces [supportingText] and puts the field in error.
  final String? errorText;

  /// Leading icon or 24dp image.
  final Widget? leading;

  /// Trailing icon or 24dp image.
  final Widget? trailing;

  /// variant.
  final MorphTextFieldVariant variant;

  /// Hides the input (single line only).
  final bool obscureText;

  /// Disabled fields are faded and skipped by keyboard focus.
  final bool enabled;

  /// keyboardType.
  final TextInputType? keyboardType;

  /// textInputAction.
  final TextInputAction? textInputAction;

  /// inputFormatters.
  final List<TextInputFormatter>? inputFormatters;

  /// Called whenever the controller notifies.
  final ValueChanged<String>? onChanged;

  /// onSubmitted.
  final ValueChanged<String>? onSubmitted;

  /// Called on a tap outside the field. Default: unfocus.
  final TapRegionCallback? onTapOutside;

  /// Maximum visible lines. Above 1 the field grows as text wraps; null
  /// lets it grow without a limit.
  final int? maxLines;

  /// Minimum visible lines. Set equal to [maxLines] for a fixed-height text
  /// area that scrolls vertically.
  final int? minLines;

  /// Shows text that cannot be edited, styled as a regular field.
  final bool readOnly;

  /// autofocus.
  final bool autofocus;

  /// Adds an asterisk to the label, which is also read by assistive tech.
  final bool isRequired;

  /// Text before the input, such as a currency symbol.
  final String? prefixText;

  /// Text after the input, such as a unit or email domain.
  final String? suffixText;

  /// Accessibility label for [prefixText], such as "Euro".
  final String? prefixSemanticsLabel;

  /// Accessibility label for [suffixText], such as "At gmail dot com".
  final String? suffixSemanticsLabel;

  /// Placeholder shown while the field is focused and empty.
  final String? placeholder;

  /// Character limit. Enables the counter.
  final int? maxLength;

  /// Shows the counter. Default: on when [maxLength] is set.
  final bool? showCounter;

  /// Counter label for assistive tech.
  final MorphTextFieldCounterLabelBuilder counterSemanticsLabelBuilder;

  /// Shows [supportingText] only while the field is focused.
  final bool supportingTextOnFocusOnly;

  /// Shows an error icon in error when there is no [trailing] widget.
  final bool showErrorIcon;

  /// Shows a clear button while the field has text.
  final bool showClearButton;

  /// Shows a show/hide password button. Starts from [obscureText].
  final bool showPasswordToggle;

  /// Clear button label.
  final String clearButtonSemanticsLabel;

  /// Password toggle label while the password is hidden.
  final String showPasswordSemanticsLabel;

  /// Password toggle label while the password is visible.
  final String hidePasswordSemanticsLabel;

  /// Error icon label.
  final String errorIconSemanticsLabel;

  /// Pointer cursor. Default: text, or basic when disabled.
  final MouseCursor? mouseCursor;

  /// Selection context menu.
  final EditableTextContextMenuBuilder? contextMenuBuilder;

  /// textCapitalization.
  final TextCapitalization textCapitalization;

  /// textAlign.
  final TextAlign textAlign;

  /// Density from 0 down to -3; each step removes 4dp of height. Overrides
  /// the theme density.
  final int? density;

  /// Leading/trailing icon position in multi-line fields. Overrides
  /// [MorphTextFieldTheme.iconAlignment].
  final MorphTextFieldSlotAlignment? iconAlignment;

  /// Prefix/suffix text position in multi-line fields. Overrides
  /// [MorphTextFieldTheme.affixAlignment].
  final MorphTextFieldSlotAlignment? affixAlignment;

  /// Per-field theme. Default: `MorphThemeData.textFieldTheme`.
  final MorphTextFieldTheme? theme;

  /// Called on each tap in the field.
  final VoidCallback? onTap;

  /// onEditingComplete.
  final VoidCallback? onEditingComplete;

  /// The hasError.
  bool get hasError => errorText != null;

  @override
  State<MorphTextField> createState() => _MorphTextFieldState();
}

class _MorphTextFieldState extends State<MorphTextField>
    with TickerProviderStateMixin
    implements TextSelectionGestureDetectorBuilderDelegate {
  late final TextEditingController _controller =
      widget.controller ?? TextEditingController();
  late final FocusNode _focusNode = widget.focusNode ?? FocusNode();
  final GlobalKey<EditableTextState> _editableKey =
      GlobalKey<EditableTextState>();
  late final MorphTextFieldAutofillClient _autofillClient =
      MorphTextFieldAutofillClient(_editableKey);
  late final MorphTextFieldSelectionBuilder _selectionBuilder =
      MorphTextFieldSelectionBuilder(delegate: this, onTap: _handleTap);
  late final SingleMotionController _labelMotion = SingleMotionController(
    motion: _springOf(MorphMotion.spatialFast),
    vsync: this,
  );
  late final SingleMotionController _effectsMotion = SingleMotionController(
    motion: _springOf(MorphMotion.effectsFast),
    vsync: this,
    initialValue: 1,
  );
  late final SingleMotionController _shapeMotion = SingleMotionController(
    motion: _springOf(MorphMotion.spatialFast),
    vsync: this,
  );
  late final Listenable _motion = Listenable.merge(<Listenable>[
    _labelMotion,
    _effectsMotion,
    _shapeMotion,
  ]);
  late bool _obscured = widget.obscureText;
  bool _focused = false;
  bool _hovered = false;
  bool _showFocusRing = false;
  bool _showSelectionHandles = false;
  double? _floatTarget;
  double? _shapeTarget;
  MorphTextFieldColors? _fromColors;
  MorphTextFieldColors? _toColors;

  @override
  GlobalKey<EditableTextState> get editableTextKey => _editableKey;

  @override
  bool get forcePressEnabled =>
      morphTextFieldForcePressEnabled(defaultTargetPlatform);

  @override
  bool get selectionEnabled => widget.enabled;

  @override
  void initState() {
    super.initState();
    _focused = _focusNode.hasFocus;
    _focusNode.addListener(_handleFocusChange);
    _controller.addListener(_handleTextChange);
    FocusManager.instance.addHighlightModeListener(_handleHighlightModeChange);
    MorphFocusInteraction.instance.addListener(_handleFocusInteractionChanged);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _syncVisuals(animate: _toColors != null);
  }

  @override
  void didUpdateWidget(MorphTextField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.obscureText != widget.obscureText ||
        oldWidget.showPasswordToggle != widget.showPasswordToggle) {
      _obscured = widget.obscureText;
    }
    _syncVisuals();
  }

  @override
  void dispose() {
    FocusManager.instance.removeHighlightModeListener(
      _handleHighlightModeChange,
    );
    MorphFocusInteraction.instance.removeListener(_handleFocusInteractionChanged);
    _focusNode.removeListener(_handleFocusChange);
    _controller.removeListener(_handleTextChange);
    _labelMotion.dispose();
    _effectsMotion.dispose();
    _shapeMotion.dispose();
    if (widget.focusNode == null) {
      _focusNode.dispose();
    }
    if (widget.controller == null) {
      _controller.dispose();
    }
    super.dispose();
  }

  static SpringMotion _springOf(MorphSpring spring) =>
      SpringMotion(spring.toDescription(), snapToEnd: true);

  MorphTextFieldTheme _fieldThemeOf(MorphThemeData theme) =>
      widget.theme ?? theme.textFieldTheme;

  int _densityOf(MorphTextFieldTheme fieldTheme) =>
      MorphTextFieldTheme.clampDensity(widget.density ?? fieldTheme.density);

  MorphTextFieldStates get _states => MorphTextFieldStates(
    enabled: widget.enabled,
    hovered: _hovered,
    focused: _focused,
    error: widget.hasError,
  );

  bool get _populated => _controller.text.isNotEmpty;

  /// The toggle's state only applies while the toggle is shown, so a hidden
  /// toggle can never leave a multi-line field obscured.
  bool get _isObscured =>
      widget.showPasswordToggle ? _obscured : widget.obscureText;

  bool get _floating =>
      widget.label != null && ((_focused && widget.enabled) || _populated);

  MorphTextFieldColors get _currentColors {
    final MorphTextFieldColors to = _toColors!;
    return MorphTextFieldColors.lerp(
      _fromColors ?? to,
      to,
      _effectsMotion.value.clamp(0, 1),
    );
  }

  /// Retargets the label and color springs for the current state.
  void _syncVisuals({bool animate = true}) {
    final MorphThemeData theme = MorphTheme.of(context);
    final MorphTextFieldTheme fieldTheme = _fieldThemeOf(theme);
    final bool instant =
        !animate || (MediaQuery.maybeDisableAnimationsOf(context) ?? false);
    _labelMotion.motion = _springOf(fieldTheme.labelSpring);
    _effectsMotion.motion = _springOf(fieldTheme.effectsSpring);
    _shapeMotion.motion = _springOf(fieldTheme.shapeSpring);
    final double shapeTarget = _focused && widget.enabled ? 1 : 0;
    if (_shapeTarget != shapeTarget) {
      _shapeTarget = shapeTarget;
      if (instant) {
        _shapeMotion.value = shapeTarget;
      } else {
        _shapeMotion.animateTo(shapeTarget);
      }
    }

    final double float = _floating ? 1 : 0;
    if (_floatTarget != float) {
      _floatTarget = float;
      if (instant) {
        _labelMotion.value = float;
      } else {
        _labelMotion.animateTo(float);
      }
    }

    final MorphTextFieldColors colors = fieldTheme.resolveColors(
      theme.colorScheme,
      variant: widget.variant,
      states: _states,
    );
    if (colors == _toColors) {
      return;
    }
    _fromColors = _toColors == null ? colors : _currentColors;
    _toColors = colors;
    if (instant) {
      _effectsMotion.value = 1;
    } else {
      _effectsMotion.animateTo(1, from: 0);
    }
  }

  void _handleFocusInteractionChanged() {
    if (!mounted) {
      return;
    }
    final bool show = MorphFocusRing.shouldShow(_focusNode, context);
    if (_showFocusRing != show) {
      setState(() => _showFocusRing = show);
    }
  }

  void _handleFocusChange() {
    setState(() {
      _focused = _focusNode.hasFocus;
      _showFocusRing = MorphFocusRing.shouldShow(_focusNode, context);
      _syncVisuals();
    });
  }

  void _handleHighlightModeChange(FocusHighlightMode mode) {
    if (!mounted) {
      return;
    }
    final bool show = MorphFocusRing.shouldShow(_focusNode, context);
    if (show == _showFocusRing) {
      return;
    }
    setState(() => _showFocusRing = show);
  }

  void _handleTextChange() {
    widget.onChanged?.call(_controller.text);
    setState(_syncVisuals);
  }

  void _handleTap() => widget.onTap?.call();

  /// Touch selections show handles; keyboard and mouse selections do not.
  bool _shouldShowSelectionHandles(SelectionChangedCause? cause) {
    if (!_selectionBuilder.shouldShowSelectionToolbar ||
        !_selectionBuilder.shouldShowSelectionHandles) {
      return false;
    }
    if (cause == SelectionChangedCause.keyboard || !widget.enabled) {
      return false;
    }
    if (widget.readOnly && _controller.selection.isCollapsed) {
      return false;
    }
    if (cause == SelectionChangedCause.longPress ||
        cause == SelectionChangedCause.stylusHandwriting) {
      return true;
    }
    return _controller.text.isNotEmpty;
  }

  void _handleSelectionChanged(
    TextSelection selection,
    SelectionChangedCause? cause,
  ) {
    final bool show = _shouldShowSelectionHandles(cause);
    if (show != _showSelectionHandles) {
      setState(() => _showSelectionHandles = show);
    }
    if (cause == SelectionChangedCause.longPress) {
      _editableKey.currentState?.bringIntoView(selection.extent);
    }
    final bool desktop = switch (defaultTargetPlatform) {
      TargetPlatform.macOS ||
      TargetPlatform.linux ||
      TargetPlatform.windows => true,
      TargetPlatform.android ||
      TargetPlatform.fuchsia ||
      TargetPlatform.iOS => false,
    };
    if (desktop && cause == SelectionChangedCause.drag) {
      _editableKey.currentState?.hideToolbar();
    }
  }

  /// Tapping the caret handle toggles the toolbar.
  void _handleSelectionHandleTapped() {
    if (_controller.selection.isCollapsed) {
      _editableKey.currentState?.toggleToolbar();
    }
  }

  void _updateHover({required bool hovered}) {
    if (_hovered == hovered) {
      return;
    }
    setState(() {
      _hovered = hovered;
      _syncVisuals();
    });
  }

  void _clear() => _controller.clear();

  void _toggleObscured() => setState(() => _obscured = !_obscured);

  @override
  Widget build(BuildContext context) {
    return MorphComponentTheme(
      builder: (BuildContext context) {
        final MorphThemeData theme = MorphTheme.of(context);
        final MorphTextFieldTheme fieldTheme = _fieldThemeOf(theme);
        final Widget field = Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            _buildInteractive(theme, fieldTheme),
            ListenableBuilder(
              listenable: _effectsMotion,
              builder: (BuildContext context, Widget? _) =>
                  _buildSupporting(theme, fieldTheme),
            ),
          ],
        );
        final BoxConstraints? constraints = fieldTheme.constraints;
        return constraints == null
            ? field
            : ConstrainedBox(constraints: constraints, child: field);
      },
    );
  }
}
