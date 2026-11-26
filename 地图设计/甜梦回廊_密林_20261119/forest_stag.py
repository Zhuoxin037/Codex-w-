"""The stage-four stag as the first floor's actual encounter."""

from math import cos, radians, sin
from pathlib import Path

from floor_upgrade import DIM, text, write
from forest_combat import dust
from forest_economy import FN, RUN, say
from stag_visual import NAMESPACE as S, stage as visuals

ACTOR = "@e[type=minecraft:marker,tag=sd.stag.actor,distance=0..,limit=1]"
BODY = "@e[type=minecraft:ravager,tag=sd.stag.body,distance=0..,limit=1]"
RIG = "@e[type=minecraft:item_display,tag=sd.stag.rig,distance=0..,limit=1]"
PARTS = "@e[type=minecraft:item_display,tag=sd.stag.part,distance=..18]"
PLAYER = "tag=sd.floor_run,tag=zx.rg_active,gamemode=!creative,gamemode=!spectator,scores={sd.floor_death=0}"
TARGET = f"@p[{PLAYER},distance=..32]"
AUDIENCE = f"@a[{PLAYER},distance=..40]"
SLEEPERS = "type=minecraft:villager,tag=zx.j_body"
SLEEP_TARGET = f"@e[{SLEEPERS},distance=..14,sort=nearest,limit=1]"
AIR = "#sweetdream_floor:room_air"
BAR = "sweetdream_floor:forest_stag"
OBJS = ("state","age","form","idle","cycle","move","clip","frame","last","hp","blocked","yaw","oldyaw","half","next")
HEALTH = 260
# Impact and recovery ages are shared with the exported animation playback.
TIMES = {1:(34,43),2:(42,37),3:(32,30),4:(44,40),5:(50,46)}
RUSH_STEPS = (.45,.58,.70,.80,.86,.90,.92,.92,.92,.92,.92,.86,.80,.72,.58,.44)
CLIP_TIMING = {
    "crown_sweep": (((0,0),(24,14),(54,34)), ((0,0),(24,14),(38,26),(74,43))),
    "root_call": (((0,0),(16,7),(30,16),(44,25),(76,42)), ((0,0),(16,9),(76,37))),
    "resin_cast": (((0,0),(18,8),(22,12),(26,16),(60,32)), ((0,0),(18,8),(24,14),(60,30))),
    "crown_slam": (((0,0),(26,18),(84,44)), ((0,0),(26,18),(84,40))),
    "charged_rush": (((0,0),(40,19),(64,35),(104,50)), ((0,0),(40,17),(64,33),(104,46))),
}


def stage(world, resource_root=None, rebuild_visuals=True):
    home = Path(world)/"datapacks/zz_sweetdream_floor/data/sweetdream_floor/function"

    def mc(name, *rows):
        write(home/f"stag/{name}.mcfunction", "\n".join(rows))

    def insert(name, anchor, line):
        p = home/f"{name}.mcfunction"
        old = text(p)
        if line not in old:
            if anchor not in old:
                raise ValueError(f"Missing stag hook in {p}")
            write(p, old.replace(anchor,line+"\n"+anchor,1))

    load = home/"load.mcfunction"
    if "sd.stag.state" not in text(load):
        write(load,text(load)+"\n".join((*(f"scoreboard objectives add sd.stag.{name} dummy" for name in OBJS),
                                      f'bossbar add {BAR} {{"text":"朽冠鹿"}}',
                                      f"bossbar set {BAR} max {HEALTH}",f"bossbar set {BAR} color green",
                                      f"bossbar set {BAR} style notched_10")))
    else:
        missing = [name for name in ("half","next") if f"scoreboard objectives add sd.stag.{name} " not in text(load)]
        if missing:
            write(load, text(load) + "\n".join(f"scoreboard objectives add sd.stag.{name} dummy" for name in missing))

    boss = home/"combat/boss.mcfunction"
    old_path = home/"combat/boss_knight.mcfunction"
    if not old_path.is_file():
        write(old_path,text(boss))
    write(boss,"\n".join((
        f'execute if data storage {RUN} {{floor:2}} run return run function {FN}combat/boss_knight',
        f"execute positioned ~ ~ ~-4 run function {S}spawn",
        f"execute unless entity {ACTOR} positioned ~ ~ ~4 run function {S}spawn",
        f"execute unless entity {ACTOR} run return run function {S}abort",
        say("朽冠鹿","green"))))
    info = home/"room/info/boss.mcfunction"
    info_knight = home/"room/info/boss_knight.mcfunction"
    if not info_knight.is_file():
        write(info_knight,text(info))
    write(info,"\n".join((f'execute if data storage {RUN} {{floor:2}} run return run function {FN}room/info/boss_knight',
                          text(info_knight).replace("坠梦骑士","朽冠鹿").replace("骑士守着遗迹的尽头。","根系从鹿蹄下散开。"))))
    insert("combat/tick", f"function {FN}combat/mobs/tick", f"execute if dimension {DIM} run function {S}world_tick")
    insert("combat/tick", f"execute unless entity @e[tag=sd.floor_enemy",
           f"execute if entity {ACTOR} run return 0")
    clean = home/"combat/clean_forest.mcfunction"
    call = f"execute in {DIM} run function {S}cleanup"
    if call not in text(clean):
        write(clean,call+"\n"+text(clean))

    mc("abort", f"function {S}cleanup", f"function {FN}combat/boss_abort")
    mc("spawn", f"execute if entity {ACTOR} run return 0",
       f"execute unless block ~ ~ ~ {AIR} run return 0",
       f"execute unless block ~ ~4 ~ {AIR} run return 0",
       f"execute if block ~ ~-1 ~ {AIR} run return 0",
       f"function {S}cleanup",f"execute summon minecraft:marker run function {S}init")
    mc("init", "tag @s add sd.stag.actor",
       f'summon minecraft:ravager ~ ~ ~ {{Tags:["sd.stag.body","sd.floor_enemy"],CustomName:{{text:"朽冠鹿"}},PersistenceRequired:1b,NoAI:1b,Silent:1b,NoGravity:1b,DeathLootTable:"minecraft:empty",Health:{HEALTH}f,attributes:[{{id:"minecraft:max_health",base:{HEALTH}d}},{{id:"minecraft:armor",base:9d}},{{id:"minecraft:armor_toughness",base:20d}},{{id:"minecraft:scale",base:1.22d}},{{id:"minecraft:attack_damage",base:0d}},{{id:"minecraft:knockback_resistance",base:1d}}],active_effects:[{{id:"minecraft:invisibility",amplifier:0,duration:-1,show_particles:0b,show_icon:0b}}]}}',
       *(row for party,hp in ((2,338),(3,416),(4,494)) for row in (
            f"execute if score #combat_party sd.floor matches {party}{'..' if party == 4 else ''} run attribute {BODY} minecraft:max_health base set {hp}",
            f"execute if score #combat_party sd.floor matches {party}{'..' if party == 4 else ''} run data modify entity {BODY} Health set value {hp}f")),
       *[f"scoreboard players set @s sd.stag.{key} {val}" for key,val in (("state",0),("age",0),("form",1),("cycle",0),("idle",15),("last",-1),("frame",0),("oldyaw",999),("next",0))],
       'summon minecraft:item_display ~ ~ ~ {Tags:["sd.stag.rig"],teleport_duration:1}',
       f"function {S}visual/1/spawn",f"function {S}mount",f"function {S}aim",
       f"execute at @s run function {S}sync",f"bossbar set {BAR} players {AUDIENCE}",
       f"execute store result bossbar {BAR} max run attribute {BODY} minecraft:max_health get",
       f"execute store result bossbar {BAR} value run data get entity {BODY} Health 1",f"bossbar set {BAR} visible true",
       f"particle minecraft:spore_blossom_air ~ ~1 ~ 1 .7 1 .04 30 normal {AUDIENCE}")
    mc("clear_fx", "kill @e[tag=sd.stag.fx,distance=0..]",
       f"tag {AUDIENCE} remove sd.stag.hit",f"tag {AUDIENCE} remove sd.stag.rushed",
       f"tag @e[{SLEEPERS},distance=0..] remove sd.stag.hit",f"tag @e[{SLEEPERS},distance=0..] remove sd.stag.rushed")
    mc("cleanup", f"function {S}clear_fx", "kill @e[tag=sd.stag.part,distance=0..]",f"kill {RIG}",
       "kill @e[tag=sd.stag.body,distance=0..]", "kill @e[tag=sd.stag.actor,distance=0..]",
       f"bossbar set {BAR} players",f"bossbar set {BAR} visible false")
    mc("world_tick",
       f"execute unless entity {ACTOR} if entity {BODY} run function {S}cleanup",
       f"execute as {ACTOR} at @s run function {S}tick")
    mc("tick", f"execute if score @s sd.stag.state matches 8 run return run function {S}death_tick",
       f"execute unless entity @e[type=minecraft:ravager,tag=sd.stag.body,distance=..5,nbt=!{{Health:0f}}] run return run function {S}death",
       f"execute if entity @e[type=minecraft:ravager,tag=sd.stag.body,tag=zx.stop,distance=..5] run return 0",
       f"execute store result score @s sd.stag.hp run data get entity {BODY} Health 1000",
       f"execute store result bossbar {BAR} value run data get entity {BODY} Health 1",
       f"bossbar set {BAR} players {AUDIENCE}",
       f"execute store result score @s sd.stag.half run attribute {BODY} minecraft:max_health get 500",
       f"execute if score @s sd.stag.form matches 1 if score @s sd.stag.hp <= @s sd.stag.half unless score @s sd.stag.state matches 7 run return run function {S}morph",
       "scoreboard players set @s sd.stag.move 0",
       f"execute if score @s sd.stag.state matches 0 run function {S}idle",
       f"execute if score @s sd.stag.state matches 1..7 run function {S}action",
       f"execute at @s run function {S}render",
       f"execute as @e[type=minecraft:marker,tag=sd.stag.fx,distance=..36] at @s run function {S}hazard/tick",
       f"execute as @e[type=minecraft:block_display,tag=sd.stag.root_prop,distance=..36] run function {S}hazard/root_prop")
    mc("turn", "tp @s ~ ~ ~ ~ 0", "scoreboard players set @s sd.stag.move 2")
    mc("aim",f"execute if entity {SLEEP_TARGET} facing entity {SLEEP_TARGET} feet rotated ~ 0 run return run function {S}turn",
       f"execute if entity {TARGET} facing entity {TARGET} feet rotated ~ 0 run function {S}turn")
    mc("mount", f"execute as {PARTS} run ride @s mount {RIG}")
    mc("sync", f"tp {BODY} ~ ~ ~ ~ 0",f"tp {RIG} ~ ~ ~",
       "execute store result score @s sd.stag.yaw run data get entity @s Rotation[0] 10",
       f"execute unless score @s sd.stag.yaw = @s sd.stag.oldyaw as {PARTS} run data modify entity @s Rotation set from entity {ACTOR} Rotation",
       "scoreboard players operation @s sd.stag.oldyaw = @s sd.stag.yaw")
    mc("render", f"execute if score @s sd.stag.move matches 1.. rotated as @s run function {S}sync",
       "scoreboard players operation @s sd.stag.clip = @s sd.stag.state",
       "execute if score @s sd.stag.state matches 0 if score @s sd.stag.move matches 1 run scoreboard players set @s sd.stag.clip 6",
       "execute if score @s sd.stag.state matches 7 run scoreboard players set @s sd.stag.clip 0",
       "scoreboard players add @s sd.stag.frame 1",
       "execute unless score @s sd.stag.clip = @s sd.stag.last run scoreboard players set @s sd.stag.frame 0",
       "execute if score @s sd.stag.state matches 1..5 run scoreboard players operation @s sd.stag.frame = @s sd.stag.age",
       "execute if score @s sd.stag.state matches 8 run scoreboard players operation @s sd.stag.frame = @s sd.stag.age",
       "execute if score @s sd.stag.clip matches 0 if score @s sd.stag.frame matches 60.. run scoreboard players set @s sd.stag.frame 0",
       "execute if score @s sd.stag.clip matches 6 if score @s sd.stag.frame matches 24.. run scoreboard players set @s sd.stag.frame 0",
       "scoreboard players operation @s sd.stag.last = @s sd.stag.clip",
       f"execute if score @s sd.stag.form matches 1 run function {S}visual/1/select",
       f"execute if score @s sd.stag.form matches 2 run function {S}visual/2/select")
    mc("idle", f"execute unless entity {TARGET} run return 0",
       "scoreboard players remove @s sd.stag.idle 1",
       f"execute if score @s sd.stag.idle matches ..0 run return run function {S}choose",
       f"execute if entity {SLEEP_TARGET} run return run function {S}walk_sleep",
       f"execute if entity @p[{PLAYER},distance=3.7..32] facing entity {TARGET} feet rotated ~ 0 positioned ^ ^ ^.22 run function {S}move/walk")
    mc("walk_sleep",f"execute if entity @e[{SLEEPERS},distance=3.7..14,sort=nearest,limit=1] facing entity {SLEEP_TARGET} feet rotated ~ 0 positioned ^ ^ ^.22 run function {S}move/walk")
    mc("choose", f"function {S}aim",
       "scoreboard players set @s sd.stag.age -1", "scoreboard players set @s sd.stag.blocked 0",
       f"execute if score @s sd.stag.next matches 5 run return run function {S}follow_rush",
       "scoreboard players add @s sd.stag.cycle 1",
       "execute if score @s sd.stag.form matches 1 if score @s sd.stag.cycle matches 5.. run scoreboard players set @s sd.stag.cycle 1",
       "execute if score @s sd.stag.form matches 2 if score @s sd.stag.cycle matches 6.. run scoreboard players set @s sd.stag.cycle 1",
       *[f"execute if score @s sd.stag.form matches {phase} if score @s sd.stag.cycle matches {i} run scoreboard players set @s sd.stag.state {st}"
         for phase,order in ((1,(1,2,4,3)),(2,(4,1,3,2,1))) for i,st in enumerate(order,1)],
       f"execute if score @s sd.stag.state matches 1 unless entity @p[{PLAYER},distance=..6] unless entity @e[{SLEEPERS},distance=..6] run scoreboard players set @s sd.stag.state 5",
       f"execute if score @s sd.stag.state matches 4 unless entity @p[{PLAYER},distance=..8] unless entity @e[{SLEEPERS},distance=..8] run scoreboard players set @s sd.stag.state 2")
    mc("follow_rush","scoreboard players set @s sd.stag.next 0","scoreboard players set @s sd.stag.state 5")
    mc("action", "scoreboard players add @s sd.stag.age 1",
       *[f"execute if score @s sd.stag.state matches {i} run return run function {S}attack/{name}" for i,name in enumerate(("sweep","roots","resin","slam","rush"),1)],
       f"execute if score @s sd.stag.state matches 7 run function {S}morph_tick")
    mc("finish", "scoreboard players set @s sd.stag.idle 10",
       "execute if score @s sd.stag.form matches 2 run scoreboard players set @s sd.stag.idle 6",
       "execute if score @s sd.stag.state matches 3 run scoreboard players set @s sd.stag.next 5",
       "execute if score @s sd.stag.state matches 3 run scoreboard players set @s sd.stag.idle 3",
       "scoreboard players set @s sd.stag.state 0", "scoreboard players set @s sd.stag.age 0")
    mc("morph", f"function {S}clear_fx", "scoreboard players set @s sd.stag.state 7", "scoreboard players set @s sd.stag.age 0",
       "scoreboard players set @s sd.stag.last -1", f"bossbar set {BAR} color yellow",
       f"playsound minecraft:block.wood.break hostile {AUDIENCE} ~ ~ ~ .8 .55")
    mc("morph_tick", f"execute if score @s sd.stag.age matches 4..30 run particle minecraft:block{{block_state:{{Name:\"minecraft:moss_block\"}}}} ~ ~1.5 ~ 1 .4 1 .1 10 normal {AUDIENCE}",
       f"execute if score @s sd.stag.age matches 13 run function {S}swap",
       f"execute if score @s sd.stag.age matches 26.. run function {S}finish")
    mc("swap", "kill @e[type=minecraft:item_display,tag=sd.stag.form1,distance=..10]",
       "scoreboard players set @s sd.stag.form 2", "scoreboard players set @s sd.stag.cycle 0",
       "scoreboard players set @s sd.stag.last -1", "scoreboard players set @s sd.stag.oldyaw 999",
       "scoreboard players set @s sd.stag.move 2",f"function {S}visual/2/spawn",f"function {S}mount",
       f"playsound minecraft:block.rooted_dirt.break hostile {AUDIENCE} ~ ~ ~ 1 .6")
    mc("death", f"function {S}clear_fx", "scoreboard players set @s sd.stag.state 8", "scoreboard players set @s sd.stag.age 0",
       f"bossbar set {BAR} value 0", f"playsound minecraft:block.wood.break hostile {AUDIENCE} ~ ~ ~ 1 .55",f"function {S}render")
    mc("death_tick", "scoreboard players add @s sd.stag.age 1",f"function {S}render",
       f"execute if score @s sd.stag.age matches 28 run particle minecraft:ash ~ ~1 ~ 1 .8 1 .07 70 normal {AUDIENCE}",
       f"execute if score @s sd.stag.age matches 30.. run function {S}cleanup")

    movement(mc)
    attacks(mc)
    hazards(mc)
    report = visuals(home,resource_root) if rebuild_visuals else None
    retime_visuals(home)
    return report


def retime_visuals(home):
    # Reuse the approved poses and retime only the game's playback.
    for clip, forms in CLIP_TIMING.items():
        for form, anchors in enumerate(forms,1):
            path = home / f"stag/visual/{form}/{clip}"
            frames = sorted(int(p.stem) for p in path.glob("[0-9]*.mcfunction"))
            if not frames:
                raise ValueError(f"Missing authored frames for {clip} phase {form}")
            dispatch = []
            for frame in frames:
                for (old_start,start),(old_end,end) in zip(anchors,anchors[1:]):
                    if old_start <= frame <= old_end:
                        age = start + round((frame-old_start)*(end-start)/(old_end-old_start))
                        dispatch.append((age,frame))
                        break
            write(path/"select.mcfunction","\n".join(
                f"execute if score @s sd.stag.frame matches {age} run function {S}visual/{form}/{clip}/{frame}"
                for age,frame in dispatch))


def movement(mc):
    samples = ((-2.35,-2.0),(-2.35,2.65),(2.35,-2.0),(2.35,2.65),(0.,0.),(0.,3.2))
    checks = " ".join(f"if block ^{x} ^{y} ^{z} {AIR}" for x,z in samples for y in (.15,2.65,3.7))
    footing = f"unless block ^-.75 ^-.2 ^-1.3 {AIR} unless block ^.75 ^-.2 ^1.25 {AIR}"
    mc("move/walk", f"execute {checks} {footing} run function {S}move/place")
    mc("move/place", "tp @s ~ ~ ~ ~ 0", "scoreboard players set @s sd.stag.move 1")
    mc("move/rush", "scoreboard players set @s sd.stag.blocked 1",
       f"execute {checks} {footing} run function {S}move/rush_safe")
    mc("move/rush_safe", "scoreboard players set @s sd.stag.blocked 0",f"function {S}move/place",f"function {S}geometry/rush_hit")


def mark_at(x,z,r=.61,y=.22,once=""):
    cmd=f"execute positioned ^{x:.3f} ^{y:.2f} ^{z:.3f} run tag "
    return tuple(cmd+f"{sel}[{filters}{once},distance=..{r}] add sd.stag.hit" for sel,filters in (("@a",PLAYER),("@e",SLEEPERS)))


def damage(power, cap):
    impact = f"{FN}combat/mobs/impact {{power:{power},cap:{cap}}}"
    return (f"execute as @a[{PLAYER},tag=sd.stag.hit,distance=..36] run function {impact}",
            f"execute as @e[{SLEEPERS},tag=sd.stag.hit,distance=..36] run function {impact}",
            f"tag {AUDIENCE} remove sd.stag.hit",f"tag @e[{SLEEPERS},distance=0..] remove sd.stag.hit")


def attacks(mc):
    gold = dust([.98,.63,.17],.9)
    root = dust([.69,.79,.35],.84)
    execute = "execute if score @s sd.stag.age matches "

    def at(t,name,form=None):
        restriction = f"if score @s sd.stag.form matches {form} " if form else ""
        return f"{execute}{t} {restriction}rotated as @s run function {S}{name}"

    def finish(state):
        return tuple(at(f"{t}..","finish",i) for i,t in enumerate(TIMES[state],1))

    def border(x,z,particle=gold):
        return f"particle {particle} ^{x:.3f} ^.12 ^{z:.3f} 0 0 0 0 1 normal {AUDIENCE}"

    sweep = [(r*sin(radians(a)),r*cos(radians(a))) for r in (.5,1.2,1.9,2.6,3.3,4.0,4.7,5.4)
             for a in range(-80,81,max(8,int(35/r)))]
    mc("geometry/sweep_cue",*[border(5.9*sin(radians(a)),5.9*cos(radians(a))) for a in range(-85,86,10)],
       *[border(r*sin(radians(a)),r*cos(radians(a))) for a in (-85,85) for r in (1.,2.,3.,4.,5.)])
    mc("geometry/sweep_hit",*[row for x,z in sweep for row in mark_at(x,z,.71,.22)],*damage(850,40),
       f"playsound minecraft:entity.player.attack.sweep hostile {AUDIENCE} ~ ~ ~ 1 .65")
    mc("attack/sweep",f"execute if score @s sd.stag.age matches 1..5 run function {S}aim",
       *[at(t,"geometry/sweep_cue") for t in (1,5,9,12)],at(14,"geometry/sweep_hit"),
       *[at(t,"geometry/sweep_cue",2) for t in (17,20,24)],at(26,"geometry/sweep_hit",2),*finish(1))
    mc("geometry/slam_cue",*[border(x,z) for x in (-1.95,1.95) for z in range(1,9)],
       *[border(x,z) for x in (-1.4,-.7,0,.7,1.4) for z in (.2,8.)])
    mc("geometry/slam_hit",*[row for x in (-1.45,-.72,0,.72,1.45) for z in (.45,1.1,1.75,2.4,3.05,3.7,4.35,5,5.65,6.3,6.95,7.6) for row in mark_at(x,z,.63)],
       *damage(1200,50),f"playsound minecraft:entity.ravager.step hostile {AUDIENCE} ~ ~ ~ 1.2 .55")
    mc("attack/slam",f"execute if score @s sd.stag.age matches 1..7 run function {S}aim",
       *[at(t,"geometry/slam_cue") for t in (2,7,12,16)],at(18,"geometry/slam_hit"),at(18,"hazard/bands",2),*finish(4))
    mc("attack/roots",*[at(t,"hazard/root_target",1) for t in (7,16,25)],
       at(7,"hazard/root_target",2),at(9,"hazard/bands",2),at(19,"hazard/root_target",2),*finish(2))
    mc("attack/resin",at(1,"hazard/reset_resin"),
       *[at(t,f"hazard/resin_mark/{idx}",1) for idx,t in enumerate((8,12,16),1)],
       at(8,"hazard/resin_mark/1",2),at(10,"hazard/resin_mark/2",2),at(14,"hazard/resin_mark/3",2),*finish(3))

    for x in (-1,1):
        name = "left" if x<0 else "right"
        mc(f"geometry/rush_rail/{name}",*[border(x*2.6,z,root) for z in range(1,15)])
    mc("geometry/rush_cue",f"function {S}geometry/rush_rail/left",f"function {S}geometry/rush_rail/right",
       *[border(x,13.5,root) for x in (-1.8,-1.2,-.6,0,.6,1.2,1.8)])
    mc("geometry/rush_hit",*[row for x in (-1.75,-.88,0,.88,1.75) for z in (-.45,.35,1.15) for row in mark_at(x,z,.92,.25,",tag=!sd.stag.rushed")],
       f"tag @a[{PLAYER},tag=sd.stag.hit,distance=..15] add sd.stag.rushed",
       f"tag @e[{SLEEPERS},tag=sd.stag.hit,distance=..15] add sd.stag.rushed",*damage(1050,45))
    mc("attack/rush", at(1,"geometry/rush_reset"),
       f"execute if score @s sd.stag.age matches 1..9 run function {S}aim",
       *[at(t,"geometry/rush_cue") for t in (2,6,10,13,16)],
       at(19,"geometry/rush_cue",1),
       *(f"{execute}{age} if score @s sd.stag.form matches {form} unless score @s sd.stag.blocked matches 1 rotated as @s positioned ^ ^ ^{step:.3f} run function {S}move/rush"
         for form,start in ((1,20),(2,18)) for age,step in enumerate(RUSH_STEPS,start)),*finish(5))
    mc("geometry/rush_reset",f"tag {AUDIENCE} remove sd.stag.rushed",f"tag @e[{SLEEPERS},distance=0..] remove sd.stag.rushed",
       f"playsound minecraft:entity.ravager.roar hostile {AUDIENCE} ~ ~ ~ .9 .65")


def hazards(mc):
    ring = dust([.95,.60,.18],.9)
    root = dust([.67,.78,.37],.8)
    mc("hazard/tick", "scoreboard players add @s sd.stag.age 1",
       f"execute if entity @s[tag=sd.stag.root_effect] run return run function {S}hazard/root_tick",
       *[f"execute if entity @s[tag=sd.stag.pool{n}] run return run function {S}hazard/resin_tick/{n}" for n in (1,2,3)])
    mc("hazard/root_target",f"execute if entity {SLEEP_TARGET} positioned as {SLEEP_TARGET} positioned ~ 81 ~ run return run function {S}hazard/root_make {{age:0,band:0}}",
       f"execute if entity {TARGET} positioned as {TARGET} positioned ~ 81 ~ run function {S}hazard/root_make {{age:0,band:0}}")
    mc("hazard/bands",*[f"execute positioned ^{side*2.65:.2f} ^ ^{z} run function {S}hazard/root_make {{age:{-i*3},band:1}}"
                          for side in (-1,1) for i,z in enumerate((2,3.25,4.5,5.75,7))])
    mc("hazard/root_make",f"execute unless block ~ ~ ~ {AIR} run return 0",
       f"execute if block ~ ~-1 ~ {AIR} run return 0",
       f"$execute summon minecraft:marker run function {S}hazard/root_init {{age:$(age),band:$(band)}}")
    mc("hazard/root_init", "tag @s add sd.stag.fx", "tag @s add sd.stag.root_effect",
       "$scoreboard players set @s sd.stag.age $(age)",
       "$scoreboard players set @s sd.stag.move $(band)")
    mc("hazard/root_tick",
       *[f"execute if score @s sd.stag.age matches {t} run function {S}hazard/root_cue" for t in (-8,-4,1,4,7,10)],
       f"execute if score @s sd.stag.age matches 12 run function {S}hazard/root_hit",
       "execute if score @s sd.stag.age matches 19.. run kill @s")
    mc("hazard/root_cue",
       *[f"execute unless score @s sd.stag.move matches 1 run particle {root} ~{2.0*sin(radians(a)):.3f} ~.11 ~{2.0*cos(radians(a)):.3f} 0 0 0 0 1 normal {AUDIENCE}" for a in range(0,360,36)],
       *[f"execute if score @s sd.stag.move matches 1 run particle {root} ~{1.02*sin(radians(a)):.3f} ~.11 ~{1.02*cos(radians(a)):.3f} 0 0 0 0 1 normal {AUDIENCE}" for a in range(0,360,90)])
    mc("hazard/root_hit",
       f"execute unless score @s sd.stag.move matches 1 run tag @a[{PLAYER},distance=..2.05] add sd.stag.hit",
       f"execute unless score @s sd.stag.move matches 1 run tag @e[{SLEEPERS},distance=..2.05] add sd.stag.hit",
       f"execute if score @s sd.stag.move matches 1 run tag @a[{PLAYER},distance=..1.10] add sd.stag.hit",
       f"execute if score @s sd.stag.move matches 1 run tag @e[{SLEEPERS},distance=..1.10] add sd.stag.hit",
       *damage(650,31),
       f"playsound minecraft:block.mangrove_roots.break hostile {AUDIENCE} ~ ~ ~ .8 .88",
       f"execute positioned ~-.34 ~.02 ~-.34 summon minecraft:block_display run function {S}hazard/root_display")
    mc("hazard/root_display", 'data merge entity @s {Tags:["sd.stag.fx","sd.stag.root_prop"],block_state:{Name:"minecraft:mangrove_roots"},transformation:{translation:[0f,0f,0f],scale:[.68f,1.25f,.68f],left_rotation:[0f,0f,0f,1f],right_rotation:[0f,0f,0f,1f]}}',
       "scoreboard players set @s sd.stag.age 0")
    mc("hazard/root_prop", "scoreboard players add @s sd.stag.age 1", "execute if score @s sd.stag.age matches 8.. run kill @s")
    mc("hazard/reset_resin", "kill @e[tag=sd.stag.resin,distance=0..]")
    for n,offset in ((1,-3.2),(2,0.),(3,3.2)):
        pool = f"@e[tag=sd.stag.pool{n},distance=0..,limit=1]"
        orb = f"@e[tag=sd.stag.orb{n},distance=0..,limit=1]"
        layer = f"@e[tag=sd.stag.layer{n},distance=0..,limit=1]"
        mc(f"hazard/resin_mark/{n}",
           f"execute unless entity {TARGET} run return 0",
           f"execute positioned as {TARGET} positioned ~ 81 ~ rotated as @s rotated ~ 0 positioned ^{offset} ^ ^.6 if block ~ ~ ~ {AIR} unless block ~ ~-1 ~ {AIR} summon minecraft:marker run function {S}hazard/resin_init/{n}")
        mc(f"hazard/resin_init/{n}", "tag @s add sd.stag.fx", "tag @s add sd.stag.resin", f"tag @s add sd.stag.pool{n}",
           "scoreboard players set @s sd.stag.age 0",
           f'execute at {ACTOR} rotated as {ACTOR} positioned ^ ^2.1 ^2.25 run summon minecraft:block_display ~ ~ ~ {{Tags:["sd.stag.fx","sd.stag.resin","sd.stag.orb{n}"],teleport_duration:11,block_state:{{Name:"minecraft:honey_block"}},transformation:{{translation:[-.17f,0f,-.17f],scale:[.34f,.36f,.34f],left_rotation:[0f,0f,0f,1f],right_rotation:[0f,0f,0f,1f]}}}}',
           f"playsound minecraft:block.honey_block.place hostile {AUDIENCE} ~ ~ ~ .65 1.25")
        mc(f"hazard/resin_tick/{n}",f"execute if score @s sd.stag.age matches 1 run tp {orb} ~ ~.05 ~",
           *[f"execute if score @s sd.stag.age matches {t} run function {S}hazard/resin_cue" for t in (1,4,7,10)],
           f"execute if score @s sd.stag.age matches 12 run function {S}hazard/resin_land/{n}",
           f"execute if score @s sd.stag.age matches 12..87 run effect give @a[{PLAYER},distance=..1.8] minecraft:slowness 1 1 true",
           f"execute if score @s sd.stag.age matches 88.. run kill {layer}",
           "execute if score @s sd.stag.age matches 88.. run kill @s")
        mc(f"hazard/resin_land/{n}",f"kill {orb}",
           f'summon minecraft:block_display ~-1.25 ~.025 ~-1.25 {{Tags:["sd.stag.fx","sd.stag.resin","sd.stag.layer{n}"],block_state:{{Name:"minecraft:honey_block"}},transformation:{{translation:[0f,0f,0f],scale:[2.5f,.07f,2.5f],left_rotation:[0f,0f,0f,1f],right_rotation:[0f,0f,0f,1f]}}}}',
           f"tag @a[{PLAYER},distance=..1.8] add sd.stag.hit",
           f"tag @e[{SLEEPERS},distance=..1.8] add sd.stag.hit",
           *damage(600,30),
           f"playsound minecraft:block.honey_block.slide hostile {AUDIENCE} ~ ~ ~ .85 .85")
    mc("hazard/resin_cue",*[f"particle {ring} ~{1.8*sin(radians(a)):.3f} ~.09 ~{1.8*cos(radians(a)):.3f} 0 0 0 0 1 normal {AUDIENCE}" for a in range(0,360,36)])
