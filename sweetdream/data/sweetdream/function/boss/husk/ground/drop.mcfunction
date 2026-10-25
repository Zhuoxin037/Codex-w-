execute unless block ~0 ~-0.04 ~0 #sweetdream:boss_passable run return run function sweetdream:boss/husk/ground/land
execute unless block ~-0.6 ~-0.04 ~-0.6 #sweetdream:boss_passable run return run function sweetdream:boss/husk/ground/land
execute unless block ~-0.6 ~-0.04 ~0.6 #sweetdream:boss_passable run return run function sweetdream:boss/husk/ground/land
execute unless block ~0.6 ~-0.04 ~-0.6 #sweetdream:boss_passable run return run function sweetdream:boss/husk/ground/land
execute unless block ~0.6 ~-0.04 ~0.6 #sweetdream:boss_passable run return run function sweetdream:boss/husk/ground/land
execute positioned ~ ~-0.04 ~ run tp @s ~ ~ ~
scoreboard players remove @s sdh.fallsteps 1
execute if score @s sdh.fallsteps matches 1.. at @s run function sweetdream:boss/husk/ground/drop
