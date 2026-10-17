execute unless block ~0 ~-0.04 ~0 #sweetdream:boss_passable run return run function sweetdream:boss/fireaxe/ground/land
execute unless block ~-0.64 ~-0.04 ~-0.64 #sweetdream:boss_passable run return run function sweetdream:boss/fireaxe/ground/land
execute unless block ~-0.64 ~-0.04 ~0.64 #sweetdream:boss_passable run return run function sweetdream:boss/fireaxe/ground/land
execute unless block ~0.64 ~-0.04 ~-0.64 #sweetdream:boss_passable run return run function sweetdream:boss/fireaxe/ground/land
execute unless block ~0.64 ~-0.04 ~0.64 #sweetdream:boss_passable run return run function sweetdream:boss/fireaxe/ground/land
execute positioned ~ ~-0.04 ~ run tp @s ~ ~ ~
scoreboard players remove @s sdbf.fallsteps 1
execute if score @s sdbf.fallsteps matches 1.. at @s run function sweetdream:boss/fireaxe/ground/drop
