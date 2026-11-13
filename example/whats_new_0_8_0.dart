// A runnable tour of the 0.8.0 additions. The snippets in doc/UPGRADE_0_8_0.md
// are excerpts of this file, so they are analyzed with the package.
//
//   flutter run -t example/whats_new_0_8_0.dart
import 'package:material_ui/material_ui.dart'
    show
        BuildContext,
        Color,
        Column,
        CrossAxisAlignment,
        EdgeInsets,
        Icon,
        MaterialApp,
        Scaffold,
        SingleChildScrollView,
        SizedBox,
        State,
        StatefulWidget,
        StatelessWidget,
        Text,
        Widget,
        runApp;
import 'package:morph_expressive/morph_expressive.dart';

void main() => runApp(const WhatsNewApp());

class WhatsNewApp extends StatelessWidget {
  const WhatsNewApp({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = MorphThemeData.light(seedColor: const Color(0xFF6750A4));
    return MaterialApp(
      theme: theme.toThemeData(),
      home: MorphTheme(
        data: theme,
        child: const Scaffold(
          body: SingleChildScrollView(
            padding: EdgeInsets.all(24),
            child: WhatsNewPage(),
          ),
        ),
      ),
    );
  }
}

class WhatsNewPage extends StatefulWidget {
  const WhatsNewPage({super.key});

  @override
  State<WhatsNewPage> createState() => _WhatsNewPageState();
}

class _WhatsNewPageState extends State<WhatsNewPage> {
  MorphOperationState operation = MorphOperationState.idle;
  bool loading = true;
  int range = 1;
  int tab = 0;
  final MorphTabsController tabs = MorphTabsController();

  @override
  void dispose() {
    tabs.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Operations: the application owns the state.
        MorphAsyncButton(
          label: 'Save changes',
          state: operation,
          presentation: MorphOperationPresentation.preserveWidth,
          labels: const {
            MorphOperationState.success: 'Saved',
            MorphOperationState.error: 'Retry',
          },
          onPressed: () =>
              setState(() => operation = MorphOperationState.loading),
        ),
        const SizedBox(height: 24),
        // Placeholders: one coordinated, tilted shimmer.
        MorphSkeletonGroup(
          loading: loading,
          angle: 18,
          semanticLabel: 'Loading profile',
          placeholder: Column(
            children: [
              const MorphSkeleton.avatar(),
              MorphSkeleton.lines(count: 3),
            ],
          ),
          child: const Text('Real content, same layout'),
        ),
        const SizedBox(height: 24),
        // Reactive group: the neighbours of a pressed item give way a little.
        MorphReactiveButtonGroup(
          selectedIndex: range,
          selectedExpansion: 0.08,
          onSelectedIndexChanged: (next) =>
              setState(() => range = next ?? range),
          items: const [
            MorphReactiveGroupItem(label: Text('Day')),
            MorphReactiveGroupItem(label: Text('Week')),
            MorphReactiveGroupItem(label: Text('Month')),
          ],
        ),
        const SizedBox(height: 24),
        // Shape button with a continuous rotation.
        MorphShapeButton(
          shape: MorphShapeCatalog.cookie7Sided,
          rotationEnabled: true,
          semanticLabel: 'Favorite',
          onPressed: () {},
          child: const Icon(MorphIcons.favorite_border),
        ),
        const SizedBox(height: 24),
        // Tabs linked to real pages: share one controller.
        MorphTabs(
          controller: tabs,
          tabs: const [
            MorphTab(label: 'Overview'),
            MorphTab(label: 'Activity'),
          ],
          selectedIndex: tab,
          onTabSelected: (i) => setState(() => tab = i),
          indicatorStyle: MorphTabsIndicatorStyle.surface,
        ),
        SizedBox(
          height: 80,
          child: MorphTabsView(
            controller: tabs,
            selectedIndex: tab,
            onTabSelected: (i) => setState(() => tab = i),
            children: const [Text('Overview page'), Text('Activity page')],
          ),
        ),
        // Menus: submenus open on hover; choose click explicitly if preferred.
        MorphMenu.entries(
          submenuBehavior: const MorphMenuSubmenuBehavior(
            mode: MorphMenuSubmenuOpenMode.click,
          ),
          anchorBuilder: (context, open) =>
              MorphButton(onPressed: open, label: const Text('Menu')),
          entries: [MorphMenuEntry(label: 'Rename', onPressed: () {})],
        ),
        const SizedBox(height: 24),
        // FAB menu: one surface; the renderer falls back to Canvas by itself.
        SizedBox(
          height: 240,
          child: MorphFabMenu(
            items: [
              MorphFabMenuItem(
                icon: const Icon(MorphIcons.add),
                label: 'Create',
                onPressed: () {},
              ),
              MorphFabMenuItem(
                icon: const Icon(MorphIcons.favorite),
                label: 'Save',
                onPressed: () {},
              ),
            ],
          ),
        ),
      ],
    );
  }
}
