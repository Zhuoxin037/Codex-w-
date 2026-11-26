"""Run-only talents for the Forest map and its later floors."""

import json
from pathlib import Path

from floor_upgrade import text, write
from forest_combat_clock import SKILL
from forest_economy import FN, RUN, button, literal, say


ASTRO = FN + "astrology/"
STATE = "sweetdream_floor:talent"
RANKS = ("人格", "凡格", "神格")
COLORS = ("white", "aqua", "light_purple")
TALENTS = (
    (("return_mana", "余息", "消耗生物身上的状态时，返还 8 魔力。"),
     ("herb", "余药", "普通、精英战后额外恢复 4 点生命。"),
     ("scout", "拾荒眼", "精英战后，全队额外获得 1 梦屑。"),
     ("attack", "锋骨", "本局基础攻击力 +1。"),
     ("health", "韧生", "本局生命上限 +2。")),
    (("twice", "分枝", "获得 2 个随机人格。"),
     ("recover", "续生", "受到伤害后恢复 1 点生命。"),
     ("cut", "削时", "消耗生物身上的状态时，主手武器的技能冷却减少 3 秒。"),
     ("shield", "盈生", "恢复生命时，额外获得 1 点吸收生命。冷却 3 秒。")),
    (("rewind", "回刻", "每场战斗结束，全部武器的技能冷却减少 30 秒。"),
     ("heart", "林心", "本局生命上限 +30%。"),
     ("starlight", "摘星", "普通、精英战后的装备抽取若抽中常器或异器，重抽一次。"),
     ("mana", "识海", "本局魔力值上限 +30%。")),
)
IDS = {key: rank * 10 + index + 10 for rank, group in enumerate(TALENTS)
       for index, (key, _, _) in enumerate(group)}
PARTY = "@a[tag=sd.floor_run,tag=zx.rg_active,distance=0..,scores={sd.floor_death=0}]"
ACTIVE = "@s[tag=sd.floor_run,tag=zx.rg_active,scores={sd.floor_death=0},gamemode=!spectator]"
NOW = "#now manacore.meta"
RETIRED = ("astrology/grant_rewind", "astrology/rewind", "astrology/rewind_go",
           *(f"astrology/grant_{i}" for i in range(1, 6)))


def stage(world):
    packs = Path(world) / "datapacks"
    data = packs / "zz_sweetdream_floor/data"
    root = data / "sweetdream_floor/function"

    def mc(name, *lines):
        write(root / f"{name}.mcfunction", "\n".join(lines))

    def change(name, update):
        path = root / f"{name}.mcfunction"
        write(path, update(text(path)))

    def append(name, line):
        change(name, lambda body: body if line in body.splitlines() else body + line)

    for name in RETIRED:
        (root / f"{name}.mcfunction").unlink(missing_ok=True)

    catalog(root, mc, change)
    effects(data, packs, mc, change, append)
    caps(mc, change)


def catalog(root, mc, change):
    def unowned(key):
        return f"unless entity @s[tag=sd.astro.{key}]"

    def add_to_pool(key, weight, condition=""):
        return (f"execute {unowned(key)}{condition} run data modify storage {RUN} astro_pool append "
                f"value {{id:{IDS[key]},weight:{weight}}}")

    openings = {
        "twice": (f"function {ASTRO}personal_pick", f"function {ASTRO}personal_pick"),
        "attack": ("attribute @s minecraft:attack_damage modifier add sweetdream_floor:talent_attack 1 add_value",
                   f"function {ASTRO}attack_stat {{value:1}}"),
        "health": ("attribute @s minecraft:max_health modifier add sweetdream_floor:talent_health 2 add_value",
                   f"function {ASTRO}cap_sync"),
        "heart": ("attribute @s minecraft:max_health modifier add sweetdream_floor:talent_heart 0.3 add_multiplied_total",
                  f"function {ASTRO}cap_sync"),
        "mana": (f"function {ASTRO}cap_sync",),
        "shield": (f"function {ASTRO}remember_health",),
    }
    show = []
    for rank, group in enumerate(TALENTS):
        for key, name, detail in group:
            line = say(f"{RANKS[rank]} · {name}  {detail}", COLORS[rank])
            mc(f"astrology/grant_{IDS[key]}",
               f"execute if entity @s[tag=sd.astro.{key}] run return 0",
               f"tag @s add sd.astro.{key}", line, *openings.get(key, ()))
            show.append(f"execute if entity @s[tag=sd.astro.{key}] run {line}")
    mc("astrology/list", *show)

    pool = [add_to_pool(key, weight, " if score #personal_left sd.floor matches 2.." if key == "twice" else "")
            for group, weight in zip(TALENTS, (280, 125, 25))
            for key, _, _ in group]
    change("astrology/claim", lambda body: "\n".join(
        line for line in body.splitlines() if "astro_pool append" not in line and f"{ASTRO}personal_count" not in line
    ).replace(f"data modify storage {RUN} astro_pool set value []",
              f"function {ASTRO}personal_count\ndata modify storage {RUN} astro_pool set value []\n" + "\n".join(pool)))
    mc("astrology/personal_count", "scoreboard players set #personal_left sd.floor 0",
       *(f"execute {unowned(key)} run scoreboard players add #personal_left sd.floor 1" for key, _, _ in TALENTS[0]))
    mc("astrology/personal_pick", f"data modify storage {RUN} astro_pool set value []",
       *(add_to_pool(key, 1) for key, _, _ in TALENTS[0]),
       f"execute unless data storage {RUN} astro_pool[0] run return 0",
       f"execute store result storage {RUN} draw.total int 1 run data get storage {RUN} astro_pool",
       f"function {FN}reward/random_quality with storage {RUN} draw",
       f"function {ASTRO}pick with storage {RUN} astro_pool[0]")

    roster = "@s[" + ",".join(f"tag=!sd.astro.{key}" for key in IDS) + "]"
    change("room/status", lambda body: "\n".join(
        f"execute unless entity {roster} run tellraw @s " + literal(button("本局天赋", 114, "light_purple"))
        if "[本局天赋]" in line else line for line in body.splitlines()))
    mc("astrology/reset", *(f"scoreboard players reset @s {obj}" for obj in
                            ("sd.astro_floor", "sd.god_floor", "sd.god_menu", "sd.astro_last", "sd.astro_cd")),
       "execute if entity @s[tag=sd.astro.attack] run attribute @s minecraft:attack_damage modifier remove sweetdream_floor:talent_attack",
       f"execute if entity @s[tag=sd.astro.attack] run function {ASTRO}attack_stat {{value:-1}}",
       *(f"execute if entity @s[tag=sd.astro.{key}] run attribute @s minecraft:max_health modifier remove sweetdream_floor:talent_{key}"
         for key in ("health", "heart")),
       "execute if entity @s[tag=sd.astro.heart] run attribute @s minecraft:max_health modifier remove sweetdream_floor:astro_heart",
       "execute if entity @s[tag=sd.talent_shield_added,tag=zx.thp_on] run function fallendream:lib/thp/clear",
       "tag @s remove sd.talent_shield_added",
       *(f"tag @s remove sd.astro.{key}" for key in (*IDS, "echo", "reprise")),
       f"execute if score @s sd.astro_mana matches 1.. run function {ASTRO}mana_cap",
       f"execute if score @s sd.astro_hp matches 1.. run function {ASTRO}health_stat",
       "scoreboard players reset @s sd.astro_mana", "scoreboard players reset @s sd.astro_hp")

    # The floor boss already owns the per-player selection and transition.
    rewind, heart, starlight, mana = TALENTS[2]
    gods = (starlight, heart, rewind, mana)
    guards = "@s[" + ",".join(f"tag=sd.astro.{key}" for key, _, _ in gods) + "]"
    for check in ("god_check", "god_show"):
        change(f"reward/{check}", lambda body: "\n".join(
            f"execute if entity {guards} run " + line.split(" run ", 1)[1]
            if line.startswith("execute if entity @s[tag=sd.astro.") else line
            for line in body.splitlines()))
    change("reward/god_show", lambda body: "\n".join(
        [line for line in body.splitlines() if "click_event" not in line] + [
            f"execute {unowned(key)} run tellraw @s " + literal([
                button(name, 40 + n, "light_purple"), {"text": "  " + detail, "color": "gray"}])
            for n, (key, name, detail) in enumerate(gods)]))
    change("reward/god", lambda body: "\n".join(
        [line for line in body.splitlines() if "#input" not in line and not line.startswith(f"function {FN}reward/god_show")]
        + [f"execute if score #input sd.floor matches {40 + n} {unowned(key)} run return run function {FN}reward/god_{40 + n}"
           for n, (key, _, _) in enumerate(gods)] + [f"function {FN}reward/god_show"]))
    old = text(root / "reward/god_40.mcfunction").splitlines()
    for n, (key, _, _) in enumerate(gods):
        mc(f"reward/god_{40 + n}", *(f"function {ASTRO}grant_{IDS[key]}" if "astrology/grant" in line else line for line in old))
    change("run/route", lambda body: body.replace("matches 40..42 if score #phase sd.floor matches 4",
                                                   "matches 40..43 if score #phase sd.floor matches 4"))


def effects(data, packs, mc, change, append):
    for objective in ("sd.astro_last", "sd.astro_cd", "sd.astro_mana", "sd.astro_hp"):
        append("load", f"scoreboard objectives add {objective} dummy")

    end = f"execute as {PARTY} at @s run function {ASTRO}battle_end"
    source = f"function {ASTRO}battle_source"
    shared = PARTY.replace("tag=sd.floor_run", "tag=sd.astro.scout,tag=sd.floor_run")
    change("combat/win", lambda body: "\n".join(
        line for line in body.splitlines() if not any(old in line for old in (
            "sd.floor_win_source", "sd.astro.scout", "sd.astro.herb", "sd.astro.reprise", f"{ASTRO}rewind", end, source,
        ))
    ).replace(f"data remove storage {RUN} encounter", "\n".join((
        f"data remove storage {RUN} encounter",
        "tag @s add sd.floor_win_source", end, "tag @s remove sd.floor_win_source",
        f'execute if data storage {RUN} current{{kind:"elite"}} if entity {shared} run scoreboard players add #lumen sd.floor 1',
    ))).replace("\n\nplaysound", "\nplaysound").replace(
        f"function {FN}reward/battle_offer", f"{source}\nfunction {FN}reward/battle_offer"))
    # A normal victory already heals the player who drove room settlement by four.
    # Keep that bonus and combine it with the talent on that player only.
    mc("astrology/battle_source",
       *(f'execute if data storage {RUN} current{{kind:"{kind}"}} if entity @s[tag=sd.astro.herb] '
         "run return run effect give @s minecraft:instant_health 1 1 true" for kind in ("combat", "elite")),
       "effect give @s minecraft:instant_health 1 0 true")
    mc("astrology/battle_end",
       f"execute if entity @s[tag=sd.astro.rewind] run function {ASTRO}rewind_all",
       *(f'execute if data storage {RUN} current{{kind:"{kind}"}} if entity @s[tag=sd.astro.herb,tag=!sd.floor_win_source] '
         "run effect give @s minecraft:instant_health 1 0 true" for kind in ("combat", "elite")))
    reroll = f"execute if entity @s[tag=sd.astro.starlight] if score #quality_total sd.floor matches 1.. run function {ASTRO}reroll"
    change("reward/category", lambda body: "\n".join(
        line for line in body.splitlines() if "tag=sd.astro.starlight" not in line
    ).replace(f'{{draw_source:"elite"}} run function {FN}reward/roll_elite',
              f'{{draw_source:"elite"}} run function {FN}reward/roll_elite\n{reroll}'))
    mc("astrology/reroll", f"execute store result score #astro_tier sd.floor run data get storage {RUN} exact_tier",
       "execute unless score #astro_tier sd.floor matches 1..2 run return 0",
       *(f'execute if data storage {RUN} {{draw_source:"{kind}"}} run return run function {FN}reward/roll_{kind}'
         for kind in ("normal", "elite")))

    # Count the original living targets while their original selector still matches.
    rel = Path("fallendream/function/lib/mark_take.mcfunction")
    override = data / rel
    upstream = packs / "fallendream/data" / rel
    body = text(override if override.exists() else upstream)
    body = "\n".join(line for line in body.splitlines() if f"run function {ASTRO}consume with storage" not in line)
    marker = next(line for line in body.splitlines() if "run function fallendream:tag/unmark " in line)
    count = f"execute unless data storage zx:work mc{{done:1b}} run function {ASTRO}consume with storage zx:work mc"
    write(override, body.replace(marker, count + "\n" + marker, 1))
    mc("astrology/consume",
       "scoreboard players set #talent_consumer sd.floor 0",
       *(f"$execute as $(by) if entity {ACTIVE} if entity @s[tag=sd.astro.{key}] run scoreboard players set #talent_consumer sd.floor 1"
         for key in ("return_mana", "cut")),
       "execute unless score #talent_consumer sd.floor matches 1 run return 0",
       "scoreboard players set #talent_eaten sd.floor 0",
       '$execute as $(target) if entity @s[type=#fallendream:living,tag=zx.status.$(mark)] '
       'unless entity @s[type=minecraft:player] unless data entity @s {Health:0.0f} run scoreboard players add #talent_eaten sd.floor 1',
       f"$execute if score #talent_eaten sd.floor matches 1.. as $(by) at @s if entity {ACTIVE} run function {ASTRO}consume_apply")
    mc("astrology/consume_apply",
       f"execute if entity @s[tag=sd.astro.return_mana] run function {ASTRO}consume_mana",
       f"execute if entity @s[tag=sd.astro.cut] run function {ASTRO}consume_cooldown")
    mc("astrology/consume_mana", "scoreboard players set #talent_factor sd.floor 8",
       "scoreboard players operation #talent_factor sd.floor *= #talent_eaten sd.floor",
       f"execute store result storage {STATE} mana.value double 1 run scoreboard players get #talent_factor sd.floor",
       f"function {FN}run/mana with storage {STATE} mana")
    mc("astrology/consume_cooldown", f"data remove storage {STATE} cd.skill",
       f'data modify storage {STATE} cd.skill set from entity @s SelectedItem.components."minecraft:custom_data".skill',
       f"execute unless data storage {STATE} cd.skill run return 0",
       "scoreboard players set #talent_factor sd.floor 60",
       "scoreboard players operation #talent_factor sd.floor *= #talent_eaten sd.floor",
       f"execute store result storage {STATE} cd.ticks int 1 run scoreboard players get #talent_factor sd.floor",
       "function fallendream:lib/uuid", "execute unless data storage zx:data self{ok:1b} run return 0",
       f"data modify storage {STATE} cd.uuid set from storage zx:data self.uuid",
       f"function {ASTRO}reduce_one with storage {STATE} cd")
    mc("astrology/reduce_one",
       '$execute unless data storage sweetdream_floor:clock weapons."$(skill)" run return 0',
       '$execute unless data storage manacore:players "$(uuid)".cooldowns."$(skill)".end run return 0',
       '$data modify storage manacore:in arg set value {uuid:"$(uuid)",skill:"$(skill)",ticks:$(ticks)}',
       "function manacore:api/cooldown/reduce")
    # Read the item's real active skill. Weapon internals also use the clock,
    # but their attack delays and passive timers are not active skill cooldowns.
    equipment = packs / "fallendream/data/fallendream/function/equipment"
    skills = sorted({skill for kind in ("axe", "bow", "staff", "sword")
                     for item in (equipment / kind).rglob("give*.mcfunction")
                     for line in text(item).splitlines() if line.lstrip("$").startswith("give @s ")
                     for skill in SKILL.findall(line)})
    if "fallendream:tidemark" not in skills:
        raise ValueError("Could not read active weapon skills from the staged pack")
    mc("astrology/rewind_all", "function fallendream:lib/uuid",
       f"execute if data storage zx:data self{{ok:1b}} run function {ASTRO}rewind_owned with storage zx:data self")
    mc("astrology/rewind_owned",
       *(f'$execute if data storage manacore:players "$(uuid)".cooldowns."{skill}".end run function {ASTRO}reduce_one '
         f'{{uuid:"$(uuid)",skill:"{skill}",ticks:600}}' for skill in skills))
    write(data / "sweetdream_floor/advancement/talent/hurt.json", json.dumps({
        "criteria": {"hurt": {"trigger": "minecraft:entity_hurt_player", "conditions": {
            "player": [{"condition": "minecraft:entity_properties", "entity": "this",
                        "predicate": {"nbt": '{Tags:["sd.floor_run"]}'}}],
            "damage": {"taken": {"min": 0.000001}, "blocked": False,
                       "type": {"tags": [{"id": "sweetdream_floor:enemy_floor_adjustments", "expected": False}]}},
        }}}, "rewards": {"function": ASTRO + "on_hurt"},
    }, indent=2))
    life(mc, change)


def life(mc, change):
    sample = "execute store result score #talent_hp sd.floor run data get entity @s Health 1000"
    mc("astrology/on_hurt", "advancement revoke @s only sweetdream_floor:talent/hurt",
       f"execute unless entity {ACTIVE} run return 0",
       "execute if data entity @s {Health:0.0f} run return 0",
       f"execute if entity @s[tag=sd.astro.shield] run function {ASTRO}remember_health",
       f"execute if entity @s[tag=sd.astro.recover,tag=!zx.nr_active] run function {ASTRO}heal_one")
    mc("astrology/remember_health", sample,
       "scoreboard players operation @s sd.astro_last = #talent_hp sd.floor")
    tick = f"execute if entity @s[tag=sd.astro.shield] run function {ASTRO}healing_tick"
    change("room/event/tick", lambda body: body if tick in body.splitlines() else tick + "\n" + body)
    mc("astrology/healing_tick", sample,
       f"execute if score #talent_hp sd.floor > @s sd.astro_last unless score @s sd.astro_cd > {NOW} run function {ASTRO}shield",
       "scoreboard players operation @s sd.astro_last = #talent_hp sd.floor")
    mc("astrology/shield", f"scoreboard players operation @s sd.astro_cd = {NOW}",
       "scoreboard players add @s sd.astro_cd 60",
       "scoreboard players set #thp_v zx.meta 0",
       "execute store result score #thp_v zx.meta run data get entity @s AbsorptionAmount",
       "scoreboard players add #thp_v zx.meta 1",
       "function fallendream:lib/thp/set", "tag @s add sd.talent_shield_added")

    # Apply the exact heal through the pack's temporarily clamped heal path.
    # Multiplying the final cap makes this compatible with Linxin and black market caps.
    cap = "execute store result score #talent_max sd.floor run attribute @s minecraft:max_health get 1000"
    mc("astrology/heal_one", sample, cap,
       "execute if entity @s[tag=zx.heal_p] run scoreboard players operation #talent_hp sd.floor > #talent_max sd.floor",
       "execute if entity @s[tag=zx.heal_on] run scoreboard players operation #talent_hp sd.floor > #talent_max sd.floor",
       "execute if entity @s[tag=zx.heal_p] run attribute @s minecraft:max_health modifier remove fallendream:heal_cap",
       "execute if entity @s[tag=zx.heal_on] run attribute @s minecraft:max_health modifier remove fallendream:heal_cap",
       "tag @s remove zx.heal_p", "tag @s remove zx.heal_on", cap,
       "scoreboard players add #talent_hp sd.floor 1000",
       "scoreboard players operation #talent_hp sd.floor < #talent_max sd.floor",
       "scoreboard players set #talent_ratio sd.floor 0",
       "scoreboard players set #talent_radix sd.floor 1000",
       f"function {ASTRO}heal_digit", f"function {ASTRO}heal_digit",
       "scoreboard players remove #talent_ratio sd.floor 1000000",
       f"execute store result storage {STATE} heal.scale double 0.000001 run scoreboard players get #talent_ratio sd.floor",
       f"function {ASTRO}heal_apply with storage {STATE} heal")
    mc("astrology/heal_digit", "scoreboard players operation #talent_hp sd.floor *= #talent_radix sd.floor",
       "scoreboard players operation #talent_p sd.floor = #talent_hp sd.floor",
       "scoreboard players operation #talent_p sd.floor /= #talent_max sd.floor",
       "scoreboard players operation #talent_ratio sd.floor *= #talent_radix sd.floor",
       "scoreboard players operation #talent_ratio sd.floor += #talent_p sd.floor",
       "scoreboard players operation #talent_hp sd.floor %= #talent_max sd.floor")
    mc("astrology/heal_apply", "$attribute @s minecraft:max_health modifier add fallendream:heal_cap $(scale) add_multiplied_total",
       "effect give @s minecraft:instant_health 1 20 true", "tag @s add zx.heal_p")


def caps(mc, change):
    uuid = ("function fallendream:lib/uuid", "execute unless data storage zx:data self{ok:1b} run return 0")
    uuid_arg = "data modify storage manacore:in arg.uuid set from storage zx:data self.uuid"
    mc("astrology/attack_stat", *uuid,
       '$data modify storage manacore:in arg set value {uuid:"",key:"base_attack",value:$(value)}',
       uuid_arg, "function manacore:api/stats/add")
    cap_hook = f"function {ASTRO}cap_sync"
    black = f"execute if score @s sd.bl_pct matches 1.. run function {FN}black/update_mana"
    change("room/event/second", lambda body: body.replace(black, cap_hook))
    mc("astrology/cap_sync",
       f"execute if entity @s[tag=sd.astro.mana] run function {ASTRO}mana_cap", black,
       *(f"execute if entity @s[tag=sd.astro.{key}] run return run function {ASTRO}health_stat" for key in ("health", "heart")))

    for name, attr, ledger in (("mana_cap", "max_mana", "sd.astro_mana"),
                               ("health_stat", "max_health", "sd.astro_hp")):
        mana = attr == "max_mana"
        bonus = (
            ("scoreboard players add @s sd.bl_mana 0",
             "scoreboard players operation #talent_base sd.floor += @s sd.bl_mana") if mana else
            ("execute if entity @s[tag=sd.astro.health] run scoreboard players add #talent_base sd.floor 200",
             "execute if entity @s[tag=sd.astro.health] run scoreboard players add #talent_cap sd.floor 200")
        )
        mc(f"astrology/{name}", *uuid,
           f'data modify storage manacore:in arg set value {{uuid:"",key:"{attr}"}}',
           uuid_arg, "function manacore:api/stats/get",
           "execute store result score #talent_base sd.floor run data get storage manacore:out r.value 100.000000001",
           f"scoreboard players add @s {ledger} 0",
           f"scoreboard players operation #talent_base sd.floor -= @s {ledger}",
           "scoreboard players set #talent_cap sd.floor 0", *bonus,
           f"execute if entity @s[tag=sd.astro.{'mana' if mana else 'heart'}] run function {ASTRO}cap_percent",
           f"execute if score #talent_cap sd.floor = @s {ledger} run return 0",
           "scoreboard players operation #talent_delta sd.floor = #talent_cap sd.floor",
           f"scoreboard players operation #talent_delta sd.floor -= @s {ledger}",
           f"scoreboard players operation @s {ledger} = #talent_cap sd.floor",
           f'data modify storage manacore:in arg set value {{uuid:"",key:"{attr}",value:0.0}}',
           uuid_arg, "execute store result storage manacore:in arg.value double 0.01 run scoreboard players get #talent_delta sd.floor",
           "function manacore:api/mana/max/add" if mana else "function manacore:api/stats/add",
           *((f"function {FN}run/mana {{value:0.0}}",) if mana else ()))
    mc("astrology/cap_percent", "scoreboard players set #talent_three sd.floor 3",
       "scoreboard players set #talent_ten sd.floor 10",
       "scoreboard players operation #talent_base sd.floor *= #talent_three sd.floor",
       "scoreboard players operation #talent_base sd.floor /= #talent_ten sd.floor",
       "scoreboard players operation #talent_cap sd.floor += #talent_base sd.floor")
