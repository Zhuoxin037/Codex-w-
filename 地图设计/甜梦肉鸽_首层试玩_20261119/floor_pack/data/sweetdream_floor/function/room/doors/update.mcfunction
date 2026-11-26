# The corridor carves a quartz threshold into the deepslate perimeter only at a connected doorway.
$execute positioned $(x) 81 $(z) positioned ~$(radius) ~ ~ if block ~ ~-1 ~ minecraft:smooth_quartz run function sweetdream_floor:room/doors/threshold {x:0,z:2,width:0,depth:4}
$execute positioned $(x) 81 $(z) positioned ~-$(radius) ~ ~ if block ~ ~-1 ~ minecraft:smooth_quartz run function sweetdream_floor:room/doors/threshold {x:0,z:2,width:0,depth:4}
$execute positioned $(x) 81 $(z) positioned ~ ~ ~$(radius) if block ~ ~-1 ~ minecraft:smooth_quartz run function sweetdream_floor:room/doors/threshold {x:2,z:0,width:4,depth:0}
$execute positioned $(x) 81 $(z) positioned ~ ~ ~-$(radius) if block ~ ~-1 ~ minecraft:smooth_quartz run function sweetdream_floor:room/doors/threshold {x:2,z:0,width:4,depth:0}
