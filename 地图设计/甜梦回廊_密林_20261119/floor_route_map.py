"""Attach the approved parchment overlay to the actual floor generation."""

from math import pi
from pathlib import Path
import json

from route_trial_art import stage_resources
from route_trial_scenes import MAP_VIEWS, MapView, compact


NS = "fallenroute:floor/"
FLOOR = "sweetdream_floor:run"
GRAPH = "zx:rogue"
STATE = "fallenroute:floor"
MAP = 'minecraft:filled_map[minecraft:custom_data~{rg_map:1b}]'
ARMED = 'minecraft:filled_map[minecraft:custom_data~{rg_map:1b},minecraft:consumable]'
DIMS = ("sweetdream:floor_1_forest", "sweetdream:floor_2_trial")
CELLS = range(25)
KINDS = {"entry":"入口", "combat":"普通战斗", "elite":"精英战斗", "boss":"层主", "safe":"安全角落",
         "forge":"铸造坊", "merchant":"行商", "blackmarket":"黑市", "astrology":"占星室",
         "gamble":"赌博房", "rental":"租借商人", "event":"随机事件"}
EDGES = tuple((c,c+1) for c in CELLS if c%5!=4) + tuple((c,c+5) for c in range(20))
STEP = 2.08
ROOM_SIDE = 1.51


def point(cell):
    return (cell%5-2)*STEP,(2-cell//5)*STEP


def fn(name, args=""):
    return f"function {NS}{name}" + (f" {args}" if args else "")


def message(label,color="gold"):
    return "title @s actionbar " + compact({"text":label,"color":color})


def stage(world):
    world = Path(world)
    pack = world/"datapacks/zz_fallendream_route_map"

    def write(path, text):
        target=pack/path
        target.parent.mkdir(parents=True,exist_ok=True)
        target.write_text(text+"\n",encoding="utf8")

    def data(path, value):
        write(path,json.dumps(value,ensure_ascii=False,indent=2))

    def mc(path,*lines):
        write(f"data/fallenroute/function/floor/{path}.mcfunction","\n".join(lines))

    data("pack.mcmeta",{"pack":{"pack_format":71,"description":"坠梦 · 楼层地图展开"}})
    for name in ("load","tick"):
        data(f"data/minecraft/tags/function/{name}.json",{"values":[NS+name]})
    data("data/fallenroute/item_modifier/floor/input.json",{"function":"minecraft:set_components","components":{
        "minecraft:consumable":{"consume_seconds":3600,"animation":"none","sound":"minecraft:intentionally_empty","has_consume_particles":False},
    }})
    data("data/fallenroute/advancement/floor/input.json",{"criteria":{"use":{"trigger":"minecraft:using_item","conditions":{
        "item":{"items":"minecraft:filled_map","predicates":{"minecraft:custom_data":"{rg_map:1b}"}},
    }}},"rewards":{"function":NS+"input"}})
    for name, values in {"air":["air","cave_air","void_air","light"],"tall":["#minecraft:fences","#minecraft:walls"]}.items():
        data(f"data/fallenroute/tags/block/floor_{name}.json",{"values":[v if v.startswith('#') else f'minecraft:{v}' for v in values]})

    mc("load",*(f"scoreboard objectives add rgp.{obj} dummy" for obj in ("sys","id","room","pulse","quiet","hover","cell")),
       "scoreboard players add #id rgp.sys 0")
    mc("tick","execute as @a[tag=rgp.open] at @s run "+fn("watch"),
       "execute as @a[tag=sd.floor_run,tag=zx.rg_active] at @s run "+fn("arm"),
       *(f"execute in {dim} as @e[type=minecraft:interaction,tag=rgp.ui,distance=0..] at @s if data entity @s interaction.player run {fn('click')}" for dim in DIMS),
       *(f"execute in {dim} as @e[type=minecraft:marker,tag=rgp.anchor,distance=0..] at @s run {fn('owner_watch')}" for dim in DIMS))
    mc("arm", "scoreboard players add @s rgp.quiet 1",
       "execute if score @s rgp.quiet matches 8.. run scoreboard players set @s rgp.quiet 8",
       *(f"execute if items entity @s {slot} {MAP} unless items entity @s {slot} {ARMED} run item modify entity @s {slot} fallenroute:floor/input"
         for slot in ("hotbar.8","weapon.offhand")))
    mc("input", "advancement revoke @s only fallenroute:floor/input",
       "execute unless entity @s[tag=sd.floor_run,tag=zx.rg_active,tag=!sd.floor_mirror] run return 0",
       "scoreboard players operation @s rgp.pulse = @s rgp.quiet", "scoreboard players set @s rgp.quiet 0",
       "execute if score @s rgp.pulse matches ..5 run return 0",
       f"execute if entity @s[tag=rgp.open] at @s run return run {fn('close')}",
       f"execute at @s run {fn('open')}")
    mc("available", "execute unless entity @s[tag=sd.floor_run,tag=zx.rg_active,tag=!sd.floor_mirror,tag=!sd.rejoin_pending,scores={zx.rg_room=0..24,sd.floor_death=0}] run return fail",
       f"execute unless dimension {DIMS[0]} unless dimension {DIMS[1]} run return fail",
       f"execute unless score #phase sd.floor matches 1 run return fail",
       f"execute if data storage {FLOOR} encounter run return fail",
       f"execute if data storage {FLOOR} choice_room if score @s sd.flow_pick = #flow_pick sd.floor run return fail",
       "return 1")
    mc("open",f"execute store result score #usable rgp.sys run {fn('available')}",
       "execute unless score #usable rgp.sys matches 1 run return run "+message("现在无法打开楼层地图。"),
       f"execute if entity @e[tag=rgp.anchor,distance=..4] run return run "+message("往旁边走一步再展开。"),
       f"execute anchored eyes positioned ^ ^ ^ rotated ~ 0 run {fn('place')}")
    mc("allocate", "scoreboard players add #id rgp.sys 1", "scoreboard players operation @s rgp.id = #id rgp.sys")
    mc("begin",f"execute unless score @s rgp.id matches 1.. run {fn('allocate')}",
       "tag @s add rgp.open", "scoreboard players operation @s rgp.room = @s zx.rg_room", "scoreboard players set @s rgp.hover -1",
       "attribute @s minecraft:entity_interaction_range modifier add fallenroute:floor_reach 1.35 add_value",
       fn("reachable"))
    mc("stamp", 'execute as @e[tag=rgp.new,distance=..5] run rotate @s ~180 0',
       "scoreboard players operation @e[tag=rgp.new,distance=..5] rgp.id = @s rgp.id",
       "tag @e[tag=rgp.new,distance=..5] remove rgp.new")
    mc("close", "tag @s remove rgp.open", "attribute @s minecraft:entity_interaction_range modifier remove fallenroute:floor_reach",
       f"execute store result storage {STATE} owner.id int 1 run scoreboard players get @s rgp.id",
       fn("remove",f"with storage {STATE} owner"))
    mc("remove",*(f"$execute in {dim} run kill @e[tag=rgp.ui,distance=0..,scores={{rgp.id=$(id)}}]" for dim in DIMS))
    mc("owner_watch",f"execute store result storage {STATE} owner.id int 1 run scoreboard players get @s rgp.id",
       fn("owner_check",f"with storage {STATE} owner"))
    mc("owner_check",f"$execute unless entity @a[tag=rgp.open,distance=0..,scores={{rgp.id=$(id)}}] run {fn('remove','{id:$(id)}')}")
    mc("watch",f"execute store result score #usable rgp.sys run {fn('available')}",
       f"execute unless score #usable rgp.sys matches 1 run return run {fn('close')}",
       f"execute unless score @s rgp.room = @s zx.rg_room run return run {fn('close')}",fn("hover"))

    map_graph(mc)
    map_panels(mc,data)
    map_input(mc)
    stage_resources(world,KINDS)


def map_graph(mc):
    open_edges = []
    for i in range(len(EDGES)):
        open_edges.extend((f"scoreboard players set #e{i} rgp.sys 0",
                           f"execute store result score #e{i} rgp.sys run data get storage {GRAPH} floor.edges[{i}]"))
    mc("reachable", *open_edges,
       f"execute store result score #shrub rgp.sys run data get storage {FLOOR} shrub.edge",
       f"execute unless data storage {FLOOR} shrub.edge run scoreboard players set #shrub rgp.sys -1",
       *(f"scoreboard players set #r{i} rgp.sys 0" for i in CELLS),
       *(f"scoreboard players set #a{i} rgp.sys 0" for i in CELLS),
       *(f"execute if score @s zx.rg_room matches {i} run scoreboard players set #r{i} rgp.sys 1" for i in CELLS),
       *(fn("flood") for _ in CELLS),
       *(f"execute if score @s zx.rg_room matches {a} if score #e{i} rgp.sys matches 1 run scoreboard players set #a{b} rgp.sys 1"
         for i,pair in enumerate(EDGES) for a,b in (pair,pair[::-1])))
    mc("flood", *(f"execute if score #r{a} rgp.sys matches 1 if score #e{i} rgp.sys matches 1 if data storage {GRAPH} floor.cells[{{cell:{b},present:1b,visited:1b}}] run scoreboard players set #r{b} rgp.sys 1"
                  for i,pair in enumerate(EDGES) for a,b in (pair,pair[::-1])))


def map_panels(mc,data):
    def layer(line):
        return line.replace('"rd.ui"','"rgp.ui","rgp.new"').replace('"rd.rotate",','').replace('"rd.node",','')

    dispatch=[]
    for variant in MAP_VIEWS:
        view=MapView(variant)
        clear=" ".join(f"if block {p} #fallenroute:floor_air unless block {under} #fallenroute:floor_tall" for p,under in view.clearance())
        dispatch.append(f"execute {clear} run return run {fn('board/'+variant)}")
        rows=[fn("begin"),'summon minecraft:marker ~ ~ ~ {Tags:["rgp.ui","rgp.new","rgp.anchor"]}',
              layer(view.plane(0,0,0,12,12,"parchment","rgp.paper")),
              f"execute if dimension {DIMS[0]} run "+layer(view.text(0,5.23,"密林",1.5)),
              f"execute if dimension {DIMS[1]} run "+layer(view.text(0,5.23,"矿洞",1.5)),
              layer(view.text(4.75,5.23,"收起",1.03)),
              layer(view.hitbox(4.75,5.33,"rgp.cancel",1.1,.58)),
              "scoreboard players set @e[tag=rgp.cancel,tag=rgp.new,distance=..5] rgp.cell -1"]
        for i,(a,b) in enumerate(EDGES):
            ax,ay=point(a)
            bx,by=point(b)
            road=lambda name:layer(view.plane((ax+bx)/2,(ay+by)/2,-.08,STEP-ROOM_SIDE+.025,.14,name,"rgp.road",0 if ay==by else pi/2))
            rows.extend((f"execute if score #e{i} rgp.sys matches 1 unless score #shrub rgp.sys matches {i} run "+road("road"),
                         f"execute if score #shrub rgp.sys matches {i} if score #e{i} rgp.sys matches 0 run "+road("tree"),
                         f"execute if score #shrub rgp.sys matches {i} if score #e{i} rgp.sys matches 1 run "+road("tree_open")))
        for i in CELLS:
            x,y=point(i)
            stamp=lambda name:layer(view.plane(x,y,-.19,ROOM_SIDE,ROOM_SIDE,name,f"rgp.frame_{i}"))
            mc(f"board/{variant}_{i}",
               f"execute if score #r{i} rgp.sys matches 0 if score #a{i} rgp.sys matches 0 run "+stamp("room"),
               f"execute if score #r{i} rgp.sys matches 1 run "+stamp("seen"),
               f"execute if score #r{i} rgp.sys matches 0 if score #a{i} rgp.sys matches 1 run "+stamp("fresh"),
               f"$execute if data storage {GRAPH} floor.cells[{{cell:{i},revealed:1b}}] run "+layer(view.plane(x,y,-.26,1.65,1.65,"icon_$(kind)",f"rgp.icon_{i}")),
               layer(view.hitbox(x,y,f"rgp.cell_{i}",1.63,1.63)),
               f"scoreboard players set @e[tag=rgp.cell_{i},tag=rgp.new,distance=..5] rgp.cell {i}")
            rows.append(f"execute if data storage {GRAPH} floor.cells[{{cell:{i},present:1b}}] run {fn(f'board/{variant}_{i}',f'with storage {GRAPH} floor.cells[{i}]')}")
        mc(f"board/{variant}",*rows,fn("stamp"))
    mc("place",*dispatch,message("前方太窄，退半步展开地图。"))
    for i in CELLS:
        data(f"data/fallenroute/predicate/floor/look_{i}.json",{"condition":"minecraft:entity_properties","entity":"this","predicate":{
            "type_specific":{"type":"minecraft:player","looking_at":{"type":"minecraft:interaction","nbt":f'{{Tags:["rgp.cell_{i}"]}}'}},
        }})
    mc("hover","scoreboard players set #hover rgp.sys -1",
       *(f"execute if predicate fallenroute:floor/look_{i} run scoreboard players set #hover rgp.sys {i}" for i in CELLS),
       "execute if score @s rgp.hover = #hover rgp.sys run return 0",
       f"execute store result storage {STATE} owner.id int 1 run scoreboard players get @s rgp.id",
       fn("hover_draw",f"with storage {STATE} owner"),"scoreboard players operation @s rgp.hover = #hover rgp.sys")
    mc("hover_draw",*(row for i in CELLS for row in (
        f"$execute if score @s rgp.hover matches {i} as @e[tag=rgp.icon_{i},distance=0..,scores={{rgp.id=$(id)}}] run {fn('scale','{factor:0.892857}')}",
        f"$execute if score #hover rgp.sys matches {i} as @e[tag=rgp.icon_{i},distance=0..,scores={{rgp.id=$(id)}}] run {fn('scale','{factor:1.12}')}",
        f"execute if score #hover rgp.sys matches {i} if data storage {GRAPH} floor.cells[{{cell:{i},revealed:1b}}] run {fn('label',f'with storage {GRAPH} floor.cells[{i}]')}",
    )))
    mc("scale",f"$execute store result storage {STATE} zoom float $(factor) run data get entity @s transformation.scale[0] 1000000",
       f"execute store result storage {STATE} zoom float 0.000001 run data get storage {STATE} zoom",
       f"data modify entity @s transformation.scale[0] set from storage {STATE} zoom",
       f"data modify entity @s transformation.scale[1] set from storage {STATE} zoom")
    mc("label",f"$function {NS}name/$(kind)")
    for key,label in KINDS.items():
        mc("name/"+key,message(label,"dark_aqua"))


def map_input(mc):
    mc("click",f"data modify storage {STATE} click.uuid set from entity @s interaction.player", "data remove entity @s interaction",
       f"execute store result storage {STATE} click.id int 1 run scoreboard players get @s rgp.id",
       f"execute store result storage {STATE} click.cell int 1 run scoreboard players get @s rgp.cell",
       fn("resolve",f"with storage {STATE} click"))
    mc("resolve",f"$execute as @a[tag=rgp.open,distance=..5,nbt={{UUID:$(uuid)}},scores={{rgp.id=$(id)}}] at @s run {fn('pick','{cell:$(cell)}')}")
    mc("pick",f"execute if data storage {STATE} click{{cell:-1}} run return run {fn('close')}",
       f"execute store result score #usable rgp.sys run {fn('available')}",
       f"execute unless score #usable rgp.sys matches 1 run return run {fn('close')}",
       f"$execute if score @s zx.rg_room matches $(cell) run return run {fn('close')}",
       fn("reachable"),
       f"$execute if score #r$(cell) rgp.sys matches 1 run return run {fn('travel','{cell:$(cell)}')}",
       f"$execute if score #a$(cell) rgp.sys matches 1 if data storage {GRAPH} floor.cells[{{cell:$(cell),present:1b}}] run return run {fn('travel','{cell:$(cell)}')}",
       message("这间房当前不可达。"))
    mc("travel","$function sweetdream_floor:room/read_go {cell:$(cell)}",
       f"execute store result score #safe rgp.sys run {fn('can_land',f'with storage {FLOOR} inspected')}",
       "execute unless score #safe rgp.sys matches 1 run return run "+message("这间房暂时无法落脚。"),
       f"execute store result score #paid rgp.sys run function sweetdream_floor:explore/enter with storage {FLOOR} inspected",
       "tag @a[tag=sd.explore_arriving,distance=0..] remove sd.explore_arriving",
       "execute unless score #paid rgp.sys matches 1 run return run "+message("探索次数不足。"),
       f"$function sweetdream_floor:room/teleport_cell with storage {GRAPH} floor.cells[$(cell)]",
       f"$execute if score @s zx.rg_room matches $(cell) run {fn('close')}")
    mc("can_land",*(
        f"$execute positioned $(x) 81 $(z) align xz positioned ~{x} ~ ~{z} "
        "if block ~ ~ ~ #sweetdream_floor:room_air if block ~ ~1 ~ #sweetdream_floor:room_air "
        "unless block ~ ~-1 ~ #sweetdream_floor:room_air run return 1"
        for x,z in ((4.5,.5),(.5,4.5),(-3.5,.5),(.5,-3.5),(.5,.5))
    ),"return fail")
