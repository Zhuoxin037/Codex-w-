function fallendream:boss/b_staff/hit/context
execute unless block ~ ~ ~ #fallendream:b_staff_clear run return run function fallendream:boss/b_staff/fx/end
scoreboard players set #touched bs.ok 0
execute positioned ~-0.28 ~-0.28 ~-0.28 as @a[gamemode=!creative,gamemode=!spectator,dx=0.56,dy=0.56,dz=0.56,sort=nearest] run function fallendream:boss/b_staff/hit/bolt_candidate
execute positioned ~-0.28 ~-0.28 ~-0.28 as @e[type=!#fallendream:no_damage,dx=0.56,dy=0.56,dz=0.56,sort=nearest] run function fallendream:boss/b_staff/hit/bolt_candidate
execute if score #touched bs.ok matches 1 run function fallendream:boss/b_staff/fx/end
