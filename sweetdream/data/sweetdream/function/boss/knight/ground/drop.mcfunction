execute unless block ~0 ~-0.04 ~0 #sweetdream:boss_passable run return run function sweetdream:boss/knight/ground/land
execute unless block ~-0.6 ~-0.04 ~-0.6 #sweetdream:boss_passable run return run function sweetdream:boss/knight/ground/land
execute unless block ~-0.6 ~-0.04 ~0.6 #sweetdream:boss_passable run return run function sweetdream:boss/knight/ground/land
execute unless block ~0.6 ~-0.04 ~-0.6 #sweetdream:boss_passable run return run function sweetdream:boss/knight/ground/land
execute unless block ~0.6 ~-0.04 ~0.6 #sweetdream:boss_passable run return run function sweetdream:boss/knight/ground/land
execute positioned ~ ~-0.04 ~ run tp @s ~ ~ ~
scoreboard players remove @s sdk.fallsteps 1
execute if score @s sdk.fallsteps matches 1.. at @s run function sweetdream:boss/knight/ground/drop
