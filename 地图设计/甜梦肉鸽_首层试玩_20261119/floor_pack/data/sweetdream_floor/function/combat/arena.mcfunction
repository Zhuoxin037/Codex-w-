$setblock $(px) 81 $(pz) minecraft:air
$execute positioned $(x).5 81 $(z).5 if data storage sweetdream_floor:run current{kind:"boss"} run return run function sweetdream_floor:combat/boss
$execute positioned $(x).5 81 $(z).5 run function sweetdream_floor:combat/spawn
