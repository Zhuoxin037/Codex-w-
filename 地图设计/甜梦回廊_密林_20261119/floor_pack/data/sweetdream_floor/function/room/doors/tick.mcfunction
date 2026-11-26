execute as @e[type=minecraft:block_display,tag=sd.floor_gate_open,distance=0..] run scoreboard players remove @s sd.floor 1
execute as @e[type=minecraft:block_display,tag=sd.floor_gate_open,scores={sd.floor=..0},distance=0..] run function sweetdream_floor:room/doors/discard
execute as @e[type=minecraft:block_display,tag=sd.floor_gate_ready,distance=0..] run function sweetdream_floor:room/doors/lower
tag @e[type=minecraft:block_display,tag=sd.floor_gate_new,distance=0..] add sd.floor_gate_ready
tag @e[type=minecraft:block_display,tag=sd.floor_gate_new,distance=0..] remove sd.floor_gate_new
