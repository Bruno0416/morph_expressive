import 'package:material_ui/material_ui.dart'
    show
        Alignment,
        Border,
        BorderRadius,
        BoxDecoration,
        BuildContext,
        Column,
        Container,
        CrossAxisAlignment,
        EdgeInsets,
        FocusNode,
        GestureDetector,
        HitTestBehavior,
        Icon,
        IconData,
        ListenableBuilder,
        MainAxisSize,
        SizedBox,
        State,
        StatefulWidget,
        StatelessWidget,
        Text,
        ValueChanged,
        ValueKey,
        Widget;
import 'package:morph_expressive/morph_expressive.dart';

import 'demo.dart';

/// Hosts a context-menu use case and the shared "last action" readout.
///
/// [builder] receives a `report` callback to pass as `onSelected`; each call
/// updates the readout under the content and counts the selections.
class ContextLabHost extends StatefulWidget {
  const ContextLabHost({super.key, required this.builder, this.instructions});

  final Widget Function(BuildContext context, ValueChanged<String> report)
  builder;

  /// Visible instructions shown above the content.
  final String? instructions;

  @override
  State<ContextLabHost> createState() => _ContextLabHostState();
}

class _ContextLabHostState extends State<ContextLabHost> {
  String _last = 'none yet';
  int _count = 0;

  void _report(String value) => setState(() {
    _last = value;
    _count++;
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (widget.instructions != null) ...[
          DemoReadout(widget.instructions!),
          const SizedBox(height: 12),
        ],
        widget.builder(context, _report),
        const SizedBox(height: 12),
        DemoReadout('Last action: $_last · selections: $_count'),
      ],
    );
  }
}

/// A visible right-click surface with a title and a hint line.
class ContextTarget extends StatelessWidget {
  const ContextTarget({
    super.key,
    required this.title,
    this.hint = 'Right-click here',
    this.icon,
    this.width = 240,
    this.height = 120,
    this.highlighted = false,
  });

  final String title;
  final String hint;
  final IconData? icon;
  final double width;
  final double height;

  /// Draws the focus-style outline (keyboard lab).
  final bool highlighted;

  @override
  Widget build(BuildContext context) {
    final morph = MorphTheme.of(context);
    final scheme = morph.colorScheme;
    return Container(
      width: width,
      height: height,
      padding: const EdgeInsets.all(16),
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: scheme.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: highlighted ? scheme.primary : scheme.outlineVariant,
          width: highlighted ? 2 : 1,
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) Icon(icon, color: scheme.onSurfaceVariant),
          Text(
            title,
            style: morph.textTheme.titleSmall?.copyWith(
              color: scheme.onSurface,
            ),
          ),
          Text(
            hint,
            style: morph.textTheme.bodySmall?.copyWith(
              color: scheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}

/// Target that shows a focus outline while [node] has focus.
class FocusableContextTarget extends StatelessWidget {
  const FocusableContextTarget({
    super.key,
    required this.node,
    required this.title,
    required this.hint,
    this.width = 240,
    this.height = 120,
    this.icon,
  });

  final FocusNode node;
  final String title;
  final String hint;
  final double width;
  final double height;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: node,
      builder: (context, _) =>
          ContextTarget(title: title, hint: hint, highlighted: node.hasFocus),
    );
  }
}

/// A [MorphContextMenuRegion] that owns a focus node, takes focus on click and
/// draws a focus outline, so Shift+F10 / the Menu key work in every lab.
class FocusableContextRegion extends StatefulWidget {
  const FocusableContextRegion({
    super.key,
    required this.title,
    required this.items,
    required this.report,
    this.hint = 'Right-click here',
    this.width = 320,
    this.height = 140,
    this.density,
    this.icon,
  });

  final String title;
  final String hint;
  final double width;
  final double height;
  final IconData? icon;
  final List<MorphMenuNode> Function() items;
  final ValueChanged<String> report;
  final MorphDensity? density;

  @override
  State<FocusableContextRegion> createState() => _FocusableContextRegionState();
}

class _FocusableContextRegionState extends State<FocusableContextRegion> {
  final FocusNode _node = FocusNode(debugLabel: 'context-lab-region');

  @override
  void dispose() {
    _node.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTapDown: (_) => _node.requestFocus(),
      child: MorphContextMenuRegion<String>(
        focusNode: _node,
        density: widget.density,
        children: widget.items(),
        onSelected: widget.report,
        child: FocusableContextTarget(
          key: const ValueKey<String>('context-target'),
          node: _node,
          title: widget.title,
          hint: widget.hint,
          width: widget.width,
          height: widget.height,
          icon: widget.icon,
        ),
      ),
    );
  }
}
