import 'package:material_ui/material_ui.dart'
    show
        BuildContext,
        CustomScrollView,
        EdgeInsets,
        Icon,
        SizedBox,
        SliverList,
        State,
        StatefulWidget,
        TextEditingController,
        Widget;
import 'package:morph_expressive/morph_expressive.dart';
import 'package:widgetbook/widgetbook.dart';
import 'package:widgetbook_annotation/widgetbook_annotation.dart' as widgetbook;

import '../../utilities/demo.dart';
import '../../utilities/knobs.dart';
import '../../utilities/stage.dart';

const _path = '[Inputs]/Search';

@widgetbook.UseCase(name: 'Search bar', type: MorphSearchBar, path: _path)
Widget searchBarUseCase(BuildContext context) {
  final hint = context.knobs.string(label: 'hint', initialValue: 'Search...');
  final enabled = context.knobs.boolean(label: 'enabled', initialValue: true);
  final leading = context.knobs.boolean(
    label: 'leading icon',
    initialValue: true,
  );
  final clear = context.knobs.boolean(
    label: 'clear button',
    initialValue: true,
  );
  final readOnly = context.knobs.boolean(label: 'read only');
  final expand = context.knobs.boolean(
    label: 'expand on focus',
    initialValue: true,
  );
  return _SearchBarHarness(
    key: resetKey([readOnly, expand]),
    hint: hint,
    enabled: enabled,
    leading: leading,
    clear: clear,
    readOnly: readOnly,
    expand: expand,
  );
}

class _SearchBarHarness extends StatefulWidget {
  const _SearchBarHarness({
    super.key,
    required this.hint,
    required this.enabled,
    required this.leading,
    required this.clear,
    required this.readOnly,
    required this.expand,
  });

  final String hint;
  final bool enabled;
  final bool leading;
  final bool clear;
  final bool readOnly;
  final bool expand;

  @override
  State<_SearchBarHarness> createState() => _SearchBarHarnessState();
}

class _SearchBarHarnessState extends State<_SearchBarHarness> {
  final TextEditingController _controller = TextEditingController();
  String _submitted = '';

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stage(
      children: [
        SizedBox(
          width: 520,
          child: MorphSearchBar(
            controller: _controller,
            hintText: widget.hint,
            enabled: widget.enabled,
            readOnly: widget.readOnly,
            expandOnFocus: widget.expand,
            showClearButton: widget.clear,
            leading: widget.leading ? Icon(FluentIcons.line.search) : null,
            onChanged: (_) => setState(() {}),
            onSubmitted: (value) => setState(() => _submitted = value),
          ),
        ),
        DemoReadout('Query: "${_controller.text}" · submitted: "$_submitted"'),
      ],
    );
  }
}

@widgetbook.UseCase(name: 'Search anchor', type: MorphSearchAnchor, path: _path)
Widget searchAnchorUseCase(BuildContext context) {
  final fullScreen = context.knobs.boolean(label: 'full screen view');
  return _SearchAnchorHarness(
    key: resetKey([fullScreen]),
    fullScreen: fullScreen,
  );
}

class _SearchAnchorHarness extends StatefulWidget {
  const _SearchAnchorHarness({super.key, required this.fullScreen});

  final bool fullScreen;

  @override
  State<_SearchAnchorHarness> createState() => _SearchAnchorHarnessState();
}

class _SearchAnchorHarnessState extends State<_SearchAnchorHarness> {
  static const _all = [
    'Apple',
    'Banana',
    'Cherry',
    'Dragon fruit',
    'Elderberry',
  ];
  String _picked = 'none';
  final MorphSearchController _search = MorphSearchController();

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stage(
      children: [
        SizedBox(
          width: 520,
          child: MorphSearchAnchor.bar(
            searchController: _search,
            isFullScreen: widget.fullScreen,
            barHintText: 'Search fruit',
            suggestionsBuilder: (context, controller) {
              final query = controller.text.toLowerCase();
              return [
                for (final item in _all.where(
                  (e) => e.toLowerCase().contains(query),
                ))
                  MorphListItem(
                    headline: item,
                    onTap: () {
                      controller.closeView(item);
                      setState(() => _picked = item);
                    },
                  ),
              ];
            },
          ),
        ),
        DemoReadout('Picked: $_picked'),
      ],
    );
  }
}

@widgetbook.UseCase(
  name: 'Sliver search bar',
  type: MorphSliverSearchBar,
  path: _path,
)
Widget sliverSearchBarUseCase(BuildContext context) {
  final behavior = enumKnob<MorphSearchBarScrollBehavior>(
    context,
    label: 'scroll behavior',
    values: MorphSearchBarScrollBehavior.values,
  );
  return CustomScrollView(
    slivers: [
      MorphSliverSearchBar(
        key: resetKey([behavior]),
        scrollBehavior: behavior,
        padding: const EdgeInsets.all(16),
        child: const MorphSearchBar(hintText: 'Search the list'),
      ),
      SliverList.builder(
        itemCount: 40,
        itemBuilder: (context, i) => MorphListItem(headline: 'Row ${i + 1}'),
      ),
    ],
  );
}
