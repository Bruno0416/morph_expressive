#!/usr/bin/env python3
"""Keep dependency barrel exports from silently expanding Morph's namespaces."""

from pathlib import Path
import re
import sys

ROOT = Path(__file__).resolve().parent.parent
SOURCE_DIRS = ("lib", "test", "example", "preview/lib", "preview/test")
PROTECTED = ("package:material_ui/", "package:material_new_shapes/")
GEOMETRY = {
    "CornerRounding",
    "Matrix4PointTransformer",
    "Morph",
    "MorphToPathExtension",
    "RoundedPolygon",
    "RoundedPolygonToPathExtension",
    "pathFromCubics",
}


def tokens(source):
    """Read directives without treating comments or string contents as code."""
    index = 0
    while index < len(source):
        if source[index].isspace():
            index += 1
        elif source.startswith("//", index):
            end = source.find("\n", index)
            index = len(source) if end < 0 else end + 1
        elif source.startswith("/*", index):
            depth = 1
            index += 2
            while index < len(source) and depth:
                if source.startswith("/*", index):
                    depth += 1
                    index += 2
                elif source.startswith("*/", index):
                    depth -= 1
                    index += 2
                else:
                    index += 1
        else:
            start = index
            raw = source[index] == "r" and source[index + 1:index + 2] in ("'", '"')
            if raw:
                index += 1
            if source[index] in ("'", '"'):
                quote = source[index]
                delimiter = quote * (3 if source.startswith(quote * 3, index) else 1)
                index += len(delimiter)
                while index < len(source) and not source.startswith(delimiter, index):
                    index += 2 if not raw and source[index] == "\\" else 1
                index += len(delimiter)
            else:
                match = re.match(r"[A-Za-z_$][\w$]*", source[index:])
                index += len(match[0]) if match else 1
            yield source[start:index], start


def directive_issues(source):
    stream = iter(tokens(source))
    issues = []
    for token, offset in stream:
        if token not in ("import", "export"):
            continue
        directive = []
        for item, _ in stream:
            if item == ";":
                break
            directive.append(item)
        uris = [item.strip("r'\"") for item in directive if item[:1] in ("'", '"', "r")]
        protected = [uri for uri in uris if uri.startswith(PROTECTED)]
        if not protected:
            continue
        line = source.count("\n", 0, offset) + 1
        if any("/src/" in uri for uri in protected):
            issues.append((line, "use the dependency's public entrypoint, not /src/"))
        if "show" not in directive:
            issues.append((line, "dependency imports/exports require an explicit show list (hide/as alone is insufficient)"))
            continue
        shown = set(directive[directive.index("show") + 1:]) - {","}
        if any(uri.startswith("package:material_ui/") for uri in protected):
            if "as" not in directive and shown & GEOMETRY:
                issues.append((line, "Material UI geometry needs a prefix; Morph's public geometry comes from material_new_shapes"))
    return issues


def check(root=ROOT):
    files = sorted({path for directory in SOURCE_DIRS for path in (root / directory).rglob("*.dart")})
    issues = [
        f"{path.relative_to(root)}:{line}: {message}"
        for path in files
        for line, message in directive_issues(path.read_text(encoding="utf-8"))
    ]
    if issues:
        print("\n".join(issues), file=sys.stderr)
        return 1
    print(f"Dependency namespaces OK: {len(files)} Dart files; explicit Material UI/shape imports")
    return 0


if __name__ == "__main__":
    raise SystemExit(check())
