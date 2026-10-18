execute unless block ~0 ~-0.06 ~0 #sweetdream:boss_passable run return run function sweetdream:boss/fireaxe/fx/chunk_land
execute unless block ~-0.12 ~-0.06 ~-0.12 #sweetdream:boss_passable run return run function sweetdream:boss/fireaxe/fx/chunk_land
execute unless block ~-0.12 ~-0.06 ~0.12 #sweetdream:boss_passable run return run function sweetdream:boss/fireaxe/fx/chunk_land
execute unless block ~0.12 ~-0.06 ~-0.12 #sweetdream:boss_passable run return run function sweetdream:boss/fireaxe/fx/chunk_land
execute unless block ~0.12 ~-0.06 ~0.12 #sweetdream:boss_passable run return run function sweetdream:boss/fireaxe/fx/chunk_land
execute positioned ~ ~-0.04 ~ run tp @s ~ ~ ~
scoreboard players remove @s sdbf.fxsteps 1
execute if score @s sdbf.fxsteps matches 1.. at @s run function sweetdream:boss/fireaxe/fx/chunk_fall
