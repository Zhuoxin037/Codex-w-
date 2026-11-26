execute unless block ~ ~-0.2 ~ #fallendream:boss_passable run return 0
execute positioned ~ ~-0.25 ~ run tp @s ~ ~ ~
scoreboard players remove @s sdh.jumpsteps 1
execute if score @s sdh.jumpsteps matches 1.. at @s run function fallendream:boss/husk/leap/project_ground
