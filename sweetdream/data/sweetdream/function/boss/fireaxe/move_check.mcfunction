execute unless block ~-0.665 ~0.05 ~-0.665 #sweetdream:boss_passable run return 0
execute unless block ~-0.665 ~1 ~-0.665 #sweetdream:boss_passable run return 0
execute unless block ~-0.665 ~2 ~-0.665 #sweetdream:boss_passable run return 0
execute unless block ~-0.665 ~3 ~-0.665 #sweetdream:boss_passable run return 0
execute unless block ~-0.665 ~4.35 ~-0.665 #sweetdream:boss_passable run return 0
execute unless block ~-0.665 ~0.05 ~0.665 #sweetdream:boss_passable run return 0
execute unless block ~-0.665 ~1 ~0.665 #sweetdream:boss_passable run return 0
execute unless block ~-0.665 ~2 ~0.665 #sweetdream:boss_passable run return 0
execute unless block ~-0.665 ~3 ~0.665 #sweetdream:boss_passable run return 0
execute unless block ~-0.665 ~4.35 ~0.665 #sweetdream:boss_passable run return 0
execute unless block ~0.665 ~0.05 ~-0.665 #sweetdream:boss_passable run return 0
execute unless block ~0.665 ~1 ~-0.665 #sweetdream:boss_passable run return 0
execute unless block ~0.665 ~2 ~-0.665 #sweetdream:boss_passable run return 0
execute unless block ~0.665 ~3 ~-0.665 #sweetdream:boss_passable run return 0
execute unless block ~0.665 ~4.35 ~-0.665 #sweetdream:boss_passable run return 0
execute unless block ~0.665 ~0.05 ~0.665 #sweetdream:boss_passable run return 0
execute unless block ~0.665 ~1 ~0.665 #sweetdream:boss_passable run return 0
execute unless block ~0.665 ~2 ~0.665 #sweetdream:boss_passable run return 0
execute unless block ~0.665 ~3 ~0.665 #sweetdream:boss_passable run return 0
execute unless block ~0.665 ~4.35 ~0.665 #sweetdream:boss_passable run return 0
$execute if score #ground_$(ground) sdbf.step matches 1 if block ~ ~-0.1 ~ #sweetdream:boss_passable if block ~ ~-1.1 ~ #sweetdream:boss_passable run return 0
scoreboard players set @s sdbf.moved 1
tp @s ~ ~ ~
