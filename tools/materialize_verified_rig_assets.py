#!/usr/bin/env python3
"""Materialize the already-approved horse rig source assets without re-encoding.

The source ZIPs on GitHub main are the authority. This script copies the exact
member bytes into assets/horse/rig/ and refuses to overwrite a different file.
Recovered assets are additionally verified against their pinned SHA-256 hashes.
"""

from __future__ import annotations

import hashlib
import sys
import zipfile
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
DEST = ROOT / "assets" / "horse" / "rig"

HEAD_PACK = ROOT / "asset_packs" / "Pferd-und-Steve-source-head-core-v01.zip"
RECOVERY_PACK = ROOT / "asset_packs" / "Pferd-und-Steve-source-rig-missing-v01.zip"

HEAD_ASSETS = (
    "horse_head_upper_v01.png",
    "horse_jaw_v01.png",
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


def exact_member(zf: zipfile.ZipFile, basename: str) -> str:
    matches = [
        name for name in zf.namelist()
        if not name.endswith("/") and Path(name).name == basename
    ]
    if len(matches) != 1:
        raise RuntimeError(
            f"{basename}: expected exactly one source member, got {len(matches)}"
        )
    return matches[0]


def write_exact(name: str, data: bytes) -> None:
    target = DEST / name
    if target.exists():
        current = target.read_bytes()
        if current != data:
            raise RuntimeError(
                f"refusing to overwrite different existing runtime asset: {target}"
            )
        print(f"UNCHANGED {target.relative_to(ROOT)}")
        return

    target.parent.mkdir(parents=True, exist_ok=True)
    target.write_bytes(data)
    print(
        f"WROTE {target.relative_to(ROOT)} "
        f"({len(data)} bytes, sha256={hashlib.sha256(data).hexdigest()})"
    )


def main() -> int:
    for pack in (HEAD_PACK, RECOVERY_PACK):
        if not pack.is_file():
            print(f"FAIL missing source pack: {pack.relative_to(ROOT)}", file=sys.stderr)
            return 2

    try:
        with zipfile.ZipFile(HEAD_PACK) as zf:
            bad = zf.testzip()
            if bad is not None:
                raise RuntimeError(f"corrupt member in {HEAD_PACK.name}: {bad}")

            for name in HEAD_ASSETS:
                member = exact_member(zf, name)
                write_exact(name, zf.read(member))

        with zipfile.ZipFile(RECOVERY_PACK) as zf:
            bad = zf.testzip()
            if bad is not None:
                raise RuntimeError(f"corrupt member in {RECOVERY_PACK.name}: {bad}")

            for name, expected_hash in RECOVERED_SHA256.items():
                member = exact_member(zf, name)
                data = zf.read(member)
                actual_hash = hashlib.sha256(data).hexdigest()
                if actual_hash != expected_hash:
                    raise RuntimeError(
                        f"{name}: sha256 {actual_hash} != pinned {expected_hash}"
                    )
                write_exact(name, data)

    except (zipfile.BadZipFile, RuntimeError) as exc:
        print(f"FAIL {exc}", file=sys.stderr)
        return 3

    print("PASS exact approved rig assets materialized without re-encoding.")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
