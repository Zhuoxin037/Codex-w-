"""Wooden equipment lockers with personal, lossless item transfer."""

from forest_economy import FN, button, literal, say


CABINET = FN + "gear/"
STATE = "sweetdream_floor:gear"
HAND = "if items entity @s weapon.mainhand *"
DROPPED = "@e[type=minecraft:item,tag=sd.gear_transfer,distance=0..,limit=1]"
OWNER = "@a[tag=sd.gear_owner,limit=1]"


def cabinet(read, mc, replace, before, append):
    mc("room/store", f"function {CABINET}route")
    replace("run/arrive", 'setblock 6 81 78 minecraft:ender_chest[facing=north]',
            f"execute positioned 6 81 78 run function {CABINET}build")
    replace("run/arrive", '多余装备可放进寄存箱。', '状态菜单中可存取装备。')
    append("room/status", "tellraw @s " + literal(button("装备寄存", 125, "gold")))
    old = next((line for line in read("room/battle").splitlines()
                if "#weapons" in line and "最多携带三把武器" in line), None)
    if old:
        replace("room/battle", old, "execute if score #weapons sd.floor matches 4.. run return run tellraw @s " +
                literal([{"text":"开战最多带三把武器。  ","color":"yellow"},button("寄存主手",126,"green"),
                         {"text":"  "},button("装备寄存",125,"gold")]))
    commands = (
        f"execute if score #input sd.floor matches 125..126 run return run function {CABINET}route",
        f"execute if score #input sd.floor matches 600..626 run return run function {CABINET}route",
    )
    ledger = read("run/route").splitlines()[0]
    if commands[0] not in read("run/route"):
        before("run/route", ledger, "\n".join(commands))
    sign = literal([{"text": "装备柜", "color": "dark_green", "bold": True,
                     "click_event": {"action": "run_command", "command": "/trigger sd.floor_cmd set 125"}},
                    {"text": "右键存取"}, {"text": ""}, {"text": ""}])
    mc("gear/build",
       "setblock ~ ~ ~ stripped_spruce_wood[axis=y]",
       f"setblock ~ ~1 ~ spruce_sign[rotation=8]{{is_waxed:1b,front_text:{{messages:{sign}}},back_text:{{messages:{sign}}}}}")
    mc("gear/route", "execute if score #phase sd.floor matches 2 run return run " + say("战斗结束后可存取装备。", "gray"),
       "execute unless entity @s[tag=sd.floor_run,tag=zx.rg_active] run return 0",
       f"execute if score #input sd.floor matches 22 run return run function {CABINET}menu",
       f"execute if score #input sd.floor matches 125 run return run function {CABINET}menu",
       f"execute if score #input sd.floor matches 126 run return run function {CABINET}put",
       "scoreboard players operation #gear_slot sd.floor = #input sd.floor",
       "scoreboard players remove #gear_slot sd.floor 600",
       f"execute store result storage {STATE} slot.index int 1 run scoreboard players get #gear_slot sd.floor",
       f"function {CABINET}take with storage {STATE} slot")
    mc("gear/menu", say("装备寄存", "gold"), "tellraw @s " + literal(button("寄存主手", 126, "green")),
       *(f"function {CABINET}row {{index:{i},code:{600+i},label:{i+1}}}" for i in range(27)))
    mc("gear/row",
       f"$execute unless data entity @s EnderItems[{{Slot:$(index)b}}] run return 0",
       f"$data modify storage {STATE} shown set from entity @s EnderItems[{{Slot:$(index)b}}]",
       f"$data modify storage {STATE} shown merge value {{code:$(code),label:$(label)}}",
       f"execute unless data storage {STATE} shown.components run data modify storage {STATE} shown.components set value {{}}",
       f'data modify storage {STATE} shown.name set from storage {STATE} shown.components."minecraft:item_name"',
       f'data modify storage {STATE} shown.name set from storage {STATE} shown.components."minecraft:custom_name"',
       f"data modify storage {STATE} shown.itemx set string storage {STATE} shown.id 10",
       f"execute unless data storage {STATE} shown.name run function {CABINET}name with storage {STATE} shown",
       f"function {CABINET}line with storage {STATE} shown")
    mc("gear/name", f'$data modify storage {STATE} shown.name set value {{translate:"item.minecraft.$(itemx)"}}')
    mc("gear/line", '$tellraw @s {type:"nbt",nbt:"shown.name",storage:"sweetdream_floor:gear",interpret:true,color:"aqua",'
       'click_event:{action:"run_command",command:"/trigger sd.floor_cmd set $(code)"},'
       'hover_event:{action:"show_item",id:"$(id)",count:$(count),components:$(components)}}')
    mc("gear/find_free", "scoreboard players set #gear_slot sd.floor -1",
       *(f"execute unless data entity @s EnderItems[{{Slot:{i}b}}] run return run scoreboard players set #gear_slot sd.floor {i}" for i in range(27)))
    mc("gear/slot", f"execute store result storage {STATE} slot.index int 1 run scoreboard players get #gear_slot sd.floor")
    mc("gear/put", f"execute unless items entity @s weapon.mainhand * run return run " + say("主手拿着要存的装备。", "gray"),
       f"function {CABINET}find_free", "execute if score #gear_slot sd.floor matches -1 run return run " + say("装备柜已满。", "yellow"),
       f"function {CABINET}slot", f"function {CABINET}put_at with storage {STATE} slot")
    mc("gear/put_at", "$execute store success score #gear_moved sd.floor run item replace entity @s enderchest.$(index) from entity @s weapon.mainhand",
       "execute unless score #gear_moved sd.floor matches 1 run return 0",
       "item replace entity @s weapon.mainhand with minecraft:air", say("已存入。", "green"), f"function {CABINET}menu")
    mc("gear/take", f"execute {HAND} run return run " + say("腾空主手再取出。", "gray"),
       "$execute store success score #gear_moved sd.floor run item replace entity @s weapon.mainhand from entity @s enderchest.$(index)",
       "execute unless score #gear_moved sd.floor matches 1 run return 0",
       "$item replace entity @s enderchest.$(index) with minecraft:air", say("已取出。", "green"), f"function {CABINET}menu")
    drops(mc, before, append)


def drops(mc, before, append):
    gear = "execute if data entity @s Item.components.\"minecraft:custom_data\".zx run return 1"
    mc("gear/is_equipment", gear,
       *(f'execute if data entity @s Item{{id:"minecraft:iron_{part}"}} run return 1'
         for part in ("helmet", "chestplate", "leggings", "boots")), "return 0")
    boundary = f"execute if function {CABINET}boundary run return run " + say("先捡起你丢在地上的装备。", "yellow")
    before("run/join_party", "tag @s remove sd.lobby_ready", boundary)
    before("training/enter", "function fallendream:lib/uuid",
           f"execute if function {CABINET}boundary run return run function {CABINET}training_block")
    mc("gear/training_block", "tag @s add sd.training_gate", say("先捡起你丢在地上的装备。", "yellow"))
    append("lobby/practice/tick", 'kill @e[type=minecraft:item,distance=0..,nbt={Item:{components:{"minecraft:custom_data":{sd_training:1b}}}}]')
    mc("gear/boundary", "tag @s add sd.gear_owner",
       "scoreboard players set #gear_dropped sd.floor 0",
       f"execute as @e[type=minecraft:item,distance=..96] if function {CABINET}is_equipment on origin if entity @s[tag=sd.gear_owner] run scoreboard players set #gear_dropped sd.floor 1",
       "tag @s remove sd.gear_owner", "return run scoreboard players get #gear_dropped sd.floor")
    # This line must precede the tutorial's early return in the global tick.
    start = f"function {FN}lobby/rejoin/tick"
    before("tick", start, "\n".join(
        f"execute in sweetdream:{dim} if entity @a[tag=sd.floor_run,distance=0..] run function {CABINET}scan"
        for dim in ("floor_1_forest", "floor_2_trial")))
    mc("gear/scan",
       f"execute as @e[type=minecraft:item,tag=!sd.gear_returning,distance=0..] at @s if function {CABINET}is_equipment run function {CABINET}drop_source")
    mc("gear/drop_source", "tag @s add sd.gear_transfer",
       f"execute on origin if entity @s[tag=sd.floor_run,tag=zx.rg_active] run function {CABINET}receive_drop",
       "tag @s remove sd.gear_transfer")
    mc("gear/receive_drop", f"function {CABINET}find_free",
       f"execute if score #gear_slot sd.floor matches -1 run return run function {CABINET}return_drop",
       f"function {CABINET}slot", "tag @s add sd.gear_owner",
       f"execute summon minecraft:item_display run function {CABINET}relay with storage {STATE} slot",
       "tag @s remove sd.gear_owner")
    mc("gear/relay", f"data modify entity @s item set from entity {DROPPED} Item",
       f"$execute store success score #gear_moved sd.floor run item replace entity {OWNER} enderchest.$(index) from entity @s contents",
       f"execute if score #gear_moved sd.floor matches 1 run kill {DROPPED}",
       f'execute if score #gear_moved sd.floor matches 1 run title {OWNER} actionbar {{text:"装备已存入木柜",color:"green"}}',
       "kill @s")
    mc("gear/return_drop", f"data modify entity {DROPPED} Owner set from entity @s UUID",
       f"data merge entity {DROPPED} {{PickupDelay:0s}}", f"tp {DROPPED} @s",
       f"tag {DROPPED} add sd.gear_returning")
