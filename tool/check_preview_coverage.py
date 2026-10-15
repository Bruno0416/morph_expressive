#!/usr/bin/env python3
"""Confirma que la preview tenga una ruta visual para cada familia exportada."""
from pathlib import Path
import re

root = Path(__file__).resolve().parents[1]
catalog = (root / 'preview/lib/component_catalog.dart').read_text()
gallery = (root / 'preview/lib/component_gallery.dart').read_text()
categories = set(re.findall(r"MorphCatalogEntry\('([^']+)'", catalog))
# Foundation contains theme tokens, not interactive components; its removal
# from the public showcase is intentional.
categories.discard('foundation')
cases = set(re.findall(r"case '([^']+)':", gallery))
missing = sorted(categories - cases)
print(f'Preview: {len(categories) - len(missing)}/{len(categories)} familias con ejemplos')
if missing:
    raise SystemExit('Familias sin preview: ' + ', '.join(missing))
if "'icon_lab'" in gallery:
    raise SystemExit('La galeria de iconos eliminada no debe volver.')
print('Cobertura de familias OK')
