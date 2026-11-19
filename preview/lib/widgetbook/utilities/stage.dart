import 'package:material_ui/material_ui.dart'
    show
        Axis,
        BuildContext,
        Center,
        Column,
        CrossAxisAlignment,
        EdgeInsets,
        EdgeInsetsGeometry,
        MainAxisSize,
        Padding,
        SingleChildScrollView,
        SizedBox,
        StatelessWidget,
        Text,
        Widget,
        Wrap,
        WrapCrossAlignment;
import 'package:morph_expressive/morph_expressive.dart';

/// Scrollable canvas used by most use cases.
///
/// Fills the viewport, scrolls vertically and lays [children] out in a column
/// with consistent spacing. Use [StageSection] for titled groups.
class Stage extends StatelessWidget {
  const Stage({
    super.key,
    required this.children,
    this.padding = const EdgeInsets.all(24),
    this.gap = 28,
  });

  final List<Widget> children;
  final EdgeInsetsGeometry padding;
  final double gap;

  @override
  Widget build(BuildContext context) {
    return SizedBox.expand(
      child: SingleChildScrollView(
        padding: padding,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            for (var i = 0; i < children.length; i++) ...[
              if (i > 0) SizedBox(height: gap),
              children[i],
            ],
          ],
        ),
      ),
    );
  }
}

/// Centers a single [child] inside the canvas (playground use cases).
class StageCenter extends StatelessWidget {
  const StageCenter({
    super.key,
    required this.child,
    this.padding,
    this.horizontalScroll = false,
  });

  final Widget child;
  final EdgeInsetsGeometry? padding;

  /// Also scrolls horizontally, for controls whose content does not wrap
  /// (large text on a narrow viewport).
  final bool horizontalScroll;

  @override
  Widget build(BuildContext context) {
    Widget content = child;
    if (horizontalScroll) {
      content = SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: content,
      );
    }
    return SizedBox.expand(
      child: Center(
        child: SingleChildScrollView(
          padding: padding ?? const EdgeInsets.all(24),
          child: content,
        ),
      ),
    );
  }
}

/// Titled group with an optional explanatory note.
class StageSection extends StatelessWidget {
  const StageSection({
    super.key,
    required this.title,
    required this.child,
    this.note,
  });

  final String title;
  final String? note;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final morph = MorphTheme.of(context);
    final scheme = morph.colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: morph.textTheme.titleMedium?.copyWith(color: scheme.onSurface),
        ),
        if (note != null)
          Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Text(
              note!,
              style: morph.textTheme.bodySmall?.copyWith(
                color: scheme.onSurfaceVariant,
              ),
            ),
          ),
        const SizedBox(height: 12),
        child,
      ],
    );
  }
}

/// Wrapping row used for matrices of examples.
class StageWrap extends StatelessWidget {
  const StageWrap({
    super.key,
    required this.children,
    this.spacing = 12,
    this.runSpacing = 12,
    this.crossAxisAlignment = WrapCrossAlignment.center,
  });

  final List<Widget> children;
  final double spacing;
  final double runSpacing;
  final WrapCrossAlignment crossAxisAlignment;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: spacing,
      runSpacing: runSpacing,
      crossAxisAlignment: crossAxisAlignment,
      children: children,
    );
  }
}

/// Small captioned cell for matrices (caption above the example).
class StageCell extends StatelessWidget {
  const StageCell({super.key, required this.caption, required this.child});

  final String caption;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final morph = MorphTheme.of(context);
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          caption,
          style: morph.textTheme.labelSmall?.copyWith(
            color: morph.colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 6),
        child,
      ],
    );
  }
}
