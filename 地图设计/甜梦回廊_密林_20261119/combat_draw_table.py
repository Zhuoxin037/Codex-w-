"""Put the draw-lab carousel on the combat room's existing reward flow."""

import json
from pathlib import Path

from draw_lab import compact, display, text_display, timeline
from draw_lab_art import stage_resources
from floor_route_map import DIMS


F = "sweetdream_floor:"
D = "drawlab:combat/"
RUN = F+"run"
STATE = "drawlab:combat"
OBJ = "dl.combat"
LENGTH = 66
TABLE_SCALE = .70
PLAYERS = "@a[tag=sd.floor_run,tag=zx.rg_active,tag=!sd.rejoin_pending,distance=0..,scores={sd.floor_death=0}]"


def local(x=0,y=0,z=0):
    return " ".join("~" if abs(v)<.00005 else f"~{v*TABLE_SCALE:.4f}" for v in (x,y,z))


def msg(label,color="gold"):
    return "tellraw @s "+compact({"text":label,"color":color})


def button(label,code):
    return "tellraw @s "+compact({"text":"["+label+"]","color":"gold","underlined":True,
        "click_event":{"action":"run_command","command":f"/trigger sd.floor_cmd set {code}"}})


def stage(world,original,rooms):
    pack=Path(world)/"datapacks/zzzzz_fallendream_draw"

    def asset(name,body):
        path=pack/name
        path.parent.mkdir(parents=True,exist_ok=True)
        path.write_text(body.rstrip()+"\n",encoding="utf8")

    def mc(name,*rows):
        space,sub=name.split(":",1)
        asset(f"data/{space}/function/{sub}.mcfunction","\n".join(rows))

    def lab(name,*rows):
        mc(D+name,*rows)

    def original_rows(path):
        return (Path(original)/f"data/sweetdream_floor/function/{path}.mcfunction").read_text(encoding="utf8").splitlines()

    def room_rows(path):
        return (Path(rooms)/f"data/sweetdream_floor/function/{path}.mcfunction").read_text(encoding="utf8").splitlines()

    asset("pack.mcmeta",json.dumps({"pack":{"pack_format":71,"description":"坠梦 · 战后抽取台"}},ensure_ascii=False))
    for name in ("load","tick"):
        asset(f"data/minecraft/tags/function/{name}.json",compact({"values":[D+name]}))
    lab("load",*(f"scoreboard objectives add {o} dummy" for o in (OBJ,"dl.actor","dl.done")),
        f"scoreboard players add #serial {OBJ} 0")
    mc(F+"reward/battle_offer",
       *(f'execute if data storage {RUN} current{{kind:"{kind}"}} if data storage {RUN} choice_room.x run return run function {D}room/start'
         for kind in ("combat","elite")),
       *original_rows("reward/battle_offer"))
    mc(F+"flow/recover_choice",f"execute if data storage {STATE} room run return 0",*original_rows("flow/recover_choice"))
    route=original_rows("run/route")
    route.insert(2,f"execute if score #phase sd.floor matches 3 if data storage {STATE} room run return run function {D}turn/input")
    mc(F+"run/route",*route)
    pick=room_rows("reward/pick_go")
    offset=next(i for i,row in enumerate(pick) if "draw_prepare" in row)
    pick.insert(offset,f"execute if data storage {STATE} room run return run function {D}draw/choose with storage {RUN} draw")
    mc(F+"reward/pick_go",*pick)
    mc(F+"bank/clear",f"execute if data storage {STATE} room run return run function {D}turn/done",*original_rows("bank/clear"))
    room_control(lab)
    turns(lab)
    drawing(lab)
    stage_resources(world,())


def participants(body):
    return (f"execute as {PLAYERS} if score @s sd.flow_pick = #flow_pick sd.floor "
            f"unless score @s dl.done = #flow_pick sd.floor run {body}")


def owner(body):
    return (f"execute as {PLAYERS} if score @s dl.actor = #owner {OBJ} "
            f"if score @s sd.flow_pick = #flow_pick sd.floor run {body}")


def room_control(lab):
    lab("room/start",
        f"function {D}room/clear",
        f"data modify storage {STATE} room set from storage {RUN} choice_room",
        f"scoreboard players set #turn {OBJ} 0",
        f"scoreboard players set #owner {OBJ} 0",
        f"scoreboard players set #frame {OBJ} -1",
        "scoreboard players set #phase sd.floor 3",
        f"function {D}room/center with storage {STATE} room",
        participants(msg("右击房间中央的抽取台。")))
    lab("room/center",f"$execute positioned $(x).5 81 $(z).5 run function {D}room/build")

    def named(entry,name):
        text=compact({"text":name})
        return entry.replace('"minecraft:item_model":',f'"minecraft:item_name":{text},"minecraft:item_model":',1)

    lab("room/build",
        named(display("dl.table","drawlab:forest_pedestal",local(),scale=TABLE_SCALE),"抽取台"),
        named(display("dl.dial","drawlab:dial",local(),scale=TABLE_SCALE),"抽取盘"),
        named(display("dl.pointer","drawlab:pointer",local(0,.66,1.05),scale=TABLE_SCALE),"停轮指针"),
        f'summon minecraft:interaction {local(0,.25,0)} {{Tags:["dl.click"],width:2.12f,height:.64f,response:1b}}',
        f"function {D}room/prompt")
    lab("room/prompt",text_display(local(0,1.40,0),"右击抽取","#eddbac",.84,tag="dl.idle",bold=True))
    lab("room/restore_prompt",
        f"$execute positioned $(x).5 81 $(z).5 unless entity @e[tag=dl.idle,distance=..3] run function {D}room/prompt")
    lab("room/clear","kill @e[tag=dl.set,distance=0..]","kill @e[tag=dl.click,distance=0..]",
        "kill @e[tag=dl.play,distance=0..]","kill @e[tag=dl.idle,distance=0..]")
    lab("tick",
        f"execute unless data storage {STATE} room run return 0",
        *(f"execute {'if' if i else 'unless'} data storage {RUN} {{floor:2}} in {dim} run function {D}room/tick"
          for i,dim in enumerate(DIMS)))
    lab("room/tick",
        f"execute unless score #phase sd.floor matches 3 run return run function {D}room/end",
        f"execute as @e[tag=dl.click,type=interaction,distance=0..,limit=1] at @s if data entity @s interaction.player run function {D}room/click",
        f"scoreboard players set #remaining {OBJ} 0",
        participants(f"scoreboard players add #remaining {OBJ} 1"),
        f"execute if score #remaining {OBJ} matches 0 run return run function {D}room/complete",
        f"execute if score #turn {OBJ} matches 0 run return 0",
        f"scoreboard players set #owner_here {OBJ} 0",
        owner(f"scoreboard players set #owner_here {OBJ} 1"),
        f"execute if score #owner_here {OBJ} matches 0 run return run function {D}turn/release",
        f"execute if score #turn {OBJ} matches 2 run function {D}draw/tick")
    lab("room/click",f"data modify storage {STATE} click.uuid set from entity @s interaction.player",
        "data remove entity @s interaction",f"function {D}room/resolve with storage {STATE} click")
    lab("room/resolve",f"$execute as @a[nbt={{UUID:$(uuid)}},distance=..5.5] at @s run function {D}turn/open")
    lab("room/complete",f"function {D}room/end",f"function {F}flow/open_choice","scoreboard players set #phase sd.floor 1")
    lab("room/end",f"function {D}room/clear",
        f"data remove storage {STATE} room",
        f"function {D}turn/reset")


def turns(lab):
    member="if entity @s[tag=sd.floor_run,tag=zx.rg_active,tag=!sd.rejoin_pending,scores={sd.floor_death=0}] if score @s sd.flow_pick = #flow_pick sd.floor"
    lab("turn/open",
        f"execute unless score #phase sd.floor matches 3 run return 0",
        f"execute unless data storage {STATE} room run return 0",
        f"execute {member} run return run function {D}turn/join")
    lab("turn/join",
        f"execute if score @s dl.done = #flow_pick sd.floor run return run {msg('你已结算本房的装备奖励。','gray')}",
        f"execute if score #turn {OBJ} matches 1.. unless score @s dl.actor = #owner {OBJ} run return run {msg('有队友在抽取，稍等一下。','gray')}",
        f"execute if score #turn {OBJ} matches 3 run return run function {D}turn/claim",
        f"execute if score #turn {OBJ} matches 2 run return 0",
        f"execute if score #turn {OBJ} matches 1 run return run function {F}reward/show",
        f"scoreboard players add #serial {OBJ} 1",
        f"scoreboard players operation @s dl.actor = #serial {OBJ}",
        f"scoreboard players operation #owner {OBJ} = @s dl.actor",
        f"scoreboard players set #turn {OBJ} 1",
        f'data modify storage {RUN} draw_source set value "normal"',
        f'execute if data storage {RUN} current{{kind:"elite"}} run data modify storage {RUN} draw_source set value "elite"',
        f"function {F}reward/ask")
    lab("turn/input",
        f"execute if score #input sd.floor matches 23 run return run function {D}turn/open",
        f"execute if score #input sd.floor matches 117 run return run function {D}turn/open",
        f"execute unless score @s dl.actor = #owner {OBJ} run return 0",
        f"execute unless score @s sd.flow_pick = #flow_pick sd.floor run return 0",
        f"execute if score #turn {OBJ} matches 3 if score #input sd.floor matches 116 run return run function {D}turn/done",
        f"execute unless score #turn {OBJ} matches 1 run return 0",
        f"execute if score #input sd.floor matches 38..39 run return run function {F}reward/category",
        f"execute if score #input sd.floor matches 30..33 run return run function {F}reward/pick",
        f"execute if score #input sd.floor matches 115..116 run return run function {F}bank/route")
    lab("turn/reset",
        f"scoreboard players set #turn {OBJ} 0",f"scoreboard players set #owner {OBJ} 0",
        f"scoreboard players set #frame {OBJ} -1",
        *(f"data remove storage {RUN} {key}" for key in ("offers","exact_tier","draw_category","choosing_category","draw_source","battle_draw")),
        *(f"data remove storage {STATE} {key}" for key in ("result","items","candidates")))
    lab("turn/release",
        "kill @e[tag=dl.play,distance=0..]",f"function {D}turn/reset",
        f"function {D}room/restore_prompt with storage {STATE} room")
    lab("turn/done","scoreboard players operation @s dl.done = #flow_pick sd.floor",
        f"function {D}turn/release",
        participants(msg("轮到下一位，右击抽取台。","gray")))
    lab("turn/claim",
        f"scoreboard players set #occupied {OBJ} 0",
        f"execute store result score #occupied {OBJ} run data get entity @s Inventory",
        f"execute if score #occupied {OBJ} matches 36.. run return run function {D}turn/full",
        f"function {F}reward/give_go with storage {STATE} result",
        f"function {D}turn/done")
    lab("turn/full",msg("背包已满。空出一格后领取。","yellow"),
        button("领取",117),button("装备寄存",125),button("销毁",116))


def drawing(lab):
    lab("draw/choose",
        f"$data modify storage {STATE} result set from storage {RUN} pool[$(index)]",
        f"execute unless data storage {STATE} result.id run return 0",
        f"scoreboard players set #turn {OBJ} 2",
        f"data modify storage {STATE} items set value []",
        f"data modify storage {STATE} candidates set from storage {RUN} pool",
        f"data modify storage {RUN} preview_entry set from storage {STATE} result",
        f"function {D}draw/read_item",
        f"execute unless data storage {STATE} items[0] run return run function {D}draw/start_claim",
        f"function {D}draw/remove with storage {STATE} result",
        *(f"function {D}draw/sample" for _ in range(3)),
        f"function {D}draw/stage with storage {STATE} room")
    lab("draw/read_item",f"data remove storage {RUN} preview_item",
        f"execute summon minecraft:item_display run function {F}market/read_preview",
        f"execute if data storage {RUN} preview_item.id run data modify storage {STATE} items append from storage {RUN} preview_item")
    lab("draw/remove",f'$data remove storage {STATE} candidates[{{id:"$(id)"}}]')
    lab("draw/sample",f"execute unless data storage {STATE} candidates[0] run return 0",
        f"execute store result score #sample {OBJ} run data get storage {STATE} candidates",
        f"scoreboard players remove #sample {OBJ} 1",
        f"execute store result storage {STATE} scratch.max int 1 run scoreboard players get #sample {OBJ}",
        f"function {D}draw/random with storage {STATE} scratch",
        f"function {D}draw/snapshot with storage {STATE} scratch")
    lab("draw/random",f"$execute store result storage {STATE} scratch.index int 1 run random value 0..$(max) drawlab:preview")
    lab("draw/snapshot",f"$data modify storage {RUN} preview_entry set from storage {STATE} candidates[$(index)]",
        f"$data remove storage {STATE} candidates[$(index)]",f"function {D}draw/read_item")
    lab("draw/stage",f"$execute positioned $(x).5 81 $(z).5 run function {D}draw/spawn")
    lab("draw/spawn","kill @e[tag=dl.idle,distance=0..]",
        f"execute store result score #count {OBJ} run data get storage {STATE} items",
        *(f"execute if data storage {STATE} items[{i}] run function {D}draw/slot_{i}" for i in range(4)),
        f"scoreboard players set #frame {OBJ} 0",
        f"function {D}draw/at_center with storage {STATE} room")
    for i in range(4):
        lab(f"draw/slot_{i}",
            display(f"dl.card_{i}","drawlab:tablet",local(0,.75),scale=.045,billboard="vertical",moving=True),
            display(f"dl.icon_{i}","drawlab:tablet",local(0,.75,.082),scale=.042,billboard="vertical",moving=True,ctx="gui"),
            f"data modify entity @e[tag=dl.icon_{i},distance=..3,limit=1] item set from storage {STATE} items[{i}]")
    lab("draw/tick",f"scoreboard players add #frame {OBJ} 1",
        f"execute if score #frame {OBJ} matches {LENGTH} run return run {owner(f'execute at @s run function {D}draw/start_claim')}",
        f"function {D}draw/at_center with storage {STATE} room")
    lab("draw/start_claim",f"scoreboard players set #turn {OBJ} 3",f"function {D}turn/claim")
    lab("draw/at_center",f"$execute positioned $(x).5 81 $(z).5 run function {D}draw/animate")
    lab("draw/animate",*(f"execute if score #count {OBJ} matches {count} run return run function {D}draw/animate_{count}"
                         for count in range(1,5)))
    lab("draw/reveal",
        text_display(local(0,.73,1.56),"","#f2d49b",.95,tag="dl.result").replace('["dl.result"]','["dl.play","dl.result"]'),
        f'data modify storage {STATE} revealed set value {{text:"",color:"#f2d49b",bold:true}}',
        f"data modify storage {STATE} revealed.text set from storage {STATE} result.name",
        f"data modify entity @e[tag=dl.result,distance=..5,limit=1] text set from storage {STATE} revealed")
    for count in range(1,5):
        lab(f"draw/animate_{count}",*(f"execute if score #frame {OBJ} matches {i} run return run function {D}draw/frames_{count}/{i}"
                                       for i in range(0,LENGTH,2)))
        timeline(lab,count=count,length=LENGTH,locate=local,directory=f"draw/frames_{count}",
                 reveal=[f"function {D}draw/reveal"],size=.85)
