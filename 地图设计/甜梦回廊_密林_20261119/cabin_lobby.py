"""Compile the approved cabin and connect the lobby's physical entrances."""

from pathlib import Path
import runpy

from architecture import write

HERE = Path(__file__).resolve().parent
CANDIDATE = HERE / "林间隐屋_细节候选" / "build.py"
OFFSET = 256
SPAWN = (252.5, 76, 20.5)
SPAWN_ANGLE = -165
CAMP = (257.5, 78, 15.5)
TUTORIAL = (266.5, 78, 2.5)
PAD = "minecraft:waxed_oxidized_cut_copper"
CAMP_BOX = "x=257,y=78,z=15,dx=1,dy=1,dz=1"
TUTORIAL_BOX = "x=265,y=78,z=1,dx=1,dy=1,dz=1"
LOBBY_BOX = "x=208,y=69,z=-48,dx=95,dy=64,dz=111"
CHUNKS = "208 -48 303 63"
READY = "sweetdream_floor:lobby/cabin/ready"
STORAGE = "sweetdream_floor:run"


def placed(command):
    kind, *fields = command.split(" ", 1)
    if kind == "fill":
        a, y, z, b, vy, vz, material = fields[0].split()
        return f"fill {int(a)+OFFSET} {y} {z} {int(b)+OFFSET} {vy} {vz} {material}"
    if kind == "setblock":
        x, y, z, material = fields[0].split()
        return f"setblock {int(x)+OFFSET} {y} {z} {material}"
    if kind == "summon":
        entity, x, y, z, data = fields[0].split(" ", 4)
        if entity == "minecraft:block_display":
            return f"summon {entity} {float(x)+OFFSET:g} {y} {z} {data}"
    raise ValueError(f"Unexpected cabin command: {command[:100]}")


def rewrite(path, old, new):
    body = path.read_text(encoding="utf-8")
    if body.count(old) != 1:
        raise ValueError(f"Unexpected baseline for {path}: {old}")
    path.write_text(body.replace(old, new), encoding="utf-8")


def tutorial_chunks(addon):
    functions = addon / "data/sweetdream_floor/function"
    spectators = "@a[tag=sd.floor_tutorial]"
    state = f"data storage {STORAGE} {{tutorial_chunks:1b}}"
    bounds = "-112 32 -81 63"
    write(functions/"tutorial/stage/hold_chunks.mcfunction", [
        f"execute in minecraft:overworld run forceload add {bounds}",
        f"data modify storage {STORAGE} tutorial_chunks set value 1b",
    ])
    write(functions/"tutorial/stage/release_chunks.mcfunction", [
        "execute in minecraft:overworld positioned -99 90 48 run function sweetdream_floor:tutorial/stage/sleep",
        f"execute in minecraft:overworld run forceload remove {bounds}",
        f"data remove storage {STORAGE} tutorial_chunks",
    ])
    stage = f"execute if entity {spectators} run return run function sweetdream_floor:tutorial/stage/tick"
    rewrite(functions/"tick.mcfunction", stage, "\n".join([
        f"execute if entity {spectators} unless {state} run function sweetdream_floor:tutorial/stage/hold_chunks",
        f"execute unless entity {spectators} if {state} run function sweetdream_floor:tutorial/stage/release_chunks",
        stage,
    ]))


def stage(addon):
    functions = addon / "data/sweetdream_floor/function"
    cabin = functions / "lobby/cabin"
    source = runpy.run_path(str(CANDIDATE))
    scene = list(map(placed, source["build"]()))
    build_parts = []
    for i, start in enumerate(range(0, len(scene), 3500)):
        write(cabin / f"blocks_{i:02}.mcfunction", scene[start:start+3500])
        build_parts.append(f"function sweetdream_floor:lobby/cabin/blocks_{i:02}")
    write(cabin / "build.mcfunction", [
        f"forceload add {CHUNKS}",
        f"schedule function {READY} 1s replace",
    ])
    write(cabin / "ready.mcfunction", [f"execute in minecraft:overworld run function {READY}_loaded"])
    write(cabin / "ready_loaded.mcfunction", [
        f"execute unless loaded {x} 78 {z} run return run schedule function {READY} 1s replace"
        for x in range(208,304,16) for z in range(-48,64,16)
    ] + [
        f"execute if data storage {STORAGE} {{cabin_layout:1b}} run return 0",
        f"kill @e[tag=sd.floor_lobby_display,{LOBBY_BOX}]",
        *build_parts,
        f"kill @e[type=minecraft:item,{LOBBY_BOX}]",
        f"setworldspawn {int(SPAWN[0])} {SPAWN[1]} {int(SPAWN[2])} {SPAWN_ANGLE}",
        f"data modify storage {STORAGE} cabin_layout set value 1b",
        f"forceload remove {CHUNKS}",
    ])
    write(cabin / "return.mcfunction", [
        "tag @s remove sd.floor_pad",
        f"execute in minecraft:overworld run spawnpoint @s {int(SPAWN[0])} {SPAWN[1]} {int(SPAWN[2])} {SPAWN_ANGLE}",
        f"execute in minecraft:overworld run tp @s {' '.join(map(str,SPAWN))} {SPAWN_ANGLE} 0",
    ])
    old_load = f"execute in minecraft:overworld unless data storage {STORAGE} {{lobby:1b}} run function sweetdream_floor:lobby/build"
    rewrite(functions/"load.mcfunction", old_load, old_load +
            f"\nexecute in minecraft:overworld unless data storage {STORAGE} {{cabin_layout:1b}} run function sweetdream_floor:lobby/cabin/build")
    rewrite(functions/"tick.mcfunction", f"unless data storage {STORAGE} {{lobby:1b}}",
            f"unless data storage {STORAGE} {{lobby:1b,cabin_layout:1b}}")
    # The older structure still builds the teaching rooms on a fresh world.
    rewrite(functions/"lobby/structure.mcfunction", "setworldspawn -48 90 48 90",
            f"setworldspawn {int(SPAWN[0])} {SPAWN[1]} {int(SPAWN[2])} {SPAWN_ANGLE}")
    for name in ("lobby/back","lobby/first_join","run/exit","run/stale"):
        path = functions / (name + ".mcfunction")
        if name == "lobby/first_join":
            rewrite(path,
                    "execute unless entity @s[tag=sd.floor_run] in minecraft:overworld run tp @s -48.5 90 48.5 90 0",
                    "execute unless entity @s[tag=sd.floor_run] run function sweetdream_floor:lobby/cabin/return")
            rewrite(path, "run function sweetdream_floor:lobby/menu", "at @s run function sweetdream_floor:lobby/menu")
        else:
            rewrite(path,"execute in minecraft:overworld run tp @s -48.5 90 48.5 90 0",
                    "function sweetdream_floor:lobby/cabin/return")
            rewrite(path,"\nfunction sweetdream_floor:lobby/menu", "\nexecute at @s run function sweetdream_floor:lobby/menu")
    write(functions/"lobby/player_tick.mcfunction", [
        "execute unless entity @s[tag=sd.floor_kit_clean,tag=!sd.floor_kit] run function sweetdream_floor:run/recycle_legacy_kit",
        "execute unless dimension minecraft:overworld run return run function sweetdream_floor:lobby/back",
        "execute if entity @s[y=-64,dy=132] run return run function sweetdream_floor:lobby/back",
        "execute if entity @s[tag=sd.floor_tutorial] run return 0",
        f"execute unless entity @s[{LOBBY_BOX}] run return run function sweetdream_floor:lobby/back",
        f"execute if entity @s[{TUTORIAL_BOX}] if block ~ ~-1 ~ minecraft:amethyst_block run return run function sweetdream_floor:tutorial/enter",
        f"execute unless entity @s[{CAMP_BOX}] run tag @s remove sd.floor_pad",
        f"execute unless block ~ ~-1 ~ {PAD} run tag @s remove sd.floor_pad",
        f"execute if entity @s[tag=!sd.floor_pad,{CAMP_BOX}] if block ~ ~-1 ~ {PAD} run function sweetdream_floor:lobby/pad",
    ])
    hint = 'tellraw @s {"text":"走到屋前篝火旁的铜砖，选择职业入梦。屋内紫晶台通往演示室。","color":"gray"}'
    guard = [
        f"execute unless entity @s[{CAMP_BOX}] run return run {hint}",
        f"execute unless block ~ ~-1 ~ {PAD} run return run {hint}",
    ]
    rewrite(functions/"run/start.mcfunction",
            "execute unless entity @s[x=-67,y=90,z=36,dx=28,dy=6,dz=23] run return 0",
            "\n".join(guard))
    rewrite(functions/"lobby/menu.mcfunction",
            'tellraw @s {"text":"选职业进入第一层「密林」。每局重置本地图背包和寄存箱。","color":"gray"}',
            "\n".join(guard + [
                'tellraw @s {"text":"选职业进入第一层「密林」。每局重置本地图背包和寄存箱。","color":"gray"}',
            ]))
    tutorial_chunks(addon)
