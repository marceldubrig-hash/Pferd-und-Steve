#!/usr/bin/env python3
"""Audit the already-approved horse cutout source assets without modifying them.

This script opens the versioned source ZIPs on GitHub main, lists their image
contents, and verifies that every confirmed cutout asset can be identified
exactly once by its canonical stem. It never extracts, converts, regenerates,
or rewrites an image.
"""

from __future__ import annotations

import sys
import zipfile
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]

PACKS = (
    ROOT / "asset_packs" / "Pferd-und-Steve-source-core-v01.zip",
    ROOT / "asset_packs" / "Pferd-und-Steve-source-head-core-v01.zip",
)

EXPECTED_STEMS = (
    "horse_head_upper_v01",
    "horse_jaw_v01",
    "horse_head_talk_halfopen_preview_v01",
    "horse_head_talk_open_preview_v01",
    "horse_body_v01",
    "horse_tail_v01",
    "horse_front_legs_segments_sheet_v01",
    "horse_hind_legs_segments_sheet_v01",
)

IMAGE_EXTENSIONS = {".png", ".webp", ".jpg", ".jpeg"}


def main() -> int:
    all_images: list[tuple[Path, str]] = []

    for pack in PACKS:
        if not pack.is_file():
            print(f"ERROR: source pack not found: {pack.relative_to(ROOT)}", file=sys.stderr)
            return 2

        try:
            with zipfile.ZipFile(pack) as zf:
                bad_file = zf.testzip()
                if bad_file is not None:
                    print(
                        f"ERROR: corrupt member in {pack.relative_to(ROOT)}: {bad_file}",
                        file=sys.stderr,
                    )
                    return 3

                image_names = [
                    name
                    for name in zf.namelist()
                    if not name.endswith("/")
                    and Path(name).suffix.lower() in IMAGE_EXTENSIONS
                ]

                print(f"{pack.relative_to(ROOT)}")
                if not image_names:
                    print("  (no supported image files)")
                for name in image_names:
                    print(f"  - {name}")
                    all_images.append((pack, name))
        except zipfile.BadZipFile:
            print(f"ERROR: invalid ZIP: {pack.relative_to(ROOT)}", file=sys.stderr)
            return 4

    print("\nCanonical rig asset check:")

    failed = False
    for stem in EXPECTED_STEMS:
        matches = [
            (pack, name)
            for pack, name in all_images
            if Path(name).stem == stem
        ]

        if len(matches) != 1:
            failed = True
            print(f"  FAIL {stem}: expected exactly one match, got {len(matches)}")
            for pack, name in matches:
                print(f"       {pack.relative_to(ROOT)} :: {name}")
            continue

        pack, name = matches[0]
        print(f"  OK   {stem}: {pack.relative_to(ROOT)} :: {name}")

    if failed:
        print(
            "\nERROR: confirmed rig source assets are not uniquely identifiable. "
            "Refusing to guess or regenerate anything.",
            file=sys.stderr,
        )
        return 5

    print("\nPASS: all confirmed rig source assets are present exactly once.")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
