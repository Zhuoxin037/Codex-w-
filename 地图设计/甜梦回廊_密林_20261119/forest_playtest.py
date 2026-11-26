"""Prelight the floor, end personal sessions on rejoin, and tune the hunter."""

from itertools import product
from math import cos, radians, sin
from pathlib import Path

from floor_upgrade import text, write
from forest_combat import dust

F = "sweetdream_floor:"
ROGUE = "fallendream:rogue/"
ALIVE = "tag=sd.floor_run,tag=zx.rg_active,scores={sd.floor_death=0},gamemode=!creative,gamemode=!spectator"
SLEEPER = "type=minecraft:villager,tag=zx.j_body"
HUNTER = F + "combat/mobs/hunter/"


def stage(world):
    data = Path(world) / "datapacks/zz_sweetdream_floor/data"
    home = data / "sweetdream_floor/function"

    def mc(name, *rows):
        write(home / f"{name}.mcfunction", "\n".join(rows))

    def before(path, anchor, addition):
        body = text(path)
        if addition not in body:
            if body.count(anchor) != 1:
                raise ValueError(f"Expected one {anchor!r} in {path}")
            write(path, body.replace(anchor, addition + "\n" + anchor, 1))

    lighting(data, home, mc, before)
    rejoin(home, mc, before)
    hunter(home, mc)


def lighting(data, home, mc, before):
    # Place ambient light after the halls and door trims finish carving.
    # Delayed furniture still owns its lanterns and authored local lighting.
    r = data / "fallendream/function/rogue"
    before(r / "gen/build_links.mcfunction", "data modify storage zx:rogue built set value 1b",
           f"function {F}scene/light_all")
    mc("scene/light_all",
       *(f'execute if data storage zx:rogue floor.cells[{{cell:{i},present:1b}}] run function {F}scene/light_cell with storage zx:rogue floor.cells[{i}]'
         for i in range(25)))
    mc("scene/light_cell", f"$execute positioned $(x) 80 $(z) run function {F}scene/light/$(radius)")
    for radius in (13, 14, 17):
        # A symmetric grid at head height lights the floor. Fill the canopy
        # separately where its leaves do not occupy the chosen air.
        axis = sorted({-radius + 1, radius - 1, *range(-radius + 3, radius - 1, 4)})
        near_doors = [(sign * (radius - 1), cross) for sign in (-1, 1) for cross in (-2, 0, 2)]
        edge = near_doors + [(z, x) for x, z in near_doors]
        grid = list(product(axis, repeat=2))
        points = dict.fromkeys([(x, 2, z) for x, z in grid + edge] +
                               [(x, 6, z) for x, z in grid])
        mc(f"scene/light/{radius}", *(f"setblock ~{x} ~{y} ~{z} minecraft:light[level=15] keep"
                                     for x, y, z in points))
    scene = home / "scene/furnish.mcfunction"
    anchor = f"$function {F}room/vendor/check with storage zx:rogue floor.cells[$(cell)]"
    before(scene, anchor, f"$function {F}scene/light_cell {{x:$(x),z:$(z),radius:$(radius)}}")


def rejoin(home, mc, before):
    before(home / "load.mcfunction", "scoreboard objectives add sd.event_time dummy",
           "\n".join(("scoreboard objectives add sd.logout minecraft.custom:minecraft.leave_game",
                      "scoreboard objectives add sd.logout_snap dummy",
                      "scoreboard objectives add sd.last_online dummy")))
    before(home / "tick.mcfunction", f"function {F}lobby/healing/tick", f"function {F}lobby/rejoin/tick")
    mc("lobby/rejoin/tick",
       "scoreboard players add #online_tick sd.floor 0",
       "scoreboard players operation #online_prev sd.floor = #online_tick sd.floor",
       "scoreboard players add #online_tick sd.floor 1",
       f"execute as @a at @s run function {F}lobby/rejoin/check")
    mc("lobby/rejoin/check",
       "scoreboard players add @s sd.logout 0",
       "execute unless score @s sd.logout = @s sd.logout_snap run tag @s add sd.rejoin_pending",
       "execute unless score @s sd.last_online = #online_prev sd.floor run tag @s add sd.rejoin_pending",
       "scoreboard players operation @s sd.logout_snap = @s sd.logout",
       "scoreboard players operation @s sd.last_online = #online_tick sd.floor",
       f"execute if entity @s[tag=sd.rejoin_pending] run function {F}lobby/rejoin/return")
    mc("lobby/rejoin/return",
       "execute if data entity @s {Health:0f} run return 0",
       f"execute if entity @s[tag=sd.training] run function {F}training/leave",
       "execute if entity @s[tag=sd.training] run return 0",
       "execute if entity @s[tag=sd.floor_run] run function fallendream:lib/uuid",
       'execute if entity @s[tag=sd.floor_run] unless data storage zx:data self{ok:1b} run return 0',
       f"function {F}lobby/back",
       "tag @s remove sd.lobby_ready",
       "tag @s remove sd.rejoin_pending")
    # Do not trigger room entry while a reconnect is waiting for ManaCore
    # to restore the player's slot and finish the normal exit path.
    for name in ("run/player_tick", "training/player_tick"):
        path = home / f"{name}.mcfunction"
        original = text(path)
        guard = "execute if entity @s[tag=sd.rejoin_pending] run return 0"
        if guard not in original:
            write(path, guard + "\n" + original)
    clock = home / "clock/running.mcfunction"
    original = text(clock)
    guard = "execute if entity @s[tag=sd.rejoin_pending] run return 0"
    if guard not in original:
        write(clock, guard + "\n" + original)


def hunter(home, mc):
    directory = home / "combat/mobs"
    init = directory / "init_crown.mcfunction"
    write(init, text(init).replace('{id:"minecraft:attack_damage",base:4d}',
                                   '{id:"minecraft:attack_damage",base:5d},{id:"minecraft:movement_speed",base:0.29d}'))
    target = f"@p[{ALIVE},distance=..7]"
    spectators = f"@a[{ALIVE},distance=..20]"
    facing = f"execute facing entity {target} feet rotated ~ 0 run tp @s ~ ~ ~ ~ 0"
    busy = "@e[tag=sd.mob.long_attack,distance=0..]"
    write(directory / "crown_tick.mcfunction", "\n".join((
          "scoreboard players add @s sd.mob_time 1",
          f"execute if entity @s[tag=sd.mob.hunter_cast] run return run function {HUNTER}sequence",
          f"execute if score @s sd.mob_time matches 56.. if entity {target} unless entity {busy} run function {HUNTER}start")))
    mc("combat/mobs/hunter/start",
       "tag @s add sd.mob.hunter_cast",
       "tag @s add sd.mob.long_attack",
       "data merge entity @s {NoAI:1b}",
       "scoreboard players set @s sd.mob_time 0",
       facing,
       f"playsound minecraft:block.wood.hit hostile {spectators} ~ ~ ~ 1 .7",
       f"execute rotated as @s run function {HUNTER}sweep_cue")
    mc("combat/mobs/hunter/sequence",
       f"execute if score @s sd.mob_time matches 1..5 if entity {target} run function {HUNTER}aim",
       *(f"execute if score @s sd.mob_time matches {t} rotated as @s run function {HUNTER}sweep_cue" for t in (5,8)),
       f"execute if score @s sd.mob_time matches 11 rotated as @s run function {HUNTER}sweep_hit",
       f"execute if score @s sd.mob_time matches 15 if entity {target} run function {HUNTER}aim",
       *(f"execute if score @s sd.mob_time matches {t} rotated as @s run function {HUNTER}thrust_cue" for t in (15,19,22)),
       f"execute if score @s sd.mob_time matches 25 rotated as @s run function {HUNTER}thrust_hit",
       f"execute if score @s sd.mob_time matches 30.. run function {HUNTER}finish")
    mc("combat/mobs/hunter/aim", facing)
    mc("combat/mobs/hunter/finish", "tag @s remove sd.mob.hunter_cast", "tag @s remove sd.mob.long_attack",
       "scoreboard players set @s sd.mob_time 0", "data merge entity @s {NoAI:0b}")
    orange = dust([1.,.48,.25],1.0)
    pale = dust([1.,.8,.44],.95)

    def polar(radius, angle):
        return radius*sin(radians(angle)), radius*cos(radians(angle))

    def cue(x, z, particle):
        return f"particle {particle} ^{x:.3f} ^.14 ^{z:.3f} 0 0 0 0 1 normal {spectators}"

    def strike(name, points, power, cap):
        hits = []
        for x,z in points:
            for selector in (f"@a[{ALIVE}", f"@e[{SLEEPER}"):
                hits.append(f"execute positioned ^{x:.3f} ^.20 ^{z:.3f} run tag {selector},distance=..0.65] add sd.mob.hunter_hit")
        mc(f"combat/mobs/hunter/{name}", *hits,
           *(f"execute as {sel}tag=sd.mob.hunter_hit,distance=..12] run function {F}combat/mobs/impact {{power:{power},cap:{cap}}}" for sel in ("@a[","@e[type=minecraft:villager,")),
           "tag @a[tag=sd.mob.hunter_hit,distance=..12] remove sd.mob.hunter_hit",
           "tag @e[type=minecraft:villager,tag=sd.mob.hunter_hit,distance=..12] remove sd.mob.hunter_hit",
           f"playsound minecraft:entity.player.attack.sweep hostile {spectators} ~ ~ ~ 1 .67")

    angles = range(-69,70,9)
    mc("combat/mobs/hunter/sweep_cue", *(cue(*polar(4.75, a), orange) for a in angles),
       *(cue(*polar(r,a), orange) for a in (-69,69) for r in (1,2,3,4)))
    strike("sweep_hit", [polar(r,a) for r in (.5,1.25,2,2.75,3.5,4.25)
                          for a in range(-66,67,12)], 800, 38)
    mc("combat/mobs/hunter/thrust_cue", *(cue(x,z,pale) for x in (-1.3,1.3) for z in range(1,8)),
       *(cue(x,7.4,pale) for x in (-.65,0,.65)))
    strike("thrust_hit", [(x,z) for x in (-.75,0,.75) for z in (.5,1.25,2,2.75,3.5,4.25,5,5.75,6.5,7)], 900, 44)
