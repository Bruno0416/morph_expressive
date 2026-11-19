// Quick start copied verbatim from README.md (Quick start section). Compiled by
// test/doc_examples_test.dart; keep both in sync.
import 'package:material_ui/material_ui.dart'
    show Center, Color, Scaffold, Text, runApp;
import 'package:morph_expressive/morph_expressive.dart'
    show MorphButton, MorphMaterialApp, MorphThemeData;

void main() {
  runApp(
    MorphMaterialApp(
      data: MorphThemeData.light(seedColor: const Color(0xFF6750A4)),
      home: Scaffold(
        body: Center(
          child: MorphButton.filled(
            variant: .tertiary,
            onPressed: () {},
            child: const Text('Continue'),
          ),
        ),
      ),
    ),
  );
}
