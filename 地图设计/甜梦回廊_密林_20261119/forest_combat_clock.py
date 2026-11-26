"""Count weapon cooldown and automatic mana recovery in combat time."""

import json
from pathlib import Path
import re

from floor_upgrade import text, write


CLOCK = "sweetdream_floor:clock/"
NOW = "#sd_weapon_now manacore.math"
TICK = "#now manacore.meta"
PARTICIPANTS = "@s[tag=sd.floor_run,tag=zx.rg_active,scores={sd.floor_death=0},gamemode=!spectator]"
FLOORS = ("sweetdream:floor_1_forest", "sweetdream:floor_2_trial")
SKILL = re.compile(r'\bskill(?:\s*:\s*| set value )"([a-z0-9_.:/-]+)"')


def stage(world):
    packs = Path(world) / "datapacks"
    addon = packs / "zz_sweetdream_floor/data"
    home = addon / "sweetdream_floor/function"

    def mc(name, *rows):
        write(home / f"clock/{name}.mcfunction", "\n".join(rows))

    def edit(pack, namespace, name, old, new):
        rel = Path(namespace) / "function" / f"{name}.mcfunction"
        dest = addon / rel
        path = dest if dest.exists() else packs / pack / "data" / rel
        body = text(path)
        if new and new in body:
            return
        if body.count(old) != 1:
            raise ValueError(f"Expected one match in {path}: {old}")
        write(dest, body.replace(old, new))

    def floor(name, old, new):
        edit("zz_sweetdream_floor", "sweetdream_floor", name, old, new)

    def mana(name, old, new):
        edit("manacore-1.0.0", "manacore", name, old, new)

    def dream(name, old, new):
        edit("fallendream", "fallendream", name, old, new)

    equipment = packs / "fallendream/data/fallendream/function/equipment"
    skills = {}
    for kind in ("axe", "bow", "staff", "sword"):
        for path in (equipment / kind).rglob("*.mcfunction"):
            for skill in SKILL.findall(text(path)):
                skills[skill] = True
    if "fallendream:tidemark" not in skills:
        raise ValueError("Could not read the weapon skill IDs from the staged pack")
    catalog = json.dumps(dict(sorted(skills.items())), separators=(",", ":"))
    mc("load",
       f"data modify storage sweetdream_floor:clock weapons set value {catalog}",
       "scoreboard objectives add sd.mana_clock dummy",
       "scoreboard objectives add sd.well_clock dummy")

    # Training deliberately uses normal recovery so a player can repeat a test.
    mc("running",
       "execute if entity @s[tag=sd.training,gamemode=!spectator] if dimension sweetdream:training run return 1",
       f"execute unless score #phase sd.floor matches 2 run return 0",
       f"execute unless entity {PARTICIPANTS} run return 0",
       *(f"execute if dimension {dimension} run return 1" for dimension in FLOORS),
       "return 0")
    mc("seed",
       '$execute unless data storage manacore:players "$(uuid)".sd_weapon_clock store result storage manacore:players "$(uuid)".sd_weapon_clock int 1 run scoreboard players get #now manacore.meta')
    mc("cooldown_now",
       f"scoreboard players operation {NOW} = {TICK}",
       '$execute unless data storage sweetdream_floor:clock weapons."$(skill)" run return 0',
       f'$function {CLOCK}seed {{uuid:"$(uuid)"}}',
       f'$execute store result score {NOW} run data get storage manacore:players "$(uuid)".sd_weapon_clock')
    mc("advance",
       "function manacore:api/player/self_uuid",
       f'execute if data storage manacore:out r.uuid unless data storage manacore:out r{{uuid:""}} run function {CLOCK}advance_uuid with storage manacore:out r')
    mc("advance_uuid",
       f'$function {CLOCK}seed {{uuid:"$(uuid)"}}',
       f'$execute store result score {NOW} run data get storage manacore:players "$(uuid)".sd_weapon_clock',
       f"scoreboard players add {NOW} 1",
       f'$execute store result storage manacore:players "$(uuid)".sd_weapon_clock int 1 run scoreboard players get {NOW}',
       "scoreboard players add @s sd.mana_clock 1",
       f'$execute if score @s sd.mana_clock >= #interval manacore.meta run function {CLOCK}regen {{uuid:"$(uuid)"}}',
       "execute if entity @s[tag=sd.event_well] run scoreboard players add @s sd.well_clock 1",
       f"execute if entity @s[tag=sd.event_well,scores={{sd.well_clock=60..}}] run function {CLOCK}well")
    mc("regen",
       "scoreboard players set @s sd.mana_clock 0",
       '$data modify storage manacore:work entry set value {uuid:"$(uuid)"}',
       "function manacore:internal/mana/regen_driver")
    mc("well",
       "scoreboard players set @s sd.well_clock 0",
       "function sweetdream_floor:run/mana {value:1.0}")

    # Keep formation ticking on ManaCore's original timer. Weapon records
    # already in the save stay valid because the new clock starts at #now.
    load = home / "load.mcfunction"
    line = f"function {CLOCK}load"
    if line not in text(load):
        write(load, text(load).rstrip("\n") + "\n" + line)
    mana("core/tick", "scoreboard players add #now manacore.meta 1",
         f"scoreboard players add {TICK} 1\nexecute as @a at @s if function {CLOCK}running run function {CLOCK}advance")
    mana("internal/player/second_macro",
         "function manacore:internal/mana/regen_driver with storage manacore:work entry",
         f"$function {CLOCK}seed {{uuid:\"$(uuid)\"}}")
    mana("internal/cooldown/start_go", f"scoreboard players operation #dur manacore.math += {TICK}",
         f"$function {CLOCK}cooldown_now {{uuid:\"$(uuid)\",skill:\"$(skill)\"}}\n"
         f"scoreboard players operation #dur manacore.math += {NOW}")
    mana("internal/cooldown/start_go", f".start int 1 run scoreboard players get {TICK}",
         f".start int 1 run scoreboard players get {NOW}")
    mana("internal/cooldown/check_has", f"scoreboard players operation #rem manacore.math -= {TICK}",
         f"$function {CLOCK}cooldown_now {{uuid:\"$(uuid)\",skill:\"$(skill)\"}}\n"
         f"scoreboard players operation #rem manacore.math -= {NOW}")
    dream("equipment/tool/look/cooldown_get", f"scoreboard players operation #v_cdn zx.meta -= {TICK}",
          f"$function {CLOCK}cooldown_now {{uuid:\"$(uuid)\",skill:\"$(skill)\"}}\n"
          f"scoreboard players operation #v_cdn zx.meta -= {NOW}")
    floor("room/event/second", "execute if entity @s[tag=sd.event_well] run function sweetdream_floor:run/mana {value:1.0}",
          "# Echo Well recovery is settled by the combat clock.")
    floor("room/event/reset", "scoreboard players set @s sd.event_time 0",
          "scoreboard players set @s sd.event_time 0\nscoreboard players set @s sd.well_clock 0")

    # Keep stat calculation and active refunds. Skip only the periodic
    # reductions and the effects which compensate for time already elapsed.
    cd_stat = "execute unless score #cdr zx.meta = @s zx.cdr run function fallendream:upgrade/api/cd_stat"
    dream("upgrade/api/cd_tick", cd_stat,
          cd_stat + f"\nexecute at @s unless function {CLOCK}running run return 0")
    gate = f"execute at @s unless function {CLOCK}running run return 0"

    def prepend(path):
        rel = Path("fallendream/function") / f"{path}.mcfunction"
        dest = addon / rel
        body = text(dest if dest.exists() else packs / "fallendream/data" / rel)
        if gate not in body:
            write(dest, gate + "\n" + body)

    prepend("equipment/axe/charge/freeze_cd")
    crescent = "equipment/sword/crescent/freeze_tick"
    rel = Path("fallendream/function") / f"{crescent}.mcfunction"
    dest = addon / rel
    body = text(dest if dest.exists() else packs / "fallendream/data" / rel)
    compensate = "run function manacore:api/cooldown/increase"
    guarded = f"run function {CLOCK}compensate with storage manacore:in arg"
    if guarded not in body:
        write(dest, body.replace(compensate, guarded))
    mc("compensate",
       '$execute unless data storage sweetdream_floor:clock weapons."$(skill)" run return run function manacore:api/cooldown/increase',
       f"execute at @s if function {CLOCK}running run function manacore:api/cooldown/increase")

    # Several armor passives grant mana directly. Keep their other effects
    # and keep one-off refunds functional while disabling timed mana payouts.
    for name in ("breath_hold/regen", "bright_candle/regen", "dionysus_helmet/regen", "dusk_dawn/low_mana",
                 "furnace_core/regen", "lethe_shore/regen", "intravenous_pump/regen_mana",
                 "intravenous_pump/ol_regen", "stellar_elegy/regen",
                 "resonance/mana8"):
        prepend(f"equipment/armor/{name}")
    dream("equipment/armor/fade/passive", "scoreboard players remove @s zx.fd_t 1",
          gate + "\nscoreboard players remove @s zx.fd_t 1")
    mana_add = "function manacore:api/mana/add"
    for name in ("empty_camp", "light_pillow"):
        dream(f"equipment/armor/{name}/second", mana_add,
              f"execute at @s if function {CLOCK}running run {mana_add}")
    glimmer_balance = "scoreboard players operation @s zx.regen_milli += #gl_m zx.meta"
    dream("equipment/armor/glimmer/regen", f"{mana_add}\n{glimmer_balance}",
          f"execute at @s if function {CLOCK}running run {mana_add}\n"
          f"execute at @s if function {CLOCK}running run {glimmer_balance}")
    return len(skills)
