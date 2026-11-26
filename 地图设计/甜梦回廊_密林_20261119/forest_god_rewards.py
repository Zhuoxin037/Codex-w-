"""Grant real run talents from the floor boss reward."""

from pathlib import Path

from floor_upgrade import DIM, text, write
from forest_economy import FN, RUN, button, literal, say
from forest_floors import NEXT
from forest_services import TALENTS


MEMBERS = "tag=sd.floor_run,tag=zx.rg_active,scores={sd.floor_death=0}"
PARTY = f"@a[{MEMBERS},distance=0..]"
FLOOR = "#god_floor sd.floor"
REWIND = ("rewind", "回刻", "每次战斗结束，当前主手武器的技能冷却减少 15 秒。")
GODS = ((40, *TALENTS[4], "astrology/grant_4"),
        (41, *TALENTS[5], "astrology/grant_5"),
        (42, *REWIND, "astrology/grant_rewind"))
OWNED = "@s[" + ",".join(f"tag=sd.astro.{key}" for _,key,*_ in GODS) + "]"


def stage(world):
    home = Path(world)/"datapacks/zz_sweetdream_floor/data/sweetdream_floor/function"

    def mc(name,*lines):
        write(home/f"{name}.mcfunction","\n".join(lines))

    def append(name,line):
        path = home/f"{name}.mcfunction"
        original = text(path)
        if line not in original:
            write(path,original+line)

    def replace(name,old,new):
        path = home/f"{name}.mcfunction"
        original = text(path)
        if new in original:
            return
        if original.count(old)!=1:
            raise ValueError(f"Missing boss reward hook in {path}: {old}")
        write(path,original.replace(old,new,1))

    append("load","scoreboard objectives add sd.god_floor dummy")
    append("load","scoreboard objectives add sd.god_menu dummy")
    for obj in ("sd.god_floor", "sd.god_menu"):
        append("astrology/reset",f"scoreboard players reset @s {obj}")
    append("astrology/reset","tag @s remove sd.astro.rewind")
    description = f"神格 · {REWIND[1]}  {REWIND[2]}"
    append("astrology/list",f"execute if entity @s[tag=sd.astro.rewind] run "+say(description,"light_purple"))
    replace("room/status","tag=!sd.astro.heart]","tag=!sd.astro.heart,tag=!sd.astro.rewind]")
    mc("astrology/grant_rewind","tag @s add sd.astro.rewind",say(description,"light_purple"))
    mc("astrology/rewind",
       "data modify storage sweetdream_floor:talent cooldown set value {}",
       'data modify storage sweetdream_floor:talent cooldown.skill set from entity @s SelectedItem.components."minecraft:custom_data".skill',
       "execute unless data storage sweetdream_floor:talent cooldown.skill run return 0",
       f"function {FN}astrology/rewind_go with storage sweetdream_floor:talent cooldown")
    mc("astrology/rewind_go",
       '$execute unless data storage sweetdream_floor:clock weapons."$(skill)" run return 0',
       "function fallendream:lib/uuid",
       'execute unless data storage zx:data self{ok:1b} run return 0',
       '$data modify storage manacore:in arg set value {skill:"$(skill)",ticks:300}',
       "data modify storage manacore:in arg.uuid set from storage zx:data self.uuid",
       "function manacore:api/cooldown/reduce")

    replace("combat/win",
            f'execute if data storage {RUN} current{{kind:"boss"}} run return run function {FN}reward/god_show',
            f'execute as {PARTY} if entity @s[tag=sd.astro.rewind] run function {FN}astrology/rewind\n'
            f'execute if data storage {RUN} current{{kind:"boss"}} run return run function {FN}reward/god_begin')
    replace("run/route",f"if score #phase sd.floor matches 3..4 if data storage {RUN} choice_room",
            f"if score #phase sd.floor matches 3 if data storage {RUN} choice_room")
    route = f"execute as @a[scores={{sd.floor_cmd=1..}}] at @s run function {FN}route"
    replace("tick",route,"\n".join((
        f'execute if score #phase sd.floor matches 4 if data storage {RUN} {{floor:2}} in {NEXT} run function {FN}reward/god_tick',
        f'execute if score #phase sd.floor matches 4 unless data storage {RUN} {{floor:2}} in {DIM} run function {FN}reward/god_tick',
        route)))

    read_floor = f"execute store result score {FLOOR} run data get storage {RUN} floor"
    check_party = f"execute unless entity @s[{MEMBERS}] run return 0"
    check_dim = (
        f'execute if data storage {RUN} {{floor:2}} unless dimension {NEXT} run return 0',
        f'execute unless data storage {RUN} {{floor:2}} unless dimension {DIM} run return 0',
    )
    claimed = f"execute if score @s sd.god_floor = {FLOOR}"
    mark = f"scoreboard players operation @s sd.god_floor = {FLOOR}"
    waiting = say("已选好神格，等队友领取。", "gray")
    mc("reward/god_begin",
       "scoreboard players set #phase sd.floor 4",
       f'execute unless data storage {RUN} {{floor:2}} run title {PARTY} title {{"text":"密林通关","color":"aqua"}}',
       f'execute if data storage {RUN} {{floor:2}} run title {PARTY} title {{"text":"试验层通关","color":"aqua"}}',
       f"function {FN}reward/god_tick")
    mc("reward/god_tick",
       f"execute unless entity {PARTY} run return 0",
       read_floor,
       "scoreboard players set #god_pending sd.floor 0",
       f"execute as {PARTY} at @s run function {FN}reward/god_check",
       f"execute if score #god_pending sd.floor matches 0 run function {FN}reward/god_finish")
    mc("reward/god_check",f"{claimed} run return 0",
       f"execute if entity {OWNED} run return run {mark}",
       "scoreboard players add #god_pending sd.floor 1",
       f"execute unless score @s sd.god_menu = {FLOOR} run function {FN}reward/god_show")
    mc("reward/god_show","execute unless score #phase sd.floor matches 4 run return 0",
       check_party,*check_dim,read_floor,
       f"{claimed} run return run {waiting}",
       f"execute if entity {OWNED} run return 0",
       f"scoreboard players operation @s sd.god_menu = {FLOOR}",
       say("选择一项神格", "light_purple"),
       *(f"execute unless entity @s[tag=sd.astro.{key}] run tellraw @s "+
          literal([button(name,code,"light_purple"),{"text":"  "+detail,"color":"gray"}])
         for code,key,name,detail,_ in GODS))
    mc("reward/god","execute unless score #phase sd.floor matches 4 run return 0",
       check_party,*check_dim,read_floor,f"{claimed} run return 0",
       *(f"execute if score #input sd.floor matches {code} unless entity @s[tag=sd.astro.{key}] run return run function {FN}reward/god_{code}"
         for code,key,*_ in GODS),
       f"function {FN}reward/god_show")
    for code,_,_,_,grant in GODS:
        mc(f"reward/god_{code}",mark,f"function {FN}{grant}",
           f"playsound minecraft:block.amethyst_block.chime player @s ~ ~ ~ 1 1.2",
           f"function {FN}reward/god_tick",
           f"execute if score #phase sd.floor matches 4 run {waiting}")
    mc("reward/god_finish",
       "scoreboard players set #phase sd.floor 5",
       f"function {FN}flow/open_choice",
       f"execute as {PARTY} at @s run function {FN}next/end_menu")
