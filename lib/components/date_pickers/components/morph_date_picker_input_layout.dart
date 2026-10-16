import 'package:flutter/widgets.dart';

/// Date picker input area that reserves room for the filled field's floating
/// label and error text, but scrolls rather than overflowing when the available
/// height is reduced by the keyboard, text scaling, or a compact screen.
class MorphDatePickerInputLayout extends StatelessWidget {
  const MorphDatePickerInputLayout({required this.child, super.key});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        return SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minHeight: constraints.maxHeight > 16
                  ? constraints.maxHeight - 16
                  : 0,
            ),
            // Pin the form to the top: validation/supporting text may grow
            // below it without shifting the painted input surfaces upward.
            child: Align(alignment: Alignment.topCenter, child: child),
          ),
        );
      },
    );
  }
}
