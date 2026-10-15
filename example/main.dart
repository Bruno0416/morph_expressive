import 'package:material_ui/material_ui.dart';
import 'package:morph_expressive/morph_expressive.dart';

void main() => runApp(const MorphExampleApp());

class MorphExampleApp extends StatelessWidget {
  const MorphExampleApp({super.key});

  @override
  Widget build(BuildContext context) {
    const seed = Color(0xFF6750A4);
    final theme = MorphThemeData.light(seedColor: seed);

    return MaterialApp(
      title: 'Morph Expressive example',
      theme: theme.toThemeData(),
      home: MorphTheme(
        data: theme,
        child: Scaffold(
          appBar: AppBar(title: const Text('Morph Expressive')),
          body: Center(
            child: MorphButton(
              label: const Text('Continue'),
              icon: const Icon(MorphIcons.check),
              onPressed: () {},
            ),
          ),
        ),
      ),
    );
  }
}
