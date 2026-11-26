execute unless block ~0 ~-0.04 ~0 #fallendream:boss_passable run return run function fallendream:boss/knight/ground/land
execute unless block ~-0.6 ~-0.04 ~-0.6 #fallendream:boss_passable run return run function fallendream:boss/knight/ground/land
execute unless block ~-0.6 ~-0.04 ~0.6 #fallendream:boss_passable run return run function fallendream:boss/knight/ground/land
execute unless block ~0.6 ~-0.04 ~-0.6 #fallendream:boss_passable run return run function fallendream:boss/knight/ground/land
execute unless block ~0.6 ~-0.04 ~0.6 #fallendream:boss_passable run return run function fallendream:boss/knight/ground/land
execute positioned ~ ~-0.04 ~ run tp @s ~ ~ ~
scoreboard players remove @s sdk.fallsteps 1
execute if score @s sdk.fallsteps matches 1.. at @s run function fallendream:boss/knight/ground/drop
