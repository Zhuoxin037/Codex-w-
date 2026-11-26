execute if score #edu_frame sd.floor matches 1 run function sweetdream_floor:tutorial/stage/pose {right:-41,left:-12,turn:0}
execute if score #edu_frame sd.floor matches 1 run item replace entity @e[type=minecraft:armor_stand,tag=sd.edu_hero,distance=..25,limit=1] weapon.mainhand with minecraft:recovery_compass[minecraft:item_model="sweetdream:look"]
execute if score #edu_frame sd.floor matches 1 run function sweetdream_floor:tutorial/stage/cue {line:"",color:"aqua"}
execute if score #edu_frame sd.floor matches 31 run function sweetdream_floor:tutorial/stage/pose {right:-73,left:-55,turn:0}
execute if score #edu_frame sd.floor matches 31 run function sweetdream_floor:tutorial/stage/cue {line:"渊海      治疗      基础攻击",color:"yellow"}
execute if score #edu_frame sd.floor matches 31 run particle minecraft:end_rod -92.1 91.7 48.5 1.0 0.08 0.7 0.015 14 force
execute if score #edu_frame sd.floor matches 67 run function sweetdream_floor:tutorial/stage/pose {right:-90,left:-30,turn:10}
execute if score #edu_frame sd.floor matches 67 run function sweetdream_floor:tutorial/stage/cue {line:"选「渊海」 · 从这一档的渊海装备里抽",color:"aqua"}
execute if score #edu_frame sd.floor matches 87 run function sweetdream_floor:tutorial/stage/pose {right:-49,left:0,turn:0}
execute if score #edu_frame sd.floor matches 87 run item replace entity @e[type=minecraft:armor_stand,tag=sd.edu_hero,distance=..25,limit=1] weapon.mainhand with minecraft:iron_sword[minecraft:item_model="sweetdream:tidemark"]
execute if score #edu_frame sd.floor matches 87 run particle minecraft:happy_villager -94.4 91.55 48.5 0.4 0.25 0.45 0.02 13 force
execute if score #edu_frame sd.floor matches 87 run function sweetdream_floor:tutorial/stage/cue {line:"本次示例 · 获得潮痕",color:"gold"}
