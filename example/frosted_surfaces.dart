import 'package:material_ui/material_ui.dart'
    as ui
    show
        Alignment,
        BoxDecoration,
        BoxShape,
        BuildContext,
        Color,
        Colors,
        Container,
        DecoratedBox,
        EdgeInsets,
        IgnorePointer,
        LinearGradient,
        ListView,
        MaterialApp,
        Navigator,
        Padding,
        Positioned,
        RadialGradient,
        SafeArea,
        Scaffold,
        ScrollConfiguration,
        SizedBox,
        Stack,
        StackFit,
        StatelessWidget,
        Text,
        Theme,
        Widget,
        Wrap,
        runApp;
import 'package:morph_expressive/morph_expressive.dart';

/// Standalone, copyable example of glass surfaces and blur-safe scrolling.
///
/// Copy this file to `lib/main.dart` of a Flutter app that depends on
/// `morph_expressive` and `material_ui`, then run that app on Android or iOS.
void main() => ui.runApp(const FrostedSurfacesExampleApp());

class FrostedSurfacesExampleApp extends ui.StatelessWidget {
  const FrostedSurfacesExampleApp({super.key});

  @override
  ui.Widget build(ui.BuildContext context) {
    final theme = MorphThemeData.dark(seedColor: const ui.Color(0xFF86DCCB))
        .copyWith(
          floatingSurfaceGlass: const MorphSurfaceGlass(
            blurX: 14,
            blurY: 14,
            tintOpacity: 0.58,
          ),
        );

    return ui.MaterialApp(
      title: 'Morph Frosted Surfaces',
      theme: theme.toThemeData(),
      // Put MorphTheme above the Navigator so dialogs and sheets inherit it.
      builder: (context, child) =>
          MorphTheme(data: theme, child: child ?? const ui.SizedBox.shrink()),
      home: const FrostedSurfacesExamplePage(),
    );
  }
}

/// Public API demo: opaque, theme-frosted, and explicitly configured cards,
/// plus an opened dropdown panel, menu, dialog and sheet over a complex scene.
class FrostedSurfacesExamplePage extends ui.StatelessWidget {
  const FrostedSurfacesExamplePage({super.key});

  static const MorphSurfaceGlass _localGlass = MorphSurfaceGlass(
    blurX: 20,
    blurY: 20,
    tintOpacity: 0.35,
    borderColor: ui.Color(0x66FFFFFF),
    borderWidth: 1,
  );

  @override
  ui.Widget build(ui.BuildContext context) {
    // Also make the example work when opened from `example/main.dart`, whose
    // app theme does not otherwise enable floating glass.
    final theme = MorphTheme.of(context).copyWith(
      floatingSurfaceGlass: const MorphSurfaceGlass(
        blurX: 14,
        blurY: 14,
        tintOpacity: 0.58,
      ),
    );

    return MorphTheme(
      data: theme,
      child: ui.Scaffold(
        backgroundColor: ui.Colors.transparent,
        body: ui.Stack(
          fit: ui.StackFit.expand,
          children: <ui.Widget>[
            const _ColorfulBackdrop(),
            ui.SafeArea(
              child: ui.ScrollConfiguration(
                // Unlike Flutter's shader-backed indicator this adds no
                // ImageFiltered ancestor above the frosted cards.
                behavior: const MorphScrollBehavior(),
                child: ui.ListView(
                  padding: const ui.EdgeInsets.symmetric(
                    horizontal: 22,
                    vertical: 20,
                  ),
                  children: <ui.Widget>[
                    ui.Text(
                      'Frosted Surfaces',
                      style: ui.Theme.of(context).textTheme.headlineMedium,
                    ),
                    const ui.SizedBox(height: 8),
                    const ui.Text(
                      'Scroll past either edge. The colorful background stays '
                      'visible through opt-in frosted cards.',
                    ),
                    const ui.SizedBox(height: 24),
                    const MorphCard(
                      headline: 'Opaque by default',
                      supportingText:
                          'No backdrop sampling, even though the '
                          'theme enables glass for floating surfaces.',
                    ),
                    const ui.SizedBox(height: 12),
                    const MorphCard(
                      frosted: true,
                      headline: 'Theme frosted',
                      supportingText:
                          'Uses floatingSurfaceGlass from MorphTheme.',
                    ),
                    const ui.SizedBox(height: 12),
                    const MorphCard(
                      glass: _localGlass,
                      headline: 'Custom frosted',
                      supportingText: 'Local blur, tint and border override.',
                    ),
                    const ui.SizedBox(height: 24),
                    ui.Text(
                      'Floating surfaces',
                      style: ui.Theme.of(context).textTheme.titleLarge,
                    ),
                    const ui.SizedBox(height: 12),
                    const MorphDropdownMenu<String>(
                      items: <MorphDropdownItem<String>>[
                        MorphDropdownItem(label: 'Dart', value: 'dart'),
                        MorphDropdownItem(label: 'Kotlin', value: 'kotlin'),
                        MorphDropdownItem(label: 'Rust', value: 'rust'),
                      ],
                      singleSelect: true,
                      fieldStyle: MorphDropdownFieldStyle(
                        hintText: 'Frosted dropdown panel',
                      ),
                    ),
                    const ui.SizedBox(height: 16),
                    ui.Wrap(
                      spacing: 12,
                      runSpacing: 12,
                      children: <ui.Widget>[
                        MorphMenu.entries(
                          anchorBuilder: (context, open) => MorphButton(
                            style: MorphButtonStyle.outlined,
                            label: const ui.Text('Open menu'),
                            onPressed: open,
                          ),
                          entries: <MorphMenuEntry>[
                            MorphMenuEntry(label: 'Edit', value: 'edit'),
                            MorphMenuEntry(label: 'Share', value: 'share'),
                          ],
                        ),
                        MorphButton(
                          label: const ui.Text('Open dialog'),
                          onPressed: () => MorphDialog.show<void>(
                            context,
                            dialog: MorphDialog(
                              title: 'Frosted dialog',
                              content: const ui.Text(
                                'The background is blurred; the text remains '
                                'sharp and readable.',
                              ),
                              actions: <ui.Widget>[
                                MorphButton(
                                  label: const ui.Text('Close'),
                                  onPressed: () =>
                                      ui.Navigator.of(context).pop(),
                                ),
                              ],
                            ),
                          ),
                        ),
                        MorphButton(
                          style: MorphButtonStyle.tonal,
                          label: const ui.Text('Open sheet'),
                          onPressed: () => MorphBottomSheet.show<void>(
                            context,
                            builder: (context) => const ui.Padding(
                              padding: ui.EdgeInsets.all(28),
                              child: ui.Text(
                                'Frosted bottom sheet. Dismiss to see the '
                                'backdrop and cards again.',
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const ui.SizedBox(height: 24),
                    const MorphCard(
                      glass: MorphSurfaceGlass.disabled(),
                      headline: 'Explicitly opaque',
                      supportingText:
                          'A disabled glass override beats any '
                          'theme setting.',
                    ),
                    const ui.SizedBox(height: 180),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// A non-uniform backdrop makes the difference between opaque and frosted
/// surfaces obvious. It uses only Flutter drawing primitives, no assets.
class _ColorfulBackdrop extends ui.StatelessWidget {
  const _ColorfulBackdrop();

  @override
  ui.Widget build(ui.BuildContext context) {
    return ui.IgnorePointer(
      child: ui.DecoratedBox(
        decoration: const ui.BoxDecoration(
          gradient: ui.LinearGradient(
            begin: ui.Alignment.topLeft,
            end: ui.Alignment.bottomRight,
            colors: <ui.Color>[
              ui.Color(0xFF16243F),
              ui.Color(0xFF336E82),
              ui.Color(0xFF674F91),
            ],
          ),
        ),
        child: ui.Stack(
          fit: ui.StackFit.expand,
          children: <ui.Widget>[
            ui.Positioned(
              top: 95,
              right: -72,
              child: ui.Container(
                width: 270,
                height: 270,
                decoration: const ui.BoxDecoration(
                  shape: ui.BoxShape.circle,
                  gradient: ui.RadialGradient(
                    colors: <ui.Color>[
                      ui.Color(0xD6F1AD7A),
                      ui.Color(0x00F1AD7A),
                    ],
                  ),
                ),
              ),
            ),
            ui.Positioned(
              bottom: 80,
              left: -110,
              child: ui.Container(
                width: 340,
                height: 340,
                decoration: const ui.BoxDecoration(
                  shape: ui.BoxShape.circle,
                  gradient: ui.RadialGradient(
                    colors: <ui.Color>[
                      ui.Color(0xE06EE0CA),
                      ui.Color(0x006EE0CA),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
