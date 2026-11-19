import 'package:material_ui/material_ui.dart'
    show
        Alignment,
        Border,
        BorderRadius,
        BoxConstraints,
        BoxDecoration,
        BuildContext,
        Builder,
        Color,
        Column,
        Container,
        CrossAxisAlignment,
        EdgeInsets,
        GlobalKey,
        MainAxisSize,
        Padding,
        Element,
        Row,
        Size,
        SizedBox,
        State,
        StatefulWidget,
        StatelessWidget,
        Text,
        ValueChanged,
        Widget,
        WidgetsBinding,
        Wrap,
        WrapCrossAlignment;
import 'package:flutter/rendering.dart'
    show RenderBox, RenderPhysicalModel, RenderPhysicalShape;
import 'package:morph_expressive/morph_expressive.dart';

/// Display names of the three real [MorphDensity] values.
const Map<MorphDensity, String> densityLabels = <MorphDensity, String>{
  MorphDensity.compact: 'Compact',
  MorphDensity.standard: 'Standard',
  MorphDensity.comfortable: 'Comfortable',
};

/// Installs a real nested [MorphTheme] whose `density` is [density].
///
/// The theme is the ambient one copied with `copyWith(density: ...)`; nothing
/// is scaled or transformed, so every component below resolves its own
/// density-aware metrics exactly as it would in an application.
class DensityScope extends StatelessWidget {
  const DensityScope({super.key, required this.density, required this.child});

  final MorphDensity density;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return MorphTheme(
      data: MorphTheme.of(context).copyWith(density: density),
      child: child,
    );
  }
}

/// Builds [builder] once per density, side by side, each inside its own real
/// [DensityScope] so all three columns are live.
class DensityColumns extends StatelessWidget {
  const DensityColumns({
    super.key,
    required this.builder,
    this.width = 280,
    this.densities = MorphDensity.values,
  });

  /// Builds the column content; the [BuildContext] sits under the column's
  /// density theme.
  final Widget Function(BuildContext context, MorphDensity density) builder;

  /// Width of each column.
  final double width;

  final List<MorphDensity> densities;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 24,
      runSpacing: 24,
      crossAxisAlignment: WrapCrossAlignment.start,
      children: [
        for (final density in densities)
          SizedBox(
            width: width,
            child: DensityScope(
              density: density,
              child: Builder(
                builder: (context) => Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _DensityHeader(density: density),
                    const SizedBox(height: 10),
                    builder(context, density),
                  ],
                ),
              ),
            ),
          ),
      ],
    );
  }
}

class _DensityHeader extends StatelessWidget {
  const _DensityHeader({required this.density});

  final MorphDensity density;

  @override
  Widget build(BuildContext context) {
    final morph = MorphTheme.of(context);
    final metrics = morph.densityMetrics;
    String signed(double v) => v > 0 ? '+${_n(v)}' : _n(v);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          densityLabels[density]!,
          style: morph.textTheme.titleSmall?.copyWith(
            color: morph.colorScheme.primary,
          ),
        ),
        Text(
          'row ${signed(metrics.rowHeight)} · pad '
          '${signed(metrics.paddingHorizontal)} · gap ${signed(metrics.gap)}',
          style: morph.textTheme.labelSmall?.copyWith(
            color: morph.colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}

String _n(double v) =>
    v == v.roundToDouble() ? v.toInt().toString() : v.toStringAsFixed(1);

/// Formats a layout value for readouts (`40`, `7.5`).
String formatMetric(double value) => _n(value);

/// Wraps [child] and prints its measured size under it.
///
/// Sizes are read from the real render boxes after layout, so they reflect the
/// density-resolved geometry (not a guess). When the control paints a smaller
/// surface than its layout box (hit-target inflation), both are shown.
class MeasuredBox extends StatefulWidget {
  const MeasuredBox({
    super.key,
    required this.child,
    this.prefix = '',
    this.showReadout = true,
    this.onSize,
  });

  final Widget child;
  final String prefix;

  /// Prints the measured size under [child].
  final bool showReadout;

  /// Called after layout with the visual size whenever it changes.
  final ValueChanged<Size>? onSize;

  @override
  State<MeasuredBox> createState() => _MeasuredBoxState();
}

class _MeasuredBoxState extends State<MeasuredBox> {
  final GlobalKey _key = GlobalKey();
  Size? _size;
  Size? _visual;

  void _measure() {
    if (!mounted) return;
    final context = _key.currentContext;
    final object = context?.findRenderObject();
    if (context == null || object is! RenderBox || !object.hasSize) return;
    final visual = _visualBox(context as Element) ?? object.size;
    if (object.size != _size || visual != _visual) {
      setState(() {
        _size = object.size;
        _visual = visual;
      });
      widget.onSize?.call(visual);
    }
  }

  /// The painted surface of the control: the first Material-style physical
  /// layer below the wrapper. Controls inflate their layout box to the
  /// accessible target, so the layout size and the visual size differ.
  Size? _visualBox(Element root) {
    Size? found;
    void visit(Element element) {
      if (found != null) return;
      final object = element.renderObject;
      if (element != root &&
          (object is RenderPhysicalShape || object is RenderPhysicalModel) &&
          (object! as RenderBox).hasSize) {
        found = (object as RenderBox).size;
        return;
      }
      element.visitChildren(visit);
    }

    root.visitChildren(visit);
    return found;
  }

  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((_) => _measure());
    final morph = MorphTheme.of(context);
    final size = _size;
    final visual = _visual;
    String readout() {
      if (size == null || visual == null) return '…';
      final layout = '${_n(size.width)} × ${_n(size.height)}';
      if (visual == size) return '${widget.prefix}$layout';
      return '${widget.prefix}visual ${_n(visual.width)} × '
          '${_n(visual.height)} · layout $layout';
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [Container(key: _key, child: widget.child)],
        ),
        if (widget.showReadout)
          Padding(
            padding: const EdgeInsets.only(top: 2, bottom: 8),
            child: Text(
              readout(),
              style: morph.textTheme.labelSmall?.copyWith(
                color: morph.colorScheme.onSurfaceVariant,
              ),
            ),
          ),
      ],
    );
  }
}

/// Dashed-looking outline used to show an accessible target around a control.
class TargetOutline extends StatelessWidget {
  const TargetOutline({super.key, required this.child, this.minSize = 48});

  final Widget child;
  final double minSize;

  @override
  Widget build(BuildContext context) {
    final scheme = MorphTheme.of(context).colorScheme;
    return Container(
      constraints: BoxConstraints(minWidth: minSize, minHeight: minSize),
      decoration: BoxDecoration(
        border: Border.all(color: scheme.outline),
        borderRadius: BorderRadius.circular(4),
      ),
      alignment: Alignment.center,
      child: child,
    );
  }
}

/// WCAG 2.x contrast ratio between two opaque colors.
double contrastRatio(Color a, Color b) {
  final la = a.computeLuminance();
  final lb = b.computeLuminance();
  final hi = la > lb ? la : lb;
  final lo = la > lb ? lb : la;
  return (hi + 0.05) / (lo + 0.05);
}

/// `6.46:1 · AA` style readout for [foreground] on [background].
String contrastLabel(Color background, Color foreground) {
  final ratio = contrastRatio(background, foreground);
  final grade = ratio >= 7
      ? 'AAA'
      : ratio >= 4.5
      ? 'AA'
      : ratio >= 3
      ? 'large text only'
      : 'fails';
  return '${ratio.toStringAsFixed(2)}:1 · $grade';
}
