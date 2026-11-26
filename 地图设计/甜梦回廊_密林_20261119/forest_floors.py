"""Add an independent second test dimension and carry the run forward."""

import gzip
from pathlib import Path
import struct

from floor_upgrade import DIM, MAP_ID, edit, text, write
from forest_economy import FN, RUN, button, literal, say

NEXT = "sweetdream:floor_2_trial"
NEXT_MAP = MAP_ID + 1
NS = "sweetdream:rogue/"
TRANSFER = "sd.floor_transfer"


def next_map(blob):
    raw = gzip.decompress(blob)
    old, new = DIM.encode(), NEXT.encode()
    before = struct.pack(">H", len(old)) + old
    assert raw.count(before) == 1
    return gzip.compress(raw.replace(before, struct.pack(">H", len(new)) + new, 1), mtime=0)


def stage(world):
    root = Path(world) / "datapacks/zz_sweetdream_floor/data"
    f = root / "sweetdream_floor/function"
    r = root / "sweetdream/function/rogue"
    original = root / "sweetdream/dimension/floor_1_forest.json"
    write(original.with_name("floor_2_trial.json"), text(original))
    cached = Path(world)/"data"/f"map_{MAP_ID}.dat"
    cached.with_name(f"map_{NEXT_MAP}.dat").write_bytes(next_map(cached.read_bytes()))

    def mc(path, *rows):
        write(f/f"{path}.mcfunction", "\n".join(rows))

    def wrap(name, directory, namespace, args=()):
        path = directory/f"{name}.mcfunction"
        body = text(path)
        write(directory/f"{name}_forest.mcfunction", body)
        write(directory/f"{name}_trial.mcfunction",body.replace(DIM,NEXT).replace(str(MAP_ID),str(NEXT_MAP)))
        arglist = ",".join(f'{k}:"$({k})"' if k=="kind" else f'{k}:$({k})' for k in args)
        arglist = f" {{{arglist}}}" if arglist else ""
        macro = "$" if args else ""
        write(path, f'{macro}execute if data storage {RUN} {{floor:2}} run return run function {namespace}{name}_trial{arglist}\n'
              f'{macro}return run function {namespace}{name}_forest{arglist}')

    # Most generation work executes in the chosen dimension already. Adapt the
    # few entry points that switch dimensions or refer to a specific held map.
    for name in ("gen/request","gen/tick","cleanup/request","cleanup/tick","second","prep/begin","prep/tick",
                 "prep/repair_off","prototype/enter","player_tick","map/repair"):
        wrap(name,r,NS)
    wrap("map/draw_icon",r,NS,("cell","x","z","kind"))
    wrap("map/visit",r,NS,("cell","x","z"))
    for name in ("combat/clean","run/orphan"):
        wrap(name,f,FN)
    for name in ("run/player_tick","market/route","room/event/fire_route","room/event/cross_hurt"):
        p=f/f"{name}.mcfunction"
        body=text(p).replace(f"unless dimension {DIM} run",f"unless dimension {DIM} unless dimension {NEXT} run")
        body=body.replace(f"if dimension {DIM} if entity",f"if entity @s[tag=zx.rg_active] if entity")
        write(p,body)
    edit(f/"tick.mcfunction", (f"execute if score #phase sd.floor matches 1.. in {DIM} run function {FN}room/doors/tick",
         f"execute if score #phase sd.floor matches 1.. run function {FN}next/doors_tick"))
    mc("next/doors_tick", f'execute if data storage {RUN} {{floor:2}} in {NEXT} run return run function {FN}room/doors/tick',
       f"execute in {DIM} run function {FN}room/doors/tick")
    # Match the existing dungeon-specific entity sweeps in the shared mechanics.
    for file in (root/"sweetdream/function").rglob("*.mcfunction"):
        if file.is_relative_to(r):
            continue
        body=text(file)
        if f" in {DIM} " not in body:
            continue
        write(file, "\n".join(line+("\n"+line.replace(f" in {DIM} ",f" in {NEXT} "))
                   if line.startswith(("execute ","$execute ")) and f" in {DIM} " in line else line
                   for line in body.splitlines()))

    edit(f/"run/start.mcfunction", ("tag @s add sd.floor_run", f'data modify storage {RUN} floor set value 1\n'
         f'data remove storage {RUN} next_profile\ntag @s remove {TRANSFER}\ntag @s remove sd.floor_mirror\ntag @s add sd.floor_run'))
    for name in ("exit","stale"):
        edit(f/f"run/{name}.mcfunction", ("tag @s remove sd.floor_run",
             f"tag @s remove {TRANSFER}\ntag @s remove sd.floor_mirror\ntag @s remove sd.floor_run"))
    edit(f/"run/player_tick.mcfunction", ("execute if entity @s[tag=zx.rg_wait]",
         f'execute if entity @s[tag={TRANSFER}] run return run function {FN}next/wait\nexecute if entity @s[tag=zx.rg_wait]'))
    edit(f/"run/route.mcfunction", ("execute if score #input sd.floor matches 40..42",
         f"execute if score #input sd.floor matches 82 if score #phase sd.floor matches 5 run return run function {FN}next/start\n"
         "execute if score #input sd.floor matches 40..42"))
    path=f/"reward/god.mcfunction"
    body=text(path).splitlines()
    body[-1]=f"function {FN}next/end_menu"
    write(path,"\n".join(body))
    edit(f/"run/route.mcfunction", ("execute if score #input sd.floor matches 23 unless score #phase sd.floor matches 1",
         f"execute if score #input sd.floor matches 23 if score #phase sd.floor matches 5 run return run function {FN}next/end_menu\n"
         "execute if score #input sd.floor matches 23 unless score #phase sd.floor matches 1"))
    edit(f/"run/arrive.mcfunction", ('title @s title {"text":"第一层 · 密林","color":"green"}',
         f'execute if data storage {RUN} {{floor:2}} run title @s title {{"text":"第二层 · 跨层试验","color":"aqua"}}\n'
         f'execute unless data storage {RUN} {{floor:2}} run title @s title {{"text":"第一层 · 密林","color":"green"}}'))
    edit(f/"reward/god_show.mcfunction", ('title @s title {"text":"密林通关","color":"aqua"}',
         f'execute unless data storage {RUN} {{floor:2}} run title @s title {{"text":"密林通关","color":"aqua"}}\n'
         f'execute if data storage {RUN} {{floor:2}} run title @s title {{"text":"试验层通关","color":"aqua"}}'),
         ("领取后可以在本层试用，再返回大厅。","领取后选择继续探索或返回大厅。"))

    mc("next/end_menu", say("本层已通关。", "aqua"),
       f"execute unless data storage {RUN} {{floor:2}} run tellraw @s " + literal(button("前往第二层 · 跨层试验",82,"green")),
       "tellraw @s " + literal(button("返回等待大厅",3)))
    mc("next/start", f"execute if data storage {RUN} {{floor:2}} run return 0",
       f"execute unless dimension {DIM} run return 0",
       f"function {FN}next/snapshot", f"tag @s add {TRANSFER}",
       f"function {FN}junction/cleanup", f"function {FN}next/leave_first",
       "scoreboard players set #phase sd.floor 6", say("正在重新勘定下一层……"))
    original_exit=Path(world)/"datapacks/sweetdream/data/sweetdream/function/rogue/prototype/exit.mcfunction"
    mc("next/leave_first",*(row for row in text(original_exit).splitlines() if not row.startswith("tellraw @s ")))
    mc("next/snapshot", f"data modify storage {RUN} next_profile set value {{rich:0b,black:0b,injured:0b}}",
       f"execute if score #lumen sd.floor matches 11.. run data modify storage {RUN} next_profile.rich set value 1b",
       f'execute unless data storage zx:rogue floor.cells[{{present:1b,kind:"blackmarket"}}] run function {FN}next/check_astrology',
       "execute store result score #transfer_hp sd.floor run data get entity @s Health 100",
       "execute store result score #transfer_max sd.floor run attribute @s minecraft:max_health get 100",
       "scoreboard players set #transfer_factor sd.floor 5",
       "scoreboard players operation #transfer_hp sd.floor *= #transfer_factor sd.floor",
       f"execute if score #transfer_hp sd.floor < #transfer_max sd.floor run data modify storage {RUN} next_profile.injured set value 1b")
    mc("next/check_astrology", f"data remove storage {RUN} transfer_astrology",
       f'data modify storage {RUN} transfer_astrology set from storage zx:rogue floor.cells[{{present:1b,kind:"astrology",visited:1b}}]',
       f"execute if data storage {RUN} transfer_astrology.cell run function {FN}next/mark_skipped with storage {RUN} transfer_astrology")
    mc("next/mark_skipped", f'$execute unless data storage {RUN} rooms[{{cell:$(cell)}}] run data modify storage {RUN} next_profile.black set value 1b')
    mc("next/wait", "execute if score #rv_clean zx.meta matches 1.. run return 0",
       f"tag @s remove {TRANSFER}", f"tag @s remove sd.floor_mirror", f"data modify storage {RUN} floor set value 2",
       f"data modify storage {RUN} rooms set value []", f"data remove storage {RUN} current",
       f"data remove storage {RUN} encounter", f"data remove storage {RUN} inspected",
       f"data remove storage {RUN} merchant", f"data remove storage {RUN} sale",
       f"data remove storage {RUN} exploration_doors", f"data remove storage {RUN} ambush_pending",
       "scoreboard players set #ready sd.floor 0", "scoreboard players set #budget sd.floor 8",
       "scoreboard players set #room_anchor sd.floor 10", "scoreboard players set #last sd.floor -1",
       "scoreboard players set #phase sd.floor 1", f"function {NS}prototype/start")
    probabilities(f, mc, r)


def probabilities(f, mc, r):
    mc("generation/optional",
       "execute store result score #optional_roll sd.floor run random value 1..10000 sweetdream:rogue",
       f'execute unless data storage {RUN} {{floor:2,next_profile:{{rich:1b}}}} if score #optional_roll sd.floor matches ..2000 run function {NS}gen/assign_one {{kind:"gamble"}}',
       "execute store result score #optional_roll sd.floor run random value 1..3 sweetdream:rogue",
       f"execute if score #optional_roll sd.floor matches 1 run function {NS}gen/assign_one {{kind:\"blackmarket\"}}",
       f'execute if score #optional_roll sd.floor matches 2 if data storage {RUN} {{floor:2,next_profile:{{black:1b}}}} run function {NS}gen/assign_one {{kind:"blackmarket"}}',
       "execute store result score #optional_roll sd.floor run random value 1..10000 sweetdream:rogue",
       f'execute if score #optional_roll sd.floor matches ..1000 run function {NS}gen/assign_one {{kind:"safe"}}',
       f'execute if score #optional_roll sd.floor matches 1001..6000 if data storage {RUN} {{floor:2,next_profile:{{injured:1b}}}} run function {NS}gen/assign_one {{kind:"safe"}}')
    edit(r/"gen/assign.mcfunction", (f"function {NS}gen/assign_rest",
         f"function {NS}gen/assign_rest\nexecute if data storage {RUN} {{floor:2,next_profile:{{rich:1b}}}} run function {FN}next/replace_event"))
    edit(f/"generation/reset_pool.mcfunction", ("[0,1,2,3,4,5,6,7,8]", '[0,1,2,3,4,5,6,7,8]\n'
         f'execute if data storage {RUN} {{floor:2}} run data modify storage {RUN} unused_events set value [0,1,2,5,6,8]'))
    mc("next/replace_event", f"data modify storage {RUN} rich_pool set value []",
       f'data modify storage {RUN} rich_pool append from storage zx:rogue floor.cells[{{present:1b,kind:"event"}}]',
       f"execute unless data storage {RUN} rich_pool[0] run return 0",
       f"execute store result score #rich_size sd.floor run data get storage {RUN} rich_pool",
       "scoreboard players remove #rich_size sd.floor 1",
       f"execute store result storage {RUN} rich_draw.max int 1 run scoreboard players get #rich_size sd.floor",
       f"function {FN}reward/random with storage {RUN} rich_draw", f"function {FN}next/rich_pick with storage {RUN} draw")
    mc("next/rich_pick", f'$function {FN}next/rich_apply with storage {RUN} rich_pool[$(index)]')
    mc("next/rich_apply", '$data modify storage zx:rogue floor.cells[$(cell)].kind set value "gamble"',
       '$data modify storage zx:rogue floor.cells[$(cell)].variant set value 0',
       'scoreboard players remove #rd_k_event zx.meta 1', 'scoreboard players add #rd_k_gamble zx.meta 1')
