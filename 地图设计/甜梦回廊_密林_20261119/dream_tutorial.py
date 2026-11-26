"""Move the existing live tutorial to its own dimension."""

import json
from pathlib import Path
import re

from floor_upgrade import edit, text, write
from forest_economy import FN, RUN

DIM = "sweetdream:tutorial"
NS = FN+"tutorial/"
AREA = "-128 16 -17 79"
ARRIVAL = "-101.5 90 48.5 -90 0"
LEGACY_BOX = "x=-120,y=82,z=16,dx=96,dy=35,dz=63"


def stage(world):
    root=Path(world)/"datapacks/zz_sweetdream_floor/data"
    dim=root/"sweetdream/dimension"
    floor=root/"sweetdream_floor/function"

    def mc(name,*rows):
        write(floor/f"{name}.mcfunction","\n".join(rows))

    definition=json.loads(text(dim/"training.json"))
    write(dim/"tutorial.json",json.dumps(definition,indent=2))
    layout=floor/"lobby/structure.mcfunction"
    old=text(layout)
    geometry,rules=old.split("setworldspawn ",1)
    write(layout,geometry.replace("甜 梦 回 廊","坠梦"))
    mc("lobby/build","setworldspawn "+rules.rstrip(),f"data modify storage {RUN} lobby set value 1b")
    mc("lobby/build_loaded",f"execute in minecraft:overworld run function {FN}lobby/build")

    tags={"sd.floor_lobby_display","sd.floor_dummy"}
    for file in (floor/"tutorial").rglob("*.mcfunction"):
        body=text(file)
        for group in re.findall(r'Tags:\[([^\]]+)\]',body):
            tags.update(tag for tag in re.findall(r'"([^"]+)"',group)
                        if tag.startswith(("sd.edu","sd.floor_dummy","sd.tutorial")))
        if " in minecraft:overworld " in body:
            write(file,body.replace(" in minecraft:overworld ",f" in {DIM} "))
    file=floor/"tutorial/enter.mcfunction"
    guard=f"execute unless data storage {RUN} {{tutorial_ready:1b}} run return 0"
    write(file,guard+"\n"+text(file))
    # Old saves may already have visitors at the previous Overworld coordinates.
    edit(floor/"lobby/player_tick.mcfunction",("execute unless dimension minecraft:overworld run return",
         f"execute if entity @s[tag=sd.floor_tutorial] run return 0\n"
         "execute unless dimension minecraft:overworld run return"))
    file=floor/"tick.mcfunction"
    line=f"execute if entity @a[tag=sd.floor_tutorial] run return run function {NS}stage/tick"
    edit(file,(line, f"execute if data storage {RUN} {{tutorial_ready:1b}} "
         f"as @a[tag=sd.floor_tutorial] at @s unless dimension {DIM} in {DIM} run tp @s {ARRIVAL}\n"+line))
    file=floor/"load.mcfunction"
    write(file,text(file)+f"\nschedule function {NS}dimension/request 1s replace")
    mc("tutorial/dimension/request",
       f"execute if data storage {RUN} {{tutorial_ready:1b}} run return 0",
       f"execute in minecraft:overworld run forceload add {AREA}",
       f"execute in {DIM} run forceload add {AREA}",
       f"schedule function {NS}dimension/build 1s replace")
    mc("tutorial/dimension/build",
       f"execute if data storage {RUN} {{tutorial_ready:1b}} run return 0",
       *(f"execute in {dimension} unless loaded {x} 90 {z} run return run schedule function {NS}dimension/build 1s replace"
         for dimension in ("minecraft:overworld",DIM) for x in range(-128,-16,16) for z in (16,32,48,64)),
       f"execute in {DIM} run function {FN}lobby/structure",
       f"data remove storage {RUN} demonstration",
       f"data remove storage {RUN} tutorial_chunks",
       "scoreboard players set #edu_live sd.floor 0",
       f"execute in {DIM} positioned -99 90 48 run function {NS}stage/build",
       f"data modify storage {RUN} tutorial_ready set value 1b",
       f"execute as @a[tag=sd.floor_tutorial] in {DIM} run tp @s {ARRIVAL}",
       f"execute in minecraft:overworld run function {NS}dimension/clear_old",
       f"execute in minecraft:overworld run forceload remove {AREA}",
       f"execute in {DIM} run forceload remove {AREA}")
    mc("tutorial/dimension/clear_old",
       *(f"kill @e[tag={tag},{LEGACY_BOX}]" for tag in sorted(tags)),
       *(f"fill {x} 82 16 {min(x+7,-24)} 117 79 minecraft:air" for x in range(-120,-23,8)))
