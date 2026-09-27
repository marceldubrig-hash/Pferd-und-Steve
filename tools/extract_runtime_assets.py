#!/usr/bin/env python3
"""Extract the already-approved canonical runtime assets from the v01 pack.

The pack currently stores the approved images as WebP. Runtime paths remain PNG,
so WebP sources are converted losslessly *from the existing approved source* to
PNG. No asset is regenerated or guessed.
"""

from __future__ import annotations

import io
import sys
import zipfile
from pathlib import Path

from PIL import Image

ROOT = Path(__file__).resolve().parents[1]
PACK = ROOT / "asset_packs" / "Pferd-und-Steve-runtime-assets-v01.zip"
ALLOWED_SOURCE_EXTENSIONS = {".png", ".webp"}

TARGETS = {
    "farm_day_v01": ROOT / "assets" / "backgrounds" / "farm_day_v01.png",
    "farm_night_v01": ROOT / "assets" / "backgrounds" / "farm_night_v01.png",
    "horse_master_standing_v01": ROOT / "assets" / "horse" / "horse_master_standing_v01.png",
}


def main() -> int:
    if not PACK.is_file():
        print(f"ERROR: runtime pack not found: {PACK.relative_to(ROOT)}", file=sys.stderr)
        return 2

    with zipfile.ZipFile(PACK) as zf:
        files = [n for n in zf.namelist() if not n.endswith("/")]
        print("Runtime ZIP contents:")
        for name in files:
            print(f"  - {name}")

        resolved: dict[str, str] = {}

        for stem in TARGETS:
            matches = [
                name for name in files
                if Path(name).stem == stem
                and Path(name).suffix.lower() in ALLOWED_SOURCE_EXTENSIONS
            ]
            if len(matches) != 1:
                print(
                    f"ERROR: expected exactly one approved source for {stem}, got {matches}",
                    file=sys.stderr,
                )
                print("No runtime assets were written. Refusing to guess.", file=sys.stderr)
                return 3
            resolved[stem] = matches[0]

        for stem, target in TARGETS.items():
            source = resolved[stem]
            target.parent.mkdir(parents=True, exist_ok=True)
            source_bytes = zf.read(source)
            source_ext = Path(source).suffix.lower()

            if source_ext == ".png":
                target.write_bytes(source_bytes)
            else:
                with Image.open(io.BytesIO(source_bytes)) as image:
                    image.save(target, format="PNG", optimize=True)

            print(f"Imported {source} -> {target.relative_to(ROOT)}")

    return 0


if __name__ == "__main__":
    raise SystemExit(main())
