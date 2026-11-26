"""Compile first-floor encounter budgets and vanilla mob behavior."""

from itertools import combinations_with_replacement
from math import cos, pi, sin
from pathlib import Path

from floor_upgrade import DIM, edit, text, write
from forest_economy import FN, RUN, literal

ENEMY = "@e[tag=sd.floor_enemy,distance=0..]"
COMPANIONS = ("cover", "rooted", "resin", "root", "moss")
COST = {"cover": 1, "rooted": 2, "resin": 2, "root": 3, "moss": 4, "crown": 5}
ANCHORS = ((-4,-2), (2,-4), (4,3), (-4,3), (0,5), (-2,5), (4,5))
COMBAT = FN + "combat/mobs/"
TRACKED = ("sd.mob_time", "sd.mob_count", "sd.mob_hp", "sd.mob_cd")
RESIN_FUSE = 12
RESIN_REACH = 8
RESIN_WIDTH = 2
ROOT_PERIOD = 60
MOSS_FIRST = 60
MOSS_PERIOD = 100
MOSS_GRACE = 20
MOSS_HIT_REDUCTION = 40


def equipment(head, coat=False, weapon=None):
    rows = [f'head:{{id:"minecraft:{head}",count:1}}']
    if coat:
        rows += [f'{slot}:{{id:"minecraft:leather_{item}",count:1}}' for slot,item in
                 (("chest","chestplate"),("legs","leggings"),("feet","boots"))]
    if weapon:
        rows.append(f'mainhand:{{id:"minecraft:{weapon}",count:1,components:{{"minecraft:attribute_modifiers":[]}}}}')
    return "equipment:{" + ",".join(rows) + "}"


def mob(name, tag, hp, attack, look, *extras):
    return (f'{{Tags:["sd.floor_enemy","sd.mob.{tag}"],CustomName:{literal({"text":name})},'
            f'PersistenceRequired:1b,CanPickUpLoot:0b,DeathLootTable:"minecraft:empty",'
            f'Health:{hp}f,attributes:[{{id:"minecraft:max_health",base:{hp}d}},'
            f'{{id:"minecraft:attack_damage",base:{attack}d}}],{look}'
            + ''.join(',' + extra for extra in extras) + '}')


def stage(world, overlays_only=False):
    root = Path(world) / "datapacks/zz_sweetdream_floor/data/sweetdream_floor/function"

    def mc(name, *lines):
        write(root / f"{name}.mcfunction", "\n".join(lines))

    def m(name, *lines):
        mc(f"combat/mobs/{name}", *lines)

    if not overlays_only:
        # This setting belongs to the standalone map. Pack abilities still issue their own loot.
        edit(root / "load.mcfunction", ("gamerule naturalRegeneration false",
             "gamerule naturalRegeneration false\ngamerule doMobLoot false\n" +
             "\n".join(f"scoreboard objectives add {obj} dummy" for obj in TRACKED)))
        edit(root / "combat/clean.mcfunction", ('run kill @e[tag=sd.floor_enemy,tag=!sd.kn.body,distance=0..]',
             'run kill @e[tag=sd.floor_enemy,tag=!sd.kn.body,distance=0..]\n'
             f'execute in {DIM} run kill @e[tag=sd.mob.prop,distance=0..]'))
        edit(root / "combat/win.mcfunction", (f"function {FN}combat/open_doors",
             f"kill @e[tag=sd.mob.prop,distance=0..]\nfunction {FN}combat/open_doors"))
    mc("combat/tick",
       "execute unless score #phase sd.floor matches 2 run return 0",
       f"function {COMBAT}tick",
       f"execute unless entity {ENEMY} unless entity @e[tag=sd.mob.resin_pending,distance=0..] run function {FN}combat/win")

    plain = {
        "cover": ("zombie", mob("覆苔尸", "cover", 8, 1, equipment("moss_block"), "IsBaby:1b")),
        "rooted": ("husk", mob("扎根人", "rooted", 20, 3, equipment("oak_log", True))),
        "resin": ("husk", mob("树脂人", "resin", 10, 2, equipment("stripped_oak_log"))),
        "root": ("husk", mob("树根", "root", 12, 5, equipment("mangrove_roots"), "NoAI:1b")),
        "moss": ("husk", mob("苔藓", "moss", 30, 0, equipment("moss_block", True), "NoAI:1b")),
        "crown": ("husk", mob("断冠猎手", "crown", 38, 4, equipment("dark_oak_log", weapon="wooden_sword"))),
    }
    for key, (entity, nbt) in plain.items():
        if key in ("resin", "root", "moss", "crown"):
            # execute summon establishes @s without relying on nearest-entity ordering.
            m(f"spawn_{key}", f"execute summon minecraft:{entity} run function {COMBAT}init_{key}")
            if key == "resin":
                init = ("scoreboard players add #mob_serial sd.floor 1",
                        "scoreboard players operation @s sd.floor = #mob_serial sd.floor",
                        f"execute positioned ~-.24 ~1.05 ~-.24 summon minecraft:block_display run function {COMBAT}resin_shell")
            elif key == "moss":
                init = (f"scoreboard players set @s sd.mob_time {MOSS_FIRST}", "scoreboard players set @s sd.mob_hp 3000",
                        "scoreboard players set @s sd.mob_cd 0", "scoreboard players set @s sd.mob_count 0")
            else:
                init = ("scoreboard players set @s sd.mob_time 0",)
            m(f"init_{key}", f"data merge entity @s {nbt}", *init)
        else:
            m(f"spawn_{key}", f"summon minecraft:{entity} ~ ~ ~ {nbt}")
    m("spawn_child", f"summon minecraft:zombie ~ ~ ~ " + plain["cover"][1].replace(
        '"sd.mob.cover"]', '"sd.mob.cover","sd.mob.moss_child"]'))

    mc("combat/spawn",
       "scoreboard players set #mob_count_limit sd.floor 5",
       "execute if score #hard sd.floor matches 1 run scoreboard players set #mob_count_limit sd.floor 6",
       f'execute if data storage {RUN} current{{ambush_harder:1b}} run return run function {COMBAT}ambush_spawn',
       f'execute if data storage {RUN} current{{kind:"elite"}} run scoreboard players set #mob_count_limit sd.floor 7',
       f'execute if data storage {RUN} current{{kind:"elite"}} run return run function {COMBAT}roll_elite',
       f"execute if score #hard sd.floor matches 1 run return run function {COMBAT}roll_hard",
       f"function {COMBAT}roll_normal")
    m("ambush_spawn", "scoreboard players set #mob_count_limit sd.floor 8", f"function {COMBAT}roll_ambush")
    for name, low, high, cap in (("normal",5,7,4),("hard",8,10,5),("elite",10,12,6),("ambush",13,15,7)):
        m(f"roll_{name}", f"execute store result score #mob_budget sd.floor run random value {low}..{high} sweetdream:rogue",
          *(f"execute if score #mob_budget sd.floor matches {pts} run function {COMBAT}group/{name}_{pts}" for pts in range(low,high+1)))
        for points in range(low, high+1):
            teams = []
            extra = ("crown",) if name in ("elite", "ambush") else ()
            for size in range(2, cap + 1 - len(extra)):
                for team in combinations_with_replacement(COMPANIONS, size):
                    whole = extra + team
                    if sum(COST[key] for key in whole) != points:
                        continue
                    if any(team.count(key) > (1 if key in ("root","moss") else 2) for key in set(team)):
                        continue
                    if not {"cover","rooted","resin"}.intersection(whole):
                        continue
                    if points == 5 and "moss" in team:
                        continue
                    teams.append(whole)
            if not teams:
                raise ValueError(f"No team for {name} at {points} points")
            dispatch = [f"execute store result score #mob_group sd.floor run random value 0..{len(teams)-1} sweetdream:rogue"]
            for i, team in enumerate(teams):
                path = f"group/{name}_{points}_{i}"
                dispatch.append(f"execute if score #mob_group sd.floor matches {i} run function {COMBAT}{path}")
                m(path, f'data modify storage {RUN} encounter_team set value {literal(team)}',
                  *(f"execute positioned ~{x or ''} ~ ~{z or ''} run function {COMBAT}spawn_{key}"
                    for key, (x,z) in zip(team, ANCHORS)))
            m(f"group/{name}_{points}", *dispatch)

    m("tick",
      f'execute as @e[tag=sd.mob.root,distance=0..] at @s run function {COMBAT}root_tick',
      f'execute as @e[tag=sd.mob.moss,distance=0..] at @s run function {COMBAT}moss_tick',
      f'execute as @e[tag=sd.mob.crown,distance=0..] at @s run function {COMBAT}crown_tick',
      f'execute as @e[tag=sd.mob.shell,distance=0..] at @s run function {COMBAT}shell_tick',
      f'execute as @e[tag=sd.mob.ring,distance=0..] at @s run function {COMBAT}ring_tick',
      f'execute as @e[tag=sd.mob.sweep,distance=0..] at @s run function {COMBAT}sweep_tick')
    resin(m)
    roots(m)
    moss(m)
    crown(m)


def dust(color, size=0.8):
    return f"minecraft:dust{{color:{literal(color)},scale:{size}}}"


def stage_timing(world):
    root = Path(world)/"datapacks/zz_sweetdream_floor/data/sweetdream_floor/function/combat/mobs"

    def m(name, *lines):
        write(root/f"{name}.mcfunction", "\n".join(lines))

    for compile_mob in (resin, roots, moss):
        compile_mob(m)
    edit(root/"init_moss.mcfunction",
         ("scoreboard players set @s sd.mob_time 100", f"scoreboard players set @s sd.mob_time {MOSS_FIRST}"))


def resin_lanes(reach, width):
    span = reach * 2 - 1
    side = width - 1
    edge = f"~-{width/2:g}".replace("~-0.","~-.")
    return ((f"~-{reach} ~-.2 {edge}", f"dx={span},dy=2,dz={side}"),
            (f"{edge} ~-.2 ~-{reach}", f"dx={side},dy=2,dz={span}"))


def resin_warning():
    honey = dust([1.0,0.66,0.13])
    points = [(0,0)]
    half = RESIN_WIDTH / 2
    for step in range(1,RESIN_REACH+1):
        points.extend(((step,0),(-step,0),(0,step),(0,-step)))
        for edge in (-half, half):
            points.extend(((step,edge),(-step,edge),(edge,step),(edge,-step)))
    return tuple(f"particle {honey} ~{f'{x:g}' if x else ''} ~.09 ~{f'{z:g}' if z else ''} 0 0 0 0 1 force"
                 for x,z in dict.fromkeys(points))


def update_resin_range(world):
    # Update existing worlds without regenerating their damage and sleeper hooks.
    mobs = Path(world)/"datapacks/zz_sweetdream_floor/data/sweetdream_floor/function/combat/mobs"
    burst = mobs/"resin_burst.mcfunction"
    body = text(burst)
    current = resin_lanes(RESIN_REACH,RESIN_WIDTH)
    for old in (resin_lanes(6,1),resin_lanes(8,1)):
        for (old_pos,old_size),(pos,size) in zip(old,current):
            body = "\n".join(line.replace(old_pos,pos).replace(old_size,size)
                             if f"positioned {old_pos} run tag " in line else line
                             for line in body.splitlines())
    for pos,size in current:
        if not any(f"positioned {pos} run tag " in line and size in line for line in body.splitlines()):
            raise ValueError(f"Missing resin lane in {burst}: {pos}")
    write(burst,body)
    write(mobs/"resin_lines.mcfunction","\n".join(resin_warning()))


def resin(m):
    m("resin_shell",
      'data merge entity @s {Tags:["sd.mob.prop","sd.mob.shell"],block_state:{Name:"minecraft:honeycomb_block"},'
      'transformation:{translation:[0f,0f,0f],scale:[0.48f,0.44f,0.48f],left_rotation:[0f,0f,0f,1f],right_rotation:[0f,0f,0f,1f]}}',
      "scoreboard players operation @s sd.floor = #mob_serial sd.floor", "scoreboard players set @s sd.mob_time -1")
    m("shell_tick",
      f'execute if entity @s[tag=sd.mob.resin_pending] run return run function {COMBAT}resin_fuse',
      "scoreboard players operation #mob_match sd.floor = @s sd.floor", "tag @s add sd.mob.shell_active",
      f"execute as @e[tag=sd.mob.resin,distance=0..] if score @s sd.floor = #mob_match sd.floor at @s run function {COMBAT}shell_follow",
      "tag @s remove sd.mob.shell_active",
      "execute if entity @s[tag=sd.mob.shell_link] run return run tag @s remove sd.mob.shell_link",
      "tag @s add sd.mob.resin_pending", f"scoreboard players set @s sd.mob_time {RESIN_FUSE}",
      "tp @s ~ ~-1.0 ~", "data merge entity @s {brightness:{block:15,sky:10}}",
      f"execute at @s positioned ~.24 ~.09 ~.24 run function {COMBAT}resin_lines",
      "playsound minecraft:block.honey_block.slide hostile @a[tag=sd.floor_run,distance=..20] ~ ~ ~ 1 1.25")
    m("shell_follow", "tag @e[tag=sd.mob.shell_active,limit=1] add sd.mob.shell_link",
      "tp @e[tag=sd.mob.shell_active,limit=1] ~-.24 ~1.05 ~-.24")
    m("resin_fuse", "scoreboard players remove @s sd.mob_time 1",
      f"execute if score @s sd.mob_time matches {RESIN_FUSE//2} positioned ~.24 ~.09 ~.24 run function {COMBAT}resin_lines",
      f"execute if score @s sd.mob_time matches ..0 positioned ~.24 ~.05 ~.24 run function {COMBAT}resin_burst")
    m("resin_lines", *resin_warning())
    m("resin_burst", f"function {COMBAT}resin_lines", "playsound minecraft:block.honey_block.break hostile @a[tag=sd.floor_run,distance=..22] ~ ~ ~ 1.1 0.95",
      # Tag both lanes before dealing damage so the center hits once.
      *(f"execute positioned {pos} run tag @a[tag=sd.floor_run,{size}] add sd.mob.resin_hit"
        for pos,size in resin_lanes(RESIN_REACH,RESIN_WIDTH)),
      "execute as @a[tag=sd.mob.resin_hit,distance=0..] run damage @s 5 minecraft:mob_attack",
      "effect give @a[tag=sd.mob.resin_hit,distance=0..] minecraft:slowness 3 0 false",
      "tag @a[tag=sd.mob.resin_hit,distance=0..] remove sd.mob.resin_hit", "kill @s")


def roots(m):
    warning = dust([0.46,0.78,0.24], 1.1)
    m("root_tick", "scoreboard players add @s sd.mob_time 1",
      f"execute if score @s sd.mob_time matches {ROOT_PERIOD}.. if entity @p[tag=sd.floor_run,distance=..26] run function {COMBAT}root_target")
    m("root_target", "scoreboard players set @s sd.mob_time 0",
      f"execute at @p[tag=sd.floor_run,distance=..26] summon minecraft:marker run function {COMBAT}ring_init")
    m("ring_init", "tag @s add sd.mob.prop", "tag @s add sd.mob.ring", "scoreboard players set @s sd.mob_time 20",
      "playsound minecraft:block.roots.place hostile @a[tag=sd.floor_run,distance=..18] ~ ~ ~ 1 .75")
    m("ring_tick", "scoreboard players remove @s sd.mob_time 1",
      *(f"execute if score @s sd.mob_time matches {n} run function {COMBAT}ring_show" for n in (19,14,9,4)),
      f"execute if score @s sd.mob_time matches ..0 run function {COMBAT}ring_hit")
    m("ring_show", *(f"particle {warning} ~{2*cos(n*pi/6):.2f} ~.1 ~{2*sin(n*pi/6):.2f} 0 0 0 0 1 force" for n in range(12)))
    m("ring_hit", f"function {COMBAT}ring_show",
      'execute as @a[tag=sd.floor_run,distance=..2] run damage @s 5 minecraft:mob_attack',
      'execute as @e[tag=sd.floor_enemy,tag=!sd.mob.root,distance=..2] run damage @s 5 minecraft:mob_attack',
      "playsound minecraft:block.grass.break hostile @a[tag=sd.floor_run,distance=..20] ~ ~ ~ 1 .5", "kill @s")


def moss_hurt_commands():
    return (
        "scoreboard players set @s sd.mob_cd 20",
        # Give each newly spawned child a brief lead before damage can accelerate the next.
        f"execute if score @s sd.mob_time matches ..{MOSS_PERIOD-MOSS_GRACE} run scoreboard players remove @s sd.mob_time {MOSS_HIT_REDUCTION}",
    )


def moss(m):
    m("moss_tick", "scoreboard players remove @s sd.mob_time 1",
      "execute if score @s sd.mob_cd matches 1.. run scoreboard players remove @s sd.mob_cd 1",
      "execute store result score #moss_hp sd.floor run data get entity @s Health 100",
      f"execute if score #moss_hp sd.floor < @s sd.mob_hp if score @s sd.mob_cd matches 0 run function {COMBAT}moss_hurt",
      "scoreboard players operation @s sd.mob_hp = #moss_hp sd.floor",
      f"execute if score @s sd.mob_time matches ..0 if score @s sd.mob_count matches ..2 run function {COMBAT}moss_try")
    m("moss_hurt", *moss_hurt_commands())
    m("moss_try", "scoreboard players set #mob_live sd.floor 0", "scoreboard players set #mob_kids sd.floor 0",
      f"execute store result score #mob_live sd.floor if entity {ENEMY}",
      "execute store result score #mob_kids sd.floor if entity @e[tag=sd.mob.moss_child,distance=0..]",
      "execute if score #mob_live sd.floor >= #mob_count_limit sd.floor run return 0",
      "execute if score #mob_kids sd.floor matches 2.. run return 0",
      *(f"execute positioned ~{x or ''} ~ ~{z or ''} if block ~ ~ ~ minecraft:air run return run function {COMBAT}moss_birth"
        for x,z in ((2,0),(-2,0),(0,2),(0,-2))))
    m("moss_birth", f"function {COMBAT}spawn_child", f"scoreboard players set @s sd.mob_time {MOSS_PERIOD}",
      "scoreboard players add @s sd.mob_count 1",
      "particle minecraft:happy_villager ~ ~.6 ~ .35 .25 .35 .05 6 force",
      "playsound minecraft:block.moss.break hostile @a[tag=sd.floor_run,distance=..20] ~ ~ ~ 1 .75")


def crown(m):
    m("crown_tick", "scoreboard players add @s sd.mob_time 1",
      "execute if score @s sd.mob_time matches 184 run data merge entity @s {NoAI:0b}",
      "execute if score @s sd.mob_time matches 184.. run scoreboard players set @s sd.mob_time 0",
      f"execute if score @s sd.mob_time matches 140 if entity @p[tag=sd.floor_run,distance=..7] run function {COMBAT}sweep_start")
    m("sweep_start", "data merge entity @s {NoAI:1b}",
      f"execute facing entity @p[tag=sd.floor_run,distance=..7] feet rotated ~ 0 run function {COMBAT}sweep_place")
    m("sweep_place", 'summon minecraft:marker ~ ~ ~ {Tags:["sd.mob.prop","sd.mob.sweep","sd.mob.sweep_new"]}',
      "tp @e[tag=sd.mob.sweep_new,limit=1] ~ ~ ~ ~ 0", "scoreboard players set @e[tag=sd.mob.sweep_new,limit=1] sd.mob_time 18",
      "tag @e[tag=sd.mob.sweep_new,limit=1] remove sd.mob.sweep_new",
      "playsound minecraft:block.wood.hit hostile @a[tag=sd.floor_run,distance=..20] ~ ~ ~ 1 .6")
    m("sweep_tick", "execute unless entity @e[tag=sd.mob.crown,distance=..10] run return run kill @s",
      "scoreboard players remove @s sd.mob_time 1",
      *(f"execute if score @s sd.mob_time matches {n} run function {COMBAT}sweep_show" for n in (17,12,7,2)),
      f"execute if score @s sd.mob_time matches ..0 run function {COMBAT}sweep_hit")
    coords = [(x,z) for x in (-1.7,-.85,0,.85,1.7) for z in (1.2,2.3,3.4) if abs(x) <= z*.65]
    m("sweep_show", *(f"particle {dust([0.98,0.45,0.22],1.1)} ^{x} ^.10 ^{z} 0 0 0 0 1 force" for x,z in coords))
    m("sweep_hit", f"function {COMBAT}sweep_show",
      *(f'execute positioned ^{x} ^ ^{z} run tag @a[tag=sd.floor_run,distance=..0.85] add sd.mob.sweep_hit' for x,z in coords),
      "execute as @a[tag=sd.mob.sweep_hit,distance=0..] run damage @s 5 minecraft:mob_attack",
      "tag @a[tag=sd.mob.sweep_hit,distance=0..] remove sd.mob.sweep_hit",
      "playsound minecraft:entity.player.attack.sweep hostile @a[tag=sd.floor_run,distance=..18] ~ ~ ~ 1 .65", "kill @s")
