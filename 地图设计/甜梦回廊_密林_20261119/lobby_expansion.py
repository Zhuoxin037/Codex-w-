"""Extend the cabin with a practice clearing and a shared-run ready check."""

from collections import defaultdict
import json
from pathlib import Path

from architecture import Build
from cabin_lobby import TUTORIAL
from floor_upgrade import edit, text, write
from forest_economy import FN, RUN, button, literal, say

LOBBY = FN + "lobby/"
CAMP = "x=251,y=76,z=10,dx=14,dy=7,dz=12"
PRACTICE = "x=271,y=75,z=25,dx=21,dy=9,dz=19"
READY = "sd.lobby_ready"
PRACTICING = "sd.lobby_practice"
JOB = "sd.lobby_job"
ROGUE_START = "sweetdream:rogue/prototype/start"
DUMMY = "sd.practice_dummy"
LEGACY = "-16 -16 127 127"
PRACTICE_CHUNKS = "256 16 303 47"
RACK = (275.5, 78.0, 30.5)
DUMMY_PADS = ((285.5, 78, 30.5), (285.5, 78, 38.5))
JOBS = ("我", "魔导士", "狂徒", "歌者", "同生")
TRAINING_DIM = "sweetdream:training"
TRAINING_TAG = "sd.training"
PREVIEW = "sweetdream_floor:training_preview"


def coords(point):
    return " ".join(map(str, point))


def clearing():
    b = Build()
    # A three-wide trail starts at the camp. Keep its height below the existing
    # campsite timber and leave the cabin and its furniture outside the work area.
    for x0, z0, x1, z1, y in ((260,17,262,20,77), (262,19,266,22,77),
                               (266,20,269,23,77), (269,22,273,26,77),
                               (272,25,275,30,77)):
        b.box((x0,y-2,z0),(x1,y-1,z1),"rooted_dirt")
        b.box((x0,y,z0),(x1,y,z1),"coarse_dirt")
        b.box((x0,y+1,z0),(x1,y+3,z1),"air")
    b.box((273,76,26),(291,76,42),"rooted_dirt")
    b.box((272,77,27),(291,77,42),"moss_block")
    b.box((274,77,26),(289,77,43),"moss_block")
    b.box((273,78,27),(290,91,42),"air")
    b.disk(282,77,35,8,7,"coarse_dirt")
    b.disk(283,77,35,6,6,"packed_mud")
    for x,z in ((285,30),(285,38)):
        b.disk(x,77,z,2,2,"mossy_stone_bricks")
        b.set(x,77,z,"chiseled_tuff")
        b.set(x+3,77,z,"ochre_froglight")
    # Open-sided equipment shed with dark rafters and a small spruce overhang.
    b.box((273,77,28),(278,77,34),"spruce_planks")
    for x in (273,278):
        for z in (28,34):
            b.box((x,78,z),(x,81,z),"stripped_dark_oak_log")
            b.set(x,77,z,"mossy_cobblestone")
    for n in range(4):
        y=81+n//2
        for x in (272+n,279-n):
            b.box((x,y,27),(x,y,35),"spruce_slab[type=top]" if n%2 else "spruce_slab[type=bottom]")
    b.box((275,83,27),(276,83,35),"dark_oak_slab[type=bottom]")
    b.box((273,81,28),(278,81,28),"dark_oak_log[axis=x]")
    b.box((273,81,34),(278,81,34),"dark_oak_log[axis=x]")
    b.set(277,80,28,"lantern[hanging=true]")
    b.set(274,80,34,"lantern[hanging=true]")
    b.set(274,78,32,"smithing_table")
    b.set(274,78,33,"barrel[facing=east]")
    b.set(275,78,33,"grindstone[face=floor,facing=east]")
    for x,z in ((288,28),(290,34),(289,41),(277,41),(273,38)):
        b.set(x,78,z,"mossy_cobblestone_wall")
        b.set(x,79,z,"lantern")
        b.set(x-1,78,z,"fern")
    b.box((290,78,29),(290,79,32),"spruce_fence")
    b.box((290,78,36),(290,79,40),"spruce_fence")
    b.box((278,78,42),(287,78,42),"dark_oak_log[axis=x]")
    b.set(277,79,40,"potted_fern")
    b.set(277,78,40,"mossy_cobblestone")
    return b.lines


def stage(world):
    root = Path(world)/"datapacks"
    f = root/"zz_sweetdream_floor/data/sweetdream_floor"
    functions = f/"function"
    base = root/"sweetdream/data/sweetdream/function"

    def mc(name, *body):
        write(functions/f"{name}.mcfunction", "\n".join(body))

    def interact(key, position, tag, width=1.2, height=1.6):
        name = f"lobby/{key}"
        write(f/f"advancement/{name}.json", literal({
            "criteria": {"act": {"trigger": "minecraft:player_interacted_with_entity",
                                 "conditions": {"entity": {"type": "minecraft:interaction",
                                                            "nbt": f'{{Tags:["{tag}"]}}'}}}},
            "rewards": {"function": FN + name},
        }))
        return (f"summon minecraft:interaction {coords(position)} "
                f'{{Tags:["sd.lobby_expansion","{tag}"],width:{width}f,height:{height}f,response:1b}}')

    def label(point, title, color):
        return (f"summon minecraft:text_display {coords(point)} "
                f'{{Tags:["sd.lobby_expansion"],billboard:"center",background:0,shadow:1b,view_range:0.65f,'
                f'text:{literal({"text": title, "color": color, "bold": True})}}}')

    camp_click = interact("camp_click", (258.0,78.0,16.0), "sd.lobby_camp", 1.7, 1.7)
    rack_click = interact("rack_click", RACK, "sd.practice_rack")
    mc("lobby/expansion/load",
       f"execute if data storage {RUN} {{lobby_expansion:1b}} run return 0",
       f"execute unless data storage {RUN} {{cabin_layout:1b,lobby:1b}} run return run schedule function {LOBBY}expansion/load 1s replace",
       f"execute in minecraft:overworld run forceload add {PRACTICE_CHUNKS}",
       f"execute in minecraft:overworld run forceload add {LEGACY}",
       f"schedule function {LOBBY}expansion/build 1s replace")
    mc("lobby/expansion/build", f"execute in minecraft:overworld run function {LOBBY}expansion/build_loaded")
    chunks = ((x,z) for x0,z0,x1,z1 in ((256,16,304,48),(-16,-16,128,128))
              for x in range(x0,x1,16) for z in range(z0,z1,16))
    mc("lobby/expansion/build_loaded",
       f"execute if data storage {RUN} {{lobby_expansion:1b}} run return 0",
       *(f"execute unless loaded {x} 78 {z} run return run schedule function {LOBBY}expansion/build 1s replace"
         for x,z in chunks),
       f"function {LOBBY}expansion/clear_prototype",
       f"function {LOBBY}expansion/clearing",
       f"kill @e[tag=sd.lobby_expansion,{PRACTICE}]",
       "kill @e[tag=sd.lobby_expansion,x=250,y=76,z=0,dx=20,dy=8,dz=23]",
       label((258,80.0,16), "开始游戏", "gold"),
       label((TUTORIAL[0],79.6,TUTORIAL[2]), "甜梦研习", "light_purple"),
       label((273.5,80.0,26.5), "训练场", "gold"),
       label((275.5,79.85,30.5), "领取装备", "aqua"),
       camp_click, rack_click,
       f"function {LOBBY}practice/dummies",
       f"data modify storage {RUN} lobby_expansion set value 1b",
       f"forceload remove {PRACTICE_CHUNKS}", f"forceload remove {LEGACY}")
    mc("lobby/expansion/clearing", *clearing())
    # Only the known abandoned overworld grid. The teaching island at negative
    # X and the current cabin are outside these chunks.
    mc("lobby/expansion/clear_prototype",
       *(f"fill {x} 64 -16 {x+3} 111 127 minecraft:air" for x in range(-16,128,4)),
       "fill -16 319 -16 127 319 127 minecraft:air")

    mc("lobby/camp_click",
       f"advancement revoke @s only {LOBBY}camp_click",
       f"execute at @s if dimension minecraft:overworld if entity @s[{CAMP},tag=!sd.floor_run,tag=!sd.floor_tutorial] run function {LOBBY}camp")
    mc("lobby/camp",
       "execute unless dimension minecraft:overworld run return 0",
       f"execute unless entity @s[{CAMP}] run return run {say('请到篝火旁准备入梦。')}",
       f"execute if entity @s[tag={READY}] run return run function {FN}run/start",
       f"function {LOBBY}menu")
    mc("lobby/prepare",
       "execute unless dimension minecraft:overworld run return 0",
       f"execute unless entity @s[{CAMP}] run return run {say('请到篝火旁选择职业。')}",
       f"scoreboard players operation @s {JOB} = #input sd.floor",
       f"tag @s add {READY}",
       say("已准备。再次点击「开始游戏」，已准备的玩家会一起入梦。", "green"),
       "tellraw @s "+literal([button("开始游戏",4), {"text":"    "}, button("取消准备",5,"gray")]))
    mc("lobby/unready", f"tag @s remove {READY}", say("已取消准备。"))
    mc("lobby/menu",
       "tellraw @s "+literal([{"text":"甜梦回廊   ","color":"aqua","bold":True},
                             button("甜梦研习",2,"light_purple")]),
       f"execute unless entity @s[{CAMP}] run return run {say('篝火旁准备入梦。小径右侧可前往训练场。')}",
       say("选择职业进入准备状态。","gold"),
       "tellraw @s "+literal([part for i,job in enumerate(JOBS)
                              for part in (button(job,10+i), {"text":"  "})]))
    path = functions/"route.mcfunction"
    edit(path, (f"run function {FN}run/start", f"run function {LOBBY}prepare"))
    write(path, text(path)+"\n"+"\n".join((
        f"execute if score #input sd.floor matches 4 if entity @s[tag=!sd.floor_tutorial] run return run function {LOBBY}camp",
        f"execute if score #input sd.floor matches 5 run return run function {LOBBY}unready",
        f"execute if score #input sd.floor matches 100.. if entity @s[tag=!sd.floor_tutorial,{PRACTICE}] run function {LOBBY}practice/route",
    )))
    file=functions/"lobby/player_tick.mcfunction"
    edit(file, ("execute if entity @s[tag=sd.floor_tutorial] run return 0",
         f"execute unless entity @s[{CAMP}] run tag @s remove {READY}\n"
         f"execute if entity @s[tag={PRACTICING}] unless entity @s[{PRACTICE}] run function {LOBBY}practice/clear\n"
         "execute if entity @s[tag=sd.floor_tutorial] run return 0"))
    edit(functions/"lobby/back.mcfunction", ("tag @s remove sd.floor_tutorial",
         f"tag @s remove sd.floor_tutorial\ntag @s remove {READY}\n"
         f"execute if entity @s[tag={PRACTICING}] run function {LOBBY}practice/clear"))
    edit(functions/"tutorial/enter.mcfunction", ("tag @s add sd.floor_tutorial",
         f"tag @s remove {READY}\nexecute if entity @s[tag={PRACTICING}] run function {LOBBY}practice/clear\n"
         "tag @s add sd.floor_tutorial"))
    file=functions/"load.mcfunction"
    write(file, text(file)+f"\nscoreboard objectives add {JOB} dummy\n"
          f"schedule function {LOBBY}expansion/load 1s replace")
    practice(mc, functions, base)
    party(mc, functions)


def refresh_practice(world):
    packs = Path(world)/"datapacks"
    functions = packs/"zz_sweetdream_floor/data/sweetdream_floor/function"
    base = packs/"sweetdream/data/sweetdream/function"

    def mc(name, *body):
        write(functions/f"{name}.mcfunction", "\n".join(body))

    practice(mc, functions, base)


def practice(mc, functions, base):
    mc("lobby/rack_click",
       f"advancement revoke @s only {LOBBY}rack_click",
       f"execute at @s if dimension {TRAINING_DIM} if entity @s[tag={TRAINING_TAG}] "
       f"run function {LOBBY}practice/menu")
    mc("lobby/practice/clear",
       "clear @s *[minecraft:custom_data~{sd_training:1b}]",
       "function sweetdream:profession/cleanup",
       f"function {LOBBY}restore_health",
       f"tag @s remove {PRACTICING}")

    catalog = defaultdict(list)
    for line in text(functions/"pool/load.mcfunction").splitlines():
        if " entries append value " not in line:
            continue
        entry = json.loads(line.split(" entries append value ",1)[1])
        if entry.get("name") and entry.get("id") != "look":
            catalog[entry["category"]].append(entry)
    groups = {"sword":"剑", "axe":"斧", "bow":"弓", "staff":"法杖", "armor":"盔甲", "tool":"副手"}
    menu, pages, grants = [], [], []
    page_id, action = 120, 300
    for key, title in groups.items():
        entries = sorted(catalog[key], key=lambda row: (row["tier"],row["name"]))
        page_count = (len(entries)+7)//8
        if not page_count:
            continue
        menu.extend((button(title,page_id), {"text":"  "}))
        for index in range(page_count):
            chunk=entries[index*8:index*8+8]
            pages.append(f"execute if score #input sd.floor matches {page_id} run return run function {LOBBY}practice/pages/{page_id}")
            nav = [button("装备架",100,"gray")]
            if index:
                nav.extend(({"text":"  "},button("上一页",page_id-1,"aqua")))
            if index+1 < page_count:
                nav.extend(({"text":"  "},button("下一页",page_id+1,"aqua")))
            contents=[]
            for entry in chunk:
                source=base/(entry["fn"].split(":",1)[1]+".mcfunction")
                body=[row for row in text(source).splitlines() if row.startswith("give @s ")]
                assert len(body)==1 and "custom_data={" in body[0], source
                gear=body[0].replace("custom_data={","custom_data={sd_training:1b,",1)
                grants.append(f"execute if score #input sd.floor matches {action} run return run {gear}")
                assert (functions/f"market/preview/{entry['id']}.mcfunction").is_file(), entry["id"]
                contents.append((entry["id"], button(entry["name"],action,"white")))
                action+=1
            rows=[]
            for offset in range(0,len(contents),4):
                rows.append(f"data modify storage {PREVIEW} row set value []")
                for item_id, label in contents[offset:offset+4]:
                    rows.append(f"data modify storage {PREVIEW} label set value {literal(label)}")
                    rows.append(f"function {LOBBY}practice/preview/add {{id:{literal(item_id)}}}")
                rows.append(f"function {LOBBY}practice/preview/show with storage {PREVIEW}")
            mc(f"lobby/practice/pages/{page_id}", say(f"{title}  {index+1}/{page_count}","aqua"), *rows,
               "tellraw @s "+literal(nav))
            page_id+=1
    mc("lobby/practice/menu",f"tag @s add {PRACTICING}",say("训练场 · 装备架","aqua"),
       say("按 T 打开聊天栏。悬停装备名查看详情，点击领取。"),
       "tellraw @s "+literal(menu),
       "tellraw @s "+literal([button(job,180+i,"gray") for i,job in enumerate(JOBS)]),
       "tellraw @s "+literal([button("补充生命与魔力",101,"green"),{"text":"  "},button("清空训练装备",102,"gray")]))
    mc("lobby/practice/route",
       f"execute unless dimension {TRAINING_DIM} run return 0",
       f"tag @s add {PRACTICING}",
       f"execute if score #input sd.floor matches 100 run return run function {LOBBY}practice/menu",
       f"execute if score #input sd.floor matches 101 run return run function {FN}run/refill",
       "execute if score #input sd.floor matches 102 run return run clear @s *[minecraft:custom_data~{sd_training:1b}]",
       f"execute if score #input sd.floor matches 180..184 run return run function {LOBBY}practice/job",
       *pages, *grants)
    mc("lobby/practice/job",
       "function sweetdream:profession/cleanup",
       "scoreboard players operation @s zx.job = #input sd.floor",
       "scoreboard players remove @s zx.job 180",
       "scoreboard players set @s zx.j_aw 0",
       "function sweetdream:profession/stats",
       "function sweetdream:profession/weapon_guard",
       f"function {FN}run/refill")
    mc("lobby/practice/dummies", *(
       f"execute positioned {coords(point)} unless entity @e[tag={DUMMY}_{i},distance=..4] run "
       'summon minecraft:husk ~ ~ ~ '
       f'{{Tags:["sd.lobby_expansion","{DUMMY}","{DUMMY}_{i}","zx.debug_dummy"],NoAI:1b,Silent:1b,'
       'PersistenceRequired:1b,Rotation:[90f,0f],CustomName:{text:"训练假人",color:"yellow"},CustomNameVisible:1b,'
       'Health:1024f,attributes:[{id:"minecraft:max_health",base:1024d},{id:"minecraft:knockback_resistance",base:1d}],'
       'DeathLootTable:"minecraft:empty",equipment:{head:{id:"minecraft:carved_pumpkin",count:1},'
       'chest:{id:"minecraft:leather_chestplate",count:1}}}'
       for i,point in enumerate(DUMMY_PADS)))
    mc("lobby/practice/tick",
       f"execute if entity @a[tag={TRAINING_TAG}] run function {LOBBY}practice/dummies",
       f'kill @e[type=minecraft:item,{PRACTICE},nbt={{Item:{{components:{{"minecraft:custom_data":{{sd_training:1b}}}}}}}}]')
    preview = LOBBY+"practice/preview/"
    mc("lobby/practice/preview/add",
       f"data remove storage {PREVIEW} item",
       f"$execute summon minecraft:item_display run function {preview}read {{id:\"$(id)\"}}",
       f'execute if data storage {PREVIEW} item.id run data modify storage {PREVIEW} label.hover_event set value {{action:"show_item",count:1}}',
       f"data modify storage {PREVIEW} label.hover_event.id set from storage {PREVIEW} item.id",
       f"data modify storage {PREVIEW} label.hover_event.components set from storage {PREVIEW} item.components",
       f"data modify storage {PREVIEW} row append from storage {PREVIEW} label",
       f'data modify storage {PREVIEW} row append value {{text:"    "}}')
    mc("lobby/practice/preview/read",
       f"$function {FN}market/preview_equipment {{id:\"$(id)\"}}",
       f"data modify storage {PREVIEW} item set from entity @s item",
       "kill @s")
    mc("lobby/practice/preview/show", "$tellraw @s $(row)")


def party(mc, functions):
    start = functions/"run/start.mcfunction"
    body = text(start)
    global_state = body[body.index("scoreboard players set #phase sd.floor 1"):body.index("effect clear @s")]
    personal = body[body.index("effect clear @s"):].replace(
        "scoreboard players operation #jselect zx.meta = #input sd.floor",
        f"scoreboard players operation #jselect zx.meta = @s {JOB}")
    guards = body.splitlines()[:3]
    mc("run/start", *guards,
       f"execute unless entity @s[{CAMP},tag={READY}] run return run {say('请先在篝火旁准备。')}",
       f"function {FN}room/event/reset",
       f"data modify storage {RUN} floor set value 1",
       f"data remove storage {RUN} next_profile",
       "scoreboard players add #serial sd.floor 1", global_state.rstrip(),
       f"execute as @a[{CAMP},tag={READY},tag=!sd.floor_tutorial,scores={{{JOB}=10..14}}] "
       f"at @s run function {FN}run/join_party")
    mc("run/join_party",
       f"tag @s remove {READY}",
       f"tag @s remove {PRACTICING}",
       "tag @s remove sd.floor_transfer",
       "tag @s remove sd.floor_mirror",
       "tag @s remove sd.floor_hud",
       "tag @s add sd.floor_run",
       "scoreboard players operation @s sd.floor = #serial sd.floor",
       "scoreboard players set @s sd.floor_death 0",
       "scoreboard players set @s sd.lobby_room -1",
       personal.rstrip())
    mc("lobby/restore_health",
       "scoreboard players set @s zx.job 0",
       "scoreboard players set @s zx.j_aw 0",
       "function sweetdream:profession/stats",
       "effect give @s minecraft:instant_health 1 5 true")
    for name in ("exit", "stale"):
        file = functions/f"run/{name}.mcfunction"
        edit(file,(f"function {LOBBY}cabin/return",
              f"function {LOBBY}restore_health\nfunction {LOBBY}cabin/return"))
    edit(functions/"run/exit.mcfunction",
         (f"function {FN}run/orphan", f"execute unless entity @a[tag=sd.floor_run] run function {FN}run/orphan"))
    file = functions/"room/event/reset.mcfunction"
    # Per-player event modifiers are always removed, while room-wide event
    # choices remain intact until the last player leaves.
    edit(file,
         (f"data remove storage {RUN} ambush_pending\ndata remove storage {RUN} fire_quote", ""))
    for name in ("orphan_forest", "orphan_trial"):
        file = functions/f"run/{name}.mcfunction"
        write(file, text(file)+f"\ndata remove storage {RUN} ambush_pending\n"
              f"data remove storage {RUN} fire_quote")
    file = functions/"run/death.mcfunction"
    death = text(file)
    write(file, f"execute if entity @a[tag=sd.floor_run,scores={{sd.floor_death=0}}] "
          f"run return run function {FN}run/party_death\n"+death)
    mc("run/party_death",
       'title @s title {"text":"梦境崩散","color":"red"}',
       f"execute unless entity @s[nbt={{Health:0.0f}}] run function {FN}run/exit")
    file = functions/"run/player_tick.mcfunction"
    edit(file,
         ("execute if score #ready sd.floor matches 0", "execute unless entity @s[tag=sd.floor_hud]"),
         (f"execute if score #phase sd.floor matches 2 run return run function {FN}combat/tick\n", ""),
         ("unless score #last sd.floor = @s zx.rg_room", "unless score @s sd.lobby_room = @s zx.rg_room"))
    file = functions/"room/arrive.mcfunction"
    edit(file, ("scoreboard players operation #last sd.floor = @s zx.rg_room",
         "scoreboard players operation @s sd.lobby_room = @s zx.rg_room\nscoreboard players operation #last sd.floor = @s zx.rg_room"))
    file = functions/"tick.mcfunction"
    lobby_tick = f"execute as @a[tag=!sd.floor_run] at @s run function {LOBBY}player_tick"
    edit(file, (lobby_tick, lobby_tick+"\n"+
         'execute if score #phase sd.floor matches 2 as @a[tag=sd.floor_run,tag=zx.rg_active,scores={sd.floor_death=0},limit=1] '
         f'at @s run function {FN}combat/tick\n'
         f'execute in minecraft:overworld run function {LOBBY}practice/tick'))
    file = functions/"load.mcfunction"
    write(file, text(file)+"\nscoreboard objectives add sd.lobby_room dummy")

    file = functions/"next/start.mcfunction"
    edit(file, ("tag @s add sd.floor_transfer",
         "tag @a[tag=sd.floor_run,tag=zx.rg_active,scores={sd.floor_death=0}] add sd.floor_transfer\n"
         "tag @a[tag=sd.floor_transfer] remove sd.floor_hud"),
         (f"function {FN}next/leave_first", f"execute as @a[tag=sd.floor_transfer] at @s run function {FN}next/leave_first"))
    file = functions/"next/wait.mcfunction"
    edit(file, ("data modify storage sweetdream_floor:run floor set value 2",
         "scoreboard players set @s sd.lobby_room -1\n"
         f"execute if data storage {RUN} {{floor:2}} run return run function {ROGUE_START}\n"
         f"data modify storage {RUN} floor set value 2"))
