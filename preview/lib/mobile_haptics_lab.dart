import 'package:gap/gap.dart';
import 'package:material_ui/material_ui.dart'
    show
        AlwaysScrollableScrollPhysics,
        BorderRadius,
        BoxDecoration,
        BuildContext,
        Center,
        Column,
        CrossAxisAlignment,
        DecoratedBox,
        EdgeInsets,
        Icon,
        ListTile,
        ListView,
        MainAxisSize,
        Material,
        MaterialPageRoute,
        MaterialType,
        Navigator,
        Padding,
        Scaffold,
        SizedBox,
        Stack,
        State,
        StatefulWidget,
        SwitchListTile,
        Text,
        ValueChanged,
        VoidCallback,
        Widget,
        Wrap;
import 'package:morph_expressive/morph_expressive.dart';

/// Touch-first playground. Run natively to feel the actual platform haptics;
/// the web preview does not provide an equivalent hardware signal.
class MorphMobileHapticsLab extends StatefulWidget {
  const MorphMobileHapticsLab({
    required this.hapticsEnabled,
    required this.hapticFeedback,
    required this.onHapticsEnabledChanged,
    required this.onHapticFeedbackChanged,
    required this.darkMode,
    required this.onToggleTheme,
    super.key,
  });

  final bool hapticsEnabled;
  final MorphHapticFeedback hapticFeedback;
  final ValueChanged<bool> onHapticsEnabledChanged;
  final ValueChanged<MorphHapticFeedback> onHapticFeedbackChanged;
  final bool darkMode;
  final VoidCallback onToggleTheme;

  @override
  State<MorphMobileHapticsLab> createState() => _MorphMobileHapticsLabState();
}

class _MorphMobileHapticsLabState extends State<MorphMobileHapticsLab> {
  int _selected = 0;
  int _drawerSelected = 0;
  int _refreshCount = 0;
  String _lastAction = 'No action yet';
  final MorphNavigationDrawerController _drawer =
      MorphNavigationDrawerController();

  @override
  void dispose() {
    _drawer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = MorphTheme.of(context);
    final scheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: scheme.surface,
      appBar: MorphAppBar.top(
        titleText: 'Morph · Touch Lab',
        centerTitle: true,
        automaticallyImplyLeading: false,
        leading: MorphIconButton(
          variant: MorphIconButtonVariant.standard,
          icon: const Icon(MorphIcons.menu),
          tooltip: 'Open navigation drawer',
          onPressed: _drawer.open,
        ),
        actions: [
          MorphIconButton(
            variant: MorphIconButtonVariant.standard,
            icon: Icon(
              widget.darkMode
                  ? FluentIcons.line.weather_sunny
                  : FluentIcons.line.weather_moon,
            ),
            tooltip: 'Switch theme',
            onPressed: widget.onToggleTheme,
          ),
        ],
      ),
      body: Stack(
        children: [
          ListView(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
            children: [
              Text('Device haptics', style: theme.typeScale.headlineSmall),
              const Gap(6),
              Text(
                'Try each gesture on your phone. Toggle haptics off to verify '
                'that Morph is silent, then compare Light / Medium / Heavy.',
                style: theme.typeScale.bodyMedium.copyWith(
                  color: scheme.onSurfaceVariant,
                ),
              ),
              const Gap(12),
              _section(
                context,
                'Global settings',
                Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Material(
                      type: MaterialType.transparency,
                      child: SwitchListTile.adaptive(
                        contentPadding: EdgeInsets.zero,
                        title: const Text('Enable Morph haptics'),
                        value: widget.hapticsEnabled,
                        onChanged: widget.onHapticsEnabledChanged,
                      ),
                    ),
                    const Gap(8),
                    MorphButtonGroup(
                      type: MorphButtonGroupType.connected,
                      overflow: MorphButtonGroupOverflow.none,
                      selectedIndex: switch (widget.hapticFeedback) {
                        MorphHapticFeedback.medium => 1,
                        MorphHapticFeedback.heavy => 2,
                        _ => 0,
                      },
                      selectionRequired: true,
                      onSelectedIndexChanged: (index) {
                        if (index == null) return;
                        widget.onHapticFeedbackChanged(switch (index) {
                          1 => MorphHapticFeedback.medium,
                          2 => MorphHapticFeedback.heavy,
                          _ => MorphHapticFeedback.light,
                        });
                      },
                      actions: const [
                        MorphButtonGroupAction(label: Text('Light')),
                        MorphButtonGroupAction(label: Text('Medium')),
                        MorphButtonGroupAction(label: Text('Heavy')),
                      ],
                    ),
                  ],
                ),
              ),
              _section(
                context,
                'Buttons · radius and haptics',
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Hold, release, and tap quickly. Watch the corners round '
                      'back smoothly after your finger lifts.',
                      style: theme.typeScale.bodySmall,
                    ),
                    const Gap(14),
                    Wrap(
                      spacing: 12,
                      runSpacing: 12,
                      children: [
                        MorphButton.filled(
                          onPressed: () => _record('Filled button'),
                          child: const Text('Tap / hold'),
                        ),
                        MorphButton.tonal(
                          onPressed: () => _record('Tonal button'),
                          child: const Text('Tonal'),
                        ),
                        MorphButton.outlined(
                          onPressed: () => _record('Outlined button'),
                          child: const Text('Outlined'),
                        ),
                        MorphIconButton(
                          variant: MorphIconButtonVariant.filled,
                          icon: const Icon(MorphIcons.star),
                          tooltip: 'Icon button haptic',
                          onPressed: () => _record('Icon button'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              _section(
                context,
                'Connected button group',
                MorphButtonGroup(
                  type: MorphButtonGroupType.connected,
                  overflow: MorphButtonGroupOverflow.none,
                  selectedIndex: _selected,
                  selectionRequired: true,
                  onSelectedIndexChanged: (index) {
                    if (index == null) return;
                    setState(() {
                      _selected = index;
                      _lastAction = 'Selected ${index + 1}';
                    });
                  },
                  actions: const [
                    MorphButtonGroupAction(label: Text('Day')),
                    MorphButtonGroupAction(label: Text('Week')),
                    MorphButtonGroupAction(label: Text('Month')),
                  ],
                ),
              ),
              _section(
                context,
                'Swipeable list',
                Column(
                  children: [
                    Text(
                      'Drag left/right to reveal actions, or tap ⋮. Listen for '
                      'the rhythmic feedback while it moves.',
                      style: theme.typeScale.bodySmall,
                    ),
                    const Gap(8),
                    MorphList(
                      itemCount: 3,
                      itemBuilder: (context, index) => MorphListItem(
                        headline: 'Swipe item ${index + 1}',
                        supportingText: 'Swipe or tap more options',
                        leading: const Icon(MorphIcons.star),
                        swipe: MorphListItemSwipe(
                          mode: MorphListSwipeMode.reveal,
                          leading: [
                            MorphListSwipeAction(
                              icon: const Icon(MorphIcons.star),
                              tooltip: 'Favorite',
                              onPressed: () =>
                                  _record('Favorited ${index + 1}'),
                            ),
                          ],
                          trailing: [
                            MorphListSwipeAction(
                              icon: const Icon(MorphIcons.archive),
                              tooltip: 'Archive',
                              onPressed: () => _record('Archived ${index + 1}'),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              _section(
                context,
                'Snackbar and sheets',
                Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: [
                    MorphButton(
                      label: const Text('Swipe snackbar'),
                      onPressed: () => MorphSnackbar.show(
                        context,
                        message: 'Swipe left or right to dismiss',
                        swipeDismissible: true,
                        showCloseButton: true,
                      ),
                    ),
                    MorphButton(
                      label: const Text('Bottom sheet'),
                      onPressed: () => MorphBottomSheet.show<void>(
                        context,
                        builder: (sheetContext) => Padding(
                          padding: const EdgeInsets.all(24),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Drag to expand or close',
                                style: theme.typeScale.titleLarge,
                              ),
                              const Gap(20),
                              MorphButton(
                                onPressed: () =>
                                    Navigator.of(sheetContext).pop(),
                                label: const Text('Close'),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    MorphButton(
                      label: const Text('Side sheet'),
                      onPressed: () => MorphSideSheet.show<void>(
                        context,
                        title: 'Slide from the edge',
                        body: const Padding(
                          padding: EdgeInsets.all(20),
                          child: Text('Drag the edge and dismiss this panel.'),
                        ),
                      ),
                    ),
                    MorphButton(
                      label: const Text('Automatic back'),
                      onPressed: () => Navigator.of(context).push(
                        MaterialPageRoute<void>(
                          builder: (_) => Scaffold(
                            appBar: const MorphAppBar.top(
                              titleText: 'Back haptic',
                              automaticallyImplyLeading: true,
                            ),
                            body: const Center(
                              child: Text('Tap the automatic back arrow.'),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              _section(
                context,
                'Pull to refresh',
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Pull down inside this area until the threshold.',
                    ),
                    const Gap(8),
                    SizedBox(
                      height: 210,
                      child: MorphRefreshIndicator(
                        onRefresh: () async {
                          if (mounted) setState(() => _refreshCount++);
                        },
                        child: ListView.builder(
                          physics: const AlwaysScrollableScrollPhysics(),
                          itemCount: 8,
                          itemBuilder: (_, i) => Material(
                            type: MaterialType.transparency,
                            child: ListTile(
                              title: Text('Refresh item ${i + 1}'),
                              subtitle: Text(
                                'Refreshed $_refreshCount time(s)',
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const Gap(8),
              Text(
                'Last interaction: $_lastAction',
                style: theme.typeScale.labelLarge,
              ),
            ],
          ),
          MorphNavigationDrawer(
            type: MorphNavigationDrawerType.modal,
            controller: _drawer,
            selectedIndex: _drawerSelected,
            onDestinationSelected: (index) => setState(() {
              _drawerSelected = index;
              _lastAction = 'Drawer destination ${index + 1}';
            }),
            headline: 'Test navigation',
            destinations: const [
              MorphNavigationDestination(
                label: 'Home',
                icon: Icon(MorphIcons.home),
              ),
              MorphNavigationDestination(
                label: 'Favorites',
                icon: Icon(MorphIcons.star),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _section(BuildContext context, String title, Widget child) {
    final scheme = MorphTheme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.only(bottom: 18),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: scheme.surfaceContainerLow,
          borderRadius: BorderRadius.circular(24),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: MorphTheme.of(context).typeScale.titleMedium),
              const Gap(12),
              child,
            ],
          ),
        ),
      ),
    );
  }

  void _record(String action) => setState(() => _lastAction = action);
}
