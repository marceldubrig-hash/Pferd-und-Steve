#!/usr/bin/env python3
"""Temporary Step-11D visual comparison; reads assets, never rewrites them."""
from pathlib import Path
from PIL import Image, ImageDraw
import math
import re

ROOT = Path(__file__).resolve().parents[1]
SCENE = ROOT / "scenes/horse_cutout_rig.tscn"
MAIN = ROOT / "scenes/main.tscn"
OUT = ROOT / "debug"
OUT.mkdir(exist_ok=True)

VIEW_W, VIEW_H = 1536, 1384
X_RATIO = 0.60
DEPTHS = [("FAR", 0.0), ("MID", 0.5), ("NEAR", 1.0)]
HORIZON = 0.405
FAR_FOOT = 0.565
FAR_Z = 12.0
NEAR_Z = 1.40
HORSE_H = 1.65
CAMERA_H = 1.70
VISIBLE_SOURCE_H = 768.0 * 1039.0 / 1086.0
MASTER_FOOT_Y = 768.0 * 1055.0 / 1086.0
MASTER_OFFSET_Y = 768.0 * 0.5 - MASTER_FOOT_Y

main_text = MAIN.read_text()
m = re.search(r'\[node name="RigSpace"[^\]]*\]\s+scale = Vector2\(([^,]+),\s*([^)]+)\)', main_text)
if not m:
    raise SystemExit("RigSpace scale not found")
RIG_SCALE = float(m.group(1))
m = re.search(r'\[node name="HorseCutoutRig"[^\]]*\]\s+position = Vector2\(([^,]+),\s*([^)]+)\)', main_text)
if not m:
    raise SystemExit("HorseCutoutRig anchor offset not found")
RIG_OFFSET = (float(m.group(1)), float(m.group(2)))

scene = SCENE.read_text()
ext = {}
atlas = {}
nodes = []
current_kind = None
current = None
ext_re = re.compile(r'^\[ext_resource type="[^"]+" path="([^"]+)" id="([^"]+)"\]$')
sub_re = re.compile(r'^\[sub_resource type="AtlasTexture" id="([^"]+)"\]$')
node_re = re.compile(r'^\[node name="([^"]+)" type="([^"]+)"(?: parent="([^"]+)")?\]$')
vec_re = re.compile(r'Vector2\(([-0-9.eE]+),\s*([-0-9.eE]+)\)')
rect_re = re.compile(r'Rect2\(([-0-9.eE]+),\s*([-0-9.eE]+),\s*([-0-9.eE]+),\s*([-0-9.eE]+)\)')
ext_id_re = re.compile(r'ExtResource\("([^"]+)"\)')
sub_id_re = re.compile(r'SubResource\("([^"]+)"\)')

for raw in scene.splitlines():
    line = raw.strip()
    if not line:
        continue
    m = ext_re.match(line)
    if m:
        ext[m.group(2)] = m.group(1).replace("res://", "")
        current_kind = None
        current = None
        continue
    m = sub_re.match(line)
    if m:
        current_kind = "atlas"
        current = {"id": m.group(1), "atlas_id": None, "region": None}
        atlas[current["id"]] = current
        continue
    m = node_re.match(line)
    if m:
        current_kind = "node"
        current = {
            "name": m.group(1), "type": m.group(2), "parent": m.group(3),
            "position": (0.0, 0.0), "rotation": 0.0, "scale": (1.0, 1.0),
            "z_index": 0, "texture_kind": None, "texture_id": None,
            "order": len(nodes),
        }
        nodes.append(current)
        continue
    if current_kind == "atlas":
        if line.startswith("atlas ="):
            m = ext_id_re.search(line)
            if m: current["atlas_id"] = m.group(1)
        elif line.startswith("region ="):
            m = rect_re.search(line)
            if m: current["region"] = tuple(float(m.group(i)) for i in range(1, 5))
        continue
    if current_kind == "node":
        if line.startswith("position ="):
            m = vec_re.search(line)
            if m: current["position"] = (float(m.group(1)), float(m.group(2)))
        elif line.startswith("rotation ="):
            current["rotation"] = float(line.split("=", 1)[1].strip())
        elif line.startswith("scale ="):
            m = vec_re.search(line)
            if m: current["scale"] = (float(m.group(1)), float(m.group(2)))
        elif line.startswith("z_index ="):
            current["z_index"] = int(line.split("=", 1)[1].strip())
        elif line.startswith("texture = ExtResource"):
            m = ext_id_re.search(line)
            if m:
                current["texture_kind"], current["texture_id"] = "ext", m.group(1)
        elif line.startswith("texture = SubResource"):
            m = sub_id_re.search(line)
            if m:
                current["texture_kind"], current["texture_id"] = "sub", m.group(1)

def path_of(node):
    if node["parent"] is None or node["parent"] == ".":
        return node["name"]
    return node["parent"] + "/" + node["name"]

path_map = {path_of(n): n for n in nodes}

def mul(a, b):
    return (
        a[0]*b[0]+a[1]*b[2], a[0]*b[1]+a[1]*b[3],
        a[2]*b[0]+a[3]*b[2], a[2]*b[1]+a[3]*b[3],
        a[0]*b[4]+a[1]*b[5]+a[4], a[2]*b[4]+a[3]*b[5]+a[5],
    )

def local_matrix(node):
    x,y = node["position"]
    sx,sy = node["scale"]
    c,s = math.cos(node["rotation"]), math.sin(node["rotation"])
    return (c*sx,-s*sy,s*sx,c*sy,x,y)

global_matrix = {}
global_z = {}
def resolve(node):
    path = path_of(node)
    if path in global_matrix:
        return global_matrix[path], global_z[path]
    local = local_matrix(node)
    if node["parent"] is None or node["parent"] == ".":
        gm, gz = local, node["z_index"]
    else:
        pm, pz = resolve(path_map[node["parent"]])
        gm, gz = mul(pm, local), pz + node["z_index"]
    global_matrix[path], global_z[path] = gm, gz
    return gm, gz

cache = {}
def load_ext(ext_id):
    if ext_id not in cache:
        cache[ext_id] = Image.open(ROOT / ext[ext_id]).convert("RGBA")
    return cache[ext_id]

def node_image(node):
    if node["texture_kind"] == "ext":
        return load_ext(node["texture_id"]).copy()
    if node["texture_kind"] == "sub":
        sub = atlas[node["texture_id"]]
        src = load_ext(sub["atlas_id"])
        x,y,w,h = sub["region"]
        return src.crop((round(x),round(y),round(x+w),round(y+h)))
    return None

sprites = []
for n in nodes:
    if n["type"] == "Sprite2D" and n["texture_kind"]:
        gm,gz = resolve(n)
        sprites.append((gz,n["order"],n,gm))
sprites.sort(key=lambda x:(x[0],x[1]))

bg_src = Image.open(ROOT / "assets/backgrounds/farm_day_v01.png").convert("RGBA")
master_src = Image.open(ROOT / "assets/horse/horse_master_standing_v01.png").convert("RGBA")

def background():
    scale = max(VIEW_W/bg_src.width, VIEW_H/bg_src.height)
    im = bg_src.resize((round(bg_src.width*scale), round(bg_src.height*scale)), Image.Resampling.LANCZOS)
    canvas = Image.new("RGBA",(VIEW_W,VIEW_H),(0,0,0,255))
    canvas.alpha_composite(im,(round((VIEW_W-im.width)/2),round((VIEW_H-im.height)/2)))
    return canvas

def projection(depth_t):
    z = FAR_Z + (NEAR_Z-FAR_Z)*depth_t
    gain = FAR_Z/max(z,0.01)
    foot_delta = (FAR_FOOT-HORIZON)*gain
    foot_y_ratio = HORIZON + foot_delta
    height_ratio = (HORSE_H/CAMERA_H)*max(foot_delta,0.001)
    target_h = VIEW_H*height_ratio
    visual_scale = target_h/VISIBLE_SOURCE_H
    root = (VIEW_W*X_RATIO, VIEW_H*foot_y_ratio)
    return z, root, target_h, visual_scale

def draw_master(canvas, root, visual_scale, alpha=255):
    w=max(1,round(master_src.width*visual_scale))
    h=max(1,round(master_src.height*visual_scale))
    im=master_src.resize((w,h),Image.Resampling.LANCZOS)
    if alpha != 255:
        im.putalpha(im.getchannel("A").point(lambda a: round(a*alpha/255)))
    center=(root[0], root[1]+MASTER_OFFSET_Y*visual_scale)
    canvas.alpha_composite(im,(round(center[0]-w/2),round(center[1]-h/2)))

def draw_rig(canvas, root, visual_scale, alpha=255):
    total = RIG_SCALE*visual_scale
    for _,_,node,gm in sprites:
        im=node_image(node)
        if im is None: continue
        sx=math.hypot(gm[0],gm[2])*total
        sy=math.hypot(gm[1],gm[3])*total
        rot=math.atan2(gm[2],gm[0])
        w=max(1,round(im.width*sx)); h=max(1,round(im.height*sy))
        im=im.resize((w,h),Image.Resampling.LANCZOS)
        if abs(rot)>1e-10:
            im=im.rotate(-math.degrees(rot),resample=Image.Resampling.BICUBIC,expand=True)
        if alpha != 255:
            im.putalpha(im.getchannel("A").point(lambda a: round(a*alpha/255)))
        cx=root[0]+(gm[4]+RIG_OFFSET[0])*total
        cy=root[1]+(gm[5]+RIG_OFFSET[1])*total
        canvas.alpha_composite(im,(round(cx-im.width/2),round(cy-im.height/2)))

thumb=(512,461)
sheet=Image.new("RGB",(thumb[0]*3,thumb[1]*3),(20,20,20))
draw=ImageDraw.Draw(sheet)
report=[
    f"viewport={VIEW_W}x{VIEW_H}",
    f"x_ratio={X_RATIO}",
    f"rig_scale={RIG_SCALE:.9f}",
    f"rig_offset={RIG_OFFSET}",
    f"old_visible_source_height={VISIBLE_SOURCE_H:.9f}",
]
for row,(label,t) in enumerate(DEPTHS):
    z,root,target_h,vs=projection(t)
    master=background(); draw_master(master,root,vs)
    rig=background(); draw_rig(rig,root,vs)
    overlay=background(); draw_master(overlay,root,vs,105); draw_rig(overlay,root,vs,180)
    panels=[("MASTER",master),("CUTOUT",rig),("OVERLAY",overlay)]
    for col,(pname,panel) in enumerate(panels):
        p=panel.convert("RGB").resize(thumb,Image.Resampling.LANCZOS)
        x,y=col*thumb[0],row*thumb[1]
        sheet.paste(p,(x,y))
        draw.rectangle((x,y,x+235,y+30),fill=(0,0,0))
        draw.text((x+8,y+8),f"{label} {pname}",fill="white")
    report.append(
        f"{label}: depth_t={t:.3f} z={z:.3f} root=({root[0]:.3f},{root[1]:.3f}) "
        f"target_height={target_h:.6f} horse_root_scale={vs:.9f}"
    )

sheet.save(OUT/"farm_cutout_scale_preview.jpg",quality=88,optimize=True)
(OUT/"farm_cutout_scale_preview.txt").write_text("\n".join(report)+"\n")
print("\n".join(report))
