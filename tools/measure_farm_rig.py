#!/usr/bin/env python3
"""Temporary Step-11 static alpha/anchor measurement; never writes assets."""
import hashlib
import json
import math
import re
from pathlib import Path

import numpy as np
from PIL import Image

ROOT = Path(__file__).resolve().parents[1]
scene = (ROOT / "scenes/horse_cutout_rig.tscn").read_text()
textures = dict((key, path) for path, key in re.findall(
    r'\[ext_resource type="Texture2D" path="res://([^"]+)" id="([^"]+)"\]', scene))
atlases = {}
for key, texture, region in re.findall(
    r'\[sub_resource type="AtlasTexture" id="([^"]+)"\]\s+atlas = ExtResource\("([^"]+)"\)\s+region = Rect2\(([^)]+)\)', scene):
    atlases[key] = (texture, [int(x) for x in region.split(",")])

matrices = {".": np.eye(3)}
results = {}
for header, body in re.findall(r'\[node ([^\]]+)\]\n(.*?)(?=\n\[node |\Z)', scene, re.S):
    attrs = dict(re.findall(r'(\w+)="([^"]*)"', header))
    if "parent" not in attrs:
        continue
    parent = attrs["parent"]
    path = attrs["name"] if parent == "." else parent + "/" + attrs["name"]
    def vec(key, default):
        m = re.search(r'^' + key + r' = Vector2\(([^)]+)\)', body, re.M)
        return [float(x) for x in m[1].split(",")] if m else default
    px, py = vec("position", [0, 0])
    sx, sy = vec("scale", [1, 1])
    rotation = re.search(r'^rotation = ([^\n]+)', body, re.M)
    angle = float(rotation[1]) if rotation else 0.0
    c, s = math.cos(angle), math.sin(angle)
    transform = matrices[parent] @ np.array([[c*sx, -s*sy, px], [s*sx, c*sy, py], [0, 0, 1]])
    matrices[path] = transform
    texture = re.search(r'texture = (ExtResource|SubResource)\("([^"]+)"\)', body)
    if not texture:
        continue
    if texture[1] == "SubResource":
        key, (x, y, w, h) = atlases[texture[2]]
        im = Image.open(ROOT / textures[key]).convert("RGBA").crop((x, y, x+w, y+h))
    else:
        im = Image.open(ROOT / textures[texture[2]]).convert("RGBA")
    # Same robust alpha threshold used by the approved segment-sheet analysis.
    ys, xs = np.where(np.asarray(im)[:, :, 3] >= 16)
    # Pixel corners, not only centres: report the full visible pixel boundary.
    pts = np.vstack((xs-im.width/2, ys-im.height/2, np.ones(len(xs))))
    corners = [transform @ (pts + np.array([[dx], [dy], [0]])) for dx,dy in ((0,0),(1,0),(0,1),(1,1))]
    low = np.min([a[:2].min(axis=1) for a in corners], axis=0)
    high = np.max([a[:2].max(axis=1) for a in corners], axis=0)
    results[path] = {"min": low.tolist(), "max": high.tolist()}

master = Image.open(ROOT / "assets/horse/horse_master_standing_v01.png")
print(json.dumps({
    "rig_scene_sha256": hashlib.sha256(scene.encode()).hexdigest(),
    "alpha_threshold": 16,
    "space": "unscaled static rig root, pixel edges",
    "sprite_bounds": results,
    "deepest_hoof_y": max(v["max"][1] for k,v in results.items() if k.endswith("/Hoof")),
    "top_y": min(v["min"][1] for v in results.values()),
    "master_size": list(master.size),
    "old_master_foot_y": master.height * 1055 / 1086,
    "old_master_offset_y": master.height/2 - master.height*1055/1086,
    "old_visible_source_height": master.height * 1039 / 1086,
    "reference_space_factor": master.height / 1086,
}, indent=2))
