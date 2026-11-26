execute unless block ~ ~-0.05 ~ #fallendream:b_staff_clear run return run function fallendream:boss/b_staff/fx/ground_ready
execute if score @s bs.ray matches 32.. run return run kill @s
tp @s ~ ~-0.25 ~
scoreboard players add @s bs.ray 1
execute at @s run function fallendream:boss/b_staff/fx/ground_step
