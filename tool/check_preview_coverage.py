#!/usr/bin/env python3
"""Validates that the Widgetbook preview covers the public Morph API.

Compares four sources of truth:

1. ``preview/lib/component_catalog.dart``: exported widgets, regenerated from
   the public entry point by ``tool/generate_preview_catalog.py`` (must be
   up to date).
2. ``preview/lib/widgetbook/coverage_manifest.dart``: the explicit, maintained
   mapping from every exported widget to the Widgetbook paths exercising it.
3. ``preview/lib/main.directories.g.dart``: the generated Widgetbook tree.
4. The library sources: named constructors of the visual-type families and
   the components that accept ``variant`` / ``surface``.

The semantic checks (manifest == catalog, paths exist in the live tree) are
also asserted by ``preview/test/widgetbook/coverage_test.dart``; this script
keeps them in the fast, SDK-free gate.
"""
from __future__ import annotations

from pathlib import Path
import re
import subprocess
import sys

ROOT = Path(__file__).resolve().parents[1]
PREVIEW = ROOT / 'preview' / 'lib'
CATALOG = PREVIEW / 'component_catalog.dart'
MANIFEST = PREVIEW / 'widgetbook' / 'coverage_manifest.dart'
DIRECTORIES = PREVIEW / 'main.directories.g.dart'
USE_CASES = PREVIEW / 'widgetbook' / 'use_cases'

# Families whose visual type is chosen with a named constructor. Every named
# constructor must appear in at least one use case.
TYPE_FAMILIES = {
    'MorphButton': ROOT / 'lib/components/buttons/morph_buttons.dart',
    'MorphIconButton': ROOT / 'lib/components/icon_buttons/morph_icon_buttons.dart',
    'MorphCard': ROOT / 'lib/components/cards/morph_cards.dart',
    'MorphTextField': ROOT / 'lib/components/text_fields/morph_text_fields.dart',
    'MorphChip': ROOT / 'lib/components/chips/morph_chips.dart',
}

NODE = re.compile(r'_widgetbook\.(Widgetbook\w+)\(')
NAME = re.compile(r"name:\s*'((?:[^'\\]|\\.)*)'")


def fail(problems: list[str]) -> None:
    raise SystemExit('Widgetbook coverage problems:\n  - ' + '\n  - '.join(problems))


def matching_paren(text: str, open_index: int) -> int:
    depth = 0
    quote = None
    i = open_index
    while i < len(text):
        ch = text[i]
        if quote:
            if ch == '\\':
                i += 2
                continue
            if ch == quote:
                quote = None
        elif ch in '\'"':
            quote = ch
        elif ch == '(':
            depth += 1
        elif ch == ')':
            depth -= 1
            if depth == 0:
                return i
        i += 1
    raise ValueError('unbalanced parentheses in generated directories')


def widgetbook_tree(text: str) -> tuple[set[str], set[str], int]:
    """Returns (folder paths, component names, use case count)."""
    paths: set[str] = set()
    components: set[str] = set()
    use_cases = 0
    stack: list[tuple[int, str, str]] = []  # (end, kind, name)
    for match in NODE.finditer(text):
        start = match.end() - 1
        end = matching_paren(text, start)
        while stack and stack[-1][0] < start:
            stack.pop()
        kind = match.group(1)
        name_match = NAME.search(text, start)
        name = name_match.group(1) if name_match else ''
        if kind in ('WidgetbookCategory', 'WidgetbookFolder'):
            parents = [n for _, k, n in stack if k in ('WidgetbookCategory', 'WidgetbookFolder')]
            paths.add('/'.join([*parents, name]))
        elif kind in ('WidgetbookComponent', 'WidgetbookLeafComponent'):
            components.add(name)
            if kind == 'WidgetbookLeafComponent':
                use_cases += 1
        elif kind == 'WidgetbookUseCase':
            use_cases += 1
        stack.append((end, kind, name))
    return paths, components, use_cases


def classes_with_field(field: str) -> set[str]:
    owners: set[str] = set()
    class_decl = re.compile(r'\bclass\s+(Morph\w+)(?:<[^>]+>)?\s+extends\s+\w+')
    for path in (ROOT / 'lib' / 'components').rglob('*.dart'):
        text = path.read_text(encoding='utf-8')
        if field not in text:
            continue
        decls = [(m.start(), m.group(1)) for m in class_decl.finditer(text)]
        for m in re.finditer(re.escape(field), text):
            owner = None
            for pos, name in decls:
                if pos < m.start():
                    owner = name
            if owner and not owner.startswith('_'):
                owners.add(owner)
    return owners


def main() -> None:
    problems: list[str] = []

    generator = subprocess.run(
        [sys.executable, str(ROOT / 'tool' / 'generate_preview_catalog.py'), '--check'],
        capture_output=True,
        text=True,
    )
    if generator.returncode != 0:
        problems.append((generator.stderr or generator.stdout).strip())

    for required in (CATALOG, MANIFEST, DIRECTORIES):
        if not required.is_file():
            fail([f'missing {required.relative_to(ROOT)}'])
    if (PREVIEW / 'component_gallery.dart').exists():
        problems.append('the legacy component_gallery.dart must not return; use Widgetbook use cases')

    catalog = set(re.findall(r"MorphCatalogEntry\('[^']+', '([^']+)'\)", CATALOG.read_text()))
    manifest_text = MANIFEST.read_text(encoding='utf-8')
    manifest: dict[str, list[str]] = {}
    for m in re.finditer(r"'(Morph\w+)':\s*MorphCoverage\(\s*\[([^\]]*)\]", manifest_text, re.S):
        manifest[m.group(1)] = re.findall(r"'([^']+)'", m.group(2))

    missing = sorted(catalog - manifest.keys())
    stale = sorted(manifest.keys() - catalog)
    if missing:
        problems.append('exported widgets without Widgetbook coverage: ' + ', '.join(missing))
    if stale:
        problems.append('manifest entries that are no longer exported: ' + ', '.join(stale))

    paths, components, use_case_count = widgetbook_tree(DIRECTORIES.read_text(encoding='utf-8'))
    for widget, widget_paths in sorted(manifest.items()):
        if not widget_paths:
            problems.append(f'{widget}: no Widgetbook path')
        for path in widget_paths:
            if path not in paths:
                problems.append(f'{widget}: path "{path}" is not in the generated tree')

    sources = {p: p.read_text(encoding='utf-8') for p in USE_CASES.rglob('*.dart')}
    all_use_cases = '\n'.join(sources.values())

    ctor_count = 0
    for family, library in TYPE_FAMILIES.items():
        ctors = sorted(set(re.findall(
            rf'(?:const|factory)\s+{family}\.(\w+)\(', library.read_text(encoding='utf-8'))))
        for ctor in ctors:
            ctor_count += 1
            if f'{family}.{ctor}(' not in all_use_cases:
                problems.append(f'{family}.{ctor} is not exercised by any use case')

    def files_using(widget: str) -> list[str]:
        token = re.compile(rf'\b{widget}(?:<[^>]*>)?(?:\.\w+)?\(')
        return [text for text in sources.values() if token.search(text)]

    axes = {
        'variant': (classes_with_field('final MorphVariant? variant;'), ('variantKnob', 'MorphVariant')),
        'surface': (classes_with_field('final MorphSurface surface;'), ('surfaceKnob', 'MorphSurface')),
    }
    for axis, (owners, markers) in axes.items():
        for widget in sorted(owners):
            users = files_using(widget)
            if not users:
                problems.append(f'{widget} supports `{axis}` but has no use case')
            elif not any(marker in text for text in users for marker in markers):
                problems.append(f'{widget} supports `{axis}` but no use case exposes it')

    if problems:
        fail(problems)
    print(
        f'Widgetbook: {len(catalog)}/{len(catalog)} exported widgets covered, '
        f'{len(paths)} folders, {len(components)} components, {use_case_count} use cases, '
        f'{ctor_count} named constructors, variant on {len(axes["variant"][0])} and '
        f'surface on {len(axes["surface"][0])} widgets exposed'
    )


if __name__ == '__main__':
    main()
