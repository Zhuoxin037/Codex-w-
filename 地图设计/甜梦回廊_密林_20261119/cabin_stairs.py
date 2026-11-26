"""Remove display trim and build a quarter-turn timber stair in the cabin."""

from cabin_clear import REMOVED
from cabin_finish import FINISH, blocks, staircase
from cabin_furnish import AIR, ROOT, TAG, door_frames, point, rails
from cabin_lobby import LOBBY_BOX, STORAGE, rewrite
from architecture import Build, write

STAIRS = "cabin_stairs"
RESULT = "cabin_stair_built"
RAIL = "cabin_block_railing"
RAIL_RESULT = "cabin_railing_built"
BOARD = "minecraft:spruce_stairs"
OLD_BOARD = "minecraft:dark_oak_stairs"
SUPPORT = "minecraft:spruce_stairs[facing=south,half=top]"


def design():
    """Return old and new block states, plus the blocks above the walking line."""
    old_stair = Build()
    staircase(old_stair)
    old = {pos:state for pos,state in blocks(old_stair.lines).items() if pos[0] in (1,2)}
    change = {}
    ceiling = set()

    def tread(x,y,z,new):
        change[x,y,z] = (old.get((x,y,z),AIR),new)
        ceiling.update(((x,y+1,z),(x,y+2,z)))

    for x in (1,2):
        for z in (1,2):
            change[x,78,z] = (old.get((x,78,z),AIR),AIR)
            landing = "minecraft:spruce_slab[type=top]"
            if (x,z)==(2,1):
                change[x,78,z] = (SUPPORT,"minecraft:stripped_spruce_log[axis=y]")
                landing = f"{BOARD}[facing=east,half=top]"
            tread(x,79,z,landing)
        for i in range(2,6):
            y,z = 78+i,2-i
            tread(x,y,z,f"{BOARD}[facing=north,half=bottom]")
            support = AIR if x==1 else f"{OLD_BOARD}[facing=south,half=top]"
            change[x,y-1,z] = (SUPPORT,support)
        change[x,83,-4] = ("minecraft:dark_oak_planks","minecraft:stripped_spruce_log[axis=x]")
        ceiling.update(((x,84,-4),(x,85,-4)))

    for z in (1,2):
        tread(4,78,z,f"{BOARD}[facing=west,half=bottom]")
        tread(3,79,z,f"{BOARD}[facing=west,half=bottom]")
        ceiling.update(((5,78,z),(5,79,z)))
    change[3,78,1] = (AIR,f"{OLD_BOARD}[facing=east,half=top]")
    return change,ceiling


def matches(pos,*states):
    return " ".join(f"unless block {point(pos)} {state}" for state in dict.fromkeys(states))


def railing():
    """Timber newels and recessed brackets carry the dark rail spans."""
    post = "minecraft:dark_oak_fence"
    timber = "minecraft:stripped_spruce_log[axis=y]"
    cap = "minecraft:dark_oak_button[face=floor,facing=north,powered=false]"
    cross = "minecraft:dark_oak_fence_gate[facing=north,open=false]"
    along = "minecraft:dark_oak_fence_gate[facing=east,open=false]"
    parts = {}

    # The lower capped newel sits on the main floor, and the turning newel
    # follows the edge of the landing. The gates give the spans an open profile.
    parts[4,78,3],parts[4,79,3],parts[4,80,3] = timber,post,cap
    parts[3,78,3],parts[3,79,3],parts[3,80,3] = f"{BOARD}[facing=west,half=top]",cross,post
    parts[0,78,3],parts[0,79,3],parts[0,80,3],parts[0,81,3] = timber,timber,post,cap
    for x,rail in ((1,post),(2,cross)):
        parts[x,79,3] = f"{BOARD}[facing=north,half=top]"
        parts[x,80,3] = rail

    for z,rail in ((1,post),(2,along)):
        parts[0,79,z],parts[0,80,z] = f"{BOARD}[facing=east,half=top]",rail
    parts[0,81,1],parts[0,81,0],parts[0,81,-1] = post,along,post
    for z in (0,-1):
        parts[0,80,z] = f"{BOARD}[facing=east,half=top]"
    parts[0,81,-2] = f"{BOARD}[facing=east,half=top]"
    parts[0,81,-3] = f"{BOARD}[facing=east,half=top]"
    parts[0,82,-1],parts[0,82,-2],parts[0,82,-3] = post,along,post

    # Continue the same woodwork around the upstairs opening.
    for x in (0,3):
        for z in range(-3,2):
            parts[x,84,z] = post if z%2 else along
        for z in (-3,1):
            parts[x,85,z] = cap
    for x in (1,2):
        parts[x,84,1] = cross
    return parts


def stage(addon):
    functions = addon/"data/sweetdream_floor/function"
    lobby = functions/"lobby/cabin"
    finish = lobby/"furnish.mcfunction"
    trim = list(door_frames())+list(rails())
    for line in trim:
        rewrite(finish,line+"\n","")
    positions = sorted({tuple(line.split()[2:5]) for line in trim})
    write(lobby/"rebuild_stair.mcfunction",[
        f"kill @e[type=minecraft:block_display,tag=sd.floor_cabin_rail,{LOBBY_BOX}]",
        *(f"execute positioned {' '.join(pos)} run kill @e[type=minecraft:block_display,"
          f"tag={TAG},tag=sd.floor_lobby_display,distance=..0.0001]" for pos in positions),
        f"data modify storage {STORAGE} {RESULT} set value 0b",
        f"function {ROOT}/place_stair",
        f"data modify storage {STORAGE} {STAIRS} set value 1b",
    ])
    change,ceiling = design()
    write(lobby/"place_stair.mcfunction",[
        # Apply the connected route as a whole so a saved edit cannot leave a half stair.
        *(f"execute {matches(pos,old,new)} run return 0" for pos,(old,new) in sorted(change.items())),
        *(f"execute {matches(pos,AIR)} run return 0" for pos in sorted(ceiling)),
        *(f"setblock {point(pos)} {new}" for pos,(old,new) in sorted(change.items())),
        f"data modify storage {STORAGE} {RESULT} set value 1b",
    ])
    rebuild = f"function {ROOT}/rebuild_stair"
    rewrite(functions/"load.mcfunction",
            f"unless data storage {STORAGE} {{{REMOVED}:1b}} run function {FINISH}_load",
            f"unless data storage {STORAGE} {{{STAIRS}:1b}} run function {FINISH}_load")
    clear = f"function {ROOT}/clear_furniture"
    rewrite(lobby/"ready_loaded.mcfunction",clear+"\n",clear+"\n"+rebuild+"\n")
    rewrite(lobby/"finish_loaded.mcfunction",f"run {clear}\n",
            f"run {clear}\n"
            f"execute unless data storage {STORAGE} {{{STAIRS}:1b}} run {rebuild}\n")


def stage_railing(addon):
    functions = addon/"data/sweetdream_floor/function"
    lobby = functions/"lobby/cabin"
    parts = sorted(railing().items(),key=lambda item:(item[0][1],item[0][0],item[0][2]))
    def original(pos):
        return "minecraft:spruce_fence" if pos[1]==84 else AIR
    write(lobby/"rail_stair.mcfunction",[
        f"data modify storage {STORAGE} {RAIL} set value 1b",
        f"data modify storage {STORAGE} {RAIL_RESULT} set value 0b",
        f"execute unless data storage {STORAGE} {{{RESULT}:1b}} run return 0",
        *(f"execute {matches(pos,original(pos),new)} run return 0" for pos,new in parts),
        *(f"setblock {point(pos)} {new}" for pos,new in parts),
        f"data modify storage {STORAGE} {RAIL_RESULT} set value 1b",
    ])
    rewrite(functions/"load.mcfunction",
            f"unless data storage {STORAGE} {{{STAIRS}:1b}} run function {FINISH}_load",
            f"unless data storage {STORAGE} {{{RAIL}:1b}} run function {FINISH}_load")
    rebuild = f"function {ROOT}/rebuild_stair"
    rail = f"function {ROOT}/rail_stair"
    rewrite(lobby/"ready_loaded.mcfunction",rebuild+"\n",rebuild+"\n"+rail+"\n")
    rewrite(lobby/"finish_loaded.mcfunction",f"run {rebuild}\n",
            f"run {rebuild}\n"
            f"execute unless data storage {STORAGE} {{{RAIL}:1b}} run {rail}\n")
