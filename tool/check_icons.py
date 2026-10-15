#!/usr/bin/env python3
"""Valida el reemplazo de glifos Material por fuentes Fluent en Morph Expressive."""

from pathlib import Path
import re

ROOT = Path(__file__).resolve().parent.parent
ICONS = ROOT / 'lib/foundations/morph_icons.dart'
source = ICONS.read_text(encoding='utf-8')
used = set()
for directory in ('lib', 'test'):
    for path in (ROOT / directory).rglob('*.dart'):
        if path == ICONS:
            continue
        content = path.read_text(encoding='utf-8')
        used.update(re.findall(r'\bMorphIcons\.(\w+)', content))
        if directory == 'lib' and re.search(r'(?<![\w])Icons\.[a-zA-Z_]\w*', content):
            raise SystemExit(f'Icono Material remanente: {path.relative_to(ROOT)}')

records = re.findall(
    r'static const IconData (\w+)\s*=\s*IconData\(\s*'
    r'0x([a-fA-F0-9]+),\s*fontFamily: \'(FluentKitLine|FluentKitFilled)\',\s*'
    r'fontPackage: \'fluent_icons_kit\',',
    source,
)
identifiers = {name for name, _, _ in records}
missing = used - identifiers
if missing:
    raise SystemExit(f'Constantes sin definicion: {sorted(missing)}')
if 'MaterialIcons' in source:
    raise SystemExit('La fuente MaterialIcons sigue presente')
print(f'Correcto: {len(records)} iconos predeterminados Fluent y {len(used)} referencias validas.')
