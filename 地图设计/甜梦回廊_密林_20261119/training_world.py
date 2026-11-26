"""Build the dedicated training dimension and escrow carried gear during a visit."""

import json
from pathlib import Path

from architecture import Build, MOSS, WORN, lamp
from floor_upgrade import DIM, edit, text, write
from forest_economy import FN, RUN, button, literal
from lobby_expansion import (
    DUMMY, DUMMY_PADS, LOBBY, PRACTICING, RACK, READY, TRAINING_DIM, TRAINING_TAG, coords,
)
from lobby_metrics import OBJ

NS = FN + "training/"
STORE = "sweetdream_floor:training"
GATE_TAG = "sd.training_gate"
RACK_NEAR = "sd.training_rack_near"
TRANSFER_TAG = "sd.training_transfer"
SPAWN = (267.5, 78, 30.5)
EXIT = (266.5, 78, 37.5)
FIELD = "256 16 303 47"
GATE = "272 16 287 47"

SLOTS = (
    *(f"hotbar.{i}" for i in range(9)),
    *(f"inventory.{i}" for i in range(27)),
    "armor.feet", "armor.legs", "armor.chest", "armor.head", "weapon.offhand",
)


def sign(point, title, hint, tag, color="gold"):
    label = [{"text":title,"bold":True,"color":color}]
    if hint:
        label.append({"text":"\n"+hint,"color":"white"})
    return (f'summon minecraft:text_display {coords(point)} '
            f'{{Tags:["{tag}"],text:{literal(label)},billboard:"center",background:1074792454,'
            "shadow:1b,view_range:0.45f}")


def arena():
    b = Build()
    b.box((263,74,24),(296,75,43),"tuff")
    b.box((262,76,23),(297,76,44),"rooted_dirt")
    b.box((262,77,23),(297,77,44),MOSS)
    b.shell(262,297,78,78,23,44,"mossy_stone_brick_wall")
    b.box((264,77,29),(280,77,32),"coarse_dirt")
    b.box((265,77,32),(268,77,39),"coarse_dirt")
    b.box((264,77,35),(268,77,39),"polished_tuff")
    b.set(266,77,37,"chiseled_tuff")
    for x in (264,268):
        b.box((x,78,38),(x,81,38),"stripped_dark_oak_log")
        b.set(x,79,37,"lantern")
        b.set(x,78,37,"spruce_fence")
    b.box((264,82,38),(268,82,38),"dark_oak_log[axis=x]")
    b.box((263,83,37),(269,83,39),"dark_oak_slab[type=bottom]")
    # Open equipment pavilion, with its menu approach in the middle of a wide aisle.
    b.box((272,77,27),(278,77,33),"spruce_planks")
    for x in (272,278):
        for z in (27,33):
            b.box((x,78,z),(x,82,z),"stripped_dark_oak_log")
    for n,y in enumerate((82,83,84)):
        for x in (271+n,279-n):
            b.box((x,y,26),(x,y,34),"spruce_stairs[facing="+("east" if x<275 else "west")+"]")
    b.box((274,85,26),(276,85,34),"dark_oak_slab[type=bottom]")
    b.box((272,82,27),(278,82,27),"dark_oak_log[axis=x]")
    b.box((272,82,33),(278,82,33),"dark_oak_log[axis=x]")
    b.set(275,81,27,"lantern[hanging=true]")
    b.set(275,81,33,"lantern[hanging=true]")
    b.set(274,78,27,"smithing_table")
    b.set(275,78,27,"barrel[facing=south]")
    b.set(276,78,27,"grindstone[face=floor,facing=south]")
    b.box((275,77,29),(276,77,31),"waxed_oxidized_cut_copper")
    # Clear approaches from the pavilion into two separately lit attack lanes.
    for z in (30,38):
        b.disk(287,77,z,7,3,"packed_mud")
        b.disk(285,77,z,2,2,WORN)
        b.set(285,77,z,"chiseled_tuff")
        b.box((293,78,z-2),(293,79,z+2),"mossy_cobblestone_wall")
        lamp(b,292,z-2)
        lamp(b,292,z+2)
    for x,z in ((264,25),(281,25),(292,25),(265,41),(274,42),(294,42)):
        b.oak(x,78,z,7,canopy=3)
    for x,z in ((270,26),(279,36),(270,39),(288,34),(280,42)):
        lamp(b,x,z)
    for x in range(264,297,5):
        for z in range(25,44,5):
            b.lines.append(f"setblock {x} 80 {z} minecraft:light[level=15] keep")
    return b.lines


def stage(world):
    addon = Path(world)/"datapacks/zz_sweetdream_floor/data"
    floor = addon/"sweetdream_floor/function"
    dims = addon/"sweetdream/dimension"

    def mc(name, *body):
        write(floor/f"training/{name}.mcfunction", "\n".join(body))

    definition = json.loads(text(dims/"floor_1_forest.json"))
    definition["generator"]["settings"]["biome"] = "minecraft:taiga"
    write(dims/"training.json",json.dumps(definition,indent=2))
    for file in (addon/"sweetdream/function").rglob("*.mcfunction"):
        if file.relative_to(addon/"sweetdream/function").parts[0] == "rogue":
            continue
        body = text(file)
        match = f" in {DIM} "
        if match in body:
            rows = [row+(("\n"+row.replace(match,f" in {TRAINING_DIM} ")) if match in row
                    and row.startswith(("execute ","$execute ")) else "") for row in body.splitlines()]
            write(file, "\n".join(rows))
    clock = floor/"load.mcfunction"
    write(clock, text(clock)+f"\nschedule function {NS}request 1s replace")
    mc("request",
       f"execute if data storage {STORE} {{built:1b}} run return 0",
       f"execute unless data storage {RUN} {{lobby_expansion:1b}} run return run schedule function {NS}request 1s replace",
       f"execute in minecraft:overworld run forceload add {GATE}",
       f"execute in {TRAINING_DIM} run forceload add {FIELD}",
       f"schedule function {NS}build 1s replace")
    mc("build",
       f"execute if data storage {STORE} {{built:1b}} run return 0",
       *(f"execute in minecraft:overworld unless loaded 272 78 {z} run return run schedule function {NS}build 1s replace"
         for z in (16,32)),
       *(f"execute in {TRAINING_DIM} unless loaded {x} 78 {z} run return run schedule function {NS}build 1s replace"
         for x in (256,272,288) for z in (16,32)),
       f"execute in {TRAINING_DIM} store success score #arena_built {OBJ} run function {NS}arena",
       f"execute unless score #arena_built {OBJ} matches 1 run return 0",
       f"execute in minecraft:overworld store success score #gate_built {OBJ} run function {NS}replace_gate",
       f"execute unless score #gate_built {OBJ} matches 1 run return 0",
       f"data modify storage {STORE} built set value 1b",
       f"execute in minecraft:overworld run forceload remove {GATE}",
       f"execute in {TRAINING_DIM} run forceload remove {FIELD}")
    mc("arena", *arena(),
       sign((RACK[0],80.25,RACK[2]),"装备架","走近领取 · 按 T 选择","sd.training_rack_sign","aqua"),
       f'summon minecraft:interaction {coords(RACK)} {{Tags:["sd.practice_rack"],width:3.2f,height:2.4f,response:1b}}',
       sign((EXIT[0],80.45,EXIT[2]),"返回大厅","","sd.training_exit"),
       f"function {LOBBY}practice/dummies",
       "return 1")
    mc("replace_gate",
       f"execute positioned {coords(RACK)} run kill @e[type=minecraft:interaction,tag=sd.practice_rack,distance=..2]",
       "execute positioned 275.5 79.85 30.5 run kill @e[type=minecraft:text_display,tag=sd.lobby_expansion,distance=..0.4]",
       f"kill @e[tag={DUMMY},distance=0..]",
       "kill @e[type=minecraft:text_display,tag=sd.practice_board_0,distance=0..]",
       "kill @e[type=minecraft:text_display,tag=sd.practice_board_1,distance=0..]",
       sign((RACK[0],80.0,RACK[2]),"训练场","潜行进入","sd.training_gate_sign"),
       "return 1")

    # A saved character in the old clearing can still recover their normal
    # inventory before the new gate takes a snapshot.
    file = floor/"lobby/player_tick.mcfunction"
    old = next(row for row in text(file).splitlines() if f"run function {LOBBY}practice/clear" in row)
    edit(file, (old, f"execute if entity @s[tag={PRACTICING}] run function {LOBBY}practice/clear"),
         (f"execute if entity @s[tag=sd.floor_tutorial] run return 0",
          f"execute if entity @s[tag=sd.floor_tutorial] run return 0\nfunction {NS}gate\n"
          f"execute if entity @s[tag={TRAINING_TAG}] run return 0"))
    file = floor/"route.mcfunction"
    rest = next(row for row in text(file).splitlines() if f"run function {LOBBY}practice/route" in row)
    edit(file, (rest, ""),
         ("scoreboard players enable @s sd.floor_cmd",
          f"scoreboard players enable @s sd.floor_cmd\nexecute if entity @s[tag={TRAINING_TAG}] run return run function {NS}route"))
    file = floor/"tick.mcfunction"
    edit(file,
         (f"execute as @a[tag=!sd.floor_run] at @s run function {LOBBY}player_tick",
          f"execute as @a[tag={TRAINING_TAG}] at @s run function {NS}player_tick\n"
          f"execute as @a[tag=!sd.floor_run,tag=!{TRAINING_TAG}] at @s run function {LOBBY}player_tick"),
         (f"execute in minecraft:overworld run function {LOBBY}practice/tick",
          f"execute in {TRAINING_DIM} run function {LOBBY}practice/tick"))

    mc("route",
       f"execute if score #input sd.floor matches 3 run return run function {NS}leave",
       f"execute if score #input sd.floor matches 100.. run function {LOBBY}practice/route")
    mc("gate",
       f"execute positioned {coords(RACK)} unless entity @s[distance=..3] run tag @s remove {GATE_TAG}",
       f"execute if data storage {STORE} {{built:1b}} positioned {coords(RACK)} "
       f"if entity @s[tag=!{GATE_TAG},distance=..3] at @s run function {NS}enter")
    mc("player_tick",
       f"execute unless dimension {TRAINING_DIM} run return run function {NS}leave",
       f"execute if score @s sd.floor_death matches 1.. run return run function {NS}leave",
       f"execute if entity @s[y=-64,dy=134] run return run function {NS}leave",
       f"execute positioned {coords(EXIT)} if entity @s[distance=..2] at @s run return run function {NS}leave",
       f"execute positioned {coords(RACK)} unless entity @s[distance=..4] run tag @s remove {RACK_NEAR}",
       f"execute positioned {coords(RACK)} if entity @s[tag=!{RACK_NEAR},distance=..4] at @s run function {NS}offer")
    mc("offer",
       f"tag @s add {RACK_NEAR}",
       'title @s actionbar {"text":"按 T 打开聊天栏领取装备","color":"aqua"}',
       f"function {LOBBY}practice/menu")
    escrow(mc)


def escrow(mc):
    vault = f'{STORE} vault."$(uuid)"'
    carrier = f"@a[tag={TRANSFER_TAG},distance=0..,limit=1]"
    begin_transfer = (f"tag @a[tag={TRANSFER_TAG}] remove {TRANSFER_TAG}", f"tag @s add {TRANSFER_TAG}")
    end_transfer = f"tag @s remove {TRANSFER_TAG}"
    mc("enter",
       "function sweetdream:lib/uuid",
       "execute unless data storage zx:data self{ok:1b} run return 0",
       f"function {NS}capture with storage zx:data self")
    destination = (("x","Pos[0]"),("y","Pos[1]"),("z","Pos[2]"),
                   ("yaw","Rotation[0]"),("pitch","Rotation[1]"))
    mc("capture",
       f"$execute if data storage {vault}.items run return run function {NS}restore {{uuid:\"$(uuid)\"}}",
       f"execute unless data storage {STORE} vault run data modify storage {STORE} vault set value {{}}",
       f"data modify storage {STORE} capture set value {{home:{{}},items:{{}},count:0}}",
       f"scoreboard players set #captured_slots {OBJ} 0",
       f"scoreboard players set #expected_slots {OBJ} 0",
       *begin_transfer,
       f"execute summon minecraft:item_display run function {NS}capture_slots",
       end_transfer,
       f"execute unless score #captured_slots {OBJ} = #expected_slots {OBJ} run return 0",
       f"execute store result storage {STORE} capture.count int 1 run scoreboard players get #captured_slots {OBJ}",
       *(f"data modify storage {STORE} capture.home.{field} set from entity @s {path}"
         for field,path in destination),
       f"$data modify storage {vault} set from storage {STORE} capture",
       f"$execute unless data storage {vault}.items run return 0",
       f"data remove storage {STORE} capture",
       f"tag @s add {TRAINING_TAG}", f"tag @s add {GATE_TAG}",
       f"tag @s remove {READY}",
       "scoreboard players set @s sd.floor_death 0",
       "function sweetdream:profession/cleanup",
       "clear @s",
       f"execute in {TRAINING_DIM} run tp @s {coords(SPAWN)} -90 0",
       "tellraw @s "+literal(button("返回大厅",3,"gray")))
    mc("capture_slots",
       *(f'execute if items entity {carrier} {slot} * run function {NS}capture_slot {{slot:"{slot}"}}'
         for slot in SLOTS),
       "kill @s")
    mc("capture_slot",
       f"scoreboard players add #expected_slots {OBJ} 1",
       f"scoreboard players set #captured_slot {OBJ} 0",
       "data remove entity @s item",
       f"$item replace entity @s contents from entity {carrier} $(slot)",
       f'$execute if items entity @s contents * store success score #captured_slot {OBJ} '
       f'run data modify storage {STORE} capture.items."$(slot)" set from entity @s item',
       f"scoreboard players operation #captured_slots {OBJ} += #captured_slot {OBJ}")
    mc("leave",
       "execute if data entity @s {Health:0.0f} run return 0",
       "function sweetdream:lib/uuid",
       "execute unless data storage zx:data self{ok:1b} run return 0",
       f"function {NS}restore with storage zx:data self")
    mc("restore",
       f"$execute unless data storage {vault}.count run return 0",
       f"$execute store result score #saved_slots {OBJ} run data get storage {vault}.count",
       f"scoreboard players set #restored_slots {OBJ} 0",
       "function sweetdream:profession/cleanup",
       f"function {LOBBY}restore_health",
       "clear @s",
       *begin_transfer,
       f"$execute summon minecraft:item_display run function {NS}restore_slots {{uuid:\"$(uuid)\"}}",
       end_transfer,
       f"execute unless score #restored_slots {OBJ} = #saved_slots {OBJ} run return 0",
       f"$execute store success score #sent_home {OBJ} run function {NS}return_home with storage {vault}.home",
       f"execute unless score #sent_home {OBJ} matches 1 run return 0",
       f"tag @s remove {TRAINING_TAG}", f"tag @s remove {PRACTICING}", f"tag @s remove {RACK_NEAR}",
       f"tag @s add {GATE_TAG}",
       f"$data remove storage {vault}")
    mc("restore_slots",
       *(f'$execute if data storage {vault}.items."{slot}" run function {NS}restore_slot '
         f'{{uuid:"$(uuid)",slot:"{slot}"}}' for slot in SLOTS),
       "kill @s")
    mc("restore_slot",
       f"scoreboard players set #restored_slot {OBJ} 0",
       "data remove entity @s item",
       f'$data modify entity @s item set from storage {vault}.items."$(slot)"',
       f"$execute if items entity @s contents * store success score #restored_slot {OBJ} "
       f"run item replace entity {carrier} $(slot) from entity @s contents",
       f"scoreboard players operation #restored_slots {OBJ} += #restored_slot {OBJ}")
    # Relative coordinates from the origin avoid vanilla centering whole X/Z values.
    mc("return_home", "$return run execute in minecraft:overworld positioned 0.0 0.0 0.0 "
       "run tp @s ~$(x) ~$(y) ~$(z) $(yaw) $(pitch)")
