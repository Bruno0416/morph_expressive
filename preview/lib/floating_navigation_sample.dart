import 'dart:ui' show PointerDeviceKind;

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/widgets.dart';
import 'package:morph_expressive/morph_expressive.dart';

/// Keeps refresh/selection local so the complete gallery is not rebuilt.
class FloatingNavigationSample extends StatefulWidget {
  const FloatingNavigationSample({super.key});

  @override
  State<FloatingNavigationSample> createState() =>
      _FloatingNavigationSampleState();
}

class _FloatingNavigationSampleState extends State<FloatingNavigationSample> {
  int _selectedIndex = 0;
  int _refreshCount = 0;

  Future<void> _refresh() async {
    // A short simulated request makes the running/completed states observable.
    await Future<void>.delayed(const Duration(milliseconds: 650));
    if (mounted) setState(() => _refreshCount++);
  }

  @override
  Widget build(BuildContext context) {
    final scheme = MorphTheme.of(context).colorScheme;
    final behavior = ScrollConfiguration.of(context);
    return ClipRect(
      child: RepaintBoundary(
        child: ScrollConfiguration(
          behavior: behavior.copyWith(
            dragDevices: {...behavior.dragDevices, PointerDeviceKind.mouse},
            scrollbars: false,
          ),
          child: MorphNavigationBarHost(
            bar: MorphNavigationBar.expressive(
              floating: true,
              selectedIndex: _selectedIndex,
              onDestinationSelected: (i) => setState(() => _selectedIndex = i),
              glass: const MorphNavigationGlass(
                // Restore real frosted blur. A smaller kernel is preferable in
                // the continuously animated web gallery (the original app
                // uses 10px in a simpler, single-screen composition).
                blurX: kIsWeb ? 5 : 10,
                blurY: kIsWeb ? 5 : 10,
                webBackdropBlur: true,
                tintOpacity: 0.62,
                borderColor: Color(0x50FFFFFF),
                borderWidth: 0.8,
              ),
              destinations: [
                MorphNavigationBarDestination(
                  icon: Icon(FluentIcons.line.home),
                  selectedIcon: Icon(FluentIcons.filled.home),
                  label: 'Home',
                ),
                MorphNavigationBarDestination(
                  icon: Icon(FluentIcons.line.bookmark),
                  label: 'Saved',
                ),
                MorphNavigationBarDestination(
                  icon: Icon(FluentIcons.line.person),
                  label: 'Profile',
                ),
              ],
            ),
            onRefresh: _refresh,
            body: (context, controller, padding) => ListView.builder(
              key: const ValueKey('floating_navigation_content'),
              controller: controller,
              padding: padding,
              // A nested gallery must not inherit bouncing underscroll: the
              // refresh indicator itself owns the leading reveal space.
              physics: const AlwaysScrollableScrollPhysics(
                parent: ClampingScrollPhysics(),
              ),
              itemCount: 20,
              itemBuilder: (context, i) => Container(
                height: 64,
                color: i.isEven
                    ? scheme.primaryContainer
                    : scheme.surfaceContainer,
                child: Center(
                  child: Text('Content ${i + 1} · refresh $_refreshCount'),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
