import 'package:flutter_test/flutter_test.dart';
import 'package:morph_expressive_preview/component_catalog.dart';

void main() {
  test(
    'public widget catalog has no duplicates and covers the main families',
    () {
      final names = morphComponentCatalog.map((entry) => entry.name).toList();
      expect(names.length, greaterThan(100));
      expect(names.toSet().length, names.length);
      expect(
        names,
        containsAll([
          'MorphButton',
          'MorphChipToggle',
          'MorphDropdownMenu',
          'MorphTooltip',
          'MorphTextField',
          'MorphNavigationBar',
          'MorphTabs',
        ]),
      );
    },
  );
}
