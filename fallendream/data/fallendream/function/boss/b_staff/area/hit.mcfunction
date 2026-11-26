function fallendream:boss/b_staff/hit/context
execute store result score #area_x bs.x run data get entity @s Pos[0] 100
execute store result score #area_z bs.z run data get entity @s Pos[2] 100
execute positioned ~-2.5 ~-0.1 ~-2.5 as @a[gamemode=!creative,gamemode=!spectator,dx=5,dy=2,dz=5] run function fallendream:boss/b_staff/area/candidate
execute positioned ~-2.5 ~-0.1 ~-2.5 as @e[type=!#fallendream:no_damage,dx=5,dy=2,dz=5] run function fallendream:boss/b_staff/area/candidate
