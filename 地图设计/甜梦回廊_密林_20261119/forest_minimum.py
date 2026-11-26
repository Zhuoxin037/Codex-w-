"""Guarantee one point for admitted Forest enemy hits after mitigation."""

import json
from pathlib import Path

from floor_upgrade import edit, text, write
from forest_balance import impact_on_hit
from forest_economy import FN, RUN, literal

NAMESPACE="sweetdream_floor"
CORRECTION=f"{NAMESPACE}:mob_floor_adjustment"
FLOOR_TYPES=f"{NAMESPACE}:enemy_hits"
PRIVATE=f"{NAMESPACE}:enemy_floor_adjustments"
PLAYER=[{"condition":"minecraft:entity_properties","entity":"this","predicate":{"nbt":'{Tags:["sd.floor_run"]}'}}]
STATS={"taken":"sd.min_taken","absorbed":"sd.min_absorb"}
PULSE_EFFECTS=("unluck", "luck", "hero_of_the_village")


def stage(world):
    root=Path(world)/"datapacks"
    abode=root/"zz_sweetdream_floor/data"
    verify_root=abode/NAMESPACE
    functions=verify_root/"function"
    sweep=functions/"combat/mobs/sweep_hit.mcfunction"
    if "run damage @s 5 minecraft:mob_attack" in text(sweep):
        write(sweep,impact_on_hit(text(sweep),"sweep_hit"))

    def mc(name,*rows):
        write(functions/f"{name}.mcfunction","\n".join(rows))

    def js(path,data):
        write(abode/path,literal(data))

    def add_filter(damage,key,nature):
        tags=damage.setdefault("type",{}).setdefault("tags",[])
        if not any(tag["id"]==key for tag in tags):
            tags.append({"id":key,"expected":nature})

    js(f"{NAMESPACE}/tags/damage_type/enemy_hits.json",{"values":[
        "minecraft:mob_attack","minecraft:mob_attack_no_aggro","minecraft:mob_projectile",
        "minecraft:sting","minecraft:sonic_boom","sweetdream_floor:forest_impact","fallendream:knight_blade",
    ]})
    js(f"{NAMESPACE}/damage_type/mob_floor_adjustment.json",{"message_id":"mob","scaling":"never","exhaustion":0.0})
    js(f"{NAMESPACE}/tags/damage_type/enemy_floor_adjustments.json",{"values":[CORRECTION]})
    for key in ("bypasses_armor","bypasses_cooldown","bypasses_effects","bypasses_enchantments","bypasses_shield","no_knockback"):
        path=f"minecraft/tags/damage_type/{key}.json"
        tag=json.loads(text(abode/path)) if (abode/path).exists() else {"replace":False,"values":[]}
        if CORRECTION not in tag["values"]:
            tag["values"].append(CORRECTION)
        js(path,tag)

    # Mutually exclusive listeners avoid depending on the ordering of
    # advancement rewards for a single hit.
    for kind,damage in (
        ("enemy",{"taken":{"min":0.000001},"blocked":False,"type":{"tags":[{"id":FLOOR_TYPES,"expected":True}]}}),
        ("other",{"type":{"tags":[{"id":FLOOR_TYPES,"expected":False},{"id":PRIVATE,"expected":False}]}}),
        ("blocked",{"blocked":True,"type":{"tags":[{"id":FLOOR_TYPES,"expected":True}]}}),
    ):
        js(f"{NAMESPACE}/advancement/mob_minimum/{kind}.json",{
            "criteria":{"hit":{"trigger":"minecraft:entity_hurt_player","conditions":{"player":PLAYER,"damage":damage}}},
            "rewards":{"function":f"{FN}mob_minimum/on_{kind}"},
        })
        mc(f"mob_minimum/on_{kind}",f"advancement revoke @s only {FN}mob_minimum/{kind}",
           f"function {FN}mob_minimum/{'resolve' if kind=='enemy' else 'observe'}")

    # Actual health plus absorption supplies millihitpoint accuracy. Fall
    # back to vanilla's rounded statistics if another effect healed or gave
    # absorption between samples.
    mc("mob_minimum/sample",
       "execute store result score #mh_health sd.floor run data get entity @s Health 1000",
       "execute store result score #mh_gold sd.floor run data get entity @s AbsorptionAmount 1000",
       "scoreboard players operation #mh_total sd.floor = #mh_health sd.floor",
       "scoreboard players operation #mh_total sd.floor += #mh_gold sd.floor",
       f"scoreboard players add @s {STATS['taken']} 0",
       f"scoreboard players add @s {STATS['absorbed']} 0",
       f"scoreboard players operation #mh_stat sd.floor = @s {STATS['taken']}",
       f"scoreboard players operation #mh_stat sd.floor += @s {STATS['absorbed']}")
    mc("mob_minimum/save",
       "scoreboard players operation @s sd.min_hp = #mh_total sd.floor",
       "scoreboard players operation @s sd.min_stat = #mh_stat sd.floor")
    mc("mob_minimum/observe", f"function {FN}mob_minimum/sample", f"function {FN}mob_minimum/save")
    mc("mob_minimum/resolve",
       f"execute unless score @s sd.min_stat matches 0.. run return run function {FN}mob_minimum/observe",
       f"function {FN}mob_minimum/sample",
       "scoreboard players operation #mh_rounded sd.floor = #mh_stat sd.floor",
       "scoreboard players operation #mh_rounded sd.floor -= @s sd.min_stat",
       "scoreboard players set #mh_x100 sd.floor 100",
       "scoreboard players operation #mh_rounded sd.floor *= #mh_x100 sd.floor",
       "scoreboard players operation #mh_exact sd.floor = @s sd.min_hp",
       "scoreboard players operation #mh_exact sd.floor -= #mh_total sd.floor",
       "scoreboard players operation #mh_error sd.floor = #mh_exact sd.floor",
       "scoreboard players operation #mh_error sd.floor -= #mh_rounded sd.floor",
       "scoreboard players operation #mh_actual sd.floor = #mh_rounded sd.floor",
       # Two statistic deltas can each have up to half a tenth of rounding.
       "scoreboard players remove #mh_actual sd.floor 100",
       "execute if score #mh_error sd.floor matches -100..100 run scoreboard players operation #mh_actual sd.floor = #mh_exact sd.floor",
       f"function {FN}mob_minimum/save",
       "execute if score #mh_health sd.floor matches ..0 run return 0",
       "execute if score #mh_actual sd.floor matches ..-1 run scoreboard players set #mh_actual sd.floor 0",
       "execute if score #mh_actual sd.floor matches 1000.. run return 0",
       "scoreboard players set #mh_short sd.floor 1000",
       "scoreboard players operation #mh_short sd.floor -= #mh_actual sd.floor",
       "scoreboard players add @s sd.min_due 0",
       "scoreboard players operation @s sd.min_due += #mh_short sd.floor")
    mc("mob_minimum/tick",
       f"execute if entity @s[scores={{sd.floor_death=1..}}] run return run function {FN}mob_minimum/reset",
       f"execute if score @s sd.min_due matches 1.. run function {FN}mob_minimum/flush",
       f"function {FN}mob_minimum/observe")
    mc("mob_minimum/flush",
       f"function {FN}mob_minimum/sample",
       "scoreboard players operation #mh_target_gold sd.floor = #mh_gold sd.floor",
       "scoreboard players operation #mh_target_gold sd.floor -= @s sd.min_due",
       "scoreboard players operation #mh_target_hp sd.floor = #mh_health sd.floor",
       "execute if score #mh_target_gold sd.floor matches ..-1 run scoreboard players operation #mh_target_hp sd.floor += #mh_target_gold sd.floor",
       # Max health cannot be set below one. In that final sliver, use a
       # proper damage source so vanilla can handle death and totems.
       f"execute if score #mh_target_hp sd.floor < #mh_health sd.floor if score #mh_target_hp sd.floor matches ..999 run return run function {FN}mob_minimum/finish",
       "execute if score #mh_target_gold sd.floor matches ..-1 run scoreboard players set #mh_target_gold sd.floor 0",
       *[f'execute unless data entity @s active_effects[{{id:"minecraft:{effect}"}}] run return run function {FN}mob_minimum/clamp {{effect:"minecraft:{effect}"}}' for effect in PULSE_EFFECTS],
       f"function {FN}mob_minimum/finish")
    mc("mob_minimum/clamp",
       "scoreboard players set @s sd.min_due 0",
       f'execute if score #mh_target_gold sd.floor < #mh_gold sd.floor run function {FN}mob_minimum/clamp_attribute {{attribute:"max_absorption",target:"#mh_target_gold"}}',
       f'execute if score #mh_target_hp sd.floor < #mh_health sd.floor run function {FN}mob_minimum/clamp_attribute {{attribute:"max_health",target:"#mh_target_hp"}}',
       # Removing an unused effect refreshes dirty attributes immediately.
       # Restore both attributes in this function, with no second hit or
       # temporary maximum surviving into another entity's tick.
       "$effect give @s $(effect) 1 0 true",
       "$effect clear @s $(effect)",
       f"execute if score #mh_target_gold sd.floor < #mh_gold sd.floor run attribute @s minecraft:max_absorption modifier remove {NAMESPACE}:enemy_floor",
       f"execute if score #mh_target_hp sd.floor < #mh_health sd.floor run attribute @s minecraft:max_health modifier remove {NAMESPACE}:enemy_floor")
    mc("mob_minimum/clamp_attribute",
       "$execute store result score #mh_cap sd.floor run attribute @s minecraft:$(attribute) get 1000",
       "execute unless score #mh_cap sd.floor matches 1.. run return 0",
       "scoreboard players set #mh_base sd.floor 1000",
       "$scoreboard players operation #mh_remainder sd.floor = $(target) sd.floor",
       "scoreboard players operation #mh_remainder sd.floor -= #mh_cap sd.floor",
       "scoreboard players operation #mh_remainder sd.floor *= #mh_base sd.floor",
       "scoreboard players operation #mh_factor sd.floor = #mh_remainder sd.floor",
       "scoreboard players operation #mh_factor sd.floor /= #mh_cap sd.floor",
       "scoreboard players operation #mh_remainder sd.floor %= #mh_cap sd.floor",
       "scoreboard players operation #mh_remainder sd.floor *= #mh_base sd.floor",
       "scoreboard players operation #mh_remainder sd.floor /= #mh_cap sd.floor",
       "scoreboard players operation #mh_factor sd.floor *= #mh_base sd.floor",
       "scoreboard players operation #mh_factor sd.floor += #mh_remainder sd.floor",
       f"execute store result storage {RUN} minimum.factor double 0.000001 run scoreboard players get #mh_factor sd.floor",
       f'$data modify storage {RUN} minimum.attribute set value "$(attribute)"',
       f"function {FN}mob_minimum/apply_attribute with storage {RUN} minimum")
    mc("mob_minimum/apply_attribute",f"$attribute @s minecraft:$(attribute) modifier add {NAMESPACE}:enemy_floor $(factor) add_multiplied_total")
    mc("mob_minimum/finish",
       f"execute store result storage {RUN} minimum.value double 0.001 run scoreboard players get @s sd.min_due",
       "scoreboard players set @s sd.min_due 0",
       f"function {FN}mob_minimum/deal with storage {RUN} minimum",
       f"function {FN}mob_minimum/observe",
       # The private damage is counted by vanilla. Advance the item pack's
       # common baseline so the next real hit cannot claim it twice.
       "execute if score @s zx.hurt_total matches 0.. run scoreboard players operation @s zx.hurt_seen = @s zx.hurt_total",
       "execute if score @s zx.hp_snap matches 0.. run scoreboard players operation @s zx.hp_snap = #mh_health sd.floor")
    mc("mob_minimum/deal",f"$damage @s $(value) {CORRECTION}")
    mc("mob_minimum/reset",*(f"scoreboard players reset @s {key}" for key in ("sd.min_due","sd.min_hp","sd.min_stat")))
    path=functions/"load.mcfunction"
    if "sd.min_due" not in text(path):
        write(path,text(path)+"\n".join([
            *(f"scoreboard objectives add {obj} dummy" for obj in ("sd.min_due","sd.min_hp","sd.min_stat")),
            *(f"scoreboard objectives add {obj} minecraft.custom:minecraft.damage_{part}" for part,obj in STATS.items()),
        ]))
    path=functions/"run/player_tick.mcfunction"
    call=f"function {FN}mob_minimum/tick"
    if call not in text(path):
        anchor=f"function {FN}room/event/tick"
        edit(path,(anchor,call+"\n"+anchor))
    for name in ("run/exit","run/stale","run/join_party","next/leave_first"):
        path=functions/f"{name}.mcfunction"
        call=f"function {FN}mob_minimum/reset"
        if call not in text(path):
            write(path,call+"\n"+text(path))

    protect_reactions(root,abode,add_filter)


def protect_reactions(packs,addon,add_filter):
    """A bookkeeping correction must not retrigger gear or event reactions."""
    main=packs/"fallendream/data/fallendream/advancement"
    for src,dest in ((main,addon/"fallendream/advancement"),
                     (addon/"sweetdream_floor/advancement",addon/"sweetdream_floor/advancement")):
        for path in src.rglob("*.json"):
            rel=path.relative_to(src)
            if rel.parts[0]=="mob_minimum":
                continue
            raw=text(path)
            if "entity_hurt_player" not in raw:
                continue
            value=json.loads(raw)
            for item in value.get("criteria",{}).values():
                if item["trigger"].removeprefix("minecraft:")=="entity_hurt_player":
                    add_filter(item.setdefault("conditions",{}).setdefault("damage",{}),PRIVATE,False)
            write(dest/rel,literal(value))
