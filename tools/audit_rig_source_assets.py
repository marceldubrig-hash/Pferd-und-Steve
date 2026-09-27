#!/usr/bin/env python3
"""Audit the already-approved horse cutout source assets without modifying them.

The audit opens the versioned source ZIPs on GitHub main, lists their image
contents, verifies that every confirmed cutout asset can be identified exactly
once, and pins recovered assets to their approved SHA-256 fingerprints.

It never extracts, converts, regenerates, or rewrites an image.
"""

from __future__ import annotations

import hashlib
import sys
import zipfile
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]

PACKS = (
    ROOT / "asset_packs" / "Pferd-und-Steve-source-core-v01.zip",
    ROOT / "asset_packs" / "Pferd-und-Steve-source-head-core-v01.zip",
    ROOT / "asset_packs" / "Pferd-und-Steve-source-rig-missing-v01.zip",
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

RECOVERED_SHA256 = {
    "horse_head_talk_halfopen_preview_v01.png":
        "43f186bf8032f4decc51a077ae19d0a399f6b5523cfdf815581378c6610a3051",
    "horse_head_talk_open_preview_v01.png":
        "04b188a6f78c18a6cb511711cc46849319163cd62ed8a8c982ded244df514930",
    "horse_body_v01.png":
        "5273e578ab5edf4f3345f4011182f2cf64fe8cdb326f2e93c7bceecb6a819606",
    "horse_tail_v01.png":
        "b608633b49b8cf6eb3dd612cf2482d9b482c4bfc7d8a72dbf9a4ecb1c7d58fe1",
    "horse_front_legs_segments_sheet_v01.png":
        "21003a4575973514be9f1508e828c0f90c2f0d12f3f519188b4e1b495eb96e8a",
    "horse_hind_legs_segments_sheet_v01.png":
        "d24aba84e51075cdd1e5c83d12432d2d7a1731c8c9bbb522c2db731bc04744e3",
}

IMAGE_EXTENSIONS = {".png", ".webp", ".jpg", ".jpeg"}


def main() -> int:
    all_images: list[tuple[Path, str]] = []
    failed = False

    for pack in PACKS:
        if not pack.is_file():
            print(f"FAIL source pack not found: {pack.relative_to(ROOT)}", file=sys.stderr)
            failed = True
            continue

        try:
            with zipfile.ZipFile(pack) as zf:
                bad_file = zf.testzip()
                if bad_file is not None:
                    print(
                        f"FAIL corrupt member in {pack.relative_to(ROOT)}: {bad_file}",
                        file=sys.stderr,
                    )
                    failed = True
                    continue

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

                if pack.name == "Pferd-und-Steve-source-rig-missing-v01.zip":
                    for canonical_name, expected_hash in RECOVERED_SHA256.items():
                        matches = [
                            name for name in image_names
                            if Path(name).name == canonical_name
                        ]
                        if len(matches) != 1:
                            print(
                                f"  FAIL recovered asset {canonical_name}: "
                                f"expected exactly one file, got {len(matches)}",
                                file=sys.stderr,
                            )
                            failed = True
                            continue

                        actual_hash = hashlib.sha256(zf.read(matches[0])).hexdigest()
                        if actual_hash != expected_hash:
                            print(
                                f"  FAIL recovered asset {canonical_name}: "
                                f"SHA-256 {actual_hash} != {expected_hash}",
                                file=sys.stderr,
                            )
                            failed = True
                        else:
                            print(f"  HASH OK {canonical_name}: {actual_hash}")

        except zipfile.BadZipFile:
            print(f"FAIL invalid ZIP: {pack.relative_to(ROOT)}", file=sys.stderr)
            failed = True

    print("\nCanonical rig asset check:")

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
            "\nERROR: rig source audit failed. "
            "Refusing to guess, replace, or regenerate anything.",
            file=sys.stderr,
        )
        return 5

    print("\nPASS: all confirmed rig source assets are present exactly once.")
    print("PASS: all recovered assets match their approved SHA-256 fingerprints.")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
