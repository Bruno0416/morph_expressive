import 'package:material_ui/material_ui.dart'
    show
        BorderRadius,
        BoxDecoration,
        BuildContext,
        Center,
        Container,
        EdgeInsets,
        Icon,
        IconButton,
        ListView,
        Padding,
        Scaffold,
        SizedBox,
        State,
        StatefulWidget,
        Text,
        TextStyle,
        Widget,
        ValueKey,
        Column,
        CrossAxisAlignment,
        AlwaysScrollableScrollPhysics,
        ClampingScrollPhysics,
        Color;
import 'package:morph_expressive/morph_expressive.dart';

/// Native scroll test for the gradient blur. Can also be embedded in the
/// desktop gallery, without triggering browser recording or extra shaders.
class MorphGradientAppBarSample extends StatefulWidget {
  const MorphGradientAppBarSample({super.key, this.embedded = false});

  final bool embedded;

  @override
  State<MorphGradientAppBarSample> createState() =>
      _MorphGradientAppBarSampleState();
}

class _MorphGradientAppBarSampleState extends State<MorphGradientAppBarSample> {
  int _page = 0;
  int _navIndex = 0;
  int _refreshCount = 0;

  Future<void> _refresh() async {
    await Future<void>.delayed(const Duration(milliseconds: 650));
    if (mounted) {
      setState(() => _refreshCount++);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = MorphTheme.of(context);
    final scheme = theme.colorScheme;
    return Scaffold(
      backgroundColor: scheme.surface,
      extendBodyBehindAppBar: true,
      appBar: MorphAppBar.frosted(
        titleText: 'Gradient glass',
        centerTitle: true,
        automaticallyImplyLeading: !widget.embedded,
        safeArea: !widget.embedded,
        glass: const MorphAppBarGlass(),
        actions: [
          IconButton(
            tooltip: 'Glass sample',
            icon: const Icon(MorphIcons.more_vert),
            onPressed: () {},
          ),
        ],
      ),
      body: MorphNavigationBarHost(
        bar: MorphNavigationBar.morph(
          floating: true,
          iconSize: 32,
          unselectedIconScale: 0.9,
          selectedIndex: _navIndex,
          onDestinationSelected: (index) => setState(() => _navIndex = index),
          glass: const MorphNavigationGlass(
            blurX: 10,
            blurY: 10,
            tintOpacity: 0.62,
            borderColor: Color(0x50FFFFFF),
            borderWidth: 0.8,
          ),
          destinations: [
            MorphNavigationBarDestination(
              icon: FluentIcons.line.home,
              selectedIcon: FluentIcons.filled.home,
              label: 'Home',
            ),
            MorphNavigationBarDestination(
              icon: FluentIcons.line.bookmark,
              label: 'Saved',
            ),
            MorphNavigationBarDestination(
              icon: FluentIcons.line.person,
              label: 'Profile',
            ),
          ],
        ),
        onRefresh: _refresh,
        body: (context, controller, contentPadding) {
          final double topInset = widget.embedded ? 88 : 104;
          final listPadding = EdgeInsets.fromLTRB(
            12,
            topInset,
            12,
            contentPadding.bottom + 16,
          );
          return ListView.builder(
            key: const ValueKey('gradient_app_bar_scroll'),
            controller: controller,
            physics: const AlwaysScrollableScrollPhysics(
              parent: ClampingScrollPhysics(),
            ),
            padding: listPadding,
            itemCount: 27,
            itemBuilder: (context, index) {
              if (index == 1) {
                return Padding(
                  padding: const EdgeInsets.fromLTRB(14, 0, 14, 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Page indicator · tap the compact dots'),
                      const SizedBox(height: 12),
                      MorphPageIndicator(
                        count: 3,
                        selectedIndex: _page,
                        effect: MorphPageIndicatorEffect.expand,
                        activeWidth: 32,
                        inactiveWidth: 12,
                        spacing: 6,
                        onPageSelected: (index) =>
                            setState(() => _page = index),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        'Pull to refresh · completed $_refreshCount',
                        style: theme.typeScale.bodySmall.copyWith(
                          color: scheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                );
              }
              return Padding(
                padding: const EdgeInsets.only(bottom: 9),
                child: Container(
                  height: 86,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: index.isEven
                        ? scheme.primaryContainer
                        : scheme.secondaryContainer,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Center(
                    child: Text(
                      'Scrollable item ${index + 1} · behind the title',
                      style: TextStyle(
                        color: index.isEven
                            ? scheme.onPrimaryContainer
                            : scheme.onSecondaryContainer,
                      ),
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
