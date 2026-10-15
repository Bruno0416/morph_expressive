#!/usr/bin/env python3
"""Comprueba los nombres publicos y las referencias locales del fork."""

from pathlib import Path
import re

ROOT = Path(__file__).resolve().parent.parent
DART_FILES = tuple((ROOT / "lib").rglob("*.dart"))
issues = []

for path in DART_FILES:
    source = path.read_text(encoding="utf-8")
    if "package:material_3_expressive/" in source:
        issues.append(f"old package import: {path.relative_to(ROOT)}")
    types = re.findall(r"\b(?:class|enum|mixin|typedef)\s+(M3E\w*)", source)
    if types:
        issues.append(f"old public names: {path.relative_to(ROOT)}: {types[:5]}")

if issues:
    raise SystemExit("\n".join(issues))

print(f"Correcto: {len(DART_FILES)} archivos Dart migrados a Morph*." )
