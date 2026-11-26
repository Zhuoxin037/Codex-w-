"""Generate the in-room equipment cabinet and reuse the player's stored stacks."""

import json

from floor_route_map import DIMS


NS = "sweetdream_floor:wardrobe/"
STORE = "sweetdream_floor:wardrobe"
FLOOR = "sweetdream_floor:run"
SLOTS = (1.70, .61, -.61, -1.70)
ITEM_KIND = "sdc.kind"
KEY = "minecraft:paper[minecraft:custom_data~{fr_cabinet:1b}]"


def snbt(data):
    return json.dumps(data,ensure_ascii=False,separators=(",",":"))


def at(x,y,z,action):
    return f"execute positioned ^{x:g} ^{y:g} ^{z:g} run {action}"


def label(x,y,words,color,scale,extra="",bold=False):
    title=snbt({"text":words,"color":color,"bold":bold})
    nbt=(f'{{Tags:["sdc.panel","sdc.new"{extra}],billboard:"fixed",background:0,shadow:0b,line_width:74,'
         f'brightness:{{block:15,sky:15}},text:{title},transformation:{{translation:[0f,0f,0f],'
         f'scale:[{scale:g}f,{scale:g}f,{scale:g}f],left_rotation:[0f,0f,0f,1f],right_rotation:[0f,0f,0f,1f]}}}}')
    return at(x,y,-.13,f"summon minecraft:text_display ~ ~ ~ {nbt}")


def hitbox(x,y,index,w,h):
    return at(x,y,-.17,
              f'summon minecraft:interaction ~ ~ ~ {{Tags:["sdc.panel","sdc.new","sdc.slot_{index}"],width:{w:g}f,height:{h:g}f,response:1b}}')


def folio():
    return at(0,0,.07,
              'summon minecraft:item_display ~ ~ ~ {Tags:["sdc.panel","sdc.new"],item_display:"none",'
              'brightness:{block:15,sky:15},width:5f,height:2.4f,'
              'item:{id:"minecraft:paper",count:1,components:{"minecraft:item_model":"fallenrooms:folio"}},'
              'transformation:{translation:[0f,0f,0f],scale:[4.88f,2.3f,1f],'
              'left_rotation:[0f,0f,0f,1f],right_rotation:[0f,0f,0f,1f]}}')


def wardrobe(mc,asset,read):
    def fn(name,*lines):
        mc(NS+name,*lines)

    fn("load",*(f"scoreboard objectives add sdc.{name} dummy" for name in ("id","sys","room","slot","hover","kind")),
       "scoreboard players add #next sdc.sys 0")
    fn("tick",
       f"execute as @a[tag=sdc.open] at @s run function {NS}watch",
       *(f"execute in {dim} as @e[type=minecraft:interaction,tag=sdc.panel,distance=0..] at @s "
         f"if data entity @s interaction.player run function {NS}click" for dim in DIMS),
       *(f"execute in {dim} as @e[type=minecraft:marker,tag=sdc.anchor,distance=0..] at @s run function {NS}owner_watch" for dim in DIMS))
    fn("allowed",
       "execute unless entity @s[tag=sd.floor_run,tag=zx.rg_active,tag=!sd.rejoin_pending,tag=!sd.floor_mirror,"
       "scores={zx.rg_room=0..24,sd.floor_death=0}] run return fail",
       f"execute unless dimension {DIMS[0]} unless dimension {DIMS[1]} run return fail",
       "execute unless score #phase sd.floor matches 1..5 run return fail",
       "execute if score #phase sd.floor matches 2 run return fail",
       "return 1")
    mc("sweetdream_floor:gear/menu",f"execute at @s run function {NS}open")
    mc("sweetdream_floor:gear/put",f"execute at @s run function {NS}open")
    fn("open",
       f'execute unless function {NS}allowed run return run title @s actionbar {{text:"战斗结束后可存取装备。",color:"gray"}}',
       f"execute if entity @s[tag=sdc.open] run return run function {NS}redraw",
       "execute if entity @s[tag=rgp.open] run function fallenroute:floor/close",
       f"execute anchored eyes positioned ^ ^ ^ rotated ~ 0 positioned ^ ^-.30 ^3.35 run function {NS}place")
    checks=" ".join(f"if block ^{x:g} ^{y:g} ^{z:g} #fallenroute:floor_air"
                    for x,y,z in ((0,0,-1.4),(0,0,-.50),(-2,-.82,0),(2,-.82,0),(-2,.85,0),(2,.85,0),(0,0,0)))
    fn("place",f"execute {checks} run return run function {NS}draw",
       'title @s actionbar {text:"前方空间不足，退一步展开。",color:"gray"}')
    fn("draw",
       "execute unless score @s sdc.id matches 1.. run function "+NS+"allocate",
       "scoreboard players operation @s sdc.room = @s zx.rg_room",
       "scoreboard players set @s sdc.hover -1",
       "tag @s add sdc.open",
       "attribute @s minecraft:entity_interaction_range modifier add fallendream:cabinet_reach 0.85 add_value",
       'summon minecraft:marker ~ ~ ~ {Tags:["sdc.panel","sdc.new","sdc.anchor"]}',
       folio(),
       label(0,.78,"装备寄存","#f4e2c1",1.12,bold=True),
       label(1.155,.34,"武器","#efd6a4",.78,bold=True),
       label(-1.155,.34,"盔甲","#b5dfd7",.78,bold=True),
       label(-1.93,.79,"收起","#c7bfb2",.68),
       hitbox(-1.93,.79,4,.68,.29),
       *(hitbox(x,-.64,i,.91,.88) for i,x in enumerate(SLOTS)),
       label(0,-1.01,"右击存取","#c7bfb2",.69),
       f"function {NS}stamp",
       f"function {NS}redraw")
    fn("allocate","scoreboard players add #next sdc.sys 1","scoreboard players operation @s sdc.id = #next sdc.sys")
    fn("stamp",
       "execute as @e[tag=sdc.new,distance=..6] run rotate @s ~180 0",
       "scoreboard players operation @e[tag=sdc.new,distance=..6] sdc.id = @s sdc.id",
       *(f"scoreboard players set @e[tag=sdc.slot_{i},tag=sdc.new,distance=..6] sdc.slot {i}" for i in range(6)),
       "tag @e[tag=sdc.new,distance=..6] remove sdc.new")
    fn("read_owner",f"execute store result storage {STORE} owner.id int 1 run scoreboard players get @s sdc.id")
    fn("redraw","scoreboard players set @s sdc.hover -1",f"function {NS}read_owner",f"function {NS}refresh with storage {STORE} owner")
    fn("refresh",
       f"$kill @e[tag=sdc.content,distance=0..,scores={{sdc.id=$(id)}}]",
       f"$execute at @e[tag=sdc.anchor,distance=..7,limit=1,scores={{sdc.id=$(id)}}] rotated ~180 0 run function {NS}contents")
    content=[]
    for index,x in enumerate(SLOTS):
        slots=f"EnderItems[{{Slot:{index}b}}]"
        content.extend((f"execute unless data entity @s {slots} run "+
                        label(x,-.245,"空位","#a3a29e",.71,',"sdc.content"'),
                        f"execute if data entity @s {slots} run function {NS}paint_{index}"))
        fn(f"paint_{index}",
           f"data modify storage {STORE} item set from entity @s {slots}",
           f"data remove storage {STORE} item.Slot",
           f"data modify storage {STORE} words set value {{text:\"装备\",color:\"#e6d8c1\"}}",
           f"data modify storage {STORE} suffix set value {{id:\"\"}}",
           f"data modify storage {STORE} suffix.id set string storage {STORE} item.id 10",
           f"function {NS}translate with storage {STORE} suffix",
           f"execute if data storage {STORE} item.components.\"minecraft:item_name\" run data modify storage {STORE} words set from storage {STORE} item.components.\"minecraft:item_name\"",
           f"execute if data storage {STORE} item.components.\"minecraft:custom_name\" run data modify storage {STORE} words set from storage {STORE} item.components.\"minecraft:custom_name\"",
           at(x,-.11,-.17,
              'summon minecraft:item_display ~ ~ ~ '
              f'{{Tags:["sdc.panel","sdc.new","sdc.content","sdc.icon_{index}"],item_display:"gui",'
              'brightness:{block:15,sky:15},transformation:{translation:[0f,0f,0f],scale:[.59f,.59f,.59f],'
              'left_rotation:[0f,0f,0f,1f],right_rotation:[0f,0f,0f,1f]}}'),
           f"data modify entity @e[tag=sdc.icon_{index},tag=sdc.new,distance=..6,limit=1] item set from storage {STORE} item",
           label(x,-.65,"","#ebe2d0",.60,f',"sdc.content","sdc.label_{index}"'),
           f"data modify entity @e[tag=sdc.label_{index},tag=sdc.new,distance=..6,limit=1] text set from storage {STORE} words")
    fn("translate",f'$data modify storage {STORE} words set value {{translate:"item.minecraft.$(id)",color:"#ebe2d0"}}')
    content+=[
        "execute store result score #stored sdc.sys run data get entity @s EnderItems",
        *(f"execute if data entity @s EnderItems[{{Slot:{i}b}}] run scoreboard players remove #stored sdc.sys 1" for i in range(4)),
        "execute if score #stored sdc.sys matches 1.. run "+label(1.84,.79,"旧装备","#c7bfb2",.65,',"sdc.content"'),
        "execute if score #stored sdc.sys matches 1.. run "+hitbox(1.84,.79,5,.70,.29).replace('"sdc.new"','"sdc.new","sdc.content"'),
        f"function {NS}stamp",
    ]
    fn("contents",*content)
    fn("close","tag @s remove sdc.open",
       "attribute @s minecraft:entity_interaction_range modifier remove fallendream:cabinet_reach",
       f"function {NS}read_owner",f"function {NS}remove with storage {STORE} owner")
    fn("remove",*(f"$execute in {dim} run kill @e[tag=sdc.panel,distance=0..,scores={{sdc.id=$(id)}}]" for dim in DIMS))
    fn("owner_watch",f"function {NS}read_owner",f"function {NS}owner_present with storage {STORE} owner")
    fn("owner_present",f"$execute unless entity @a[tag=sdc.open,distance=..7,scores={{sdc.id=$(id)}}] run function {NS}remove {{id:$(id)}}")
    fn("watch",f"execute unless function {NS}allowed run return run function {NS}close",
       f"execute if entity @s[tag=rgp.open] run return run function {NS}close",
       f"execute unless score @s sdc.room = @s zx.rg_room run return run function {NS}close",
       f"function {NS}read_owner",f"function {NS}watch_near with storage {STORE} owner")
    fn("watch_near",
       f"$execute unless entity @e[tag=sdc.anchor,distance=..6.5,scores={{sdc.id=$(id)}}] run return run function {NS}close",
       f"function {NS}hover")
    fn("click",
       f"data modify storage {STORE} tap.uuid set from entity @s interaction.player",
       "data remove entity @s interaction",
       f"execute store result storage {STORE} tap.id int 1 run scoreboard players get @s sdc.id",
       f"execute store result storage {STORE} tap.slot int 1 run scoreboard players get @s sdc.slot",
       f"function {NS}resolve with storage {STORE} tap")
    fn("resolve",
       f"$execute as @a[tag=sdc.open,distance=..5,nbt={{UUID:$(uuid)}},scores={{sdc.id=$(id)}}] at @s "
       f"run function {NS}select {{slot:$(slot)}}")
    fn("select",f"execute unless function {NS}allowed run return run function {NS}close",f"$function {NS}slot_$(slot)")
    fn("slot_4",f"function {NS}close")
    fn("slot_5",f"function {NS}legacy")
    fn("legacy",f"function {NS}close",
       *(f"function sweetdream_floor:gear/row {{index:{i},code:{600+i},label:{i+1}}}" for i in range(4,27)))
    for index in range(4):
        fn(f"slot_{index}",
           f"execute if data entity @s EnderItems[{{Slot:{index}b}}] run return run function {NS}take {{slot:{index}}}",
           f"function {NS}put {{slot:{index},kind:{1 if index<2 else 2}}}")
    fn("take",
       f"$execute if items entity @s weapon.mainhand {KEY} run return run function {NS}take_free {{slot:$(slot)}}",
       'execute if items entity @s weapon.mainhand * run return run title @s actionbar {text:"空手右击取出",color:"yellow"}',
       "$execute store success score #moved sdc.sys run item replace entity @s weapon.mainhand from entity @s enderchest.$(slot)",
       "execute unless score #moved sdc.sys matches 1 run return 0",
       "$item replace entity @s enderchest.$(slot) with minecraft:air",
       f"function {NS}moved")
    fn("take_free",
       *(f"$execute unless items entity @s {target} * run return run function {NS}take_at {{source:$(slot),target:\"{target}\"}}"
         for target in [*(f"hotbar.{i}" for i in range(7)),*(f"inventory.{i}" for i in range(27))]),
       'title @s actionbar {text:"背包已满",color:"yellow"}')
    fn("take_at",
       "$execute store success score #moved sdc.sys run item replace entity @s $(target) from entity @s enderchest.$(source)",
       "execute unless score #moved sdc.sys matches 1 run return 0",
       "$item replace entity @s enderchest.$(source) with minecraft:air",
       f"function {NS}moved")
    fn("put",
       'execute unless items entity @s weapon.mainhand * run return 0',
       f"data modify storage {STORE} item set from entity @s SelectedItem",
       f"execute store result score #kind {ITEM_KIND} run function {NS}kind",
       '$execute unless score #kind sdc.kind matches $(kind) run return run title @s actionbar {text:"请选装备对应的空位",color:"yellow"}',
       "$execute store success score #moved sdc.sys run item replace entity @s enderchest.$(slot) from entity @s weapon.mainhand",
       "execute unless score #moved sdc.sys matches 1 run return 0",
       "item replace entity @s weapon.mainhand with minecraft:air",
       f"function {NS}moved")
    fn("moved", "playsound minecraft:item.armor.equip_leather player @s ~ ~ ~ .48 1.20",f"function {NS}redraw")
    classification(fn)
    hover(fn,asset)
    drops(mc,fn,read)


def classification(fn):
    # Equippable head/body slots include custom armor and vanilla iron starters.
    fn("kind",
       *(f'execute if data storage {STORE} item.components."minecraft:equippable"{{slot:"{slot}"}} run return 2'
         for slot in ("head","chest","legs","feet")),
       f'execute if data storage {STORE} item.components."minecraft:custom_data"{{zx:["armor"]}} run return 2',
       *(f'execute if data storage {STORE} item{{id:"minecraft:{material}_{part}"}} run return 2'
         for material in ("leather","chainmail","iron","golden","diamond","netherite")
         for part in ("helmet","chestplate","leggings","boots")),
       f'execute if data storage {STORE} item{{id:"minecraft:turtle_helmet"}} run return 2',
       *(f'execute if data storage {STORE} item.components."minecraft:custom_data"{{zx:["{group}"]}} run return 1'
         for group in ("sword","axe","staff","bow")),
       *(f'execute if data storage {STORE} item{{id:"minecraft:{material}_{group}"}} run return 1'
         for material in ("wooden","stone","iron","golden","diamond","netherite") for group in ("sword","axe")),
       *(f'execute if data storage {STORE} item{{id:"minecraft:{name}"}} run return 1'
         for name in ("bow","crossbow","trident","mace")),
       "return 0")


def hover(fn,asset):
    for index in range(4):
        value={"condition":"minecraft:entity_properties","entity":"this","predicate":{
            "type_specific":{"type":"minecraft:player","looking_at":{
                "type":"minecraft:interaction","nbt":f'{{Tags:["sdc.slot_{index}"]}}',
            }},
        }}
        asset(f"data/sweetdream_floor/predicate/wardrobe/look_{index}.json",snbt(value))
    fn("hover",
       "scoreboard players set #aim sdc.sys -1",
       *(f"execute if predicate sweetdream_floor:wardrobe/look_{index} run scoreboard players set #aim sdc.sys {index}" for index in range(4)),
       "execute if score @s sdc.hover = #aim sdc.sys run return 0",
       f"function {NS}icon_size with storage {STORE} owner",
       "scoreboard players operation @s sdc.hover = #aim sdc.sys")
    fn("icon_size",*(line for i in range(4) for line in (
        f'$execute if score @s sdc.hover matches {i} run data merge entity @e[tag=sdc.icon_{i},distance=0..,limit=1,'
        'scores={sdc.id=$(id)}] {start_interpolation:0,interpolation_duration:3,transformation:{scale:[.59f,.59f,.59f]}}',
        f'$execute if score #aim sdc.sys matches {i} run data merge entity @e[tag=sdc.icon_{i},distance=0..,limit=1,'
        'scores={sdc.id=$(id)}] {start_interpolation:0,interpolation_duration:3,transformation:{scale:[.69f,.69f,.69f]}}',
    )))


def drops(mc,fn,read):
    stock=read("sweetdream_floor:gear/receive_drop")
    assert stock[0]=="function sweetdream_floor:gear/find_free"
    mc("sweetdream_floor:gear/receive_drop",
       f"data modify storage {STORE} item set from entity @e[type=minecraft:item,tag=sd.gear_transfer,distance=0..,limit=1] Item",
       f"execute store result score #kind {ITEM_KIND} run function {NS}kind",
       f"function {NS}free",
       *stock[1:],
       f"execute if score #gear_moved sd.floor matches 1 if entity @s[tag=sdc.open] at @s run function {NS}redraw")
    fn("free","scoreboard players set #gear_slot sd.floor -1",
       *(f"execute if score #kind {ITEM_KIND} matches {1 if index<2 else 2} unless data entity @s EnderItems[{{Slot:{index}b}}] "
         f"run return run scoreboard players set #gear_slot sd.floor {index}" for index in range(4)))
