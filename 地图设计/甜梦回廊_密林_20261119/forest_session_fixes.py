"""Session boundaries, room services, and map-specific fixes for 坠梦."""

from pathlib import Path

from floor_upgrade import text, write
from forest_economy import FN, RUN, button, literal, say
from lobby_expansion import DUMMY_PADS


def stage(world):
    packs = Path(world) / "datapacks"
    data = packs / "zz_sweetdream_floor/data"
    root = data / "sweetdream_floor/function"

    def read(name):
        return text(root / f"{name}.mcfunction")

    def mc(name, *lines):
        write(root / f"{name}.mcfunction", "\n".join(lines))

    def replace(name, old, new):
        body = read(name)
        if new and new in body:
            return
        if old in body:
            mc(name, body.replace(old, new))

    def before(name, line, added):
        replace(name, line, added + "\n" + line)

    def append(name, line):
        body = read(name)
        if line not in body.splitlines():
            mc(name, body + line)

    gods(read, mc, replace)
    tutorial(read, mc, replace, before, append)
    training(read, mc, replace, append)
    training_hud(packs, data)
    mana(packs, data)
    visuals(read, mc, replace, append)
    events(read, mc, replace, before)
    from forest_gear_cabinet import cabinet
    cabinet(read, mc, replace, before, append)
    from forest_exhibits import stage as exhibits
    exhibits(read, mc, replace, before, append)
    from forest_room_details import stage as room_details
    room_details(data, mc, before)


def gods(read, mc, replace):
    # Each player receives a fixed offer of up to three missing god talents.
    # A menu reopen or repeated input continues to see that same hand.
    ids = (40, 41, 42, 43)
    keys = ("starlight", "heart", "rewind", "mana")
    objective = "sd.god_hidden"
    rng = "fallendream:rogue"
    replace("load", "scoreboard objectives add sd.god_menu dummy",
            f"scoreboard objectives add sd.god_menu dummy\nscoreboard objectives add {objective} dummy")
    replace("astrology/reset", "scoreboard players reset @s sd.god_menu",
            f"scoreboard players reset @s sd.god_menu\nscoreboard players reset @s {objective}")
    show = read("reward/god_show")
    if "reward/god_offer" not in show:
        show = show.replace("scoreboard players operation @s sd.god_menu = #god_floor sd.floor",
                            f"execute unless score @s sd.god_menu = #god_floor sd.floor run function {FN}reward/god_offer\n"
                            "scoreboard players operation @s sd.god_menu = #god_floor sd.floor")
    for code, key in zip(ids, keys):
        show = show.replace(f"unless entity @s[tag=sd.astro.{key}] run tellraw",
                            f"unless entity @s[tag=sd.astro.{key}] unless score @s {objective} matches {code} run tellraw")
        replace("reward/god", f"matches {code} unless entity @s[tag=sd.astro.{key}] run",
                f"matches {code} unless entity @s[tag=sd.astro.{key}] unless score @s {objective} matches {code} run")
    mc("reward/god_show", show)
    guard = "@s[" + ",".join(f"tag=!sd.astro.{key}" for key in keys) + "]"
    mc("reward/god_offer", f"scoreboard players set @s {objective} 0",
       f"execute if entity {guard} store result score @s {objective} run random value 40..43 {rng}")


def tutorial(read, mc, replace, before, append):
    obj = "sd.edu_arrival"
    append("load", f"scoreboard objectives add {obj} dummy")
    before("tutorial/enter", "tag @s add sd.floor_tutorial", f"scoreboard players set @s {obj} 30")
    # A button can remain powered while the dimension has no ticking player.
    # Require a fresh press after arrival and let the chunks finish loading.
    replace("tutorial/stage/wake", "scoreboard players set #edu_back sd.floor 0",
            "scoreboard players set #edu_back sd.floor 1")
    replace("tutorial/stage/back", "tag=sd.floor_tutorial,distance=..5",
            f"tag=sd.floor_tutorial,scores={{{obj}=..0}},distance=..4")
    before("tick", f"execute if entity @a[tag=sd.floor_tutorial] run return run function {FN}tutorial/stage/tick",
           f"scoreboard players remove @a[tag=sd.floor_tutorial,scores={{{obj}=1..}}] {obj} 1")


def training(read, mc, replace, append):
    tick = f"execute in sweetdream:training run function {FN}lobby/practice/tick"
    replace("tick", tick, tick + f"\nexecute in sweetdream:training run function {FN}training/panels")
    rows = []
    metrics = FN + "lobby/metrics/"
    for i, (x, y, z) in enumerate(DUMMY_PADS):
        tag = f"sd.practice_board_{i}"
        old_tick = f"execute in sweetdream:training positioned {x} {y} {z} if loaded ~ ~ ~ if entity @a[distance=..32] run function {metrics}dummy{i}/tick"
        replace("lobby/metrics/tick", old_tick, "")
        old_panel = f"@e[type=minecraft:text_display,tag={tag},tag=!sd.practice_panel_v3,distance=..8]"
        rows.append(f"execute positioned {x} {y} {z} if entity @a[tag=sd.training,distance=..40] run kill {old_panel}")
        rows.append(f"execute positioned {x} {y} {z} if loaded ~ ~ ~ if entity @a[tag=sd.training,distance=..40] run function {metrics}dummy{i}/tick")
        replace(f"lobby/metrics/dummy{i}/spawn_panel", f'Tags:["{tag}"]', f'Tags:["{tag}","sd.practice_panel_v3"]')
        replace(f"lobby/metrics/dummy{i}/spawn_panel", 'text:{text:""}',
                'text:[{text:"单次伤害  0.00",color:"yellow"},{text:"\\n近 5 秒  0.00",color:"aqua"}]')
        replace(f"lobby/metrics/dummy{i}/spawn_panel", "view_range:0.35f", "view_range:0.65f")
        replace(f"lobby/metrics/dummy{i}/spawn_panel", f"{y + 2.65}", f"{y + 2.35}")
        replace(f"lobby/metrics/dummy{i}/remember", "function sweetdream:lib/entity_uuid/build",
                "function fallendream:lib/entity_uuid/build")
    mc("training/panels", *rows)


def training_hud(packs, data):
    for file, hook in (("core/tick", "render"), ("lib/second", "cache")):
        rel = Path("fallendream/function") / f"{file}.mcfunction"
        dest = data / rel
        body = text(dest if dest.is_file() else packs / "fallendream/data" / rel)
        call = f"run function fallendream:equipment/tool/look/{hook}"
        old = f"execute as @a[tag=test_look_on] {call}"
        show = f"execute as @a[tag=sd.training,tag=!test_look_on] {call}"
        if old in body and show not in body:
            write(dest, body.replace(old, old + "\n" + show))


def mana(packs, data):
    # Preserve equipment bookkeeping and active returns. Pause the periodic
    # payouts at the point they actually add mana.
    files = ("upgrade/api/regen_now", "equipment/armor/tide_fold/regen", "equipment/armor/heart_vein/regen",
             "equipment/armor/dusk_dawn/set_regen", "equipment/armor/beach_vein/passive",
             "equipment/armor/external_power/passive", "equipment/armor/flesh_mill/gain",
             "equipment/armor/empty_camp/ol_regen", "equipment/armor/stellar_elegy/regen_pct")
    add = "function manacore:api/mana/add"
    gate = f"execute at @s if function {FN}clock/running run {add}"
    for name in files:
        rel = Path("fallendream/function") / f"{name}.mcfunction"
        dest = data / rel
        src = packs / "fallendream/data" / rel
        body = text(dest if dest.is_file() else src)
        if add in body and gate not in body:
            write(dest, "\n".join(line.replace(add, gate) if not line.startswith("#") else line
                                  for line in body.splitlines()))
    # 空营·超限 pays the per-second amount through a percentage API.
    rel = Path("fallendream/function/equipment/armor/empty_camp/ol_regen.mcfunction")
    dest = data / rel
    body = text(dest if dest.is_file() else packs / "fallendream/data" / rel)
    check = f"execute at @s unless function {FN}clock/running run return 0"
    if check not in body:
        write(dest, check + "\n" + body)


def visuals(read, mc, replace, append):
    replace("load", f"function {FN}mob_visual/load", "")
    # Clear any already-spawned display parts and equipment overrides as their
    # chunks load. New spawns use their underlying husk/phantom appearance.
    mc("mob_visual/clear", "kill @e[tag=sd.skin.part,distance=0..]", "kill @e[tag=sd.skin.rig,distance=0..]")
    mc("mob_visual/tick", f"function {FN}mob_visual/clear",
       f"execute as @e[tag=sd.skin.bound,distance=0..] run function {FN}mob_visual/restore_body")
    mc("mob_visual/restore_body", "effect clear @s minecraft:invisibility",
       *(f'data remove entity @s equipment.{slot}.components."minecraft:item_model"' for slot in ("head", "mainhand", "offhand")),
       *(f'data remove entity @s equipment.{slot}.components."minecraft:equippable"' for slot in ("chest", "legs", "feet")),
       "tag @s remove sd.skin.bound")
    replace("combat/mobs/shell_follow", 'execute if entity @s[tag=sd.skin.bound] run data merge entity @e[tag=sd.mob.shell_active,distance=0..,limit=1] {view_range:0f}', "")
    for name in ("hold", "block"):
        replace(f"combat/mobs/bark_guard/{name}", ',minecraft:item_model="fallendream_boss:forest_mob/empty"', "")
    for dim in ("sweetdream:floor_1_forest", "sweetdream:floor_2_trial"):
        original = f"execute in {dim} if entity @a[distance=0..] run function {FN}mob_visual/tick"
        new = f"execute in {dim} if entity @e[tag=sd.skin.bound,distance=0..] run function {FN}mob_visual/tick"
        if original in read("tick"):
            replace("tick", original, new)
        else:
            append("tick", new)
        append("tick", f"execute in {dim} if entity @e[tag=sd.skin.rig,distance=0..] run function {FN}mob_visual/clear")


def events(read, mc, replace, before):
    before("run/start", f"data modify storage {RUN} rooms set value []",
           f"data modify storage {RUN} allocated_events set value []")
    # Track variants already assigned on any floor, including skipped events.
    pool = read("generation/reset_pool")
    if "generation/filter_previous" not in pool:
        mc("generation/reset_pool", pool, f"function {FN}generation/filter_previous")
    mc("generation/filter_previous",
       *(f"execute if data storage {RUN} allocated_events[{{variant:{n}}}] run function {FN}generation/prune {{variant:{n}}}"
         for n in range(12)))
    # NBT filters can match compound list members but not integer members.
    # The source pool remains a list of integer variants for the map generator.
    mc("generation/prune", f"data modify storage {RUN} event_remaining set value []",
       f"$data modify storage {RUN} prune_variant set value $(variant)",
       f"function {FN}generation/prune_all",
       f"data modify storage {RUN} unused_events set from storage {RUN} event_remaining")
    mc("generation/prune_all",
       f"execute unless data storage {RUN} unused_events[0] run return 0",
       f"execute store result score #event_candidate sd.floor run data get storage {RUN} unused_events[0]",
       f"execute store result score #event_exclude sd.floor run data get storage {RUN} prune_variant",
       f"execute unless score #event_candidate sd.floor = #event_exclude sd.floor run data modify storage {RUN} event_remaining append from storage {RUN} unused_events[0]",
       f"data remove storage {RUN} unused_events[0]",
       f"function {FN}generation/prune_all")
    replace("generation/event_pick", f"execute unless data storage {RUN} unused_events[0] run function {FN}generation/reset_pool",
            f'execute unless data storage {RUN} unused_events[0] run return run data modify storage zx:work rd_assign.kind set value "combat"')
    pick = read("generation/event_set")
    if "allocated_events append" not in pick:
        mc("generation/event_set", pick,
           f"data modify storage {RUN} allocated_events append value {{variant:0}}",
           f"data modify storage {RUN} allocated_events[-1].variant set from storage zx:work rd_assign.variant")
