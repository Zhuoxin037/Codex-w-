function fallendream:boss/b_staff/hit/valid
execute if score #valid bs.ok matches 0 run return 0
execute store result score #vx bs.dx run data get entity @s Pos[0] 100
execute store result score #vz bs.dz run data get entity @s Pos[2] 100
scoreboard players operation #vx bs.dx -= #area_x bs.x
scoreboard players operation #vz bs.dz -= #area_z bs.z
scoreboard players operation #vx bs.dx *= #vx bs.dx
scoreboard players operation #vz bs.dz *= #vz bs.dz
scoreboard players operation #vx bs.dx += #vz bs.dz
execute if score #vx bs.dx > #radius bs.r2 run return 0
tag @e[tag=sd.bs.candidate,distance=0..] remove sd.bs.candidate
tag @s add sd.bs.candidate
scoreboard players set #sight bs.ok 0
scoreboard players set #ray bs.ray 0
execute positioned ~2.5 ~0.3 ~2.5 facing entity @s eyes run function fallendream:boss/b_staff/area/ray
execute if score #sight bs.ok matches 1 run function fallendream:boss/b_staff/hit/apply
tag @s remove sd.bs.candidate
