"""Camp and study labels, plus the Forest's original thorn-thicket model."""

from itertools import product
from pathlib import Path
from random import Random
import struct
import zlib

from architecture import Build, PITCH, RADII
from floor_upgrade import edit, text, write
from forest_economy import FN, literal
from training_world import sign


def entry_ui(f):
    root = Path(f)
    for name in ("lobby/first_join", "lobby/back", "run/exit", "run/stale"):
        path = root/f"{name}.mcfunction"
        if path.exists():
            write(path,"\n".join(row for row in text(path).splitlines()
                   if not row.endswith(FN+"lobby/menu")))
    path = root/"lobby/menu.mcfunction"
    rows=text(path).splitlines()
    write(path,"\n".join(row for row in rows
          if "[甜梦研习]" not in row and "[坠梦研习]" not in row and "选择职业进入准备状态" not in row))
    path = root/"lobby/expansion/build_loaded.mcfunction"
    write(path,"\n".join(row for row in text(path).splitlines() if not (
        row.startswith("summon minecraft:text_display ") and (
        "sd.tutorial_gate_sign" in row or '"开始游戏"' in row))))
    if f"function {FN}lobby/entry_labels" not in text(path):
        edit(path, (f"function {FN}lobby/practice/dummies",
             f"function {FN}lobby/entry_labels\nfunction {FN}lobby/practice/dummies"))

    lines=[]
    for position,label,tag,color in (
        ((258,80,16),"开始游戏","sd.start_gate_sign","gold"),
        ((266.5,79.6,2.5),"坠梦研习","sd.tutorial_gate_sign","light_purple"),
    ):
        x,y,z=position
        lines.extend((
            f"execute positioned {x} {y} {z} run kill @e[type=minecraft:text_display,tag=sd.lobby_expansion,distance=..1.1]",
            f"kill @e[type=minecraft:text_display,tag={tag},distance=0..]",
            sign(position,label,"潜行或右键" if label=="开始游戏" else "潜行进入",tag,color),
        ))
    lines.append("data modify storage sweetdream_floor:training entry_labels set value 2b")
    write(root/"lobby/entry_labels.mcfunction","\n".join(lines))
    write(root/"training/tutorial_sign.mcfunction",f"function {FN}lobby/entry_labels")
    path=root/"training/portal_updates.mcfunction"
    first=text(path).splitlines()[0]
    edit(path,(first,
         f"execute if data storage sweetdream_floor:run {{lobby_expansion:1b}} "
         "unless data storage sweetdream_floor:training {entry_labels:2b} "
         f"if loaded 266 78 2 if loaded 258 78 16 run function {FN}lobby/entry_labels"))


def bake_assets():
    """Each thorn panel has a separate branching silhouette and its own cutout atlas."""
    assets={}
    for variant in range(3):
        rng=Random(2509+variant)
        def element(fr,to,**extra):
            return {"from":fr,"to":to,"faces":{
                face:{"texture":"#bark" if extra.get("bark") else "#leaf","uv":[0,0,16,16]}
                for face in ("north","south","east","west","up","down")
            },**{k:v for k,v in extra.items() if k!="bark"}}

        elements=[]
        for x in range(1,15,2):
            height=rng.randint(6,13)
            skew=rng.choice((-22.5,0,22.5))
            depth=rng.uniform(4.0,9.0)
            pos=[x,0,round(depth,2)]
            twigs={"rotation":{"origin":pos,"axis":"z","angle":skew}}
            elements.append(element(pos,[x+.46,height,round(depth+1.25,2)],bark=True,**twigs))
            for y in (height-1,height*.65,height*.34):
                width=rng.uniform(1.5,2.9)
                # Keep the block model's leaf faces thin and avoid duplicate
                # planes at the junction of adjacent stems.
                x1=round(max(.1,x-width),2)
                x2=round(min(15.9,x+width),2)
                y1=round(y,2)
                z=round(depth+rng.random(),2)
                elements.append(element([x1,y1,z],[x2,round(y+2.8,2),z+.18],**twigs))
                elements.append(element([x1,y1,z-.55],[x2,round(y+2.1,2),z-.42],
                                        rotation={"origin":pos,"axis":"z","angle":-skew}))
        name=f"bramble_{variant}"
        assets[f"assets/fallendream_dungeon/models/item/{name}.json"]=literal({
            "ambientocclusion":False,
            "textures":{"particle":"fallendream_dungeon:item/bramble_bark",
                        "leaf":f"fallendream_dungeon:item/{name}",
                        "bark":"fallendream_dungeon:item/bramble_bark"},
            "elements":elements,
        }).encode()
        assets[f"assets/fallendream_dungeon/items/{name}.json"]=literal({
            "model":{"type":"minecraft:model","model":f"fallendream_dungeon:item/{name}"}
        }).encode()
        assets[f"assets/fallendream_dungeon/textures/item/{name}.png"]=texture(variant)
    assets["assets/fallendream_dungeon/textures/item/bramble_bark.png"]=texture(9)
    return assets


def texture(variant):
    palette=((29,50,35),(40,66,42),(60,86,47),(88,105,53),(156,128,72))
    rng=Random(989+variant)
    scan=[]
    for y in range(16):
        row=bytearray((0,))
        for x in range(16):
            if variant==9:
                color=((58,37,36),(83,55,45),(106,72,53))[(x+rng.randrange(2))%3]
                row.extend((*color,255))
                continue
            stem=8+(y-7)*.53
            spread=5*(1-abs(y-7)/9)
            opaque=abs(x-stem)<spread+rng.randrange(2)
            color=palette[4 if (x+y+variant)%13==0 else (x//3+int(y<7)+rng.randrange(2))%4]
            row.extend((*color,255 if opaque else 0))
        scan.append(row)
    def chunk(kind,data):
        return struct.pack(">I",len(data))+kind+data+struct.pack(">I",zlib.crc32(kind+data))
    return (b"\x89PNG\r\n\x1a\n"+chunk(b"IHDR",struct.pack(">IIBBBBB",16,16,8,6,0,0,0))
            +chunk(b"IDAT",zlib.compress(b"".join(scan)))+chunk(b"IEND",b""))


def shrub_functions(f):
    root=Path(f)/"junction"
    for orientation,left,right in product(("east","south"),RADII,RADII):
        b=Build(relative=True)
        def point(along,y,across):
            return (along,y,across) if orientation=="east" else (across,y,along)
        for i,(plane,inward) in enumerate(((left,-1),(PITCH-right,1))):
            b.box(point(plane,1,-3),point(plane,5,3),"barrier")
            art=b.pos(*point(plane+.5,3.03,.5))
            rotation="[0f,0.707107f,0f,0.707107f]" if orientation=="east" else "[0f,0f,0f,1f]"
            item=f'fallendream_dungeon:bramble_{(left+right+i)%3}'
            b.lines.append(f'summon minecraft:item_display {art} {{Tags:["sd.shrub_art","sd.floor_junction"],'
                           f'item:{{id:"minecraft:stick",count:1,components:{{"minecraft:item_model":"{item}"}}}},'
                           'width:9f,height:6f,view_range:0.65f,brightness:{block:12,sky:10},'
                           f'transformation:{{translation:[0f,0f,0f],left_rotation:{rotation},'
                           'scale:[7.15f,5.0f,1.65f],right_rotation:[0f,0f,0f,1f]}}')
            hitbox=b.pos(*point(plane+.5+inward*.85,1,.5))
            b.lines.append(f'summon minecraft:interaction {hitbox} '
                           '{Tags:["sd.floor_junction","sd.shrub_click"],width:3.0f,height:3.2f,response:1b}')
        write(root/f"brush/{orientation}_{left}_{right}.mcfunction","\n".join(b.lines))
    unlock=root/"unlock.mcfunction"
    if "sd.shrub_art" not in text(unlock):
        edit(unlock,("kill @e[tag=sd.shrub_click,distance=0..]",
             "kill @e[tag=sd.shrub_click,distance=0..]\nkill @e[tag=sd.shrub_art,distance=0..]"))
