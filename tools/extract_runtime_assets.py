#!/usr/bin/env python3
"""Extract only the already-approved canonical runtime PNGs from the v01 asset pack.

This script deliberately refuses to guess. If the ZIP does not contain the exact
canonical basenames, it exits without writing substitute assets.
"""

from __future__ import annotations

import shutil
import sys
import zipfile
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
PACK = ROOT / "asset_packs" / "Pferd-und-Steve-runtime-assets-v01.zip"

TARGETS = {
    "farm_day_v01.png": ROOT / "assets" / "backgrounds" / "farm_day_v01.png",
    "farm_night_v01.png": ROOT / "assets" / "backgrounds" / "farm_night_v01.png",
    "horse_master_standing_v01.png": ROOT / "assets" / "horse" / "horse_master_standing_v01.png",
}


def main() -> int:
    if not PACK.is_file():
        print(f"ERROR: runtime pack not found: {PACK.relative_to(ROOT)}", file=sys.stderr)
        return 2

    with zipfile.ZipFile(PACK) as zf:
        files = [n for n in zf.namelist() if not n.endswith("/")]
        by_basename: dict[str, list[str]] = {}
        for name in files:
            by_basename.setdefault(Path(name).name, []).append(name)

        print("Runtime ZIP contents:")
        for name in files:
            print(f"  - {name}")

        missing: list[str] = []
        ambiguous: list[tuple[str, list[str]]] = []

        for basename in TARGETS:
            matches = by_basename.get(basename, [])
            if not matches:
                missing.append(basename)
            elif len(matches) > 1:
                ambiguous.append((basename, matches))

        if missing or ambiguous:
            if missing:
                print("\nERROR: exact canonical basenames missing:", file=sys.stderr)
                for name in missing:
                    print(f"  - {name}", file=sys.stderr)
            if ambiguous:
                print("\nERROR: canonical basename appears more than once:", file=sys.stderr)
                for basename, matches in ambiguous:
                    print(f"  - {basename}: {matches}", file=sys.stderr)
            print("\nNo runtime assets were written. Refusing to guess.", file=sys.stderr)
            return 3

        for basename, target in TARGETS.items():
            source = by_basename[basename][0]
            target.parent.mkdir(parents=True, exist_ok=True)
            with zf.open(source) as src, target.open("wb") as dst:
                shutil.copyfileobj(src, dst)
            print(f"Extracted {source} -> {target.relative_to(ROOT)}")

    return 0


if __name__ == "__main__":
    raise SystemExit(main())
