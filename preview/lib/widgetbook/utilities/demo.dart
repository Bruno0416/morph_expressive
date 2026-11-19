import 'package:material_ui/material_ui.dart'
    show
        BuildContext,
        Center,
        ColoredBox,
        FontWeight,
        IconData,
        Size,
        SizedBox,
        StatelessWidget,
        Text,
        TextStyle,
        Widget;
import 'package:morph_expressive/morph_expressive.dart';
import 'package:widgetbook/widgetbook.dart';

/// Real Fluent icons shipped with the package, used across use cases.
final Map<String, IconData> demoIcons = <String, IconData>{
  'add': FluentIcons.line.add,
  'heart': FluentIcons.line.heart,
  'star': FluentIcons.line.star,
  'search': FluentIcons.line.search,
  'home': FluentIcons.line.home,
  'mail': FluentIcons.line.mail,
  'settings': FluentIcons.line.settings,
  'info': FluentIcons.line.info,
  'bookmark': FluentIcons.line.bookmark,
  'person': FluentIcons.line.person,
};

/// Dropdown knob that returns an [IconData] from [demoIcons].
IconData iconKnob(
  BuildContext context, {
  String label = 'icon',
  String initial = 'add',
}) {
  final name = context.knobs.object.dropdown<String>(
    label: label,
    options: demoIcons.keys.toList(),
    initialOption: initial,
  );
  return demoIcons[name]!;
}

/// A tinted placeholder "image" for cards, lists and carousels.
class DemoImage extends StatelessWidget {
  const DemoImage({super.key, this.index = 0, this.label, this.size});

  final int index;
  final String? label;
  final Size? size;

  @override
  Widget build(BuildContext context) {
    final scheme = MorphTheme.of(context).colorScheme;
    final colors = [
      scheme.primaryContainer,
      scheme.secondaryContainer,
      scheme.tertiaryContainer,
      scheme.errorContainer,
    ];
    final on = [
      scheme.onPrimaryContainer,
      scheme.onSecondaryContainer,
      scheme.onTertiaryContainer,
      scheme.onErrorContainer,
    ];
    final i = index % colors.length;
    return SizedBox(
      width: size?.width,
      height: size?.height,
      child: ColoredBox(
        color: colors[i],
        child: Center(
          child: Text(
            label ?? '${index + 1}',
            style: TextStyle(
              color: on[i],
              fontSize: 28,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }
}

/// Last-event readout shown under interactive demos.
class DemoReadout extends StatelessWidget {
  const DemoReadout(this.text, {super.key});

  final String text;

  @override
  Widget build(BuildContext context) {
    final morph = MorphTheme.of(context);
    return Text(
      text,
      style: morph.textTheme.bodySmall?.copyWith(
        color: morph.colorScheme.onSurfaceVariant,
      ),
    );
  }
}
