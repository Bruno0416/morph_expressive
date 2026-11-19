import 'package:flutter_test/flutter_test.dart';
import 'package:morph_expressive_preview/component_catalog.dart';
import 'package:morph_expressive_preview/main.directories.g.dart';
import 'package:morph_expressive_preview/widgetbook/coverage_manifest.dart';
import 'package:widgetbook/widgetbook.dart';

/// Display path of a node without the root, e.g. `Actions/Buttons/MorphButton`.
String _display(WidgetbookNode node) =>
    node.nodesPath.skip(1).map((n) => n.name).join('/');

void main() {
  final root = WidgetbookRoot(children: directories);
  final nodes = <WidgetbookNode>[];
  void walk(WidgetbookNode node) {
    nodes.add(node);
    node.children?.forEach(walk);
  }

  root.children?.forEach(walk);
  final folders = {
    for (final node in nodes.where((n) => n is! WidgetbookUseCase))
      _display(node),
  };
  final components = nodes.whereType<WidgetbookComponent>().toList();

  test('every catalog entry has a manifest entry and vice versa', () {
    final catalogNames = morphComponentCatalog.map((e) => e.name).toSet();
    expect(
      catalogNames.difference(morphCoverageManifest.keys.toSet()),
      isEmpty,
      reason: 'exported widgets without Widgetbook coverage',
    );
    expect(
      morphCoverageManifest.keys.toSet().difference(catalogNames),
      isEmpty,
      reason: 'manifest entries that are no longer exported',
    );
    expect(catalogNames.length, morphCoverageManifest.length);
  });

  test('every manifest path exists in the generated Widgetbook tree', () {
    for (final entry in morphCoverageManifest.entries) {
      expect(entry.value.paths, isNotEmpty, reason: entry.key);
      for (final path in entry.value.paths) {
        expect(folders, contains(path), reason: '${entry.key} -> $path');
      }
    }
  });

  test('widgets without their own component explain where they appear', () {
    final missing = <String>[];
    for (final entry in morphCoverageManifest.entries) {
      final own = components.any(
        (c) =>
            c.name == entry.key &&
            entry.value.paths.any((p) => _display(c).startsWith('$p/')),
      );
      if (!own && (entry.value.note ?? '').isEmpty) missing.add(entry.key);
    }
    expect(missing, isEmpty, reason: 'add a note or a dedicated use case');
  });

  test('no navigation category is empty', () {
    for (final category in root.children!) {
      expect(category.leaves.whereType<WidgetbookUseCase>(), isNotEmpty);
    }
    expect(
      {for (final c in root.children!) c.name},
      containsAll(<String>{
        'Foundations',
        'Actions',
        'Selection',
        'Inputs',
        'Navigation',
        'Surfaces & Content',
        'Feedback',
        'Overlays',
      }),
    );
  });
}
