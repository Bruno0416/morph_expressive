#!/usr/bin/env python3
"""Verify the animated assets used by the README and the pub.dev gallery.

* Every GIF in `doc/assets/gifs/` is a known scene (no strays), is a real
  GIF89a file and is not one of the exports made before the Morph Expressive
  branding change (their hashes are kept below; the watermark is embedded in
  the frames).
* README images use ONLY absolute `raw.githubusercontent.com` URLs on the
  `main` branch of the repository (`doc/assets/gifs/<name>.gif` and
  `doc/assets/banner.png`): no relative paths, no query strings, no `blob`
  links and no SVG sources for the repository's own assets (third-party badges
  on other hosts are not checked). The files must also exist locally, so a README
  edit cannot point at an asset that was never created. The README may show a
  curated subset of the scenes; every GIF it shows must be an allowed one.
* README GIFs weigh at most 1.5 MiB each and 8 MiB in total.
* `pubspec.yaml` declares at most ten gallery images, each an existing allowed
  GIF under 4 MiB (the pub.dev limit) with a description of at most 160
  characters.
* Retired scene names are not referenced by current documentation.
* Each GIF matches its scene in `tool/gif_capture/capture.mjs` (width, height and
  frame interval), which detects exports made with an older pipeline or scene.

Absolute URLs 404 (or show the previous content) until the files are pushed to
`main`; the guard therefore validates the local file behind every URL.
"""

import re
from hashlib import sha256
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent
GIF_DIR = ROOT / "doc" / "assets" / "gifs"

RAW_BASE = "https://raw.githubusercontent.com/Bruno0416/morph_expressive/main/"
GIF_URL = re.compile(re.escape(RAW_BASE) + r"doc/assets/gifs/([a-z0-9_]+)\.gif")
BANNER_URL = RAW_BASE + "doc/assets/banner.png"

# Scenes the documentation may use (README and pub.dev gallery).
ALLOWED_GIFS = [
    "buttons", "variants", "async_button", "frosted", "density", "context_menu",
    "tabs", "navigation", "chips", "dropdown", "lists", "dialogs", "textfields",
    "sliders", "segmented", "loading", "skeleton", "fab_menu",
]
# Kept for a guide that still explains it; not part of the README set.
GUIDE_GIFS = ["navigation_rail_drawer"]
MIN_README_GIFS = 6
RETIRED = ["navigation_morph.gif"]
MAX_SCREENSHOT_BYTES = 4 * 1024 * 1024
MAX_README_GIF_BYTES = 1536 * 1024
MAX_README_TOTAL_BYTES = 8 * 1024 * 1024
MAX_SCREENSHOTS = 10
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


known = set(ALLOWED_GIFS) | set(GUIDE_GIFS)

# Every scene the docs may use exists and is a current export; nothing stray.
for name in ALLOWED_GIFS + GUIDE_GIFS:
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
if GIF_DIR.is_dir():
    for path in sorted(GIF_DIR.glob("*.gif")):
        if path.stem not in known:
            problems.append(f"{path.name} is not a known scene (add it to ALLOWED_GIFS)")

# pub.dev gallery.
pubspec = (ROOT / "pubspec.yaml").read_text(encoding="utf-8")
block = re.search(r"(?ms)^screenshots:\n(.*?)^\S", pubspec)
entries = re.findall(
    r"- description: (.+)\n\s+path: (doc/assets/gifs/[\w.]+)", block.group(1) if block else ""
)
declared = [Path(p).stem for _, p in entries]
if len(entries) > MAX_SCREENSHOTS:
    problems.append(f"pubspec declares {len(entries)} screenshots; pub.dev allows {MAX_SCREENSHOTS}")
if len(set(declared)) != len(declared):
    problems.append(f"pubspec screenshots repeat an image: {declared}")
for description, path in entries:
    stem = Path(path).stem
    if stem not in ALLOWED_GIFS:
        problems.append(f"{path}: not an allowed gallery scene")
    if len(description.strip().strip("'\"")) > MAX_DESCRIPTION:
        problems.append(f"{path}: description longer than {MAX_DESCRIPTION} characters")
    file = ROOT / path
    if not file.is_file():
        problems.append(f"{path}: declared but missing")
    elif file.stat().st_size > MAX_SCREENSHOT_BYTES:
        problems.append(f"{path}: {file.stat().st_size} bytes exceeds the pub.dev limit")

# README references: absolute raw URLs only, each backed by a local file.
readme = (ROOT / "README.md").read_text(encoding="utf-8")
sources = re.findall(r'<img\b[^>]*?\bsrc=["\']([^"\']+)["\']', readme, re.I)
sources += re.findall(r'<source\b[^>]*?\bsrcset=["\']([^"\'\s]+)', readme, re.I)
sources += re.findall(r"!\[[^\]]*\]\(\s*<?([^)\s>]+)", readme)
shown = []
for source in sources:
    gif_match = GIF_URL.fullmatch(source)
    if gif_match:
        shown.append(gif_match.group(1))
    elif source == BANNER_URL:
        if not (ROOT / "doc" / "assets" / "banner.png").is_file():
            problems.append("README banner is referenced but doc/assets/banner.png is missing")
    elif not re.match(r"https?://", source, re.I) or "doc/assets" in source:
        problems.append(
            f"README image must be an absolute URL under {RAW_BASE}doc/assets/ "
            f"(gif scenes or banner.png), never a relative path: {source}"
        )
# Local assets must not be reached through any other spelling either.
for ref in re.findall(r"(?<![\w/])doc/assets/gifs/[\w.-]+", readme):
    problems.append(f"README references {ref} without the raw.githubusercontent.com base")
for name in shown:
    if name not in ALLOWED_GIFS:
        problems.append(f"README shows {name}.gif, which is not an allowed scene")
    elif not gif(name).is_file():
        problems.append(f"README references a missing GIF: {name}.gif")
unique = sorted(set(shown))
if len(unique) < MIN_README_GIFS:
    problems.append(f"README shows {len(unique)} GIFs; expected at least {MIN_README_GIFS}")
total = 0
for name in unique:
    if gif(name).is_file():
        size = gif(name).stat().st_size
        total += size
        if size > MAX_README_GIF_BYTES:
            problems.append(f"{name}.gif is {size} bytes; README GIFs stay under {MAX_README_GIF_BYTES}")
if total > MAX_README_TOTAL_BYTES:
    problems.append(f"README GIFs weigh {total} bytes in total; limit is {MAX_README_TOTAL_BYTES}")

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
    f"GIF assets OK: {len(ALLOWED_GIFS)} scenes, {len(unique)} shown in the README "
    f"({total // 1024} KiB), {len(entries)} declared pub.dev screenshots"
)
