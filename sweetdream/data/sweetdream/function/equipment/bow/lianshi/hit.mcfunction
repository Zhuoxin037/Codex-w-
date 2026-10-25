# @s remains the exact victim even if the initial arrow killed it.
tag @s add zx.ls_first
execute at @s as @e[type=!#sweetdream:no_damage,tag=!zx.ls_first,distance=..4,sort=nearest,limit=1] run function sweetdream:equipment/bow/lianshi/fire
tag @s remove zx.ls_first
