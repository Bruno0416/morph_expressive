import 'package:material_ui/material_ui.dart'
    show
        BuildContext,
        Colors,
        CustomScrollView,
        Icon,
        IconButton,
        ListView,
        Scaffold,
        SliverList,
        State,
        StatefulWidget,
        Widget;
import 'package:morph_expressive/morph_expressive.dart';
import 'package:widgetbook/widgetbook.dart';
import 'package:widgetbook_annotation/widgetbook_annotation.dart' as widgetbook;

import '../../../gradient_app_bar_sample.dart';
import '../../utilities/knobs.dart';

const _path = '[Navigation]/App Bars';

enum _AppBarKind { top, frosted, sliver, search, bottom }

@widgetbook.UseCase(name: 'Playground', type: MorphAppBar, path: _path)
Widget appBarPlaygroundUseCase(BuildContext context) {
  final kind = enumKnob<_AppBarKind>(
    context,
    label: 'constructor',
    values: _AppBarKind.values,
  );
  final variant = enumKnob<MorphAppBarVariant>(
    context,
    label: 'variant',
    values: MorphAppBarVariant.values,
  );
  final center = context.knobs.boolean(label: 'center title');
  final leading = context.knobs.boolean(
    label: 'leading back button',
    initialValue: true,
  );
  final actions = context.knobs.int.slider(
    label: 'actions',
    initialValue: 2,
    min: 0,
    max: 4,
  );
  final title = context.knobs.string(
    label: 'title',
    initialValue: 'Morph app bar',
  );
  final subtitle = context.knobs.string(label: 'subtitle');
  final shape = enumKnob<MorphAppBarShapeFamily>(
    context,
    label: 'shape family',
    values: MorphAppBarShapeFamily.values,
  );
  final density = enumKnob<MorphAppBarDensity>(
    context,
    label: 'density',
    values: MorphAppBarDensity.values,
  );
  return _AppBarHarness(
    key: resetKey([kind]),
    kind: kind,
    variant: variant,
    center: center,
    leading: leading,
    actions: actions,
    title: title,
    subtitle: subtitle,
    shape: shape,
    density: density,
  );
}

class _AppBarHarness extends StatefulWidget {
  const _AppBarHarness({
    super.key,
    required this.kind,
    required this.variant,
    required this.center,
    required this.leading,
    required this.actions,
    required this.title,
    required this.subtitle,
    required this.shape,
    required this.density,
  });

  final _AppBarKind kind;
  final MorphAppBarVariant variant;
  final bool center;
  final bool leading;
  final int actions;
  final String title;
  final String subtitle;
  final MorphAppBarShapeFamily shape;
  final MorphAppBarDensity density;

  @override
  State<_AppBarHarness> createState() => _AppBarHarnessState();
}

class _AppBarHarnessState extends State<_AppBarHarness> {
  final MorphSearchController _search = MorphSearchController();

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  List<Widget> get _actions => [
    for (var i = 0; i < widget.actions; i++)
      IconButton(
        tooltip: 'Action ${i + 1}',
        onPressed: () {},
        icon: Icon(
          [
            FluentIcons.line.search,
            FluentIcons.line.heart,
            FluentIcons.line.settings,
            FluentIcons.line.info,
          ][i],
        ),
      ),
  ];

  Widget? get _leading => widget.leading
      ? IconButton(
          tooltip: 'Back',
          onPressed: () {},
          icon: const Icon(MorphIcons.arrow_back),
        )
      : null;

  @override
  Widget build(BuildContext context) {
    final subtitle = widget.subtitle.isEmpty ? null : widget.subtitle;
    final body = ListView.builder(
      itemCount: 40,
      itemBuilder: (context, i) => MorphListItem(headline: 'Row ${i + 1}'),
    );
    switch (widget.kind) {
      case _AppBarKind.top:
        return Scaffold(
          backgroundColor: Colors.transparent,
          appBar: MorphAppBar.top(
            titleText: widget.title,
            subtitleText: subtitle,
            centerTitle: widget.center,
            leading: _leading,
            actions: _actions,
            variant: widget.variant,
            shapeFamily: widget.shape,
            density: widget.density,
            safeArea: false,
          ),
          body: body,
        );
      case _AppBarKind.frosted:
        return Scaffold(
          backgroundColor: Colors.transparent,
          extendBodyBehindAppBar: true,
          appBar: MorphAppBar.frosted(
            titleText: widget.title,
            subtitleText: subtitle,
            centerTitle: widget.center,
            leading: _leading,
            actions: _actions,
            variant: widget.variant,
            shapeFamily: widget.shape,
            density: widget.density,
            safeArea: false,
          ),
          body: body,
        );
      case _AppBarKind.sliver:
        return CustomScrollView(
          slivers: [
            MorphAppBar.sliver(
              titleText: widget.title,
              subtitleText: subtitle,
              centerTitle: widget.center,
              leading: _leading,
              actions: _actions,
              variant: widget.variant,
              shapeFamily: widget.shape,
              density: widget.density,
            ),
            SliverList.builder(
              itemCount: 40,
              itemBuilder: (context, i) =>
                  MorphListItem(headline: 'Row ${i + 1}'),
            ),
          ],
        );
      case _AppBarKind.search:
        return Scaffold(
          backgroundColor: Colors.transparent,
          appBar: MorphAppBar.search(
            searchController: _search,
            barHintText: widget.title,
            leading: _leading,
            actions: _actions,
            centerTitle: widget.center,
            shapeFamily: widget.shape,
            density: widget.density,
            safeArea: false,
            suggestionsBuilder: (context, controller) => [
              for (final s in ['Alpha', 'Beta', 'Gamma'])
                MorphListItem(
                  headline: s,
                  onTap: () => controller.closeView(s),
                ),
            ],
          ),
          body: body,
        );
      case _AppBarKind.bottom:
        return Scaffold(
          backgroundColor: Colors.transparent,
          body: body,
          bottomNavigationBar: MorphAppBar.bottom(
            actions: _actions.isEmpty
                ? [
                    IconButton(
                      tooltip: 'Home',
                      onPressed: () {},
                      icon: Icon(FluentIcons.line.home),
                    ),
                  ]
                : _actions,
            floatingActionButton: MorphFab(
              icon: Icon(FluentIcons.line.add),
              onPressed: () {},
            ),
            safeArea: false,
          ),
        );
    }
  }
}

@widgetbook.UseCase(
  name: 'Gradient glass sample',
  type: MorphAppBarGlass,
  path: _path,
)
Widget gradientAppBarSampleUseCase(BuildContext context) =>
    const MorphGradientAppBarSample(embedded: true);
