scoreboard players operation #mod bs.ray = @s bs.fage
scoreboard players operation #mod bs.ray %= #four bs.cfg
execute if score @s bs.fage matches ..19 if score #mod bs.ray matches 0 run function fallendream:boss/b_staff/fx/mark_particles
execute if score @s bs.fage matches 20 run function fallendream:boss/b_staff/fx/erupt
execute if score @s bs.fage matches 21 run data merge entity @s {transformation:{scale:[1f,0.5f,1f],translation:[0f,0.46875f,0f]}}
execute if score @s bs.fage matches 22 run data merge entity @s {transformation:{scale:[1f,1f,1f],translation:[0f,0.9375f,0f]}}
execute if score @s bs.fage matches 28.. run function fallendream:boss/b_staff/fx/end
