#!/usr/bin/env python3
"""Validate the package identifier, public entrypoint, URLs, and visible branding."""

from pathlib import Path
import re

ROOT = Path(__file__).resolve().parent.parent
PACKAGE = "morph_expressive"
BRAND = "Morph Expressive"
PUBLIC = ROOT / "lib" / f"{PACKAGE}.dart"
SCAN_SUFFIXES = {".dart", ".yaml", ".yml", ".md", ".py", ".sh", ".json", ".html", ".lock"}
SCAN_DIRS = ("lib", "test", "preview", "example", "doc", "tool")
GENERATED_DIRS = {
    ".dart_tool", ".git", ".gradle", ".cxx", ".plugin_symlinks",
    "build", "DerivedData", "ephemeral", "node_modules", "Pods",
}
# Construct the superseded name from tokens to avoid introducing it in checked sources.
legacy = "morph" + "_" + "ui"
old_brand = "Morph" + " UI"
problems = []

for directory in SCAN_DIRS:
    for path in (ROOT / directory).rglob("*"):
        if not path.is_file() or path.suffix not in SCAN_SUFFIXES:
            continue
        if path.resolve() == Path(__file__).resolve() or path.name == "package-lock.json":
            continue
        if any(part in GENERATED_DIRS for part in path.parts):
            continue
        # The branding scan only needs pubspec.lock; Gradle and other native
        # build tools produce binary *.lock files that are not package text.
        if path.suffix == ".lock" and path.name != "pubspec.lock":
            continue
        try:
            content = path.read_text(encoding="utf-8")
        except UnicodeDecodeError:
            problems.append(f"non-UTF-8 text file: {path.relative_to(ROOT)}")
            continue
        if (old_brand.lower() in content.lower()
                or f"package:{legacy}/" in content
                or f"{legacy}_preview" in content
                or f"Bruno0416/{legacy}" in content
                or f"{legacy.replace('_', '-')}-gif-capture" in content):
            problems.append(f"outdated package name or branding: {path.relative_to(ROOT)}")

for path in (ROOT / "pubspec.yaml", ROOT / "README.md", ROOT / "NOTICE", ROOT / "CHANGELOG.md"):
    content = path.read_text(encoding="utf-8")
    if old_brand.lower() in content.lower() or re.search(rf"\b{legacy}\b", content):
        problems.append(f"outdated branding: {path.relative_to(ROOT)}")

if f"name: {PACKAGE}\n" not in (ROOT / "pubspec.yaml").read_text(encoding="utf-8"):
    problems.append(f"pubspec.yaml must declare {PACKAGE}")
if f"name: {PACKAGE}_preview\n" not in (ROOT / "preview/pubspec.yaml").read_text(encoding="utf-8"):
    problems.append(f"preview/pubspec.yaml must declare {PACKAGE}_preview")
if not PUBLIC.is_file():
    problems.append("primary package entrypoint missing")
if (ROOT / "lib" / f"{legacy}.dart").exists():
    problems.append("legacy public entrypoint must be removed")
if "MORPH EXPRESSIVE" not in (ROOT / "preview/lib/component_gif_capture.dart").read_text(encoding="utf-8"):
    problems.append("GIF watermark is not updated")
if "Text('Morph Expressive')" not in (ROOT / "preview/lib/main.dart").read_text(encoding="utf-8"):
    problems.append("preview app bar is not updated")

if problems:
    raise SystemExit("\n".join(problems))
print("Package identity and branding OK: Morph Expressive, imports, preview, and URLs")
