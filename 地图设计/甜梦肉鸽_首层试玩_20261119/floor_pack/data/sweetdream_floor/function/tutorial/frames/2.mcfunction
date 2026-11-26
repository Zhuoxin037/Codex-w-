execute if score #edu_frame sd.floor matches 1 run function sweetdream:tag/unmark {target:"@e[type=minecraft:husk,tag=sd.edu_target,distance=..25,limit=1]",mark:"yuanhai"}
execute if score #edu_frame sd.floor matches 1 run item replace entity @e[type=minecraft:armor_stand,tag=sd.edu_hero,distance=..25,limit=1] weapon.mainhand with minecraft:iron_sword[minecraft:item_model="sweetdream:tidemark"]
execute if score #edu_frame sd.floor matches 1 run function sweetdream_floor:tutorial/stage/pose {right:0,left:0,turn:0}
execute if score #edu_frame sd.floor matches 1 run function sweetdream_floor:tutorial/stage/cue {line:"先用潮痕命中",color:"aqua"}
execute if score #edu_frame sd.floor matches 15 run function sweetdream_floor:tutorial/stage/pose {right:-110,left:0,turn:-13}
execute if score #edu_frame sd.floor matches 23 run function sweetdream_floor:tutorial/stage/pose {right:-42,left:0,turn:11}
execute if score #edu_frame sd.floor matches 23 run function sweetdream:tag/mark {target:"@e[type=minecraft:husk,tag=sd.edu_target,distance=..25,limit=1]",mark:"yuanhai"}
execute if score #edu_frame sd.floor matches 23 run function sweetdream_floor:tutorial/stage/bolt
execute if score #edu_frame sd.floor matches 23 run function sweetdream_floor:tutorial/stage/impact
execute if score #edu_frame sd.floor matches 23 run function sweetdream_floor:tutorial/stage/cue {line:"渊海已挂上",color:"aqua"}
execute if score #edu_frame sd.floor matches 53 run item replace entity @e[type=minecraft:armor_stand,tag=sd.edu_hero,distance=..25,limit=1] weapon.mainhand with minecraft:iron_sword[minecraft:item_model="sweetdream:backflow_tide"]
execute if score #edu_frame sd.floor matches 53 run function sweetdream_floor:tutorial/stage/pose {right:-103,left:0,turn:-13}
execute if score #edu_frame sd.floor matches 53 run function sweetdream_floor:tutorial/stage/cue {line:"使用退汐技能",color:"aqua"}
execute if score #edu_frame sd.floor matches 65 run function sweetdream_floor:tutorial/stage/pose {right:-36,left:0,turn:19}
execute if score #edu_frame sd.floor matches 65 run function sweetdream:tag/unmark {target:"@e[type=minecraft:husk,tag=sd.edu_target,distance=..25,limit=1]",mark:"yuanhai"}
execute if score #edu_frame sd.floor matches 65 run function sweetdream_floor:tutorial/stage/impact
execute if score #edu_frame sd.floor matches 65 run particle minecraft:splash -89.4 91 48.5 1.4 0.65 1.4 0.17 34 force
execute if score #edu_frame sd.floor matches 65 run function sweetdream_floor:tutorial/stage/cue {line:"渊海被消耗，技能被强化",color:"gold"}
execute if score #edu_frame sd.floor matches 86 run function sweetdream_floor:tutorial/stage/pose {right:0,left:0,turn:0}
