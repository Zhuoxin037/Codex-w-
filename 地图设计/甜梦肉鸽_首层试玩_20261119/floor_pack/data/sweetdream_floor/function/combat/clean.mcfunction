execute in minecraft:overworld if entity @e[tag=sd.kn.rig,distance=0..] run function sweetdream:boss/knight/remove_all
execute in minecraft:overworld run kill @e[tag=sd.floor_enemy,tag=!sd.kn.body,distance=0..]
