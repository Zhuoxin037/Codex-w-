"""Forest-only encounters and attacks for the three new creatures."""

from pathlib import Path

from floor_upgrade import edit, text, write
from forest_combat import ANCHORS, COMBAT, COST, dust, equipment, mob
from forest_economy import RUN, literal

PLAYERS = "@a[tag=sd.floor_run,tag=zx.rg_active,scores={sd.floor_death=0}"
TARGET = "@p[tag=sd.floor_run,tag=zx.rg_active,scores={sd.floor_death=0}"
LONG_ATTACK = "unless entity @e[tag=sd.mob.long_attack,distance=0..] unless entity @e[tag=sd.mob.ring,distance=0..] unless entity @e[tag=sd.mob.sweep,distance=0..]"
AIR = "#sweetdream_floor:room_air"
NEW_COST = {"moth": 2, "bark_guard": 3, "branch": 4}
TEAMS = {
    "normal": (("moth", "rooted", "cover"), ("bark_guard", "rooted", "cover"), ("bark_guard", "moss")),
    "hard": (("bark_guard", "moss", "cover"), ("moth", "bark_guard", "moss"),
             ("bark_guard", "moss", "resin", "cover")),
    "elite": (("branch", "rooted", "bark_guard", "cover"), ("branch", "moss", "bark_guard"),
              ("branch", "rooted", "resin", "bark_guard", "cover")),
    "ambush": (("branch", "moss", "bark_guard", "resin"), ("branch", "moss", "bark_guard", "rooted", "cover"),
               ("branch", "moss", "bark_guard", "rooted", "resin")),
}


def stage(world):
    functions = Path(world)/"datapacks/zz_sweetdream_floor/data/sweetdream_floor/function"
    mobs = functions/"combat/mobs"

    def m(name, *commands):
        write(mobs/f"{name}.mcfunction", "\n".join(commands))

    for mode, teams in TEAMS.items():
        for team in teams:
            points = sum((COST | NEW_COST)[kind] for kind in team)
            dispatch = mobs/f"group/{mode}_{points}.mcfunction"
            new = f"group/forest_{mode}_{points}"
            marker = f"function {COMBAT}{new}"
            if marker not in text(dispatch):
                write(dispatch, f'execute unless data storage {RUN} {{floor:2}} store result score #forest_team sd.floor run random value 1..4 sweetdream:rogue\n'
                      f'execute unless data storage {RUN} {{floor:2}} if score #forest_team sd.floor matches 1 run return run {marker}\n'+text(dispatch))
            m(new, f"data modify storage {RUN} encounter_team set value {literal(team)}",
              *(f"execute positioned ~{x} ~ ~{z} run function {COMBAT}spawn_{kind}" for kind, (x,z) in zip(team, ANCHORS)))

    tick = mobs/"tick.mcfunction"
    if "sd.mob.moth," not in text(tick):
        write(tick, text(tick)+"\n".join(f"execute as @e[tag=sd.mob.{kind},distance=0..] at @s run function {COMBAT}{kind}/tick"
                                        for kind in (*NEW_COST,"bark_shard")))
    for kind in ("root", "crown"):
        path = mobs/f"{kind}_tick.mcfunction"
        if LONG_ATTACK not in text(path):
            edit(path, (f"run function {COMBAT}"+("root_target" if kind=="root" else "sweep_start"),
                        f"{LONG_ATTACK} run function {COMBAT}"+("root_target" if kind=="root" else "sweep_start")))
    moth(m)
    bark_guard(m)
    branch(m)


def moth(m):
    glow = dust([1.0, .65, .17], .72)
    idle = dust([.87, .64, .28], .48)
    nbt = ('{Tags:["sd.floor_enemy","sd.mob.moth"],CustomName:{text:"挂灯蛾"},NoAI:1b,NoGravity:1b,BatFlags:0b,'
           'PersistenceRequired:1b,DeathLootTable:"minecraft:empty",Health:18f,'
           'attributes:[{id:"minecraft:max_health",base:18d},{id:"minecraft:scale",base:1.16d}]}')
    m("spawn_moth", f"summon minecraft:bat ~ ~.45 ~ {nbt}")
    m("moth/tick", "scoreboard players add @s sd.mob_time 1",
      "execute if score @s sd.mob_cd matches 1.. run scoreboard players remove @s sd.mob_cd 1",
      f"execute if entity @s[tag=sd.mob.moth_aim] run return run function {COMBAT}moth/aim",
      f"execute if entity @s[tag=sd.mob.moth_dash] run return run function {COMBAT}moth/dash",
      f"execute if entity @s[tag=sd.mob.moth_rest] run return run function {COMBAT}moth/rest",
      f"particle {idle} ~ ~.18 ~ 0 0 0 0 1 normal",
      f"execute if score @s sd.mob_time matches 50.. if entity {TARGET},distance=..6] {LONG_ATTACK} run return run function {COMBAT}moth/lock",
      f"execute if entity {TARGET},distance=..1.05] unless score @s sd.mob_cd matches 1.. run function {COMBAT}moth/touch",
      f"execute if entity {TARGET},distance=1.05..18] facing entity {TARGET},distance=1.05..18] feet rotated ~ 0 if block ^ ^ ^.32 {AIR} run tp @s ^ ^ ^.11 ~ 0")
    m("moth/touch", "scoreboard players set @s sd.mob_cd 24",
      f"damage {TARGET},distance=..1.05] 1.5 minecraft:mob_attack by @s")
    m("moth/lock", "scoreboard players set @s sd.mob_time 0", "tag @s add sd.mob.moth_aim", "tag @s add sd.mob.long_attack",
      f"execute facing entity {TARGET},distance=..6] feet rotated ~ 0 run tp @s ~ ~ ~ ~ 0",
      "playsound minecraft:block.copper_bulb.turn_on hostile @a[distance=..14] ~ ~ ~ .75 1.3")
    m("moth/aim", f"particle {glow} ~ ~.2 ~ .04 .05 .04 .01 4 normal",
      f"execute if score @s sd.mob_time matches 16.. run function {COMBAT}moth/launch")
    m("moth/launch", "tag @s remove sd.mob.moth_aim", "tag @s add sd.mob.moth_dash",
      f"tag {PLAYERS},distance=0..] remove sd.mob.moth_hit", "scoreboard players set @s sd.mob_time 0",
      "playsound minecraft:entity.bat.takeoff hostile @a[distance=..14] ~ ~ ~ .7 .9")
    m("moth/dash", f"execute positioned ^ ^ ^.55 unless block ~ ~ ~ {AIR} run return run function {COMBAT}moth/land",
      f"execute positioned ^ ^ ^.34 as {PLAYERS},tag=!sd.mob.moth_hit,distance=..1.0] run function {COMBAT}moth/hit",
      f"particle {glow} ~ ~.12 ~ .13 .04 .13 0 2 normal",
      "tp @s ^ ^ ^.55 ~ 0",
      f"execute if score @s sd.mob_time matches 12.. at @s run function {COMBAT}moth/land")
    m("moth/hit", "tag @s add sd.mob.moth_hit",
      "damage @s 3 minecraft:mob_attack by @e[tag=sd.mob.moth_dash,distance=..2,limit=1]")
    m("moth/land", "tag @s remove sd.mob.moth_dash", "tag @s remove sd.mob.long_attack", "tag @s add sd.mob.moth_rest",
      "scoreboard players set @s sd.mob_time 0",
      f"execute if block ~ ~-.4 ~ {AIR} run tp @s ~ ~-.36 ~",
      "particle minecraft:block{block_state:{Name:\"minecraft:coarse_dirt\"}} ~ ~.1 ~ .2 .05 .2 .03 12 normal")
    m("moth/rest", "execute unless score @s sd.mob_time matches 20.. run return 0", "tag @s remove sd.mob.moth_rest",
      f"execute if block ~ ~.4 ~ {AIR} run tp @s ~ ~.36 ~", "scoreboard players set @s sd.mob_time 0")


def bark_guard(m):
    nbt = mob("抱壳", "bark_guard", 32, 2, equipment("stripped_dark_oak_wood"), "CanBreakDoors:0b")
    shell = 'minecraft:shield[minecraft:base_color="brown",minecraft:death_protection={death_effects:[]}]'
    m("spawn_bark_guard", f"execute summon minecraft:husk run function {COMBAT}bark_guard/init")
    m("bark_guard/init", f"data merge entity @s {nbt}", "scoreboard players set @s sd.mob_hp 32000",
      f"function {COMBAT}bark_guard/hold")
    m("bark_guard/hold", f"item replace entity @s weapon.offhand with {shell}",
      "scoreboard players set @s sd.mob_count 2")
    m("bark_guard/tick", "execute if entity @s[nbt={DeathTime:1s}] run return 0",
      "execute if score @s sd.mob_cd matches 1.. run scoreboard players remove @s sd.mob_cd 1",
      f"execute if score @s sd.mob_cd matches 0 if score @s sd.mob_count matches 0 run function {COMBAT}bark_guard/hold",
      "execute store result score #bark_health sd.floor run data get entity @s Health 1000",
      f"execute if score @s sd.mob_count matches 1.. if score #bark_health sd.floor < @s sd.mob_hp run function {COMBAT}bark_guard/direction",
      "execute if score @s sd.mob_count matches 1.. unless items entity @s weapon.offhand minecraft:shield run return run kill @s",
      "execute store result score @s sd.mob_hp run data get entity @s Health 1000")
    # Measure the horizontal dot product in room coordinates so uphill shots
    # and either side of a cardinal boundary get the same frontal test.
    m("bark_guard/direction", "scoreboard players set #bark_player sd.floor 0",
      f"execute on attacker if entity @s[type=minecraft:player] run function {COMBAT}bark_guard/attacker",
      "execute unless score #bark_player sd.floor matches 1 run return 0",
      "execute store result score #bark_x sd.floor run data get entity @s Pos[0] 100",
      "execute store result score #bark_z sd.floor run data get entity @s Pos[2] 100",
      f"execute rotated ~ 0 positioned ^ ^ ^1 summon minecraft:marker run function {COMBAT}bark_guard/check_front",
      f"execute if score #bark_dot sd.floor matches 1.. run function {COMBAT}bark_guard/block")
    m("bark_guard/attacker", "scoreboard players set #bark_player sd.floor 1",
      "execute store result score #bark_dx sd.floor run data get entity @s Pos[0] 100",
      "execute store result score #bark_dz sd.floor run data get entity @s Pos[2] 100")
    m("bark_guard/check_front", "execute store result score #bark_fx sd.floor run data get entity @s Pos[0] 100",
      "execute store result score #bark_fz sd.floor run data get entity @s Pos[2] 100",
      *(f"scoreboard players operation #bark_{part}{axis} sd.floor -= #bark_{axis} sd.floor" for axis in "xz" for part in ("d", "f")),
      "scoreboard players operation #bark_dx sd.floor *= #bark_fx sd.floor",
      "scoreboard players operation #bark_dz sd.floor *= #bark_fz sd.floor",
      "scoreboard players operation #bark_dot sd.floor = #bark_dx sd.floor",
      "scoreboard players operation #bark_dot sd.floor += #bark_dz sd.floor", "kill @s")
    m("bark_guard/block", "execute store result entity @s Health float .001 run scoreboard players get @s sd.mob_hp",
      "scoreboard players remove @s sd.mob_count 1",
      f"execute if score @s sd.mob_count matches 1 run item replace entity @s weapon.offhand with {shell}",
      "playsound minecraft:item.shield.block hostile @a[distance=..14] ~ ~ ~ .85 .78",
      'particle minecraft:block{block_state:{Name:"minecraft:dark_oak_wood"}} ~ ~1 ~ .25 .24 .25 .02 18 normal',
      f"execute if score @s sd.mob_count matches 0 run function {COMBAT}bark_guard/drop")
    m("bark_guard/drop", "item replace entity @s weapon.offhand with minecraft:air", "scoreboard players set @s sd.mob_cd 80",
      "playsound minecraft:item.shield.break hostile @a[distance=..14] ~ ~ ~ .8 .9",
      f"execute positioned ^ ^ ^.8 if block ~ ~ ~ {AIR} positioned ~-.34 ~.025 ~-.24 summon minecraft:block_display run function {COMBAT}bark_shard/init")
    m("bark_shard/init", 'data merge entity @s {Tags:["sd.mob.bark_shard","sd.mob.prop"],block_state:{Name:"minecraft:dark_oak_wood"},transformation:{translation:[0f,0f,0f],left_rotation:[0f,0f,0f,1f],scale:[.68f,.13f,.48f],right_rotation:[0f,0f,0f,1f]}}')
    m("bark_shard/tick", "scoreboard players add @s sd.mob_time 1", "execute if score @s sd.mob_time matches 80.. run kill @s")


def branch(m):
    nbt = mob("空枝", "branch", 44, 2, equipment("stripped_pale_oak_wood"), "CanBreakDoors:0b")
    m("spawn_branch", f"execute summon minecraft:husk run function {COMBAT}branch/init")
    m("branch/init", f"data merge entity @s {nbt}", "scoreboard players set @s sd.mob_time 0")
    m("branch/tick", "scoreboard players add @s sd.mob_time 1",
      f"execute if entity @s[tag=sd.mob.branch_cast] run return run function {COMBAT}branch/swing",
      f"execute if score @s sd.mob_time matches 54.. if entity {TARGET},distance=..7] {LONG_ATTACK} run function {COMBAT}branch/lock")
    m("branch/lock", "tag @s add sd.mob.long_attack", "tag @s add sd.mob.branch_cast", "data merge entity @s {NoAI:1b}",
      f"execute facing entity {TARGET},distance=..7] feet rotated ~ 0 run tp @s ~ ~ ~ ~ 0",
      "scoreboard players set @s sd.mob_time 0", "playsound minecraft:block.pale_oak_wood.place hostile @a[distance=..14] ~ ~ ~ 1 .7")
    m("branch/swing",
      *(f"execute if score @s sd.mob_time matches {tick} run function {COMBAT}branch/{side}_cue"
        for tick,side in ((1,"left"),(4,"right"),(7,"left"),(10,"right"),(13,"left"),(16,"right"),(19,"left"),(22,"right"),(28,"right"))),
      *(f"execute if score @s sd.mob_time matches {tick} run function {COMBAT}branch/{side}_hit" for tick,side in ((20,"left"),(32,"right"))),
      f"execute if score @s sd.mob_time matches 39.. run function {COMBAT}branch/release")
    for name,x,col in (("left",-1.45,[.88,.84,.62]),("right",1.45,[.75,.85,.60])):
        offsets = range(1, 12)
        m(f"branch/{name}_cue", *(f"particle {dust(col,.9)} ^{x} ^.13 ^{t*.55:.2f} .08 .02 .08 0 2 normal" for t in offsets))
        m(f"branch/{name}_hit",
          *(f"execute positioned ^{x} ^.1 ^{t*.55:.2f} run tag {PLAYERS},distance=..0.69] add sd.mob.branch_hit" for t in offsets),
          f"execute as {PLAYERS},tag=sd.mob.branch_hit,distance=0..] run damage @s 3.5 minecraft:mob_attack by @e[tag=sd.mob.branch_cast,distance=0..,limit=1]",
          f"tag {PLAYERS},tag=sd.mob.branch_hit,distance=0..] remove sd.mob.branch_hit",
          "playsound minecraft:entity.player.attack.sweep hostile @a[distance=..16] ~ ~ ~ .85 .7")
    m("branch/release", "scoreboard players set @s sd.mob_time 0", "tag @s remove sd.mob.branch_cast",
      "tag @s remove sd.mob.long_attack", "data merge entity @s {NoAI:0b}")
