execute if score #edu_frame sd.floor matches 1 run function sweetdream_floor:tutorial/stage/pose {right:0,left:0,turn:0}
execute if score #edu_frame sd.floor matches 1 run effect give @e[type=minecraft:allay,tag=sd.edu_familiar,distance=..25] minecraft:invisibility infinite 0 true
execute if score #edu_frame sd.floor matches 1 run function sweetdream_floor:tutorial/stage/cue {line:"术阵",color:"aqua"}
execute if score #edu_frame sd.floor matches 23 run function sweetdream_floor:tutorial/stage/pose {right:-100,left:-57,turn:0}
execute if score #edu_frame sd.floor matches 23 run particle minecraft:enchant -94.8 90.3 48.5 0.75 0.15 0.75 0 28 force
execute if score #edu_frame sd.floor matches 40 run function sweetdream_floor:tutorial/stage/pose {right:-69,left:-83,turn:0}
execute if score #edu_frame sd.floor matches 40 run function sweetdream_floor:tutorial/stage/cue {line:"领域",color:"aqua"}
execute if score #edu_frame sd.floor matches 40 run particle minecraft:witch -91.5 90.25 48.5 1.65 0.1 1.45 0.06 22 force
execute if score #edu_frame sd.floor matches 53 run particle minecraft:witch -91.5 90.25 48.5 1.65 0.1 1.45 0.06 22 force
execute if score #edu_frame sd.floor matches 73 run function sweetdream_floor:tutorial/stage/pose {right:-52,left:-45,turn:0}
execute if score #edu_frame sd.floor matches 73 run function sweetdream_floor:tutorial/stage/cue {line:"召唤",color:"gold"}
execute if score #edu_frame sd.floor matches 73 run effect clear @e[type=minecraft:allay,tag=sd.edu_familiar,distance=..25] minecraft:invisibility
execute if score #edu_frame sd.floor matches 73 run particle minecraft:happy_villager -90.4 91.25 49.6 0.3 0.3 0.3 0 9 force
execute if score #edu_frame sd.floor matches 93 run tp @e[type=minecraft:allay,tag=sd.edu_familiar,distance=..25] -92.0 91.4 49.6
execute if score #edu_frame sd.floor matches 114 run tp @e[type=minecraft:allay,tag=sd.edu_familiar,distance=..25] -90.4 91.05 49.6
