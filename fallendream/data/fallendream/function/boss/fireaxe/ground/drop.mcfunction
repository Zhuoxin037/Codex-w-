execute unless block ~0 ~-0.04 ~0 #fallendream:boss_passable run return run function fallendream:boss/fireaxe/ground/land
execute unless block ~-0.64 ~-0.04 ~-0.64 #fallendream:boss_passable run return run function fallendream:boss/fireaxe/ground/land
execute unless block ~-0.64 ~-0.04 ~0.64 #fallendream:boss_passable run return run function fallendream:boss/fireaxe/ground/land
execute unless block ~0.64 ~-0.04 ~-0.64 #fallendream:boss_passable run return run function fallendream:boss/fireaxe/ground/land
execute unless block ~0.64 ~-0.04 ~0.64 #fallendream:boss_passable run return run function fallendream:boss/fireaxe/ground/land
execute positioned ~ ~-0.04 ~ run tp @s ~ ~ ~
scoreboard players remove @s sdbf.fallsteps 1
execute if score @s sdbf.fallsteps matches 1.. at @s run function fallendream:boss/fireaxe/ground/drop
