import 'package:material_ui/material_ui.dart'
    show
        BuildContext,
        Column,
        Icon,
        MainAxisSize,
        SizedBox,
        State,
        StatefulWidget,
        TextEditingController,
        ValueChanged,
        Widget;
import 'package:morph_expressive/morph_expressive.dart';
import 'package:widgetbook/widgetbook.dart';
import 'package:widgetbook_annotation/widgetbook_annotation.dart' as widgetbook;

import '../../utilities/demo.dart';
import '../../utilities/knobs.dart';
import '../../utilities/stage.dart';

const _path = '[Inputs]/Text Fields';

/// Builds a [MorphTextField] through the named constructor for [variant].
Widget _fieldOfType(
  MorphTextFieldVariant variant, {
  TextEditingController? controller,
  String? label,
  String? placeholder,
  String? supportingText,
  String? errorText,
  Widget? leading,
  Widget? trailing,
  bool enabled = true,
  bool readOnly = false,
  bool showClearButton = false,
  bool showPasswordToggle = false,
  bool obscureText = false,
  bool showErrorIcon = false,
  int maxLines = 1,
  int? maxLength,
  ValueChanged<String>? onChanged,
}) {
  switch (variant) {
    case MorphTextFieldVariant.filled:
      return MorphTextField.filled(
        controller: controller,
        label: label,
        placeholder: placeholder,
        supportingText: supportingText,
        errorText: errorText,
        leading: leading,
        trailing: trailing,
        enabled: enabled,
        readOnly: readOnly,
        showClearButton: showClearButton,
        showPasswordToggle: showPasswordToggle,
        obscureText: obscureText,
        showErrorIcon: showErrorIcon,
        maxLines: maxLines,
        maxLength: maxLength,
        onChanged: onChanged,
      );
    case MorphTextFieldVariant.outlined:
      return MorphTextField.outlined(
        controller: controller,
        label: label,
        placeholder: placeholder,
        supportingText: supportingText,
        errorText: errorText,
        leading: leading,
        trailing: trailing,
        enabled: enabled,
        readOnly: readOnly,
        showClearButton: showClearButton,
        showPasswordToggle: showPasswordToggle,
        obscureText: obscureText,
        showErrorIcon: showErrorIcon,
        maxLines: maxLines,
        maxLength: maxLength,
        onChanged: onChanged,
      );
  }
}

@widgetbook.UseCase(name: 'Matrix', type: MorphTextField, path: _path)
Widget textFieldMatrixUseCase(BuildContext context) {
  final enabled = context.knobs.boolean(label: 'enabled', initialValue: true);
  final withIcons = context.knobs.boolean(label: 'icons');
  return Stage(
    children: [
      for (final variant in MorphTextFieldVariant.values)
        StageSection(
          title: 'MorphTextField.${variant.name}',
          child: SizedBox(
            width: 420,
            child: Column(
              children: [
                _fieldOfType(
                  variant,
                  label: 'Default',
                  placeholder: 'Placeholder',
                  enabled: enabled,
                  leading: withIcons ? Icon(FluentIcons.line.mail) : null,
                ),
                const SizedBox(height: 14),
                _fieldOfType(
                  variant,
                  label: 'Supporting text',
                  supportingText: 'Helper message below the field',
                  enabled: enabled,
                  trailing: withIcons ? Icon(FluentIcons.line.search) : null,
                ),
                const SizedBox(height: 14),
                _fieldOfType(
                  variant,
                  label: 'Error',
                  errorText: 'Enter a valid value.',
                  showErrorIcon: true,
                  enabled: enabled,
                ),
                const SizedBox(height: 14),
                _fieldOfType(variant, label: 'Disabled', enabled: false),
                const SizedBox(height: 14),
                _fieldOfType(variant, label: 'Multiline', maxLines: 3),
              ],
            ),
          ),
        ),
    ],
  );
}

@widgetbook.UseCase(name: 'Playground', type: MorphTextField, path: _path)
Widget textFieldPlaygroundUseCase(BuildContext context) {
  final variant = enumKnob<MorphTextFieldVariant>(
    context,
    label: 'type',
    values: MorphTextFieldVariant.values,
  );
  final label = context.knobs.string(label: 'label', initialValue: 'Email');
  final placeholder = context.knobs.string(
    label: 'placeholder',
    initialValue: 'name@example.com',
  );
  final supporting = context.knobs.string(
    label: 'supporting text',
    initialValue: 'We never share your address.',
  );
  final error = context.knobs.string(label: 'error text');
  final enabled = context.knobs.boolean(label: 'enabled', initialValue: true);
  final readOnly = context.knobs.boolean(label: 'read only');
  final clear = context.knobs.boolean(label: 'clear button');
  final password = context.knobs.boolean(label: 'password toggle');
  final leading = context.knobs.boolean(label: 'leading icon');
  final trailing = context.knobs.boolean(label: 'trailing icon');
  final lines = context.knobs.int.slider(
    label: 'max lines',
    initialValue: 1,
    min: 1,
    max: 6,
  );
  final maxLength = context.knobs.int.slider(
    label: 'max length (0 = none)',
    initialValue: 0,
    min: 0,
    max: 60,
  );
  return _TextFieldHarness(
    key: resetKey([variant, password]),
    variant: variant,
    label: label,
    placeholder: placeholder,
    supporting: supporting,
    error: error,
    enabled: enabled,
    readOnly: readOnly,
    clear: clear,
    password: password,
    leading: leading,
    trailing: trailing,
    lines: lines,
    maxLength: maxLength,
  );
}

class _TextFieldHarness extends StatefulWidget {
  const _TextFieldHarness({
    super.key,
    required this.variant,
    required this.label,
    required this.placeholder,
    required this.supporting,
    required this.error,
    required this.enabled,
    required this.readOnly,
    required this.clear,
    required this.password,
    required this.leading,
    required this.trailing,
    required this.lines,
    required this.maxLength,
  });

  final MorphTextFieldVariant variant;
  final String label;
  final String placeholder;
  final String supporting;
  final String error;
  final bool enabled;
  final bool readOnly;
  final bool clear;
  final bool password;
  final bool leading;
  final bool trailing;
  final int lines;
  final int maxLength;

  @override
  State<_TextFieldHarness> createState() => _TextFieldHarnessState();
}

class _TextFieldHarnessState extends State<_TextFieldHarness> {
  final TextEditingController _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return StageCenter(
      child: SizedBox(
        width: 380,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _fieldOfType(
              widget.variant,
              controller: _controller,
              label: widget.label.isEmpty ? null : widget.label,
              placeholder: widget.placeholder.isEmpty
                  ? null
                  : widget.placeholder,
              supportingText: widget.supporting.isEmpty
                  ? null
                  : widget.supporting,
              errorText: widget.error.isEmpty ? null : widget.error,
              showErrorIcon: widget.error.isNotEmpty,
              enabled: widget.enabled,
              readOnly: widget.readOnly,
              showClearButton: widget.clear,
              showPasswordToggle: widget.password,
              obscureText: widget.password,
              leading: widget.leading ? Icon(FluentIcons.line.mail) : null,
              trailing: widget.trailing ? Icon(FluentIcons.line.search) : null,
              maxLines: widget.lines,
              maxLength: widget.maxLength == 0 ? null : widget.maxLength,
              onChanged: (_) => setState(() {}),
            ),
            const SizedBox(height: 16),
            DemoReadout('Typed: "${_controller.text}"'),
          ],
        ),
      ),
    );
  }
}
