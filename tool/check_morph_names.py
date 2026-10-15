#!/usr/bin/env python3
"""Comprueba que la migracion fisica no deje imports ni fuentes m3e."""
from pathlib import Path
import re

ROOT = Path(__file__).resolve().parent.parent
LIB = ROOT / 'lib'
issues = []
for path in LIB.rglob('*.dart'):
    relative = path.relative_to(ROOT)
    if path.name.startswith('m3e_'):
        issues.append(f'legacy file: {relative}')
    text = path.read_text(encoding='utf-8')
    if re.search(r'\bm3e\w*', text):
        issues.append(f'legacy identifier: {relative}')
    for uri in re.findall(r"(?:import|export|part)\s+['\"]([^'\"]+)['\"]", text):
        if uri.startswith('package:morph_expressive/'):
            target = LIB / uri.removeprefix('package:morph_expressive/')
        elif uri.startswith(('package:', 'dart:')):
            continue
        else:
            target = path.parent / uri
        if not target.is_file():
            issues.append(f'broken reference {relative}: {uri}')

if (LIB / 'material_3_expressive.dart').exists():
    issues.append('legacy public facade remains')

if issues:
    raise SystemExit('\n'.join(issues))
print('Correcto: sin archivos m3e, identificadores viejos ni imports rotos.')
