scoreboard players operation #mod bs.ray = @s bs.fage
scoreboard players operation #mod bs.ray %= #four bs.cfg
execute if score @s bs.fage matches ..7 if score #mod bs.ray matches 0 run function fallendream:boss/b_staff/fx/repel_particles
execute if score @s bs.fage matches 8 run function fallendream:boss/b_staff/fx/repel_hit
execute if score @s bs.fage matches 9 run data merge entity @s {start_interpolation:0,transformation:{scale:[0.7f,1f,0.7f]}}
execute if score @s bs.fage matches 10 run data merge entity @s {start_interpolation:0,transformation:{scale:[1.1f,1f,1.1f]}}
execute if score @s bs.fage matches 11 run data merge entity @s {start_interpolation:0,transformation:{scale:[1.6f,1f,1.6f]}}
execute if score @s bs.fage matches 12 run data merge entity @s {start_interpolation:0,transformation:{scale:[2.1f,1f,2.1f]}}
execute if score @s bs.fage matches 13 run data merge entity @s {start_interpolation:0,transformation:{scale:[2.5f,1f,2.5f]}}
execute if score @s bs.fage matches 14.. run function fallendream:boss/b_staff/fx/end
