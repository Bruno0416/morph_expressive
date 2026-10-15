#!/usr/bin/env python3
"""Check modification notices on known third-party-derived Morph Expressive sources.

Keep the path inventory current if upstream-derived implementation is split
or moved. This is an attribution regression check, not a legal audit.
"""
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]

APACHE_DOCUMENTED = (
    "lib/components/loading_indicator/components/morph_expressive_loading_indicator.dart",
)

COMPOSE_REFERENCED = (
    "lib/components/sliders/morph_sliders.dart",
    "lib/components/sliders/morph_range_slider.dart",
    "lib/components/sliders/res/morph_slider_tokens.dart",
    "lib/components/sliders/components/morph_slider_track_painter.dart",
    "lib/components/sliders/components/morph_slider_track.dart",
    "lib/components/sliders/components/morph_range_slider_track.dart",
    "lib/components/sliders/components/morph_slider_centered_track.dart",
    "lib/components/sliders/components/morph_slider_build.dart",
    "lib/components/sliders/components/morph_range_slider_build.dart",
    "lib/components/progress_indicators/morph_progress_indicators.dart",
    "lib/components/progress_indicators/components/morph_circular_wavy_progress_painter.dart",
    "lib/components/progress_indicators/components/morph_linear_progress_painter.dart",
    "lib/components/progress_indicators/components/morph_circular_progress_painter.dart",
    "lib/components/toolbars/morph_toolbars.dart",
    "lib/components/toolbars/res/morph_toolbar_tokens.dart",
    "lib/components/toolbars/components/morph_toolbar_fab_layout.dart",
    "lib/components/toolbars/components/morph_toolbar_build.dart",
    "lib/components/toolbars/components/morph_toolbar_actions_row.dart",
)

BSD_DOCUMENTED = (
    "lib/components/carousel/components/morph_carousel_view.dart",
)

CAROUSEL_RELATED = (
    "lib/components/carousel/components/morph_sliver_fixed_extent_carousel.dart",
    "lib/components/carousel/components/morph_sliver_weighted_carousel.dart",
    "lib/components/carousel/components/morph_sliver_weighted_carousel_layout.dart",
    "lib/components/carousel/components/morph_carousel_position.dart",
    "lib/components/carousel/components/morph_carousel_controller.dart",
    "lib/components/carousel/components/morph_carousel_scroll_physics.dart",
    "lib/components/carousel/components/morph_carousel_wrapper.dart",
    "lib/components/carousel/components/morph_carousel_wrapper_geometry.dart",
    "lib/components/carousel/components/morph_carousel_layout_resolution.dart",
)


def check() -> None:
    problems: list[str] = []
    notice_path = ROOT / "NOTICE"
    if not notice_path.is_file():
        problems.append("NOTICE: missing")
    else:
        notice = notice_path.read_text(encoding="utf-8")
        for name in (
            "Apache License", "BSD 3-Clause", "The Android Open Source Project",
            "The Flutter Authors", "Paa Developments", "Emily Moonstone",
            "Mudit Purohit",
        ):
            if name not in notice:
                problems.append(f"NOTICE: missing attribution/license {name!r}")

    checks = (
        (APACHE_DOCUMENTED, ("Apache-2.0", "Modified in 2026")),
        (COMPOSE_REFERENCED, ("Compose design/reference", "Apache-2.0", "modified")),
        (BSD_DOCUMENTED, ("BSD-3-Clause", "Modified in 2026")),
        (CAROUSEL_RELATED, ("BSD-3-Clause", "Modified in 2026", "not been fully established")),
    )
    for paths, markers in checks:
        for path in paths:
            target = ROOT / path
            if not target.is_file():
                problems.append(f"{path}: missing source file")
                continue
            header = "\n".join(target.read_text(encoding="utf-8").splitlines()[:8])
            if not all(marker in header for marker in markers):
                problems.append(f"{path}: missing origin/modification metadata: {markers}")

    if problems:
        raise SystemExit("Third-party attribution check failed:\n - " + "\n - ".join(problems))
    print(
        "Third-party notices OK: "
        f"{len(APACHE_DOCUMENTED)} documented Apache source, "
        f"{len(BSD_DOCUMENTED)} documented BSD source, "
        f"{len(COMPOSE_REFERENCED)} Compose-referenced, "
        f"{len(CAROUSEL_RELATED)} carousel-related files"
    )


if __name__ == "__main__":
    check()
