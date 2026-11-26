"""Fold the timber stair into the northeast corner and fill the former stairwell."""

import runpy

from architecture import write
from cabin_finish import FINISH, blocks
from cabin_furnish import AIR, ROOT, point
from cabin_lobby import CANDIDATE, STORAGE, rewrite
from cabin_stairs import BOARD, RAIL, RAIL_RESULT, RESULT, design, matches, railing

CORNER = "cabin_corner_stair"
BUILT = "cabin_corner_built"
POST = "minecraft:dark_oak_fence"
PANEL = "minecraft:dark_oak_fence_gate[facing=east,open=false]"
CAP = "minecraft:dark_oak_button[face=floor,facing=north,powered=false]"
LOG = "minecraft:stripped_spruce_log[axis=y]"
PLANKS = "minecraft:spruce_planks"
SLAB = "minecraft:spruce_slab[type=top]"
CABINET = (2,78,-3)
NEW_CABINET = (2,78,-6)


def stock_blocks():
    return blocks(runpy.run_path(str(CANDIDATE))["build"]())


def changes():
    stock = stock_blocks()
    previous = stock | {pos:new for pos,(_,new) in design()[0].items()} | railing()
    desired = {}

    # The rim and all generated central supports are replaced by a flat room.
    for x,y,z in design()[0] | railing():
        if y==83 and z==-4:
            continue
        desired[x,y,z] = PLANKS if y==83 else AIR
    for x in (1,2):
        for z in range(-3,1):
            desired[x,83,z] = PLANKS

    # Lower flight runs toward the back wall. The upper flight returns beside it.
    for x,zs,facing,y0 in ((4,(-4,-5,-6),"north",78),(2,(-6,-5,-4),"south",81)):
        for i,z in enumerate(zs):
            y = y0+i
            desired[x,y,z] = f"{BOARD}[facing={facing},half=bottom]"
            for head in (y+1,y+2):
                desired[x,head,z] = AIR
            if i:
                desired[x,y-1,z] = f"minecraft:dark_oak_stairs[facing={'south' if facing=='north' else 'north'},half=top]"
    for x in (2,3,4):
        desired[x,80,-7] = SLAB if x!=3 else f"{BOARD}[facing=north,half=top]"
        desired[x,81,-7] = desired[x,82,-7] = AIR
    # Player shoulders reach the next riser before their centre leaves this cell.
    desired[4,82,-5] = AIR
    desired[2,83,-7] = AIR
    desired[4,78,-7] = LOG
    desired[4,79,-7] = LOG
    desired[3,80,-5] = PANEL
    for z in (-4,-6):
        desired[3,80,z] = POST
        desired[3,81,z] = CAP
    desired[3,78,-4] = LOG
    desired[3,79,-4] = POST
    for z in (-5,-6):
        desired[3,79,z] = f"{BOARD}[facing=east,half=top]"
    desired[1,84,-6] = desired[3,84,-6] = POST
    desired[1,85,-6] = desired[3,85,-6] = CAP
    desired[1,84,-5] = desired[3,84,-5] = PANEL
    desired[1,84,-4] = desired[3,84,-4] = POST
    desired[2,84,-7] = "minecraft:dark_oak_fence_gate[facing=north,open=false]"
    desired[1,84,-7] = desired[3,84,-7] = POST
    # Move the shared lantern away from the lower flight's headroom.
    desired[5,81,-4] = "minecraft:lantern[hanging=true]"
    desired[5,82,-4] = "minecraft:chain[axis=y]"

    return {pos:(previous.get(pos,AIR),new) for pos,new in desired.items()}


def stage(addon):
    functions = addon/"data/sweetdream_floor/function"
    lobby = functions/"lobby/cabin"
    plan = changes()
    write(lobby/"corner_stair.mcfunction",[
        f"data modify storage {STORAGE} {CORNER} set value 1b",
        f"data modify storage {STORAGE} {BUILT} set value 0b",
        f"execute unless data storage {STORAGE} {{{RESULT}:1b,{RAIL_RESULT}:1b}} run return 0",
        # Check the whole move before retiring the original stair.
        *(f"execute {matches(pos,old,new)} run return 0" for pos,(old,new) in plan.items()),
        # Remove the old light before its supporting chain.
        *(f"setblock {point(pos)} {new}" for pos,(old,new) in
          sorted(plan.items(),key=lambda item:(item[1][1]!=AIR,
                                              -item[0][1] if item[1][1]==AIR else item[0][1],
                                              item[0][0],item[0][2]))
          if old!=new and pos not in ((5,81,-4),(5,82,-4))),
        "setblock 261 82 -4 minecraft:chain[axis=y]",
        "setblock 261 81 -4 minecraft:lantern[hanging=true]",
        f"function {ROOT}/move_under_stair_storage",
        f"data modify storage {STORAGE} {BUILT} set value 1b",
    ])
    stock = stock_blocks()
    cabinet = [(2,y,z) for y in (78,79) for z in (-3,-2,-1)]
    write(lobby/"move_under_stair_storage.mcfunction",[
        *(f"execute {matches(pos,stock.get(pos,AIR))} run return 0" for pos in cabinet),
        *(f"execute {matches((x,y,z-3),AIR)} run return 0" for x,y,z in cabinet),
        f"clone {point(CABINET)} 258 79 -1 {point(NEW_CABINET)} replace move",
    ])
    corner = f"function {ROOT}/corner_stair"
    rail = f"function {ROOT}/rail_stair"
    rewrite(functions/"load.mcfunction",
            f"unless data storage {STORAGE} {{{RAIL}:1b}} run function {FINISH}_load",
            f"unless data storage {STORAGE} {{{CORNER}:1b}} run function {FINISH}_load")
    rewrite(lobby/"ready_loaded.mcfunction",rail+"\n",rail+"\n"+corner+"\n")
    rewrite(lobby/"finish_loaded.mcfunction",f"run {rail}\n",
            f"run {rail}\nexecute unless data storage {STORAGE} {{{CORNER}:1b}} run {corner}\n")
