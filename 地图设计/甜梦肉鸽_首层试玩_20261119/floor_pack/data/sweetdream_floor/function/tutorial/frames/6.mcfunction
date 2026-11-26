execute if score #edu_frame sd.floor matches 1 run item replace entity @e[type=minecraft:armor_stand,tag=sd.edu_hero,distance=..25,limit=1] weapon.offhand with minecraft:iron_helmet
execute if score #edu_frame sd.floor matches 1 run item replace entity @e[type=minecraft:armor_stand,tag=sd.edu_hero,distance=..25,limit=1] weapon.mainhand with minecraft:recovery_compass[minecraft:custom_model_data={floats:[1.0f]}]
execute if score #edu_frame sd.floor matches 1 run function sweetdream_floor:tutorial/stage/pose {right:-74,left:-68,turn:-12}
execute if score #edu_frame sd.floor matches 1 run function sweetdream_floor:tutorial/stage/cue {line:"主手：魔力提升·α · 副手：头盔",color:"aqua"}
execute if score #edu_frame sd.floor matches 28 run function sweetdream_floor:tutorial/stage/pose {right:-48,left:-54,turn:0}
execute if score #edu_frame sd.floor matches 28 run particle minecraft:enchant -94.8 91.2 48.5 0.55 0.25 0.6 0.6 30 force
execute if score #edu_frame sd.floor matches 28 run function sweetdream_floor:tutorial/stage/cue {line:"右键升级 · 头盔增加魔力上限",color:"gold"}
execute if score #edu_frame sd.floor matches 65 run item replace entity @e[type=minecraft:armor_stand,tag=sd.edu_hero,distance=..25,limit=1] weapon.offhand with minecraft:iron_sword[minecraft:item_model="sweetdream:tidemark"]
execute if score #edu_frame sd.floor matches 65 run item replace entity @e[type=minecraft:armor_stand,tag=sd.edu_hero,distance=..25,limit=1] weapon.mainhand with minecraft:recovery_compass[minecraft:custom_model_data={floats:[59.0f]}]
execute if score #edu_frame sd.floor matches 65 run function sweetdream_floor:tutorial/stage/pose {right:-82,left:-59,turn:-9}
execute if score #edu_frame sd.floor matches 65 run function sweetdream_floor:tutorial/stage/cue {line:"主手：潮痕的超限石 · 副手：潮痕",color:"aqua"}
execute if score #edu_frame sd.floor matches 86 run item replace entity @e[type=minecraft:armor_stand,tag=sd.edu_hero,distance=..25,limit=1] weapon.mainhand with minecraft:iron_sword[minecraft:item_model="sweetdream:tidemark",minecraft:item_name={text:"超限·潮痕",color:"aqua",bold:true},minecraft:unbreakable={},minecraft:custom_data={zx:["tidemark","sword","itemreplace"],rarity:"t1",skill:"sweetdream:tidemark",tags:["yuanhai","max_mana","apply","overlimit"],ol:"tidemark"}]
execute if score #edu_frame sd.floor matches 86 run item replace entity @e[type=minecraft:armor_stand,tag=sd.edu_hero,distance=..25,limit=1] weapon.offhand with minecraft:air
execute if score #edu_frame sd.floor matches 86 run function sweetdream_floor:tutorial/stage/pose {right:-54,left:-38,turn:10}
execute if score #edu_frame sd.floor matches 86 run particle minecraft:witch -94.8 91.25 48.5 0.45 0.42 0.45 0.04 20 force
execute if score #edu_frame sd.floor matches 86 run function sweetdream_floor:tutorial/stage/cue {line:"超限完成 · 超限·潮痕",color:"light_purple"}
