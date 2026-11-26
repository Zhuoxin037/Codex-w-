"""Keep combat doors, enemy confinement and Twin proxies working in the dungeon."""

import json
import re
from pathlib import Path

from floor_upgrade import DIM, text, write
from forest_economy import FN, RUN

ROOT = Path(__file__).resolve().parents[2]
TRIAL = "sweetdream:floor_2_trial"
FLOORS = (DIM, TRIAL)
OPEN = FN+"room/doors/"
AIR = "#sweetdream_floor:room_air"
FOREST_KITS = ROOT/"fallendream/data"
SLEEP = "@e[type=minecraft:villager,tag=zx.j_body,"
TWIN_PLAYERS = "@a[tag=sd.floor_run,tag=zx.rg_active,distance=0..,scores={sd.floor_death=0,zx.job=4,zx.j_form=1}]"
DELAY = "@e[type=minecraft:marker,tag=sd.gate.delay,distance=..0.25]"
PANEL = "@e[type=minecraft:block_display,tag=sd.floor_gate,distance=..0.25]"


def stage(world):
    data = Path(world)/"datapacks/zz_sweetdream_floor/data"
    home = data/"sweetdream_floor/function"

    def mc(name, *rows):
        write(home/f"{name}.mcfunction", "\n".join(rows))

    def before(name, marker, addition):
        path = home/f"{name}.mcfunction"
        body = text(path)
        if addition in body:
            return
        if marker not in body:
            raise ValueError(f"Missing runtime hook in {path}: {marker}")
        write(path,body.replace(marker,addition+"\n"+marker,1))

    # Barrier volume and wood share the same anchor. The barrier remains
    # until the eight-tick sink animation has actually cleared the aperture.
    mc("room/doors/threshold",
       f"$execute if score #door_closed sd.floor matches 0 run function {OPEN}open_visual {{x:$(x),z:$(z)}}",
       "execute if score #door_closed sd.floor matches 0 run return 0",
       f"$execute if block ~ ~ ~ minecraft:barrier positioned ~-$(x) ~ ~-$(z) unless entity {DELAY} if entity @e[type=minecraft:block_display,tag=sd.floor_gate,tag=!sd.floor_gate_open,distance=..0.25] run return 0",
       f'$function {OPEN}close_visual {{x:$(x),z:$(z),axis:"$(axis)"}}')
    mc("room/doors/update",
       *(f"$execute positioned $(x) 81 $(z) align xz positioned {offset} run function {OPEN}candidate "
         f'{{x:{x},z:{z},axis:"{axis}"}}' for offset,x,z,axis in (
             ("~$(radius) ~ ~",0,3,"z"),("~-$(radius) ~ ~",0,3,"z"),
             ("~ ~ ~$(radius)",3,0,"x"),("~ ~ ~-$(radius)",3,0,"x"))))
    mc("room/doors/candidate",
       f"$execute if block ~ ~-1 ~ minecraft:mossy_stone_bricks run return run function {OPEN}threshold {{x:$(x),z:$(z),axis:\"$(axis)\"}}",
       f"$execute if score #door_closed sd.floor matches 0 positioned ~-$(x) ~ ~-$(z) if entity {PANEL} positioned ~$(x) ~ ~$(z) run function {OPEN}open_visual {{x:$(x),z:$(z)}}")
    mc("room/doors/close_visual",
       f"$execute positioned ~-$(x) ~ ~-$(z) run kill {DELAY}",
       f"$fill ~-$(x) ~ ~-$(z) ~$(x) ~4 ~$(z) minecraft:barrier replace {AIR}",
       f"$execute positioned ~-$(x) ~ ~-$(z) as {PANEL} run function {OPEN}discard",
       f"$execute positioned ~-$(x) ~ ~-$(z) run function {OPEN}panels_$(axis)")
    mc("room/doors/open_visual",
       f"$execute positioned ~-$(x) ~ ~-$(z) if entity {DELAY} run return 0",
       f"$execute positioned ~-$(x) ~ ~-$(z) if entity {PANEL} run function {OPEN}queue_open {{x:$(x),z:$(z)}}",
       f"$execute positioned ~-$(x) ~ ~-$(z) if entity {DELAY} run return 0",
       f"$function {OPEN}release {{x:$(x),z:$(z)}}")
    mc("room/doors/queue_open",
       f"execute as @e[type=minecraft:block_display,tag=sd.floor_gate,tag=!sd.floor_gate_open,distance=..0.25] run function {OPEN}sink",
       f"$execute summon minecraft:marker run function {OPEN}queue_init {{x:$(x)}}")
    mc("room/doors/queue_init", "tag @s add sd.gate.delay", "$tag @s add sd.gate.x$(x)", "scoreboard players set @s sd.floor 9")
    mc("room/doors/release",
       "$fill ~-$(x) ~ ~-$(z) ~$(x) ~4 ~$(z) minecraft:air replace minecraft:barrier",
       "$fill ~-$(x) ~1 ~-$(z) ~$(x) ~1 ~$(z) minecraft:light[level=15] replace minecraft:air")
    mc("room/doors/delay_end",
       f"execute if entity @s[tag=sd.gate.x3] positioned ~3 ~ ~ run function {OPEN}release {{x:3,z:0}}",
       f"execute if entity @s[tag=sd.gate.x0] positioned ~ ~ ~3 run function {OPEN}release {{x:0,z:3}}",
       f"function {OPEN}discard")
    before("room/doors/tick","execute as @e[type=minecraft:block_display,tag=sd.floor_gate,tag=!sd.floor_gate_aligned", "\n".join((
           "execute as @e[type=minecraft:marker,tag=sd.gate.delay,distance=0..] run scoreboard players remove @s sd.floor 1",
           f"execute as @e[type=minecraft:marker,tag=sd.gate.delay,scores={{sd.floor=..0}},distance=0..] at @s run function {OPEN}delay_end")))
    # Old saves might have vanished barrier blocks with a legacy panel left
    # behind. Reconcile only the known gate actors and keep shrub locks.
    before("room/doors/tick", "execute as @e[type=minecraft:block_display,tag=sd.floor_gate,tag=!sd.floor_gate_aligned",
           f"execute unless data storage {RUN} encounter unless data storage {RUN} choice_room as @e[type=minecraft:block_display,tag=sd.floor_gate,tag=!sd.floor_gate_open,distance=0..] at @s run function {OPEN}orphan_panel")
    mc("room/doors/orphan_panel",
       f'execute if entity {DELAY} run return 0',
       f'execute if data entity @s {{block_state:{{Properties:{{axis:"x"}}}}}} run return run function {OPEN}queue_open {{x:3}}',
       f"function {OPEN}queue_open {{x:0}}")
    for floor,kind in zip(FLOORS,("forest","trial")):
        before(f"combat/clean_{kind}","execute in "+floor+" if entity @e[tag=sd.kn.rig",
               f"execute in {floor} as @e[type=minecraft:marker,tag=sd.gate.delay,distance=0..] at @s run function {OPEN}delay_end")
    before("combat/boss_abort",f"function {FN}room/unmark",
           f"function {FN}combat/open_doors\ndata remove storage {RUN} encounter")

    before("combat/tick",f"function {FN}combat/mobs/tick",
           f"execute if data storage {RUN} encounter run function {FN}combat/confine_enemies with storage {RUN} encounter")
    mc("combat/confine_enemies",
       f'$execute positioned $(minx) 80 $(minz) as @e[tag=sd.floor_enemy,tag=!sd.kn.body,tag=!sd.stag.body,distance=0..] unless entity @s[dx=$(width),dy=10,dz=$(width)] run function {FN}combat/return_enemy with storage {RUN} encounter')
    mc("combat/return_enemy",
       *(f"$execute positioned $(x).5 81 $(z).5 positioned ~{dx} ~ ~{dz} if block ~ ~ ~ {AIR} if block ~ ~1 ~ {AIR} unless block ~ ~-1 ~ {AIR} run return run function {FN}combat/land_enemy"
         for dx,dz in ((0,0),(-4,-2),(2,-4),(4,3),(-4,3),(0,5),(-2,5),(4,5))))
    mc("combat/land_enemy", "tp @s ~ ~ ~", "data merge entity @s {Motion:[0d,0d,0d],FallDistance:0d}")
    before("combat/begin",f"execute as @a[tag=sd.floor_run,tag=zx.rg_active",
           f"execute as {TWIN_PLAYERS} at @s run function {FN}combat/check_twin_room with storage {RUN} encounter")
    before("combat/win",f"function {FN}flow/locate_choice",
           f"execute as {TWIN_PLAYERS} at @s run function fallendream:profession/twin/return")
    mc("combat/check_twin_room", "function fallendream:profession/twin/locate",
       '$execute positioned $(minx) 78 $(minz) unless entity @e[type=minecraft:villager,tag=zx.j_anchor,distance=0..,dx=$(width),dy=19,dz=$(width)] run function fallendream:profession/twin/return')
    mc("combat/confine_returned",
       f'execute if data storage {RUN} {{floor:2}} run return run function {FN}combat/confine_returned_go {{dim:"{TRIAL}"}}',
       f'function {FN}combat/confine_returned_go {{dim:"{DIM}"}}')
    mc("combat/confine_returned_go",
       f"$execute at @s unless dimension $(dim) in $(dim) run function {FN}room/teleport_cell with storage {RUN} encounter",
       f"$execute in $(dim) run function {FN}combat/confine with storage {RUN} encounter")

    twin_overlay(data,home)
    zombie_spawns(home)
    for name in ("resin_burst","ring_hit","sweep_hit","moth/dash","moth/launch","moth/touch","branch/left_hit","branch/right_hit"):
        path=home/f"combat/mobs/{name}.mcfunction"
        copy_hits(path)


def zombie_spawns(home):
    mobs = home/"combat/mobs"
    for path in mobs.glob("spawn_*.mcfunction"):
        rows = text(path).splitlines()
        match = re.fullmatch(r"execute summon minecraft:(husk|zombie|drowned) run function (\S+)", rows[0])
        if not match:
            continue
        kind, init = match.groups()
        baby = "1b" if path.stem in ("spawn_cover", "spawn_child") else "0b"
        # Explicit summon NBT skips vanilla spawning bonuses, including jockeys.
        spawning = "sd.mob.spawning"
        write(path, "\n".join((
            f'summon minecraft:{kind} ~ ~ ~ {{IsBaby:{baby},Tags:["{spawning}"]}}',
            f'execute as @e[type=minecraft:{kind},tag={spawning},distance=..0.1,sort=nearest,limit=1] at @s run function {init}',
            *rows[1:],
        )))
        setup = home/(init.split(":", 1)[1]+".mcfunction")
        body = text(setup)
        if "minecraft:spawn_reinforcements" not in body:
            write(setup, body.replace('attributes:[', 'attributes:[{id:"minecraft:spawn_reinforcements",base:0d},', 1))


def twin_overlay(data,home):
    base="fallendream/function/profession/"
    paths=("twin/enter","twin/return","twin/protect_proxy","twin/protect_sleep","twin/recover_sleep_resistance","twin/body_tick","twin/taunt_native",
           "twin/locate_go","twin/clean_go","twin/cancel_host_go","twin/host_finish","twin/host_watch_go","tick")
    for name in paths:
        rel=f"{base}{name}.mcfunction"
        rows=[]
        for line in text(FOREST_KITS/rel).splitlines():
            rows.append(line)
            if " in minecraft:the_end " in line:
                rows.extend(line.replace(" in minecraft:the_end ",f" in {dim} ") for dim in FLOORS)
        if name=="twin/return":
            rows.append(f"execute if entity @s[tag=sd.floor_run] if data storage {RUN} encounter run function {FN}combat/confine_returned")
        write(data/rel,"\n".join(rows))
    load=home/"load.mcfunction"
    line="scoreboard objectives add zx.j_taunt_due dummy"
    if line not in text(load):
        write(load,text(load)+line)
    for rel in ("fallendream/damage_type/sleep_provocation.json","fallendream/enchantment/sleep_ward.json",
                "fallendream/tags/damage_type/sleeping_enemy_damage.json","minecraft/tags/damage_type/no_impact.json"):
        write(data/rel,text(FOREST_KITS/rel))
    path=data/"minecraft/tags/damage_type/no_knockback.json"
    raw=text(path)
    if "fallendream:sleep_provocation" not in raw:
        tag=json.loads(raw)
        tag["values"].append("fallendream:sleep_provocation")
        write(path,json.dumps(tag,separators=(",",":")))


def copy_hits(path):
    rows=text(path).splitlines()
    if any("tag=zx.j_body," in row for row in rows):
        return
    patched=[]
    for row in rows:
        patched.append(row)
        if "@a[" not in row and "@p[" not in row:
            continue
        if not any(verb in row for verb in ("run tag @a[","as @a[","effect give @a[","tag @a[","damage @p[")):
            continue
        if any(word in row for word in ("playsound","particle")):
            continue
        dest=re.sub(r"@[ap]\[([^]]+)\]",sleeper_selector,row)
        if "@p[" in row:
            # Contact can hurt a nearby sleeper even when no player stands there.
            target=re.search(r"@e\[[^]]+\]",dest)[0]
            dest=dest.replace(f"if entity {target} ","")
        patched.append(dest)
    write(path,"\n".join(patched))


def sleeper_selector(match):
    fields=[part for part in match[1].split(",") if part not in ("tag=sd.floor_run","tag=zx.rg_active","scores={sd.floor_death=0}")]
    if not any(part.startswith("distance=") for part in fields) and not any(part.startswith("dx=") for part in fields):
        fields.append("distance=0..")
    if match[0].startswith("@p"):
        fields.extend(("sort=nearest","limit=1"))
    return SLEEP+",".join(fields)+"]"
