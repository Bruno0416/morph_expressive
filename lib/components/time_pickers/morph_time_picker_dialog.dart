import 'dart:math' as math;

import 'package:flutter/services.dart';
import 'package:material_ui/material_ui.dart';

import '../../foundations/foundations.dart';
import '../dialogs/components/morph_dialog_inset.dart';
import 'components/morph_dial_time_picker.dart';
import 'components/morph_input_time_picker_form_field.dart';
import 'components/morph_time_picker_actions.dart';
import 'components/morph_time_picker_header.dart';
import 'enums/morph_time_picker_enums.dart';
import 'models/morph_time.dart';
import 'res/morph_time_picker_constants.dart';
import 'utils/morph_time_picker_utils.dart';

/// Dialog for picking a single time.
class MorphTimePickerDialog extends StatefulWidget {
  /// MorphTimePickerDialog.
  const MorphTimePickerDialog({
    required this.initialTime,
    this.initialEntryMode = MorphTimePickerEntryMode.dial,
    this.helpText,
    this.cancelText,
    this.confirmText,
    this.errorInvalidText,
    this.hourLabelText,
    this.minuteLabelText,
    this.orientation,
    this.alwaysUse24HourFormat,
    this.emptyInitialInput = false,
    this.restorationId,
    this.onTimePickerModeChange,
    this.insetPadding = MorphTimePickerConstants.defaultInsetPadding,
    this.resizeToAvoidBottomInset,
    super.key,
  });

  /// initialTime.
  final MorphTime initialTime;

  /// initialEntryMode.
  final MorphTimePickerEntryMode initialEntryMode;

  /// helpText.
  final String? helpText;

  /// cancelText.
  final String? cancelText;

  /// confirmText.
  final String? confirmText;

  /// errorInvalidText.
  final String? errorInvalidText;

  /// hourLabelText.
  final String? hourLabelText;

  /// minuteLabelText.
  final String? minuteLabelText;

  /// orientation.
  final Orientation? orientation;

  /// alwaysUse24HourFormat.
  final bool? alwaysUse24HourFormat;

  /// emptyInitialInput.
  final bool emptyInitialInput;

  /// restorationId.
  final String? restorationId;

  /// onTimePickerModeChange.
  final ValueChanged<MorphTimePickerEntryMode>? onTimePickerModeChange;

  /// insetPadding.
  final EdgeInsets insetPadding;

  /// When null, uses dialog theme `resizeToAvoidBottomInset`.
  final bool? resizeToAvoidBottomInset;

  @override
  State<MorphTimePickerDialog> createState() => _MorphTimePickerDialogState();
}

class _MorphTimePickerDialogState extends State<MorphTimePickerDialog>
    with RestorationMixin {
  late final _RestorableMorphTime _selectedTime = _RestorableMorphTime(
    widget.initialTime,
  );
  late final _RestorableMorphTimePickerEntryMode _entryMode =
      _RestorableMorphTimePickerEntryMode(widget.initialEntryMode);
  final _RestorableAutovalidateMode _autovalidateMode =
      _RestorableAutovalidateMode(AutovalidateMode.disabled);
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  @override
  String? get restorationId => widget.restorationId;

  @override
  void restoreState(RestorationBucket? oldBucket, bool initialRestore) {
    registerForRestoration(_selectedTime, 'selected_time');
    registerForRestoration(_autovalidateMode, 'autovalidateMode');
    registerForRestoration(_entryMode, 'time_entry_mode');
  }

  @override
  void dispose() {
    _selectedTime.dispose();
    _entryMode.dispose();
    _autovalidateMode.dispose();
    super.dispose();
  }

  void _handleOk() {
    if (_entryMode.value == MorphTimePickerEntryMode.input ||
        _entryMode.value == MorphTimePickerEntryMode.inputOnly) {
      final FormState? form = _formKey.currentState;
      if (form == null || !form.validate()) {
        setState(() => _autovalidateMode.value = AutovalidateMode.always);
        return;
      }
      form.save();
    }
    Navigator.of(context).pop(_selectedTime.value);
  }

  void _handleCancel() {
    Navigator.of(context).pop();
  }

  void _handleEntryModeToggle() {
    setState(() {
      switch (_entryMode.value) {
        case MorphTimePickerEntryMode.dial:
          _autovalidateMode.value = AutovalidateMode.disabled;
          _entryMode.value = MorphTimePickerEntryMode.input;
        case MorphTimePickerEntryMode.input:
          _formKey.currentState?.save();
          _entryMode.value = MorphTimePickerEntryMode.dial;
        case MorphTimePickerEntryMode.dialOnly:
        case MorphTimePickerEntryMode.inputOnly:
          break;
      }
      widget.onTimePickerModeChange?.call(_entryMode.value);
    });
  }

  void _handleTimeChanged(MorphTime time) {
    setState(() => _selectedTime.value = MorphTimePickerUtils.clampTime(time));
  }

  Size _dialogSize(BuildContext context) {
    final bool isDial = switch (_entryMode.value) {
      MorphTimePickerEntryMode.dial || MorphTimePickerEntryMode.dialOnly => true,
      MorphTimePickerEntryMode.input || MorphTimePickerEntryMode.inputOnly => false,
    };
    final Orientation orientation =
        widget.orientation ?? MediaQuery.orientationOf(context);
    if (isDial) {
      return orientation == Orientation.portrait
          ? MorphTimePickerConstants.dialPortraitDialogSize
          : MorphTimePickerConstants.dialLandscapeDialogSize;
    }
    final bool use24Hour = MorphTimePickerUtils.use24HourFormat(
      context,
      alwaysUse24HourFormat: widget.alwaysUse24HourFormat,
    );
    final double baseWidth = MorphTimePickerConstants.inputDialogSize.width;
    final double height = MorphTimePickerConstants.inputDialogSize.height;
    if (use24Hour) {
      final double periodWidth = MorphTheme.of(context)
          .timePickerTheme
          .periodPortraitSize
          .width;
      return Size(
        baseWidth - periodWidth - MorphTimePickerConstants.inputDialogPeriodGap,
        height,
      );
    }
    return Size(
      baseWidth - MorphTimePickerConstants.inputDialogWidthInset12Hour,
      height,
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = MorphTheme.of(context);
    final timeTheme = theme.timePickerTheme;
    final localizations = MaterialLocalizations.of(context);
    final Orientation orientation =
        widget.orientation ?? MediaQuery.orientationOf(context);
    final String dialHelp =
        widget.helpText ?? localizations.timePickerDialHelpText;
    final String inputHelp =
        widget.helpText ?? localizations.timePickerInputHelpText;
    final ({Widget picker, Widget? entryModeButton}) resolved =
        _resolvePickerAndEntryButton(
          localizations: localizations,
          orientation: orientation,
          dialHelp: dialHelp,
          inputHelp: inputHelp,
        );
    final bool isInputMode =
        _entryMode.value == MorphTimePickerEntryMode.input ||
        _entryMode.value == MorphTimePickerEntryMode.inputOnly;
    final Widget actions = MorphTimePickerActions(
      cancelText: widget.cancelText ?? localizations.cancelButtonLabel,
      confirmText: widget.confirmText ?? localizations.okButtonLabel,
      onCancel: _handleCancel,
      onConfirm: _handleOk,
      entryModeButton: resolved.entryModeButton,
    );
    final double textScaleFactor =
        MediaQuery.textScalerOf(context)
            .clamp(maxScaleFactor: MorphTimePickerConstants.maxTextScaleFactor)
            .scale(MorphTimePickerConstants.fontSizeToScale) /
        MorphTimePickerConstants.fontSizeToScale;
    final Size dialogSize = _dialogSize(context) * textScaleFactor;

    return MorphDialogInset(
      padding: EdgeInsets.only(
        left: widget.insetPadding.left,
        right: widget.insetPadding.right,
        top: isInputMode ? 0 : widget.insetPadding.top,
        bottom: isInputMode ? 0 : widget.insetPadding.bottom,
      ),
      resizeToAvoidBottomInset: widget.resizeToAvoidBottomInset,
      child: Material(
        color: timeTheme.backgroundColor(theme.colorScheme),
        elevation: timeTheme.elevation,
        shape: RoundedRectangleBorder(borderRadius: timeTheme.dialogShape),
        clipBehavior: Clip.antiAlias,
        child: Padding(
          padding: timeTheme.padding,
          child: AnimatedContainer(
            width: dialogSize.width,
            duration: MorphTimePickerConstants.dialogSizeAnimationDuration,
            curve: MorphMotion.exit,
            constraints: BoxConstraints(
              minHeight: math.min(216, dialogSize.height),
              maxHeight: dialogSize.height,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                if (isInputMode)
                  resolved.picker
                else
                  Flexible(child: resolved.picker),
                actions,
              ],
            ),
          ),
        ),
      ),
    );
  }

  ({Widget picker, Widget? entryModeButton}) _resolvePickerAndEntryButton({
    required MaterialLocalizations localizations,
    required Orientation orientation,
    required String dialHelp,
    required String inputHelp,
  }) {
    switch (_entryMode.value) {
      case MorphTimePickerEntryMode.dial:
        return (
          picker: MorphDialTimePicker(
            value: _selectedTime.value,
            onChanged: _handleTimeChanged,
            use24HourFormat: widget.alwaysUse24HourFormat,
            orientation: orientation,
            expandToFit: true,
            helpText: dialHelp,
          ),
          entryModeButton: MorphTimePickerEntryModeButton(
            icon: MorphIcons.keyboard_outlined,
            tooltip: localizations.inputTimeModeButtonLabel,
            onPressed: _handleEntryModeToggle,
          ),
        );
      case MorphTimePickerEntryMode.dialOnly:
        return (
          picker: MorphDialTimePicker(
            value: _selectedTime.value,
            onChanged: _handleTimeChanged,
            use24HourFormat: widget.alwaysUse24HourFormat,
            orientation: orientation,
            expandToFit: true,
            helpText: dialHelp,
          ),
          entryModeButton: null,
        );
      case MorphTimePickerEntryMode.input:
      case MorphTimePickerEntryMode.inputOnly:
        return (
          picker: Form(
            key: _formKey,
            autovalidateMode: _autovalidateMode.value,
            child: Shortcuts(
              shortcuts: const <ShortcutActivator, Intent>{
                SingleActivator(LogicalKeyboardKey.enter): NextFocusIntent(),
              },
              child: MorphInputTimePickerFormField(
                initialTime: _selectedTime.value,
                helpText: inputHelp,
                onTimeSubmitted: _handleTimeChanged,
                onTimeSaved: _handleTimeChanged,
                errorInvalidText: widget.errorInvalidText,
                hourLabelText: widget.hourLabelText,
                minuteLabelText: widget.minuteLabelText,
                use24HourFormat: widget.alwaysUse24HourFormat,
                emptyInitialInput: widget.emptyInitialInput,
              ),
            ),
          ),
          entryModeButton: _entryMode.value == MorphTimePickerEntryMode.input
              ? MorphTimePickerEntryModeButton(
                  icon: MorphIcons.schedule,
                  tooltip: localizations.dialModeButtonLabel,
                  onPressed: _handleEntryModeToggle,
                )
              : null,
        );
    }
  }
}

class _RestorableMorphTime extends RestorableValue<MorphTime> {
  _RestorableMorphTime(this.defaultValue);

  final MorphTime defaultValue;

  @override
  MorphTime createDefaultValue() => defaultValue;

  @override
  void didUpdateValue(MorphTime? oldValue) {
    notifyListeners();
  }

  @override
  MorphTime fromPrimitives(Object? data) {
    final values = data! as List<Object?>;
    return MorphTime(hour: values[0]! as int, minute: values[1]! as int);
  }

  @override
  Object toPrimitives() => <Object?>[value.hour, value.minute];
}

class _RestorableAutovalidateMode extends RestorableValue<AutovalidateMode> {
  _RestorableAutovalidateMode(this.defaultValue);

  final AutovalidateMode defaultValue;

  @override
  AutovalidateMode createDefaultValue() => defaultValue;

  @override
  void didUpdateValue(AutovalidateMode? oldValue) {
    notifyListeners();
  }

  @override
  AutovalidateMode fromPrimitives(Object? data) {
    return AutovalidateMode.values[data! as int];
  }

  @override
  Object? toPrimitives() => value.index;
}

class _RestorableMorphTimePickerEntryMode
    extends RestorableValue<MorphTimePickerEntryMode> {
  _RestorableMorphTimePickerEntryMode(this.defaultValue);

  final MorphTimePickerEntryMode defaultValue;

  @override
  MorphTimePickerEntryMode createDefaultValue() => defaultValue;

  @override
  void didUpdateValue(MorphTimePickerEntryMode? oldValue) {
    notifyListeners();
  }

  @override
  MorphTimePickerEntryMode fromPrimitives(Object? data) {
    return MorphTimePickerEntryMode.values[data! as int];
  }

  @override
  Object? toPrimitives() => value.index;
}
