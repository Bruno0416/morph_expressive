#!/usr/bin/env python3
"""Comprueba la migracion de presets y la retirada del grid de iconos."""
from pathlib import Path
import re

ROOT = Path(__file__).resolve().parent.parent


def main() -> None:
    components = ROOT / 'lib' / 'components'
    direct = [str(p.relative_to(ROOT)) for p in components.rglob('*.dart')
              if 'MaterialSpringMotion.' in p.read_text()]
    if direct:
        raise SystemExit('Quedan presets MaterialSpringMotion: ' + ', '.join(direct))

    # SpringMotion en motor no implementa copyWith(stiffness/damping).
    # El adaptador debe recibir directamente el MorphSpring configurado.
    invalid_copy_with = []
    pattern = re.compile(
        r'MorphMotion\.springMotion\([^)]*\)\s*\.copyWith\s*\('
    )
    for path in components.rglob('*.dart'):
        content = path.read_text()
        for match in pattern.finditer(content):
            line = content.count('\n', 0, match.start()) + 1
            invalid_copy_with.append(f'{path.relative_to(ROOT)}:{line}')
    if invalid_copy_with:
        raise SystemExit(
            'SpringMotion no admite copyWith; usar MorphMotion.springMotion(spring): '
            + ', '.join(invalid_copy_with)
        )

    preview = ROOT / 'preview' / 'lib' / 'component_gallery.dart'
    content = preview.read_text()
    if 'MorphIconAlignmentLab' in content or "'icon_lab'" in content:
        raise SystemExit('La galeria temporal de iconos sigue exportada')

    widget_test = ROOT / 'preview' / 'test' / 'widget_test.dart'
    if 'icon_lab_' in widget_test.read_text():
        raise SystemExit('Quedan pruebas de la galeria de iconos retirada')

    print('Motion: presets migrados y pruebas de galeria sin icon lab')


if __name__ == '__main__':
    main()
