// Integration with an existing MaterialApp, shown in doc/GETTING_STARTED.md and
// doc/THEMING.md. Compiled by test/doc_examples_test.dart.
import 'package:material_ui/material_ui.dart'
    show
        Brightness,
        BuildContext,
        Center,
        Color,
        MaterialApp,
        Scaffold,
        SizedBox,
        StatelessWidget,
        Text,
        Theme,
        ThemeMode,
        Widget,
        runApp;
import 'package:morph_expressive/morph_expressive.dart';

void main() => runApp(const ExistingApp());

class ExistingApp extends StatelessWidget {
  const ExistingApp({super.key});

  @override
  Widget build(BuildContext context) {
    const seed = Color(0xFF6750A4);
    final light = MorphThemeData.light(seedColor: seed);
    final dark = MorphThemeData.dark(seedColor: seed);

    return MaterialApp(
      theme: light.toThemeData(),
      darkTheme: dark.toThemeData(),
      themeMode: ThemeMode.system,
      // The builder wraps the Navigator, so dialogs, menus and sheets also see
      // the Morph theme. Pick the data that matches the Material brightness.
      builder: (context, child) => MorphTheme(
        data: Theme.of(context).brightness == Brightness.dark ? dark : light,
        child: child ?? const SizedBox.shrink(),
      ),
      home: Scaffold(
        body: Center(
          child: MorphButton(onPressed: () {}, child: const Text('Continue')),
        ),
      ),
    );
  }
}
