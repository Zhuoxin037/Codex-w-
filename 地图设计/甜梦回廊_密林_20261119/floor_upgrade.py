"""Adapt the packaged gameplay to the Forest dimension and physical grid."""
import json
import re
import struct
from collections import defaultdict
from pathlib import Path

import architecture

DIM = "sweetdream:floor_1_forest"
MAP_ID = 1900111901
NAMESPACE = Path("data/sweetdream/function")
PITCH = architecture.PITCH
RADII = architecture.RADII
ENTRY_Z = architecture.ENTRY_Z
REGION_START, REGION_END = -32, 191
VANILLA = {"minecraft:overworld", "minecraft:the_nether", "minecraft:the_end"}
IN_DIM = re.compile(r"(?<=\bin )(minecraft:(?:overworld|the_nether|the_end))(?= )")


def text(path):
    return path.read_text(encoding="utf-8")


def write(path, body):
    path.parent.mkdir(parents=True, exist_ok=True)
    path.write_text(body.rstrip() + "\n", encoding="utf-8")


def edit(path, *replacements):
    value = text(path)
    for old, new in replacements:
        if old not in value:
            raise ValueError(f"Missing source line in {path}: {old}")
        value = value.replace(old, new)
    write(path, value)


def floor_request(body):
    def physical(match):
        x, z = map(int, match.groups())
        return f'"x":{x//24*PITCH},"z":{z//24*PITCH},"mx":{x},"mz":{z}'

    return re.sub(r'"x":(\d+),"z":(\d+)', physical, body).replace('"radius":9', f'"radius":{RADII[0]}')


def grids():
    slices = [
        f"fill {x} 79 {REGION_START} {x+3} 105 {REGION_END} minecraft:air"
        for x in range(REGION_START, REGION_END+1, 4)
    ]
    canvas = "fill -16 319 -16 111 319 111 minecraft:black_terracotta"
    clear = "\n".join([*slices, canvas])
    cleanup = "\n".join(
        [f"execute if score #rv_clean_i zx.meta matches {i} run {fill}" for i, fill in enumerate(slices)]
        + ["scoreboard players add #rv_clean_i zx.meta 1",
           f"execute if score #rv_clean_i zx.meta matches {len(slices)}.. run function sweetdream:rogue/cleanup/finish"]
    )
    return clear, cleanup


def locator():
    lines = ["execute if entity @s[tag=sd.floor_run] if data storage sweetdream_floor:run encounter run return run function sweetdream_floor:combat/confine with storage sweetdream_floor:run encounter"]
    for cell in range(25):
        x,z = cell%5*PITCH,cell//5*PITCH
        for radius in RADII:
            inner = radius-2  # The player has cleared the gate's collision plane.
            lines.append(
                f"execute if data storage zx:rogue floor.cells[{{cell:{cell},present:1b,radius:{radius}}}] "
                f"positioned {x-inner} 78 {z-inner} if entity @s[dx={2*inner},dy=19,dz={2*inner}] "
                f"run scoreboard players set @s zx.rg_room {cell}"
            )
    lines.extend([
        "data modify storage zx:work rd_visit set value {}",
        "execute store result storage zx:work rd_visit.cell int 1 run scoreboard players get @s zx.rg_room",
        "function sweetdream:rogue/map/visit_pick with storage zx:work rd_visit",
    ])
    return "\n".join(lines)


def adapt_rogue(base, addon):
    root = base / NAMESPACE / "rogue"
    dest = addon / NAMESPACE / "rogue"
    targets = (
        "gen/tick", "gen/request", "gen/assign_apply", "gen/boss_apply", "gen/build_cell", "gen/corridor",
        "cleanup/tick", "cleanup/request", "cleanup/finish", "prep/begin", "prep/tick", "prototype/enter",
        "player_tick", "map/visit", "map/draw_icon", "second", "prep/repair_off", "map/repair",
    )
    samples = range(REGION_START+8, REGION_END+1, 16)
    loaded = "".join(f" if loaded {x} 80 {z}" for x in samples for z in samples)
    for name in targets:
        body = text(root / (name+".mcfunction")).replace("minecraft:overworld", DIM)
        if name == "gen/request":
            body = floor_request(body)
        if name == "gen/assign_apply":
            body = body.replace(".radius set value 10", f".radius set value {RADII[1]}")
        if name == "gen/boss_apply":
            body = body.replace(".radius set value 12", f".radius set value {RADII[2]}")
        if name in ("gen/build_cell","gen/corridor","map/visit","map/draw_icon"):
            body = body.replace("$(x) 319 $(z)", "$(mx) 319 $(mz)")
        if name == "gen/build_cell":
            body += '\n$function sweetdream_floor:room/vendor/check with storage zx:rogue floor.cells[$(cell)]'
        if name in ("prototype/enter","player_tick"):
            body = body.replace("0.5 81 48.5",f"0.5 81 {ENTRY_Z}.5")
        if name == "player_tick":
            original = f"execute unless dimension {DIM} run return run function sweetdream:rogue/map/release"
            body = body.replace(original,
                f"execute unless dimension {DIM} if data storage sweetdream_floor:run encounter "
                f"if score @s sd.floor_death matches 0 in {DIM} run return run function sweetdream_floor:room/teleport_cell with storage sweetdream_floor:run encounter\n"
                + original)
        if name == "prep/tick":
            row = "execute if score @s zx.rg_prept matches 40.. run function sweetdream:rogue/prototype/enter"
            body = body.replace(row, "execute if score @s zx.rg_prept matches 40.. run kill @e[type=minecraft:item,distance=0..]\n"+row)
        if name == "cleanup/finish":
            body = re.sub(r"^execute as @e\[type=minecraft:item,.* run kill @s$",
                          "kill @e[type=minecraft:item,distance=0..]",body,flags=re.MULTILINE)
        if name in ("gen/tick","cleanup/tick"):
            body = re.sub(r"(positioned 0 80 0)(?: if loaded -?\d+ 80 -?\d+)+", r"\1"+loaded, body)
        body = body.replace("-16 -16 144 144", f"{REGION_START} {REGION_START} {REGION_END} {REGION_END}")
        body = body.replace("1900102900",str(MAP_ID))
        write(dest / (name+".mcfunction"), body)
    clear, cleanup = grids()
    write(dest / "gen/clear.mcfunction",clear)
    write(dest / "cleanup/step.mcfunction",cleanup)
    write(dest / "map/locate.mcfunction",locator())


def include_dimension(body):
    # Extend complete vanilla-dimension sweeps. Each branch already uses a local selector.
    lines = body.splitlines()
    variants = defaultdict(list)
    for i, line in enumerate(lines):
        if line.startswith(("execute ", "$execute ")):
            match = IN_DIM.search(line)
            if match:
                pattern = line[:match.start()]+"{dim}"+line[match.end():]
                variants[pattern].append((i,match[0]))
    extended = {}
    for pattern, matches in variants.items():
        if {d for _,d in matches} == VANILLA:
            extended[matches[-1][0]] = pattern.replace("{dim}",DIM,1)
    return "\n".join(line + ("\n"+extended[i] if i in extended else "") for i,line in enumerate(lines)), len(extended)


def adapt_gameplay(base, addon):
    root = base / NAMESPACE
    dest = addon / NAMESPACE
    totals = {}
    for path in root.rglob("*.mcfunction"):
        rel = path.relative_to(root)
        if rel.parts[0] in ("debug","rogue"):
            continue
        original = text(path)
        if "in minecraft:the_end " not in original:
            continue
        body, count = include_dimension(original)
        if count:
            write(dest / rel,body)
            totals[rel.as_posix()] = count
    paths = {"core/tick":"equipment/tool/look/render", "lib/second":"equipment/tool/look/cache"}
    for path, call in paths.items():
        here = dest / (path+".mcfunction")
        if not here.exists():
            write(here,text(root / (path+".mcfunction")))
        row = f"execute as @a[tag=test_look_on] run function sweetdream:{call}"
        edit(here,(row,row+f"\nexecute as @a[tag=sd.floor_hud,tag=!test_look_on] run function sweetdream:{call}"))
    mirror = "equipment/tool/look/render_go.mcfunction"
    body = text(root / mirror)
    old = 'data modify storage zx:look xline set value [{"text":""}]'
    write(dest / mirror,body.replace(old,old+"\nexecute if entity @s[tag=sd.floor_hud] run function sweetdream_floor:run/mirror_text",1))
    return totals


def stage(world, addon):
    base = world / "datapacks/sweetdream"
    source = base / "data/sweetdream/dimension/rogue_preview.json"
    definition = json.loads(text(source))
    definition["generator"]["settings"]["biome"] = "minecraft:dark_forest"
    write(addon / "data/sweetdream/dimension/floor_1_forest.json",json.dumps(definition,indent=2))
    adapt_rogue(base,addon)
    totals = adapt_gameplay(base,addon)
    print(f"Extended {sum(totals.values())} vanilla dimension sweeps in {len(totals)} gameplay functions")


def map_dimension(nbt):
    old = b"minecraft:overworld"
    new = DIM.encode()
    source = struct.pack(">H",len(old))+old
    value = struct.pack(">H",len(new))+new
    if value in nbt:
        return nbt
    if nbt.count(source) != 1:
        raise ValueError("Unexpected floor map dimension")
    return nbt.replace(source,value,1)


def style_menus(functions):
    details = {
        "combat":"门已落下。清完怪群，门会打开。",
        "elite":"精英的奖励更稀有。清完守卫才能离开。",
        "boss":"骑士守着遗迹的尽头。",
        "forge":"右键铸匠查看两种强化石。",
        "merchant":"右键行商查看装备和补给。",
        "rental":"右键租借商查看可借装备。",
        "blackmarket":"右键黑市商人查看超限。",
    }
    for folder, group in (("room/info","密林"),("room/event","事件")):
        for path in (functions / folder).glob("*.mcfunction"):
            if folder.endswith("event") and path.stem.startswith("resolve_"):
                continue
            lines = text(path).splitlines()
            for i,line in enumerate(lines):
                prefix = "tellraw @s "
                if not line.startswith(prefix):
                    continue
                message = json.loads(line[len(prefix):])
                if not isinstance(message,dict) or not message.get("text") or message["text"].startswith("["):
                    continue
                title = [
                    {"text":"\n  ◇  ","color":"dark_green"},
                    {"text":group+"  ·  ","color":"dark_aqua"},
                    {"text":message["text"],"color":"green","bold":True},
                ]
                lines[i] = prefix + json.dumps(title,ensure_ascii=False,separators=(",",":"))
                if path.stem in details:
                    desc = "  " + details[path.stem]
                    lines.insert(i+1,prefix+json.dumps({"text":desc,"color":"gray"},ensure_ascii=False))
                break
            for i,line in enumerate(lines):
                if line.startswith("tellraw @s ") and '"click_event"' in line:
                    lines[i] = line.replace('"text":"[','"text":"    [',1).replace('"text": "[','"text": "    [',1)
            write(path,"\n".join(lines))
