#!/usr/bin/env python3
"""Verify the animated assets used by the README and the pub.dev gallery.

* The 14 README GIFs exist, are real GIF89a files and are not one of the
  exports made before the Morph Expressive branding change (their hashes are
  kept below; the watermark is embedded in the frames).
* `pubspec.yaml` declares exactly the ten approved gallery images, in order,
  with descriptions within the pub.dev limit, existing files and a size under
  the pub.dev per-image limit.
* Every GIF referenced by README.md exists, and every one of the 14 README GIFs
  is referenced.
* Retired scene names are not referenced by current documentation.
* Each GIF matches its scene in `tool/gif_capture/capture.mjs` (width, height and
  frame interval), which detects exports made with an older pipeline or scene.
"""

import re
from hashlib import sha256
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent
GIF_DIR = ROOT / "doc" / "assets" / "gifs"

README_GIFS = [
    "async_button", "skeleton", "fab_menu", "buttons", "segmented", "tabs",
    "loading", "navigation", "dropdown", "lists", "dialogs", "chips",
    "textfields", "sliders",
]
# Kept for a guide that still explains it; not part of the README set.
GUIDE_GIFS = ["navigation_rail_drawer"]
PUBDEV_GALLERY = [
    "async_button", "skeleton", "fab_menu", "buttons", "segmented", "tabs",
    "loading", "navigation", "dropdown", "lists",
]
RETIRED = ["navigation_morph.gif"]
MAX_SCREENSHOT_BYTES = 4 * 1024 * 1024
MAX_DESCRIPTION = 160

LEGACY_EXPORTS = {
    "buttons.gif": "901967d7d691f874dc01bac932653ad3045383b9717c21db320d1929e12e85e8",
    "chips.gif": "4d15a92aa66f2cf7618617d3b2046519a23ec062d83f6e04dcebb9f200ae55dd",
    "dropdown.gif": "a38d16bb219e441258031ea54ca4d3a0bca475da844c3b4e406faa2323383327",
    "loading.gif": "27da3ae4f5d6e8b67b366ecb56cbe8c06d7c83153e2d5d400cb15ac2b0306125",
    "navigation.gif": "953af889dd6018d866f114f354aaf9191f0426ae641c59747e888e17e767b2e1",
    "segmented.gif": "73c31dcb54e2b48c039f59c38db0d57cee582999325c725307088c96ab50e97a",
    "sliders.gif": "0584c48d41afe7e5484754129a06ed1285a9fe3cb5e77a370015c157004ea08a",
    "textfields.gif": "a809a35861494aeb38de0deb506e3fe558ae8fa5a4430b6aff65e1c6cb529e41",
}

problems = []


def gif(name):
    return GIF_DIR / f"{name}.gif"


for name in README_GIFS + GUIDE_GIFS:
    path = gif(name)
    if not path.is_file():
        problems.append(f"Missing GIF: {path.name}")
        continue
    data = path.read_bytes()
    if not data.startswith(b"GIF89a"):
        problems.append(f"{path.name} is not a GIF89a file")
    old = LEGACY_EXPORTS.get(path.name)
    if old and sha256(data).hexdigest() == old:
        problems.append(f"{path.name} is still the export with the former watermark")

# pub.dev gallery.
pubspec = (ROOT / "pubspec.yaml").read_text(encoding="utf-8")
block = re.search(r"(?ms)^screenshots:\n(.*?)^\S", pubspec)
entries = re.findall(
    r"- description: (.+)\n\s+path: (doc/assets/gifs/[\w.]+)", block.group(1) if block else ""
)
declared = [Path(p).stem for _, p in entries]
if declared != PUBDEV_GALLERY:
    problems.append(f"pubspec screenshots {declared} != approved gallery {PUBDEV_GALLERY}")
for description, path in entries:
    if len(description.strip()) > MAX_DESCRIPTION:
        problems.append(f"{path}: description longer than {MAX_DESCRIPTION} characters")
    file = ROOT / path
    if not file.is_file():
        problems.append(f"{path}: declared but missing")
    elif file.stat().st_size > MAX_SCREENSHOT_BYTES:
        problems.append(f"{path}: {file.stat().st_size} bytes exceeds the pub.dev limit")

# README references.
readme = (ROOT / "README.md").read_text(encoding="utf-8")
referenced = set(re.findall(r"doc/assets/gifs/([\w.]+\.gif)", readme))
for ref in sorted(referenced):
    if not (GIF_DIR / ref).is_file():
        problems.append(f"README references a missing GIF: {ref}")
for name in README_GIFS:
    if f"{name}.gif" not in referenced:
        problems.append(f"README does not show {name}.gif")

# Relative sources follow the branch/commit being viewed, including new GIFs.
for source in re.findall(r'<img\b[^>]*\bsrc=["\']([^"\']+)["\']', readme, re.I):
    if '.gif' in source.lower() and not re.fullmatch(r'doc/assets/gifs/[\w.-]+\.gif', source):
        problems.append(f"README GIF must use a branch-relative local path: {source}")

# Retired names must not remain in current documentation.
current_docs = [ROOT / "README.md", ROOT / "pubspec.yaml"] + sorted((ROOT / "doc").glob("*.md"))
skip = {"CHANGELOG.md", "UPGRADE_0_8_0.md", "RELEASE_0_8_0.md", "RELEASE_0_7_0.md"}
for doc in current_docs:
    if doc.name in skip:
        continue
    text = doc.read_text(encoding="utf-8")
    for retired in RETIRED:
        if retired in text:
            problems.append(f"{doc.relative_to(ROOT)} still references {retired}")
for retired in RETIRED:
    if (GIF_DIR / retired).exists():
        problems.append(f"{retired} should have been retired")

# Dimensions and frame interval must match the capture settings.
capture = (ROOT / "tool" / "gif_capture" / "capture.mjs").read_text(encoding="utf-8")
for scene, body in re.findall(r"^  (\w+): \{ ([^}]*) \},?$", capture, re.M):
    values = dict(re.findall(r"(\w+): ([\w.']+)", body))
    path = GIF_DIR / f"{scene}.gif"
    if "width" not in values or not path.is_file():
        continue
    data = path.read_bytes()
    width = int.from_bytes(data[6:8], "little")
    height = int.from_bytes(data[8:10], "little")
    if (width, height) != (int(values["width"]), int(values["height"])):
        problems.append(f"{path.name} is {width}x{height}, capture settings say "
                        f"{values['width']}x{values['height']}")
    # First Graphic Control Extension: delay in centiseconds.
    marker = data.find(b"\x21\xf9\x04")
    if marker < 0:
        problems.append(f"{path.name} has no frame delay")
        continue
    delay = int.from_bytes(data[marker + 4 : marker + 6], "little")
    want = round(100 / int(values["fps"])) if "fps" in values else None
    if want and delay != want:
        problems.append(f"{path.name} has a {delay} cs frame delay, expected {want} cs "
                        f"({values['fps']} fps)")

if problems:
    raise SystemExit("\n".join(problems))
print(
    f"GIF assets OK: {len(README_GIFS)} README GIFs, "
    f"{len(PUBDEV_GALLERY)} declared pub.dev screenshots"
)
