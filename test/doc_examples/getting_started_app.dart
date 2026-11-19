// Getting-started program shown in doc/GETTING_STARTED.md. It is copied verbatim
// into that document and compiled by test/doc_examples_test.dart.
import 'package:material_ui/material_ui.dart'
    show
        BuildContext,
        Center,
        Color,
        Column,
        MainAxisSize,
        Scaffold,
        StatelessWidget,
        Text,
        Widget,
        runApp;
import 'package:morph_expressive/morph_expressive.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MorphMaterialApp(
      // One seed color generates the whole palette. Dark mode is derived from
      // the same seed and follows the platform brightness.
      data: MorphThemeData.light(seedColor: const Color(0xFF6750A4)),
      autoTheming: true,
      home: Scaffold(
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            spacing: 16,
            children: [
              MorphButton(onPressed: () {}, child: const Text('Continue')),
              MorphButton.tonal(
                variant: .tertiary,
                onPressed: () {},
                child: const Text('Explore'),
              ),
              MorphButton.outlined(
                variant: .danger,
                surface: .frosted,
                onPressed: () {},
                child: const Text('Delete'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
