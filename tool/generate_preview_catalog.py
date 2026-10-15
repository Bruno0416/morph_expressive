#!/usr/bin/env python3
"""Genera el inventario publico de widgets para la galeria web Morph Expressive."""
from pathlib import Path
import re

ROOT = Path(__file__).resolve().parent.parent
LIB = ROOT / 'lib'
TARGET = ROOT / 'preview' / 'lib' / 'component_catalog.dart'

# 1. recorrer exportaciones publicas y partes vinculadas
pending = [LIB / 'morph_expressive.dart']
visible = set()
while pending:
    source = pending.pop().resolve()
    if source in visible or not source.is_file():
        continue
    visible.add(source)
    content = source.read_text(encoding='utf-8')
    for path in re.findall(r"\b(?:export|part)\s+['\"]([^'\"]+)['\"]", content):
        if path.startswith('package:morph_expressive/'):
            pending.append(LIB / path.removeprefix('package:morph_expressive/'))
        elif not path.startswith(('package:', 'dart:')):
            pending.append(source.parent / path)

# 2. detectar los widgets accesibles desde morph_expressive.dart
widgets = set()
for source in visible:
    if LIB not in source.parents:
        continue
    relative = source.relative_to(LIB)
    if not relative.parts or relative.parts[0] not in ('components', 'foundations'):
        continue
    category = relative.parts[1] if relative.parts[0] == 'components' else 'foundation'
    for name in re.findall(
        r'\bclass\s+(Morph\w+)(?:<[^>]+>)?\s+extends\s+(?:StatefulWidget|StatelessWidget)\b',
        source.read_text(encoding='utf-8'),
    ):
        widgets.add((category, name))

# 3. mantener el catalogo sin dependencia de analisis en runtime
header = '''// Generated from public Morph Expressive exports. Do not edit manually.
// Regenerate with: python tool/generate_preview_catalog.py

class MorphCatalogEntry {
  const MorphCatalogEntry(this.category, this.name);

  final String category;
  final String name;
}

const morphComponentCatalog = <MorphCatalogEntry>[\n'''
TARGET.parent.mkdir(parents=True, exist_ok=True)
TARGET.write_text(
    header + ''.join(
        f"  MorphCatalogEntry('{category}', '{name}'),\n"
        for category, name in sorted(widgets)
    ) + '];\n',
    encoding='utf-8',
)
print(f'Morph Expressive preview catalog: {len(widgets)} exported widgets')
