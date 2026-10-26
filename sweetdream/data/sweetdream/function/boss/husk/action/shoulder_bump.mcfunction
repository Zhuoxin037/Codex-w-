execute if score @s sdh.age matches ..6 run function sweetdream:boss/husk/face
execute if score @s sdh.age matches ..6 at @s if entity @e[tag=sd.hk.target,distance=1.25..3,limit=1] run function sweetdream:boss/husk/move {step:0.12}
execute if score @s sdh.age matches 8.. unless score @s sdh.hit0 matches 1 at @s run function sweetdream:boss/husk/hit/shoulder_bump_0
execute if score @s sdh.age matches 20.. run function sweetdream:boss/husk/melee_finish
