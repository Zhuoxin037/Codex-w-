execute in minecraft:overworld unless loaded -106 90 48 run return run schedule function sweetdream_floor:lobby/build_loaded 1s
execute in minecraft:overworld unless loaded -36 90 48 run return run schedule function sweetdream_floor:lobby/build_loaded 1s
execute in minecraft:overworld run function sweetdream_floor:lobby/structure
data modify storage sweetdream_floor:run lobby set value 1b
execute in minecraft:overworld run forceload remove -112 32 -32 64
