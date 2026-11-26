execute if score #edu_frame sd.floor matches 1 run item replace entity @e[type=minecraft:armor_stand,tag=sd.edu_hero,distance=..25,limit=1] weapon.mainhand with minecraft:iron_sword[minecraft:item_model="sweetdream:tidemark"]
execute if score #edu_frame sd.floor matches 1 run function sweetdream_floor:tutorial/stage/pose {right:-42,left:0,turn:-12}
execute if score #edu_frame sd.floor matches 1 run function sweetdream_floor:tutorial/stage/cue {line:"我 · 无特殊能力",color:"aqua"}
execute if score #edu_frame sd.floor matches 25 run item replace entity @e[type=minecraft:armor_stand,tag=sd.edu_hero,distance=..25,limit=1] weapon.mainhand with minecraft:recovery_compass[minecraft:item_model="sweetdream:apocalypse"]
execute if score #edu_frame sd.floor matches 25 run function sweetdream_floor:tutorial/stage/pose {right:-112,left:-25,turn:10}
execute if score #edu_frame sd.floor matches 25 run function sweetdream_floor:tutorial/stage/cue {line:"魔导士 · 魔力 法杖 法球",color:"aqua"}
execute if score #edu_frame sd.floor matches 25 run function sweetdream_floor:tutorial/stage/bolt
execute if score #edu_frame sd.floor matches 49 run item replace entity @e[type=minecraft:armor_stand,tag=sd.edu_hero,distance=..25,limit=1] weapon.mainhand with minecraft:iron_axe
execute if score #edu_frame sd.floor matches 49 run function sweetdream_floor:tutorial/stage/pose {right:-68,left:0,turn:16}
execute if score #edu_frame sd.floor matches 49 run function sweetdream_floor:tutorial/stage/cue {line:"狂徒 · 近战 生存 血量",color:"red"}
execute if score #edu_frame sd.floor matches 73 run item replace entity @e[type=minecraft:armor_stand,tag=sd.edu_hero,distance=..25,limit=1] weapon.mainhand with minecraft:recovery_compass[minecraft:item_model="sweetdream:job_mana_crystal"]
execute if score #edu_frame sd.floor matches 73 run function sweetdream_floor:tutorial/stage/pose {right:-72,left:-62,turn:0}
execute if score #edu_frame sd.floor matches 73 run function sweetdream_floor:tutorial/stage/cue {line:"歌者 · 术阵 召唤 追随者",color:"yellow"}
execute if score #edu_frame sd.floor matches 97 run item replace entity @e[type=minecraft:armor_stand,tag=sd.edu_hero,distance=..25,limit=1] weapon.mainhand with minecraft:recovery_compass[minecraft:item_model="sweetdream:apocalypse"]
execute if score #edu_frame sd.floor matches 97 run function sweetdream_floor:tutorial/stage/pose {right:-42,left:-50,turn:-16}
execute if score #edu_frame sd.floor matches 97 run function sweetdream_floor:tutorial/stage/cue {line:"同生 · 在两种形态间切换",color:"light_purple"}
