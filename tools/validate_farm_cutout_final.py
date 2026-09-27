#!/usr/bin/env python3
from pathlib import Path
import hashlib
import re
import sys

ROOT = Path(__file__).resolve().parents[1]
RIG = ROOT / "scenes/horse_cutout_rig.tscn"
MAIN = ROOT / "scenes/main.tscn"
SCRIPT = ROOT / "scripts/main.gd"
OUT = ROOT / "debug/farm_cutout_final_validation.txt"
EXPECTED_RIG_SHA256 = "328edf3d34090b08f4e729c690f04c36ad3f69f4d9d6813145bf73f9315cf96e"

lines = []

def check(condition, message):
    if not condition:
        lines.append("FAIL: " + message)
        OUT.parent.mkdir(exist_ok=True)
        OUT.write_text("\n".join(lines) + "\n")
        raise SystemExit(message)
    lines.append("PASS: " + message)

rig_bytes = RIG.read_bytes()
rig_text = rig_bytes.decode()
main_text = MAIN.read_text()
script_text = SCRIPT.read_text()
rig_sha = hashlib.sha256(rig_bytes).hexdigest()
check(rig_sha == EXPECTED_RIG_SHA256, f"horse_cutout_rig.tscn SHA-256 unchanged ({rig_sha})")

def block(resource_id):
    marker = f'[sub_resource type="Animation" id="{resource_id}"]'
    start = rig_text.find(marker)
    check(start >= 0, f"{resource_id} exists")
    next_pos = rig_text.find("\n[sub_resource", start + len(marker))
    if next_pos < 0:
        next_pos = rig_text.find("\n[node ", start + len(marker))
    return rig_text[start: next_pos if next_pos >= 0 else len(rig_text)]

walk = block("Animation_walk_test")
walk_reset = block("Animation_walk_reset")
jaw = block("Animation_jaw_test")
jaw_reset = block("Animation_jaw_reset")
tail = block("Animation_tail_test")
tail_reset = block("Animation_tail_reset")

check(len(re.findall(r"tracks/\d+/type =", walk)) == 15, "walk_test has exactly 15 tracks")
check(len(re.findall(r"tracks/\d+/type =", walk_reset)) == 15, "walk RESET has exactly 15 tracks")
check('length = 1.2' in walk and 'loop_mode = 1' in walk, "walk length/loop unchanged")
check('PackedFloat32Array(0, 0.28, 0.58, 0.88, 1.2)' in walk, "FrontNear walk times unchanged")
check('"values": [0.0, 0.10472, 0.0, -0.0872665, 0.0]' in walk, "FrontNear root values unchanged")
check('Vector2(-76.5412, -104.756)' in walk and 'Vector2(321.171, -197.253)' in walk and 'Vector2(-449, -201)' in walk, "torso bob values unchanged")
check('length = 0.6' in jaw and 'loop_mode = 1' in jaw, "jaw/head animation length/loop unchanged")
check('PackedFloat32Array(0, 0.15, 0.3, 0.42, 0.6)' in jaw, "jaw times unchanged")
check('"values": [-0.331613, -0.15708, -0.331613, -0.226893, -0.331613]' in jaw, "jaw values unchanged")
check('PackedFloat32Array(0, 0.18, 0.38, 0.6)' in jaw, "head times unchanged")
check('"values": [-0.00592869, -0.05828857, 0.04643119, -0.00592869]' in jaw, "head values unchanged")
check('length = 1.1' in tail and 'loop_mode = 1' in tail, "tail length/loop unchanged")
check('"values": [0.0, 0.0872665, -0.0698132, 0.0349066, 0.0]' in tail, "tail values unchanged")
check('"values": [-0.331613]' in jaw_reset and '"values": [-0.00592869]' in jaw_reset, "jaw/head RESET unchanged")
check('"values": [0.0]' in tail_reset, "tail RESET unchanged")

check('[node name="AnimationPlayer" type="AnimationPlayer" parent="."]' in rig_text and 'autoplay = "jaw_test"' in rig_text, "jaw AnimationPlayer/autoplay present")
check('[node name="TailAnimationPlayer" type="AnimationPlayer" parent="."]' in rig_text and 'autoplay = "tail_test"' in rig_text, "tail AnimationPlayer/autoplay present")
check('[node name="WalkAnimationPlayer" type="AnimationPlayer" parent="."]' in rig_text and 'autoplay = "walk_test"' in rig_text, "walk AnimationPlayer/autoplay present")

check('HorseMaster' not in main_text, "legacy HorseMaster absent from main scene")
check('[node name="HorseVisual" type="Node2D" parent="HorseRoot"]' in main_text, "HorseVisual outer container present")
check('scale = Vector2(0.701686, 0.701686)' in main_text, "RigSpace integration scale present")
check('position = Vector2(0, -516.7995)' in main_text, "rig ground-anchor offset present")
check('HORSE_VISIBLE_SOURCE_HEIGHT_PX' in script_text, "frozen old visible-height calibration present")
check('horse_visual.scale = Vector2(1.0 if facing_right else -1.0, 1.0)' in script_text, "whole-rig direction flip present")
check('horse_root.scale = Vector2.ONE * visual_scale' in script_text, "existing perspective scale path preserved")
check('horse_root.z_index = int(round(horse_depth_t * 100.0))' in script_text, "existing world-z path preserved")
check('func _minimum_depth_t_for_x' in script_text and 'func _unhandled_input' in script_text, "obstacle and input code paths remain present")
check('horse_master' not in script_text, "no legacy Sprite2D runtime reference remains")

lines.append(f"RIG_SHA256={rig_sha}")
lines.append("STATIC_RESULT: SUCCESS")
OUT.parent.mkdir(exist_ok=True)
OUT.write_text("\n".join(lines) + "\n")
print("\n".join(lines))
