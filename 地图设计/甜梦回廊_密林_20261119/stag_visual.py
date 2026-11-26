"""Export the saved stag poses to reusable Java item-display meshes."""

from collections import defaultdict
from functools import lru_cache
from hashlib import sha256
import json
from math import pi, sin
from pathlib import Path
import sys
from uuid import NAMESPACE_URL, uuid5

from floor_upgrade import write

ROOT = Path(__file__).resolve().parents[2]
ART = ROOT / "模型设计/密林层主_朽冠鹿_概念_20261123"
NAMESPACE = "sweetdream_floor:stag/"
SOURCE = ART / "阶段四_横扫追根与落脂"
FORMS = ("一阶段", "二阶段")
CLIPS = {"crown_sweep": 1, "root_call": 2, "resin_cast": 3, "crown_slam": 4, "charged_rush": 5}


def uuid_for(phase, index):
    return uuid5(NAMESPACE_URL, f"fallendream/forest/stag/{phase}/{index}")


def uuid_array(uid):
    return "[I;" + ",".join(str(int.from_bytes(uid.bytes[i:i+4], "big", signed=True)) for i in range(0, 16, 4)) + "]"


@lru_cache(maxsize=1)
def build():
    import base64
    import numpy as np

    lib = str(ROOT / ".workbuddy")
    if lib not in sys.path:
        sys.path.insert(0, lib)
    from b_staff_cast_refit_20261120 import Scene, matrices, sample
    from b_staff_runtime_assets_20261121 import quaternion, snbt
    from animate_forest_stag_rush_20261123 import Author

    funcs, assets, report = {}, {}, []
    atlas = "fallendream_boss:item/forest_stag/atlas"
    convert = np.diag([-1., 1., -1.])

    def out(name, rows):
        funcs[name] = "\n".join(rows)

    def js(name, value):
        assets[name] = json.dumps(value, ensure_ascii=False, separators=(",", ":")).encode("utf-8")

    def transform(matrix, center, fit):
        linear = convert @ matrix[:3,:3]
        scale = np.linalg.norm(linear, axis=0)
        return {
            "translation": np.round(convert @ (matrix[:3,3] + matrix[:3,:3] @ center) / 16, 6).tolist(),
            "scale": np.round(scale / fit, 6).tolist(),
            "left_rotation": quaternion(linear / np.maximum(scale, 1e-12)),
            "right_rotation": [0., 0., 0., 1.],
        }

    for phase, form in enumerate(FORMS, 1):
        source = SOURCE / f"朽冠鹿_{form}_五招累计动画.bbmodel"
        raw = source.read_bytes()
        model = json.loads(raw)
        scene = Scene(model)
        groups = {g["name"]: g for g in model["groups"]}
        bucket = defaultdict(list)
        for element in model["elements"]:
            bucket[scene.element_bone[element["uuid"]]].append(element)
        texture = model["textures"][0]
        texture_path = "assets/fallendream_boss/textures/item/forest_stag/atlas.png"
        pixels = base64.b64decode(texture["source"].split(",", 1)[1])
        assert pixels == assets.setdefault(texture_path, pixels)
        bind = matrices(scene, {})
        author = Author(model, phase)
        meshes, spawns = [], []
        for i, (bone, elements) in enumerate(bucket.items()):
            origin = np.array(groups[bone]["origin"])
            lo = np.min([e["from"] for e in elements], axis=0) - origin
            hi = np.max([e["to"] for e in elements], axis=0) - origin
            center = (lo+hi)/2
            fit = min(1., 46/max(hi-lo))

            def coord(value):
                return np.round((np.array(value)-origin-center)*fit+8, 7).tolist()

            parts = []
            for cube in elements:
                hits = [(i,a) for i,a in enumerate(cube["rotation"]) if abs(a)>1e-8]
                assert len(hits) <= 1 and all(abs(a) in (22.5,45) for _,a in hits)
                item = {"from":coord(cube["from"]), "to":coord(cube["to"]), "faces":{}}
                assert all(-16 <= v <= 32 for k in ("from","to") for v in item[k])
                if hits:
                    axis, angle = hits[0]
                    item["rotation"] = {"axis":"xyz"[axis],"angle":angle,"origin":coord(cube["origin"]),"rescale":False}
                for side, face in cube["faces"].items():
                    uv = [round(float(x)*16/512, 7) for x in face["uv"]]
                    assert all(0<=v<=16 for v in uv)
                    item["faces"][side] = {"texture":"#atlas", "uv":uv}
                    if face.get("rotation"):
                        item["faces"][side]["rotation"] = face["rotation"]
                parts.append(item)
            mesh = {"textures":{"atlas":atlas,"particle":atlas},"elements":parts}
            model_id = sha256(json.dumps(mesh,sort_keys=True).encode()).hexdigest()[:20]
            js(f"assets/fallendream_boss/models/entity/forest_stag/{model_id}.json", mesh)
            js(f"assets/fallendream_boss/items/forest_stag/{model_id}.json", {
                "model":{"type":"minecraft:model","model":f"fallendream_boss:entity/forest_stag/{model_id}"}})
            uid = uuid_for(phase,i)
            nbt = snbt({
                "Tags":["sd.stag.part",f"sd.stag.form{phase}"], "item_display":"none", "billboard":"fixed",
                "view_range":1.2,"width":10.,"height":6.,"brightness":{"block":12,"sky":12},
                "teleport_duration":1,"interpolation_duration":2,
                "item":{"id":"minecraft:stick","count":1,"components":{"minecraft:item_model":f"fallendream_boss:forest_stag/{model_id}"}},
                "transformation":transform(bind[bone],center,fit),
            })
            spawns.append(f"summon minecraft:item_display ~ ~ ~ {{UUID:{uuid_array(uid)},"+nbt[1:])
            meshes.append((uid,bone,center,fit))
        out(f"visual/{phase}/spawn", spawns)

        def frame_clip(clip, phases, body):
            dispatch, previous = [], {}
            for tick in phases:
                world = body(tick)
                rows = []
                for uid, bone, center, fit in meshes:
                    data = transform(world[bone],center,fit)
                    if data != previous.get(uid):
                        rows.append(f"data merge entity {uid} "+snbt({"start_interpolation":0,"transformation":data}))
                    previous[uid] = data
                if rows:
                    out(f"visual/{phase}/{clip}/{tick}",rows)
                    dispatch.append(f"execute if score @s sd.stag.frame matches {tick} run function {NAMESPACE}visual/{phase}/{clip}/{tick}")
            out(f"visual/{phase}/{clip}/select",dispatch)

        for anim in model["animations"]:
            name = anim["name"].removesuffix("_phase2")
            if name not in CLIPS:
                continue

            def authored(tick):
                pose = matrices(scene,sample(anim,tick/20))
                if name == "charged_rush":
                    delta = pose["stag_root"][:3,3]-bind["stag_root"][:3,3]
                    for m in pose.values():
                        m[:3,3] -= delta
                return pose

            length = round(anim["length"]*20)
            frame_clip(name, sorted({*range(0,length+1,2),length}), authored)

        def idle(tick):
            bob = .7*sin(tick/60*2*pi)
            return matrices(scene,{"head":{"rotation":[bob,0,0]}})

        def walk(tick):
            feet = {}
            for leg, pos in author.feet.items():
                a = 2*pi*tick/24 + (0 if leg in ("fore_left","hind_right") else pi)
                feet[leg] = pos + np.array([0.,max(0.,sin(a))*2.2,2.6*np.cos(a)])
            posture = author.base_values()+np.array([-1.6,0,0,0])
            return matrices(scene,author.kinematic(posture,feet,0.,0.))

        def fall(tick):
            t = min(1.,tick/28)
            pose = matrices(scene,{"head":{"rotation":[-12*t,0,0]}})
            for m in pose.values():
                s = 1.-.75*t*t
                m[:3,3] *= s
                m[:3,:3] *= s
            return pose

        frame_clip("idle", range(0,60,4), idle)
        frame_clip("walk", range(0,24,2), walk)
        frame_clip("death", range(0,29,2), fall)
        clips = {**CLIPS,"idle":0,"walk":6,"death":8}
        out(f"visual/{phase}/select", [f"execute if score @s sd.stag.clip matches {num} run function {NAMESPACE}visual/{phase}/{name}/select"
                                               for name,num in clips.items()])
        report.append({"form":phase,"cubes":len(model["elements"]),"displays":len(meshes),"source_sha256":sha256(raw).hexdigest()})
    return funcs,assets,report


def stage(functions, resource_root=None):
    funcs, assets, report = build()
    for key, body in funcs.items():
        write(functions/f"stag/{key}.mcfunction", body)
    if resource_root is not None:
        for rel, raw in assets.items():
            path = resource_root / rel
            path.parent.mkdir(parents=True,exist_ok=True)
            if not path.exists() or path.read_bytes()!=raw:
                path.write_bytes(raw)
    return report
