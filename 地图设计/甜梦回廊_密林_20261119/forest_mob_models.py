"""Export the approved Forest mob models and bind them to the existing mobs."""

import base64
from collections import defaultdict
from hashlib import sha256
import json
from pathlib import Path
import sys

from floor_upgrade import text, write


ROOT = Path(__file__).resolve().parents[2]
ART = ROOT / "模型设计/密林小怪_其余八种静态_20261124"
BASE = ART / "阶段三_基础待机与移动/模型"
BRANCH = ART / "阶段九_空枝全身薄木壳/模型/空枝_全身薄木壳_基础动作.bbmodel"
N = "sweetdream_floor:mob_visual/"
ASSETS = "assets/fallendream_boss"
ITEMS = "fallendream_boss:forest_mob"
STORAGE = "sweetdream_floor:mob_visual"
MOBS = (
    ("cover", "覆苔尸", .95), ("rooted", "扎根人", 1.78),
    ("resin", "树脂人", 1.78), ("root", "树根", .98),
    ("moss", "苔藓", 1.04), ("crown", "断冠猎手", 1.88),
    ("moth", "挂灯蛾", .63), ("bark_guard", "抱壳", 1.64),
    ("branch", "空枝", 1.30),
)
RIG = "type=minecraft:item_display,tag=sd.skin.rig"
PART = "type=minecraft:item_display,tag=sd.skin.part"
DIMS = ("sweetdream:floor_1_forest", "sweetdream:floor_2_trial")
OBJECTIVES = ("id", "kind", "part", "frame", "timer", "yaw", "move", "last")


def build():
    """Return runtime functions and assets, derived from saved geometry and poses."""
    import numpy as np

    lib = str(ROOT / ".workbuddy")
    if lib not in sys.path:
        sys.path.insert(0, lib)
    from b_staff_cast_refit_20261120 import Scene, matrices, sample
    from b_staff_runtime_assets_20261121 import quaternion, snbt

    assets, functions, report = {}, {}, {}
    convert = np.diag([-1., 1., -1.])
    load = [f"data modify storage {STORAGE} frames set value {{}}"]

    def js(path, document):
        assets[f"{ASSETS}/{path}"] = json.dumps(document, separators=(",", ":")).encode()

    js("items/forest_mob/empty.json", {"model":{"type":"minecraft:empty"}})
    for kind_id,(kind,name,height) in enumerate(MOBS,1):
        source = BRANCH if kind == "branch" else BASE/name/f"{name}_基础动作.bbmodel"
        raw = source.read_bytes()
        model = json.loads(raw)
        scene = Scene(model)
        bind = matrices(scene,{})
        groups = {g["name"]:g for g in model["groups"]}
        cubes = defaultdict(list)
        for cube in model["elements"]:
            cubes[scene.element_bone[cube["uuid"]]].append(cube)
        atlas = {}
        for i,tex in enumerate(model["textures"]):
            image = base64.b64decode(tex["source"].split(",",1)[1])
            digest = sha256(image).hexdigest()[:20]
            atlas[i] = f"fallendream_boss:item/forest_mob/{digest}"
            assets[f"{ASSETS}/textures/item/forest_mob/{digest}.png"] = image
        tex_ids = {tex["uuid"]:i for i,tex in enumerate(model["textures"])}
        poses = {
            "move" if anim["name"] in ("walk_loop","fly_loop") else "idle":
                [matrices(scene,sample(anim,t/20)) for t in range(0,round(anim["length"]*20),2)]
            for anim in model["animations"]
        }
        poses.setdefault("move",poses["idle"])
        all_poses = [bind,*poses["idle"],*poses["move"]]
        world_points = np.concatenate([scene.corners[e["uuid"]] @ bind[b][:3,:3].T+bind[b][:3,3]
                                      for b,elements in cubes.items() for e in elements])
        scale = height / ((world_points[:,1].max()-world_points[:,1].min())/16)
        # Scope coalescing to bones whose relative pose is identical at every
        # sampled frame and whose axes align. Keep the removable shell separate.
        buckets = {}
        separate = {"bark_shield","lantern_abdomen"}
        for bone,elements in cubes.items():
            for lead,parts in buckets.items():
                relative = np.linalg.inv(bind[lead]) @ bind[bone]
                if bone in separate or lead in separate or not np.allclose(relative[:3,:3],np.eye(3),atol=1e-7):
                    continue
                if all(np.allclose(frame[lead] @ relative,frame[bone],atol=2e-6) for frame in all_poses):
                    parts.append((bone,elements,relative[:3,3]))
                    break
            else:
                buckets[bone] = [(bone,elements,np.zeros(3))]

        def transform(matrix, center, fit):
            linear = convert @ matrix[:3,:3]
            axis_scales = np.linalg.norm(linear,axis=0)
            assert min(axis_scales)>0
            return {
                "translation":np.round(convert @ (matrix[:3,3]+matrix[:3,:3] @ center)*scale/16,7).tolist(),
                "scale":np.round(axis_scales*scale/fit,7).tolist(),
                "left_rotation":quaternion(linear/axis_scales),
                "right_rotation":[0.,0.,0.,1.],
            }

        frames = {clip:[{} for _ in keys] for clip,keys in poses.items()}
        spawns = []
        vertex_error = 0.
        for index,(lead,parts) in enumerate(buckets.items()):
            entries = [(cube,translation-np.array(groups[bone]["origin"]),bone)
                       for bone,bones,translation in parts for cube in bones]
            lo = np.min([np.array(e["from"])+off for e,off,_ in entries],axis=0)
            hi = np.max([np.array(e["to"])+off for e,off,_ in entries],axis=0)
            center = (lo+hi)/2
            fit = min(1.,46/max(hi-lo))
            geometry = []
            for cube,offset,bone in entries:
                def coordinate(value):
                    return np.round((np.array(value)+offset-center)*fit+8,7).tolist()
                item = {"from":coordinate(cube["from"]),"to":coordinate(cube["to"]),"faces":{}}
                assert all(-16 <= v <= 32 for key in ("from","to") for v in item[key])
                axes = [(i,a) for i,a in enumerate(cube["rotation"]) if abs(a)>1e-8]
                assert len(axes)<=1 and all(abs(a) in (22.5,45) for _,a in axes)
                if axes:
                    axis,angle = axes[0]
                    item["rotation"] = {"axis":"xyz"[axis],"angle":angle,"origin":coordinate(cube["origin"]),"rescale":False}
                for side,face in cube["faces"].items():
                    ref = face.get("texture")
                    if ref is None:
                        continue
                    ref = ref if isinstance(ref,int) else tex_ids[ref]
                    tex = model["textures"][ref]
                    uv_width = tex.get("uv_width",model["resolution"]["width"])
                    uv_height = tex.get("uv_height",model["resolution"]["height"])
                    uv = [round(float(v)*16/(uv_height if i%2 else uv_width),7) for i,v in enumerate(face["uv"])]
                    assert all(0 <= v <= 16 for v in uv)
                    item["faces"][side] = {"texture":f"#{ref}","uv":uv}
                    if face.get("rotation"):
                        item["faces"][side]["rotation"] = face["rotation"]
                # Check the relative rebasing of every rotated cube's corners.
                points = scene.corners[cube["uuid"]]
                original = points @ bind[bone][:3,:3].T + bind[bone][:3,3]
                rebased = (points+offset+np.array(groups[bone]["origin"])) @ bind[lead][:3,:3].T + bind[lead][:3,3]
                vertex_error = max(vertex_error,float(abs(original-rebased).max()))
                geometry.append(item)
            assert vertex_error < 2e-6
            doc = {"textures":{**atlas,"particle":atlas[0]},"elements":geometry}
            key = sha256(json.dumps(doc,sort_keys=False).encode()).hexdigest()[:18]
            path = f"forest_mob/{kind}/{key}"
            js(f"models/{path}.json",doc)
            js(f"items/{path}.json",{"model":{"type":"minecraft:model","model":f"fallendream_boss:{path}"}})
            changes = lead=="bark_shield" or any(not np.allclose(bind[lead],frame[lead],atol=2e-6) for frame in all_poses)
            nbt = {
                "Tags":["sd.skin.part",*["sd.skin.animated"]*changes,*["sd.skin.shield"]*(lead=="bark_shield")],
                "item_display":"none","billboard":"fixed","view_range":.85,
                "width":3.2,"height":3.,"interpolation_duration":2,"teleport_duration":1,
                "item":{"id":"minecraft:stick","count":1,"components":{"minecraft:item_model":f"fallendream_boss:{path}"}},
                "transformation":transform(bind[lead],center,fit),
            }
            if kind=="moth" and lead=="lantern_abdomen":
                nbt["brightness"]={"block":15,"sky":12}
            spawns.append(f"$execute summon minecraft:item_display run function {N}spawn_part {{id:$(id),part:{index},nbt:{snbt(nbt)}}}")
            if changes:
                for clip,keys in poses.items():
                    for frame,pose in zip(frames[clip],keys):
                        frame[f"p{index}"] = transform(pose[lead],center,fit)
        functions[f"spawn/{kind}"] = "\n".join(spawns)
        for clip,keys in frames.items():
            load.append(f"data modify storage {STORAGE} frames.{kind}.{clip} set value []")
            load.extend(f"data modify storage {STORAGE} frames.{kind}.{clip} append value {snbt(frame)}" for frame in keys)
        # Distinct lengths avoid jumping back early on the faster walk loops.
        functions[f"pose/{kind}"] = "\n".join((
            f"execute if score @s sd.skin.move matches 0 run scoreboard players set #clip_len sd.skin.id {len(frames['idle'])}",
            f"execute if score @s sd.skin.move matches 1 run scoreboard players set #clip_len sd.skin.id {len(frames['move'])}",
            "scoreboard players operation @s sd.skin.frame %= #clip_len sd.skin.id",
            f"execute store result storage {STORAGE} work.frame int 1 run scoreboard players get @s sd.skin.frame",
            f"execute if score @s sd.skin.move matches 0 run data modify storage {STORAGE} work.clip set value \"idle\"",
            f"execute if score @s sd.skin.move matches 1 run data modify storage {STORAGE} work.clip set value \"move\"",
            f"data modify storage {STORAGE} work.kind set value \"{kind}\"",
            f"function {N}frame with storage {STORAGE} work",
        ))
        report[kind] = {"source":str(source),"sha256":sha256(raw).hexdigest(),"cubes":len(model["elements"]),
                        "parts":len(buckets),"height":height,"vertex_error":vertex_error,
                        "stored_frames":{k:len(v) for k,v in frames.items()}}
    functions["frames"] = "\n".join(load)
    return functions,assets,report


def stage(world, resource_root=None):
    root = Path(world)/"datapacks/zz_sweetdream_floor/data/sweetdream_floor/function"
    funcs,assets,report = build()
    for name,body in funcs.items():
        write(root/f"mob_visual/{name}.mcfunction",body)

    def mc(name,*rows):
        write(root/f"mob_visual/{name}.mcfunction","\n".join(rows))

    def edit(name,old,new):
        p = root/f"{name}.mcfunction"
        body = text(p)
        if new in body:
            return
        if body.count(old)!=1:
            raise ValueError(f"Expected one {old!r} in {p}")
        write(p,body.replace(old,new,1))

    def add(name,line):
        p = root/f"{name}.mcfunction"
        if line not in text(p):
            write(p,text(p)+line)

    mc("load",*(f"scoreboard objectives add sd.skin.{key} dummy" for key in OBJECTIVES),
       f"function {N}frames")
    add("load",f"function {N}load")
    combat = "execute if score #phase sd.floor matches 2 as @a[tag=sd.floor_run,tag=zx.rg_active,scores={sd.floor_death=0},limit=1] at @s run function sweetdream_floor:combat/tick"
    edit("tick",combat,combat+"\n"+ "\n".join(
             f"execute in {dim} if entity @a[distance=0..] run function {N}tick" for dim in DIMS))
    for name,dim in zip(("forest","trial"),DIMS):
        add(f"combat/clean_{name}",f"execute in {dim} run function {N}clear")
    mc("clear","kill @e[tag=sd.skin.part,distance=0..]","kill @e[tag=sd.skin.rig,distance=0..]")
    mc("tick",
       f"execute if score #phase sd.floor matches 2 as @e[tag=sd.floor_enemy,tag=!sd.skin.bound,tag=!sd.stag.body,tag=!sd.kn.body,distance=0..,nbt=!{{Health:0.0f}}] at @s run function {N}try_bind",
       f"execute as @e[tag=sd.skin.bound,distance=0..] at @s run function {N}owner",
       f"execute as @e[{RIG},distance=0..] at @s run function {N}check_rig")
    mc("try_bind",*(f'execute if entity @s[tag=sd.mob.{kind}] run return run function {N}bind {{kind:"{kind}",number:{i}}}'
                    for i,(kind,_,_) in enumerate(MOBS,1)))
    mc("bind","scoreboard players add #serial sd.skin.id 1",
       "scoreboard players operation @s sd.skin.id = #serial sd.skin.id",
       "$scoreboard players set @s sd.skin.kind $(number)",
       "scoreboard players set @s sd.skin.frame -1",
       "scoreboard players set @s sd.skin.timer 0",
       "scoreboard players set @s sd.skin.last -1",
       "scoreboard players set @s sd.skin.yaw 99999",
       f'data modify storage {STORAGE} work set value {{}}',
       f'execute store result storage {STORAGE} work.id int 1 run scoreboard players get @s sd.skin.id',
       f'$data modify storage {STORAGE} work.kind set value "$(kind)"',
       f"execute summon minecraft:item_display run function {N}spawn_rig with storage {STORAGE} work",
       "tag @s add sd.skin.bound",
       "effect give @s minecraft:invisibility infinite 0 true",
       f"function {N}hide_gear")
    mc("spawn_rig","tag @s add sd.skin.rig",
       "$scoreboard players set @s sd.skin.id $(id)",
       'data merge entity @s {width:3.2f,height:3f,teleport_duration:1,view_range:0.85f}',
       f"$function {N}spawn/$(kind) {{id:$(id)}}")
    mc("spawn_part","$data merge entity @s $(nbt)",
       "$scoreboard players set @s sd.skin.part $(part)",
       f"$ride @s mount @e[{RIG},scores={{sd.skin.id=$(id)}},distance=..0.3,limit=1]")
    mc("hide_gear",
       *(f'execute if data entity @s equipment.{slot} run data modify entity @s equipment.{slot}.components."minecraft:item_model" set value "{ITEMS}/empty"'
         for slot in ("head","mainhand","offhand")),
       *(f'execute if items entity @s armor.{slot} minecraft:leather_{item} run data modify entity @s equipment.{slot}.components."minecraft:equippable" set value {{slot:"{slot}",equip_sound:"minecraft:item.armor.equip_leather"}}'
         for slot,item in (("chest","chestplate"),("legs","leggings"),("feet","boots"))))
    mc("owner",
       f"execute store result storage {STORAGE} work.id int 1 run scoreboard players get @s sd.skin.id",
       f"execute if data entity @s {{Health:0.0f}} run return run function {N}death with storage {STORAGE} work",
       f"execute if data entity @s {{HurtTime:10s}} run particle minecraft:damage_indicator ~ ~.72 ~ .16 .12 .16 .045 2 normal",
       f"execute unless data entity @s active_effects[{{id:\"minecraft:invisibility\"}}] run effect give @s minecraft:invisibility infinite 0 true",
       f"function {N}follow with storage {STORAGE} work")
    mc("follow",
       f"$execute unless entity @e[{RIG},scores={{sd.skin.id=$(id)}},distance=0..] run return run tag @s remove sd.skin.bound",
       "scoreboard players set @s sd.skin.move 0",
       f"$execute if entity @e[{RIG},scores={{sd.skin.id=$(id)}},distance=.055..] run scoreboard players set @s sd.skin.move 1",
       f"$execute unless entity @e[{RIG},scores={{sd.skin.id=$(id)}},distance=..0.001] run tp @e[{RIG},scores={{sd.skin.id=$(id)}},distance=0..,limit=1] ~ ~ ~",
       "scoreboard players add @s sd.skin.timer 1",
       f"execute store result score #yaw sd.skin.id run data get entity @s Rotation[0] 4",
       f"$execute unless score #yaw sd.skin.id = @s sd.skin.yaw run function {N}turn {{id:$(id)}}",
       f"execute if score @s sd.skin.timer matches 2.. run function {N}animate")
    mc("turn",
       f"data modify storage {STORAGE} work.rotation set from entity @s Rotation",
       f"data modify storage {STORAGE} work.rotation[1] set value 0f",
       f"$execute as @e[{RIG},scores={{sd.skin.id=$(id)}},distance=0..,limit=1] on passengers run data modify entity @s Rotation set from storage {STORAGE} work.rotation",
       "scoreboard players operation @s sd.skin.yaw = #yaw sd.skin.id")
    mc("animate","scoreboard players set @s sd.skin.timer 0",
       "scoreboard players add @s sd.skin.frame 1",
       "execute unless score @s sd.skin.move = @s sd.skin.last run scoreboard players set @s sd.skin.frame 0",
       "scoreboard players operation @s sd.skin.last = @s sd.skin.move",
       "scoreboard players set #shield sd.skin.id 0",
       "execute if items entity @s weapon.offhand minecraft:shield run scoreboard players set #shield sd.skin.id 1",
       *(f"execute if score @s sd.skin.kind matches {i} run return run function {N}pose/{kind}"
         for i,(kind,_,_) in enumerate(MOBS,1)))
    mc("frame",
       f"$data modify storage {STORAGE} current set from storage {STORAGE} frames.$(kind).$(clip)[$(frame)]",
       f"$execute as @e[{RIG},scores={{sd.skin.id=$(id)}},distance=0..,limit=1] on passengers if entity @s[tag=sd.skin.animated] run function {N}part")
    mc("part",
       f"execute store result storage {STORAGE} work.part int 1 run scoreboard players get @s sd.skin.part",
       f"function {N}part_apply with storage {STORAGE} work")
    mc("part_apply",
       f"$data modify storage {STORAGE} work.transform set from storage {STORAGE} current.p$(part)",
       f"execute if entity @s[tag=sd.skin.shield] if score #shield sd.skin.id matches 0 run data modify storage {STORAGE} work.transform.scale set value [0f,0f,0f]",
       f"function {N}merge_frame with storage {STORAGE} work")
    mc("merge_frame", "$data merge entity @s {start_interpolation:0,transformation:$(transform)}")
    mc("death",
       "tag @s remove sd.skin.bound",
       f"$execute as @e[{RIG},scores={{sd.skin.id=$(id)}},distance=0..] at @s run function {N}burst")
    mc("check_rig",
       f"execute store result storage {STORAGE} work.id int 1 run scoreboard players get @s sd.skin.id",
       f"function {N}orphan with storage {STORAGE} work")
    mc("orphan",f"$execute unless entity @e[tag=sd.skin.bound,scores={{sd.skin.id=$(id)}},distance=0..] run function {N}burst")
    mc("burst","particle minecraft:block{block_state:{Name:\"minecraft:dark_oak_wood\"}} ~ ~.58 ~ .28 .38 .28 .06 13 normal",
       f"function {N}discard")
    mc("discard","execute on passengers run kill @s","kill @s")
    # Preserve resin timing and the ground telegraph. The live chest is
    # already in the saved model, so only the pending drop needs to be shown.
    add("combat/mobs/shell_follow",
        'execute if entity @s[tag=sd.skin.bound] run data merge entity @e[tag=sd.mob.shell_active,distance=0..,limit=1] {view_range:0f}')
    edit("combat/mobs/shell_tick","data merge entity @s {brightness:{block:15,sky:10}}",
         "data merge entity @s {brightness:{block:15,sky:10},view_range:1f}")
    shield = 'minecraft:shield[minecraft:base_color="brown",minecraft:death_protection={death_effects:[]}]'
    for name in ("hold","block"):
        edit(f"combat/mobs/bark_guard/{name}",shield,
             shield[:-1]+f',minecraft:item_model="{ITEMS}/empty"]')
    if resource_root is not None:
        for name,raw in assets.items():
            path = Path(resource_root)/name
            path.parent.mkdir(parents=True,exist_ok=True)
            if not path.is_file() or path.read_bytes()!=raw:
                path.write_bytes(raw)
    return assets,report
