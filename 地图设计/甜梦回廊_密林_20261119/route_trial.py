"""Compile a standalone playable road-room and clickable-map sample."""

import json
from pathlib import Path

from route_trial_scenes import (
    COLLAPSE, DIMENSION, EDGES, MAP_VIEWS, ROAD_ARRIVAL, ROOMS, TREE,
    MapView, compact, content, display, map_art, road,
)


NS = "fallenroute:"
STATE = "fallenroute:view"
CONTENT_Z = 96
MODE = "rd.mode"
ROOM = "rd.room"
STEPS = "rd.steps"
SYS = "rd.sys"
MAP_NAME = '{text:"密林地图",color:"gold",italic:false}'
MAP_STACK = ('minecraft:carrot_on_a_stick[minecraft:item_model="minecraft:filled_map",'
             f'minecraft:item_name={MAP_NAME},minecraft:custom_data={{rd_map:1b}},minecraft:unbreakable={{}}]')
PORTALS = (
    (-1, 81, -17, 2, 2, 0, 0, -15, "z"),
    (-17, 81, -1, 0, 2, 2, -15, 0, "x"),
    (17, 81, -1, 0, 2, 2, 15, 0, "x"),
)
ROOMS_BY_ID = tuple(range(len(ROOMS)))
NEIGHBORS = tuple(tuple(sorted(b if a == i else a for a,b in EDGES if i in (a,b))) for i in ROOMS_BY_ID)
REACH_MOD = "fallenroute:map_reach"


def say(text, color="white"):
    return f"tellraw @s {compact({'text':text,'color':color})}"


def action(text, color="white"):
    return f"title @s actionbar {compact({'text':text,'color':color})}"


def here(name, args=""):
    return f"function {NS}{name}" + (f" {args}" if args else "")


def block_if(a,b):
    edge = tuple(sorted((a,b)))
    if edge == TREE:
        return f" if score #tree {SYS} matches 1"
    if edge == COLLAPSE:
        return f" if score #collapse {SYS} matches 0"
    return ""


def stage(world):
    pack = Path(world)/"datapacks/fallenroute_trial"

    def data(path, doc):
        path = pack / path
        path.parent.mkdir(parents=True,exist_ok=True)
        path.write_text(json.dumps(doc,ensure_ascii=False,indent=2)+"\n",encoding="utf8")

    def mc(name, *lines):
        path = pack / f"data/fallenroute/function/{name}.mcfunction"
        path.parent.mkdir(parents=True,exist_ok=True)
        path.write_text("\n".join(lines)+"\n",encoding="utf8")

    data("pack.mcmeta", {"pack":{"pack_format":71,"description":"坠梦 · 道路房互动试作"}})
    for event in ("load", "tick"):
        data(f"data/minecraft/tags/function/{event}.json", {"values":[NS+event]})
    data("data/fallenroute/dimension/forest.json", {
        "type":"minecraft:overworld",
        "generator":{"type":"minecraft:flat","settings":{
            "biome":"minecraft:dark_forest","layers":[{"block":"minecraft:air","height":1}],
            "lakes":False,"features":False,"structure_overrides":[],
        }},
    })

    construction(mc)
    players(mc)
    movement(mc)
    navigation(mc)
    map_view(mc, data)
    from route_trial_art import stage_resources
    stage_resources(world, (kind for _,_,kind,*_ in ROOMS))


def construction(mc):
    objectives = (MODE, ROOM, STEPS, SYS, "rd.back", "rd.map_quiet")
    mc("load", *(f"scoreboard objectives add {o} dummy" for o in objectives),
       "scoreboard objectives add rd.use minecraft.used:minecraft.carrot_on_a_stick",
       "scoreboard objectives add rd.death deathCount",
       "gamerule naturalRegeneration false",
       "gamerule doMobSpawning false", "gamerule doMobLoot false",
       "gamerule doWeatherCycle false", "gamerule doDaylightCycle false",
       "gamerule keepInventory true", "gamerule spawnRadius 0", "time set 7000",
       "execute in minecraft:overworld run forceload add 0 0",
       f"execute in {DIMENSION} if score #built {SYS} matches 1 unless score #local_map {SYS} matches 1 run {here('build/upgrade')}",
       f"execute unless score #built {SYS} matches 1 run schedule function {NS}build/request 1t replace")
    areas = [(-21,-21,21,21), *((x-15,CONTENT_Z-15,x+15,CONTENT_Z+15) for x,*_ in ROOMS)]
    mc("build/request",
       *(f"execute in {DIMENSION} run forceload add {a} {b} {c} {d}" for a,b,c,d in areas),
       f"schedule function {NS}build/check 10t replace")
    chunks = set()
    for a,b,c,d in areas:
        for x in range(a//16,c//16+1):
            for z in range(b//16,d//16+1):
                chunks.add((16*x,16*z))
    mc("build/check", f"execute if score #built {SYS} matches 1 run return 0",
       "execute in minecraft:overworld if loaded 0 80 0 run fill -5 80 -5 5 80 5 minecraft:moss_block",
       "execute in minecraft:overworld run setworldspawn 0 81 0",
       *(f"execute in {DIMENSION} unless loaded {x} 80 {z} run return run schedule function {NS}build/check 10t replace"
         for x,z in sorted(chunks)),
       f"execute in {DIMENSION} run {here('build/stage')}")
    mc("build/upgrade", "kill @e[tag=rd.scene,distance=0..]",
       "kill @e[type=minecraft:interaction,tag=rd.node,tag=!rd.shrub,tag=!rd.ui,distance=0..]",
       "forceload remove -9 -98 9 -87", f"scoreboard players set #local_map {SYS} 1")
    mc("build/stage", f"scoreboard players set #local_map {SYS} 1",
       f"execute positioned 0 80 0 run {here('build/road')}",
       *(f"execute positioned {x} 80 {CONTENT_Z} run {here('build/content_'+str(i))}" for i,(x,*_) in enumerate(ROOMS)),
       f"scoreboard players set #built {SYS} 1")
    mc("build/road", *road())
    for i in ROOMS_BY_ID:
        mc(f"build/content_{i}", *content(i))


def players(mc):
    mc("tick", f"execute unless score #built {SYS} matches 1 run return 0",
       f"execute unless entity @a[tag=rd.ready] as @a[tag=!rd.ready,limit=1] at @s run {here('player/join')}",
       f"execute as @a[tag=rd.ready,limit=1] at @s run {here('player/tick')}",
       f"execute in {DIMENSION} as @e[type=minecraft:interaction,tag=rd.ui,distance=0..] at @s if data entity @s interaction.player run {here('map/click')}",
       f"execute in {DIMENSION} as @e[type=minecraft:interaction,tag=rd.shrub,distance=0..] at @s if data entity @s interaction.player run {here('road/cut_interaction')}")
    mc("player/join", "tag @s add rd.ready", "gamemode adventure @s",
       f"scoreboard players set @s {STEPS} 8",
       "scoreboard players set @s rd.death 0", "scoreboard players set @s rd.use 0",
       f"scoreboard players set #tree {SYS} 0", f"scoreboard players set #collapse {SYS} 0",
       f"scoreboard players set #fight {SYS} 0", "tag @s add rd.seen_0",
       'item replace entity @s hotbar.0 with minecraft:stone_sword',
       'item replace entity @s hotbar.1 with minecraft:wooden_sword',
       f"item replace entity @s hotbar.8 with {MAP_STACK}",
       f"execute in {DIMENSION} run {here('room/land_0')}",
       say("走进黑口到道路房。按 9 握住地图，右键展开。","gold"))
    mc("player/tick", f"execute if data entity @s {{Health:0.0f}} if score @s {MODE} matches 2 run return run {here('map/close')}",
       "execute if data entity @s {Health:0.0f} run return 0",
       f"execute if score @s rd.death matches 1.. run return run {here('player/respawn')}",
       f"execute unless dimension {DIMENSION} run return run {here('player/respawn')}",
       f"execute if entity @s[y=-64,dy=125] run return run {here('player/respawn')}",
       f"execute if score @s {MODE} matches 2 unless entity @s[tag=rd.map_open] run return run {here('map/migrate')}",
       f'execute if score @s rd.use matches 1.. if items entity @s weapon.mainhand *[minecraft:custom_data~{{rd_map:1b}}] run return run {here("map/input")}',
       "scoreboard players set @s rd.use 0",
       "execute unless score @s rd.map_quiet matches 7.. run scoreboard players add @s rd.map_quiet 1",
       f"execute if score @s {MODE} matches 0 run return run {here('room/tick')}",
       f"execute if score @s {MODE} matches 1 run return run {here('road/tick')}",
       here("map/tick"))
    mc("player/respawn", "scoreboard players set @s rd.death 0",
       f"execute in {DIMENSION} run {here('map/leave')}",
       f"execute in {DIMENSION} run {here('room/land_0')}")
    mc("player/steps", 'title @s actionbar [{text:"探索  ",color:"aqua"},{score:{name:"@s",objective:"rd.steps"},color:"white"}]')


def movement(mc):
    for i,(x,name,*_) in enumerate(ROOMS):
        mc(f"room/land_{i}", f"execute if score @s {MODE} matches 2 run {here('map/leave')}",
           f"scoreboard players set @s {ROOM} {i}",
           f"scoreboard players set @s {MODE} 0", f"tp @s {x}.5 81 {CONTENT_Z+6}.5 180 0",
           f'title @s title {compact({"text":name,"color":"gold"})}', here("player/steps"))
        extra = ()
        if i == 1:
            extra = (f"execute if score #new {SYS} matches 1 run {here('room/fight_start')}",)
        if i == 4:
            extra = (f"execute if score #new {SYS} matches 1 if score @s {ROOM} matches 1 run {here('room/collapse')}",)
        mc(f"room/enter_{i}", f"scoreboard players set #new {SYS} 0",
           f"execute if entity @s[tag=!rd.seen_{i}] unless score @s {STEPS} matches 1.. run return run " + say("探索次数不足。","yellow"),
           f"execute if entity @s[tag=!rd.seen_{i}] run scoreboard players set #new {SYS} 1",
           f"execute if score #new {SYS} matches 1 run scoreboard players remove @s {STEPS} 1",
           f"tag @s add rd.seen_{i}", *extra, here(f"room/land_{i}"))
    mc("room/tick",
       f"execute if score @s {ROOM} matches 1 if score #fight {SYS} matches 1 if entity @e[tag=rd.mob,distance=..28] run return 0",
       f"execute if score @s {ROOM} matches 1 if score #fight {SYS} matches 1 run {here('room/fight_done')}",
       *(f"execute if score @s {ROOM} matches {i} positioned {x-1} 81 {CONTENT_Z+11} if entity @s[dx=2,dy=2,dz=0] run return run {here('road/enter')}"
         for i,(x,*_) in enumerate(ROOMS)))
    mc("room/fight_start", f"scoreboard players set #fight {SYS} 1",
       'summon minecraft:husk 69.5 81 89.5 {Tags:["rd.mob"],PersistenceRequired:1b,Health:12f,attributes:[{id:"minecraft:max_health",base:12d}]}',
       'summon minecraft:husk 76.5 81 90.5 {Tags:["rd.mob"],PersistenceRequired:1b,Health:12f,attributes:[{id:"minecraft:max_health",base:12d}]}',
       say("清理断桥后，来路会重新开启。","gold"))
    mc("room/fight_done", f"scoreboard players set #fight {SYS} 2", say("断桥已清理。","green"))
    mc("room/collapse", f"scoreboard players set #collapse {SYS} 1",
       say("断桥方向的来路塌了。沿林地支路可以绕回去。","gold"),
       "playsound minecraft:block.gravel.break player @s ~ ~ ~ 1 .65")

    mc("road/enter", f"execute if score @s {MODE} matches 2 run {here('map/leave')}",
       f"scoreboard players set @s {MODE} 1", f"tp @s {ROAD_ARRIVAL}",
       here("road/render"), here("player/steps"))
    mc("road/tick",
       *(f"execute positioned {x} {y} {z} if entity @s[dx={dx},dy={dy},dz={dz}] run return run {here(f'road/slot_{slot}')}"
         for slot,(x,y,z,dx,dy,dz,*_) in enumerate(PORTALS)),
       f"execute positioned -1 81 17 if entity @s[dx=2,dy=2,dz=0] run return run {here('road/return')}")
    mc("road/return", *(f"execute if score @s {ROOM} matches {i} run return run {here(f'room/land_{i}')}" for i in ROOMS_BY_ID))
    for slot in range(len(PORTALS)):
        mc(f"road/slot_{slot}", *(f"execute if score @s {ROOM} matches {a}{block_if(a,choices[slot])} run return run {here(f'room/enter_{choices[slot]}')}"
                                 for a,choices in enumerate(NEIGHBORS) if slot < len(choices)))
    roads(mc)


def roads(mc):
    mc("road/render", "kill @e[tag=rd.sign,distance=0..]", "kill @e[tag=rd.shrub,distance=0..]",
       display(0.5,84.26,15.7,"返回来房","#e0c490",1,"rd.sign"),
       *(f"execute if score @s {ROOM} matches {i} run {here(f'road/render_{i}')}" for i in ROOMS_BY_ID))
    for i,choices in enumerate(NEIGHBORS):
        rows = []
        for slot,(*_,x,z,axis) in enumerate(PORTALS):
            a, b = (f"{x-1} 81 {z-1}",f"{x+1} 84 {z+1}") if axis == "x" else (f"{x-1} 81 {z}",f"{x+1} 84 {z}")
            rows.append(f"fill {a} {b} air")
            lo, hi = sorted((x or z, int((x or z)*.55)))
            floor = f"{lo} 80 -1 {hi} 80 1" if axis == "x" else f"-1 80 {lo} 1 80 {hi}"
            rows.append(f"fill {floor} rooted_dirt")
            if slot >= len(choices):
                rows.append(f"fill {a} {b} dark_oak_leaves[persistent=true]")
                continue
            neighbor = choices[slot]
            label_x, label_z = x*.86+.5, z*.86+.5
            rows.append(display(label_x,84.35,label_z,ROOMS[neighbor][1],"#efdeba",1.0,"rd.sign"))
            edge = tuple(sorted((i,neighbor)))
            if edge == TREE:
                block = f"execute if score #tree {SYS} matches 0 run "
                rows.extend((f"fill {floor} moss_block",
                             block + f"fill {a} {b} azalea_leaves[persistent=true]",
                             block + f"setblock {x} 81 {z} rooted_dirt",
                             block + display(label_x,83.2,label_z,"手持剑右键剪开","#aed496",.89,"rd.sign"),
                             block + f'summon minecraft:interaction {x*.92+.5} 81 {z*.92+.5} {{Tags:["rd.shrub","rd.node"],width:2.9f,height:2.6f,response:1b}}'))
            if edge == COLLAPSE:
                block = f"execute if score #collapse {SYS} matches 1 run "
                rows.extend((block + f"fill {a} {b} cobblestone", block + f"setblock {x} 84 {z} tuff",
                             block + display(label_x,83.2,label_z,"塌方","#ec8d72",1,"rd.sign")))
        mc(f"road/render_{i}", *rows)
    mc("road/cut_interaction", f"data modify storage {STATE} click.uuid set from entity @s interaction.player",
       "data remove entity @s interaction", f"{here('road/cut_resolve')} with storage {STATE} click")
    mc("road/cut_resolve", '$execute as @a[tag=rd.ready,scores={rd.mode=1},nbt={UUID:$(uuid)}] at @s run ' + here("road/cut"))
    mc("road/cut", f"execute if score #tree {SYS} matches 1 run return 0",
       "execute unless items entity @s weapon.mainhand #minecraft:swords run return run " + action("手持备用木剑右键树丛。","gold"),
       "item replace entity @s weapon.mainhand with minecraft:air", f"scoreboard players set #tree {SYS} 1",
       "playsound minecraft:block.azalea_leaves.break player @s ~ ~ ~ 1 .82", here("road/render"),
       say("树丛已打开，铸造坊和占星室之间可以直接通行。","green"))


def navigation(mc):
    mc("map/input", "scoreboard players set @s rd.use 0",
       "execute if score @s rd.map_quiet matches ..5 run return run scoreboard players set @s rd.map_quiet 0",
       "scoreboard players set @s rd.map_quiet 0", here("map/use"))
    mc("map/use",
       f"execute if score @s {MODE} matches 2 run return run {here('map/close')}",
       f"execute if score @s {ROOM} matches 1 if score #fight {SYS} matches 1 run return run " + action("清理断桥后可打开地图。","gold"),
       here("map/open"))
    mc("map/open", f"execute anchored eyes positioned ^ ^ ^ rotated ~ 0 run {here('map/place')}")
    mc("map/leave", "kill @e[tag=rd.ui,distance=0..]", "tag @s remove rd.map_open", "tag @s remove rd.paper_map",
       f"attribute @s minecraft:entity_interaction_range modifier remove {REACH_MOD}")
    mc("map/close", here("map/leave"), f"scoreboard players operation @s {MODE} = @s rd.back")
    mc("map/migrate", here("map/close"), f"{here('map/restore_old_position')} with storage {STATE} return")
    mc("map/restore_old_position", "$tp @s $(x) $(y) $(z) $(yaw) $(pitch)")
    mc("map/click", f"data modify storage {STATE} click.uuid set from entity @s interaction.player",
       "data remove entity @s interaction", f"scoreboard players set #pick {SYS} -1",
       *(f"execute if entity @s[tag=rd.node_{i}] run scoreboard players set #pick {SYS} {i}" for i in ROOMS_BY_ID),
       f"{here('map/resolve')} with storage {STATE} click")
    mc("map/resolve", '$execute as @a[tag=rd.map_open,scores={rd.mode=2},nbt={UUID:$(uuid)}] at @s run ' + here("map/select"))
    mc("map/select", f"execute if score #pick {SYS} matches -1 run return run {here('map/close')}",
       here("map/availability"),
       *(f"execute if score #pick {SYS} matches {i} if score #{flag}{i} {SYS} matches 1 run return run {here(f'room/enter_{i}')}"
         for i in ROOMS_BY_ID for flag in ("reach","fresh")),
       action("这间房当前不可达。","yellow"))

    pairs = [(a,b) for edge in EDGES for a,b in (edge,edge[::-1])]
    mc("map/availability",
       *(f"scoreboard players set #{flag}{i} {SYS} 0" for i in ROOMS_BY_ID for flag in ("reach","fresh")),
       *(f"execute if score @s {ROOM} matches {i} run scoreboard players set #reach{i} {SYS} 1" for i in ROOMS_BY_ID),
       *(here("map/flood") for _ in ROOMS_BY_ID),
       *(f"execute if score @s {ROOM} matches {a}{block_if(a,b)} if score @s {STEPS} matches 1.. if entity @s[tag=!rd.seen_{b}] run scoreboard players set #fresh{b} {SYS} 1"
         for a,b in pairs))
    mc("map/flood", *(f"execute if score #reach{a} {SYS} matches 1{block_if(a,b)} if entity @s[tag=rd.seen_{b}] run scoreboard players set #reach{b} {SYS} 1" for a,b in pairs))
    def paint(tag, art):
        return f"execute as @e[type=minecraft:item_display,tag=rd.ui,tag={tag},distance=0..] run data merge entity @s {{item:{map_art(art)}}}"

    rows = []
    for i in ROOMS_BY_ID:
        rows.extend((paint(f"rd.frame_{i}","room"),
                     f"execute if score #reach{i} {SYS} matches 1 run " + paint(f"rd.frame_{i}","seen"),
                     f"execute if score #fresh{i} {SYS} matches 1 run " + paint(f"rd.frame_{i}","fresh")))
    for index,pair in enumerate(EDGES):
        rows.append(paint(f"rd.edge_{index}","road"))
        if tuple(sorted(pair)) == TREE:
            rows.extend((paint(f"rd.edge_{index}","tree"),
                         f"execute if score #tree {SYS} matches 1 run " + paint(f"rd.edge_{index}","tree_open")))
        if tuple(sorted(pair)) == COLLAPSE:
            rows.append(f"execute if score #collapse {SYS} matches 1 run " + paint(f"rd.edge_{index}","collapse"))
    mc("map/paint", *rows)


def map_view(mc, data):
    anchor = "@e[type=minecraft:marker,tag=rd.map_anchor,distance=0..,limit=1]"
    data("data/fallenroute/tags/block/map_clear.json", {"values":["minecraft:air","minecraft:cave_air","minecraft:void_air","minecraft:light"]})
    data("data/fallenroute/tags/block/map_tall.json", {"values":["#minecraft:fences","#minecraft:walls"]})
    placements = []
    for variant in MAP_VIEWS:
        view = MapView(variant)
        # Fences and walls collide half a block above their own coordinates.
        clear = " ".join(f"if block {pos} #{NS}map_clear unless block {under} #{NS}map_tall"
                         for pos,under in view.clearance())
        placements.append(f"execute {clear} run return run {here('map/place_'+variant)}")
        mc(f"map/place_{variant}", here("map/begin"),
           f'summon minecraft:marker ~ ~ ~ {{Tags:["rd.ui","rd.map_anchor","rd.{variant}"]}}',
           f"rotate {anchor} ~ 0", *view.board(), here("map/rotate"), here("map/paint"))
        for i, (_,label,*_) in enumerate(ROOMS):
            mc(f"map/focus_{variant}_{i}",
               f"execute as @e[type=minecraft:item_display,tag=rd.icon_{i},distance=0..] run data merge entity @s {{view_range:0f}}",
               view.room_stamp(i,1.13,-.36,"rd.focus","focus"),
               view.icon(i,1.12,-.40,"rd.focus"), here("map/rotate"), action(label,"dark_aqua"))
    mc("map/place", *placements, action("前方空间太窄，退半步展开地图。","gold"))
    mc("map/begin", here("map/leave"), f"scoreboard players operation @s rd.back = @s {MODE}",
       here("map/availability"), f"scoreboard players set @s {MODE} 2", "tag @s add rd.map_open", "tag @s add rd.paper_map",
       f"attribute @s minecraft:entity_interaction_range modifier add {REACH_MOD} 1.35 add_value",
       f"scoreboard players set #hover {SYS} -1")
    mc("map/rotate", 'execute as @e[tag=rd.rotate,distance=0..] run rotate @s ~180 0',
       "tag @e[tag=rd.rotate,distance=0..] remove rd.rotate")
    mc("map/tick",
       f"execute unless entity @s[tag=rd.paper_map] run return run {here('map/close')}",
       f"execute unless entity {anchor} run return run {here('map/close')}",
       here("map/focus"),
       f"execute if score @s rd.back matches 0 run return run {here('room/tick')}",
       f"execute if score @s rd.back matches 1 run return run {here('road/tick')}")
    for i, (_, _, _, x, y) in enumerate(ROOMS):
        data(f"data/fallenroute/predicate/focus/{i}.json", {
            "condition":"minecraft:entity_properties", "entity":"this", "predicate":{"type_specific":{
                "type":"minecraft:player", "looking_at":{"type":"minecraft:interaction",
                                                          "nbt":f'{{Tags:["rd.ui","rd.node_{i}"]}}'},
            }},
        })
    mc("map/focus", f"scoreboard players set #look {SYS} -1",
       *(f"execute if predicate {NS}focus/{i} run scoreboard players set #look {SYS} {i}" for i in ROOMS_BY_ID),
       f"execute if score #look {SYS} = #hover {SYS} run return 0",
       "kill @e[type=minecraft:item_display,tag=rd.focus,distance=0..]",
       *(f"execute if score #hover {SYS} matches {i} as @e[type=minecraft:item_display,tag=rd.icon_{i},distance=0..] run data merge entity @s {{view_range:1f}}"
         for i in ROOMS_BY_ID),
       f"scoreboard players operation #hover {SYS} = #look {SYS}",
       *(f"execute if score #hover {SYS} matches {i} at {anchor} if entity @e[type=minecraft:marker,tag=rd.map_anchor,tag=rd.{variant},distance=..0.01] run {here(f'map/focus_{variant}_{i}')}"
         for i in ROOMS_BY_ID for variant in MAP_VIEWS))
