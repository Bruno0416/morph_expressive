#!/usr/bin/env python3
"""Reject preview GIFs made before the Morph Expressive branding change.

These hashes identify the eight previous exports whose watermark is embedded
in the animation frames. Source edits alone cannot update GIF binaries. The
new lists/dialogs GIFs are also required for the README and docs.
"""

from hashlib import sha256
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent
GIF_DIR = ROOT / "doc" / "assets" / "gifs"
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

REQUIRED_EXPORTS = set(LEGACY_EXPORTS) | {"lists.gif", "dialogs.gif"}

stale = []
missing = []
for name in sorted(REQUIRED_EXPORTS):
    path = GIF_DIR / name
    if not path.is_file():
        missing.append(name)
        continue
    old_digest = LEGACY_EXPORTS.get(name)
    if old_digest and sha256(path.read_bytes()).hexdigest() == old_digest:
        stale.append(name)

if missing or stale:
    details = []
    if stale:
        details.append("GIF exports still have the former watermark: " + ", ".join(stale))
    if missing:
        details.append("Missing GIFs: " + ", ".join(missing))
    details.append("Regenerate all ten: bash tool/generate_component_gifs.sh")
    raise SystemExit("\n".join(details))

print("GIF branding OK: required assets are present and the renamed exports are updated")
