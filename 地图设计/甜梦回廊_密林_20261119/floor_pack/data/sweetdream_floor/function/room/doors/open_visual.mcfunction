$fill ~-$(x) ~ ~-$(z) ~$(x) ~4 ~$(z) minecraft:air replace minecraft:barrier
$execute positioned ~-$(x) ~ ~-$(z) as @e[type=minecraft:block_display,tag=sd.floor_gate,distance=..0.25] run function sweetdream_floor:room/doors/lift
