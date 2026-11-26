"""Migrate the installed cabin's joinery and update the Forest gate presentation."""

from itertools import product
from math import cos, pi, sin, sqrt
import runpy

from architecture import Build, write
from cabin_lobby import CANDIDATE, OFFSET, STORAGE, rewrite

FINISH = "sweetdream_floor:lobby/cabin/finish"
CHUNKS = ((240,-16), (240,0), (256,-16), (256,0))


def blocks(commands):
    result = {}
    for command in commands:
        words = command.split()
        if words[0] == "setblock":
            result[tuple(map(int, words[1:4]))] = words[4]
        if words[0] == "fill":
            first, last = map(int, words[1:4]), map(int, words[4:7])
            limits = [range(min(a,b),max(a,b)+1) for a,b in zip(first,last)]
            for pos in product(*limits):
                result[pos] = words[7]
    return result


def arch(b,x,left,right,foot):
    # Corner braces use the third block of headroom. The first two stay open.
    for face in (x-1,x+1):
        for z,direction in ((left,"north"),(right,"south")):
            b.set(face,foot+2,z,f"dark_oak_stairs[facing={direction},half=top]")
            b.set(face,foot+1,z+(-1 if z==left else 1),"spruce_trapdoor[open=true,facing="+
                  ("east" if face<x else "west")+"]")
        b.box((face,foot+3,left),(face,foot+3,right),"stripped_dark_oak_log[axis=z]")
    b.set(x,foot-1,left,"dark_oak_planks")
    b.set(x,foot-1,right,"dark_oak_planks")


def joinery(b):
    arch(b,6,0,3,78)
    arch(b,-6,-2,2,78)
    for x,z in ((5,4),(7,-1),(-7,3),(-5,-3)):
        b.set(x,81,z,"dark_oak_slab[type=bottom]")
        b.set(x,80,z,"lantern[hanging=true]")

    # The inner side of the front doors and the loft's low walk-out lintel.
    for x,direction in ((-5,"west"),(-4,"east")):
        b.set(x,80,5,f"spruce_stairs[facing={direction},half=top]")
        b.set(x,81,5,"dark_oak_slab[type=top]")
    for x in (-6,-3):
        b.set(x,79,5,"dark_oak_trapdoor[open=true,facing=north]")
    for x in (-7,-5):
        b.box((x,86,-2),(x,86,-1),"dark_oak_slab[type=top]")
        for z in (-3,0):
            b.set(x,84,z,"spruce_trapdoor[open=true,facing="+("east" if x==-7 else "west")+"]")
    for z in (-2,-1):
        b.set(-6,83,z,"dark_oak_planks")


def staircase(b):
    for step in range(6):
        y,z=78+step,2-step
        for x in (1,2):
            b.set(x,y,z,"dark_oak_stairs[facing=north]")
            if step:
                b.set(x,y-1,z,"spruce_stairs[facing=south,half=top]")
    for x in (0,3):
        b.set(x,78,2,"stripped_dark_oak_log")
        b.set(x,79,2,"dark_oak_fence")
        b.set(x,80,0,"dark_oak_fence")
        b.set(x,79,0,"spruce_stairs[facing=north,half=top]")
        b.set(x,81,0,"dark_oak_fence")
        b.set(x,84,-3,"dark_oak_fence")
        b.set(x,85,-3,"dark_oak_slab[type=bottom]")
    for x in (1,2):
        b.set(x,83,-4,"dark_oak_planks")


def chimney(b,house):
    shell,previous = Build(),Build()
    house["roofs"](shell, include_chimney=False)
    house["chimney"](previous)
    roof = blocks(shell.lines)
    for pos in sorted(blocks(previous.lines)):
        b.set(*pos,roof.get(pos,"minecraft:air").removeprefix("minecraft:"))
    # The flashing follows the roof, then the upper flue tapers to a single shaft.
    b.box((-6,84,-6),(-5,88,-5),"tuff_bricks")
    b.box((-6,89,-6),(-5,89,-5),"polished_deepslate")
    b.box((-6,90,-6),(-5,90,-5),"bricks")
    b.set(-6,90,-6,"campfire[lit=true]")
    b.set(-6,91,-6,"brick_wall[south=low,up=true]")
    b.set(-6,91,-5,"brick_wall[north=low,up=true]")
    b.set(-6,92,-6,"stone_brick_wall[up=true]")


def rail_commands():
    angle = pi/4
    for x in (.44,3.44):
        yield (
            f'summon minecraft:block_display {OFFSET+x} 85 -2.5 '
            '{Tags:["sd.floor_lobby_display","sd.floor_cabin_rail"],'
            'block_state:{Name:"minecraft:dark_oak_planks"},'
            f'transformation:{{translation:[0f,0f,0f],left_rotation:[{sin(angle/2):.8f}f,0f,0f,{cos(angle/2):.8f}f],'
            f'scale:[0.12f,0.10f,{sqrt(50):.8f}f],right_rotation:[0f,0f,0f,1f]}}}}'
        )


def cabin(functions):
    approved = runpy.run_path(str(CANDIDATE))
    known = blocks(approved["build"]())
    changes = Build()
    joinery(changes)
    staircase(changes)
    chimney(changes,approved["house"])
    patch = []
    for pos,new in blocks(changes.lines).items():
        old = known.get(pos,"minecraft:air")
        if old == new:
            continue
        x,y,z = pos
        location = f"{x+OFFSET} {y} {z}"
        patch.append(f"execute if block {location} {old} run setblock {location} {new}")
    write(functions/"lobby/cabin/finish.mcfunction", patch + [
        f"kill @e[type=minecraft:block_display,tag=sd.floor_cabin_rail,x={OFFSET-1},y=78,z=-4,dx=5,dy=10,dz=8]",
        *rail_commands(),
        f"data modify storage {STORAGE} cabin_finish set value 1b",
    ])
    write(functions/"lobby/cabin/finish_load.mcfunction", [
        f"execute unless data storage {STORAGE} finish_chunks.c{i} store success storage {STORAGE} finish_chunks.c{i} byte 1 run forceload add {x} {z}"
        for i,(x,z) in enumerate(CHUNKS)
    ] + [f"schedule function {FINISH}_ready 1s replace"])
    write(functions/"lobby/cabin/finish_ready.mcfunction",
          [f"execute in minecraft:overworld run function {FINISH}_loaded"])
    write(functions/"lobby/cabin/finish_loaded.mcfunction",[
        f"execute unless loaded {x} 78 {z} run return run schedule function {FINISH}_ready 1s replace"
        for x,z in CHUNKS
    ] + [
        f"execute unless data storage {STORAGE} {{cabin_finish:1b}} run function {FINISH}",
        *(f"execute if data storage {STORAGE} finish_chunks{{c{i}:1b}} run forceload remove {x} {z}"
          for i,(x,z) in enumerate(CHUNKS)),
        f"data remove storage {STORAGE} finish_chunks",
    ])
    ready = functions/"lobby/cabin/ready_loaded.mcfunction"
    marker = f"data modify storage {STORAGE} cabin_layout set value 1b"
    rewrite(ready,marker,f"function {FINISH}\n{marker}")
    load = functions/"load.mcfunction"
    body = load.read_text(encoding="utf-8").rstrip()
    load.write_text(body + f"\nexecute in minecraft:overworld if data storage {STORAGE} {{cabin_layout:1b}} "
                    f"unless data storage {STORAGE} {{cabin_finish:1b}} run function {FINISH}_load\n",
                    encoding="utf-8")


def gate_panels(axis):
    for y,u in product(range(5),range(7)):
        # Full-size boards repeat their native grain along the span.
        wood = "stripped_spruce_log" if 0<u<6 and (u+2*y)%4!=0 else "stripped_dark_oak_log"
        x,z = (u,0) if axis=="x" else (0,u)
        yield (
            'summon minecraft:block_display ~ ~ ~ '
            f'{{Tags:["sd.floor_gate","sd.floor_gate_new","sd.floor_gate_row_{y}"],'
            f'block_state:{{Name:"minecraft:{wood}",Properties:{{axis:"{axis}"}}}},'
            f'transformation:{{translation:[{x}.0f,{y+5}.0f,{z}.0f],'
            'left_rotation:[0f,0f,0f,1f],right_rotation:[0f,0f,0f,1f],scale:[1f,1f,1f]},'
            'width:15.0f,height:10.0f,view_range:0.75f}'
        )


def gates(functions):
    doors = functions/"room/doors"
    namespace = "sweetdream_floor:room/doors/"
    for axis in ("x","z"):
        write(doors/f"panels_{axis}.mcfunction",list(gate_panels(axis)))
    write(doors/"close_visual.mcfunction", [
        "$fill ~-$(x) ~ ~-$(z) ~$(x) ~4 ~$(z) minecraft:barrier replace minecraft:air",
        f"$execute positioned ~-$(x) ~ ~-$(z) as @e[type=minecraft:block_display,tag=sd.floor_gate,distance=..0.25] run function {namespace}discard",
        f"$execute positioned ~-$(x) ~ ~-$(z) run function {namespace}panels_$(axis)",
    ])
    for name,offset in (("lower",0),("sink",-5)):
        rows = [f"execute if entity @s[tag=sd.floor_gate_row_{i}] run data modify entity @s transformation.translation[1] set value {i+offset}.0f"
                for i in range(5)]
        if name=="sink":
            rows = ["tag @s remove sd.floor_gate_new","tag @s remove sd.floor_gate_ready",
                    "tag @s add sd.floor_gate_open","scoreboard players set @s sd.floor 9",
                    # Pre-update saves can still contain the original one-piece gate.
                    "data modify entity @s transformation.translation[1] set value -5.0f", *rows]
        else:
            rows.insert(0,"tag @s remove sd.floor_gate_ready")
        rows.append("data merge entity @s {start_interpolation:0,interpolation_duration:8}")
        write(doors/(name+".mcfunction"),rows)
    rewrite(doors/"open_visual.mcfunction","tag=sd.floor_gate,distance=..0.25",
            "tag=sd.floor_gate,tag=!sd.floor_gate_open,distance=..0.25")
    rewrite(doors/"open_visual.mcfunction",f"run function {namespace}lift",f"run function {namespace}sink")


def stage(addon):
    functions = addon/"data/sweetdream_floor/function"
    cabin(functions)
    gates(functions)
    load = functions/"load.mcfunction"
    body = load.read_text(encoding="utf-8")
    load.write_text("gamerule naturalRegeneration false\n"+body,encoding="utf-8")
    rewrite(functions/"tick.mcfunction","effect give @a[tag=sd.floor_seen] minecraft:saturation 1 0 true",
            "effect give @a[tag=sd.floor_seen,nbt=!{foodLevel:20}] minecraft:saturation 1 0 true")
