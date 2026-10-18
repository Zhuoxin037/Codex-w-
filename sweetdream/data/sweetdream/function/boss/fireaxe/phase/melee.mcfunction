scoreboard players set @s sdbf.jclear 1
execute unless block ~-0.665 ~4.5 ~-0.665 #sweetdream:boss_passable run scoreboard players set @s sdbf.jclear 0
execute unless block ~-0.665 ~6.5 ~-0.665 #sweetdream:boss_passable run scoreboard players set @s sdbf.jclear 0
execute unless block ~-0.665 ~4.5 ~0.665 #sweetdream:boss_passable run scoreboard players set @s sdbf.jclear 0
execute unless block ~-0.665 ~6.5 ~0.665 #sweetdream:boss_passable run scoreboard players set @s sdbf.jclear 0
execute unless block ~0.665 ~4.5 ~-0.665 #sweetdream:boss_passable run scoreboard players set @s sdbf.jclear 0
execute unless block ~0.665 ~6.5 ~-0.665 #sweetdream:boss_passable run scoreboard players set @s sdbf.jclear 0
execute unless block ~0.665 ~4.5 ~0.665 #sweetdream:boss_passable run scoreboard players set @s sdbf.jclear 0
execute unless block ~0.665 ~6.5 ~0.665 #sweetdream:boss_passable run scoreboard players set @s sdbf.jclear 0
execute if score @s sdbf.last_combo matches 1 if score @s sdbf.dashcd matches 0 run return run function sweetdream:boss/fireaxe/start/combo_dash
execute if score @s sdbf.jumpcd matches 0 if score @s sdbf.jclear matches 1 run return run function sweetdream:boss/fireaxe/start/combo_jump
execute if score @s sdbf.dashcd matches 0 run return run function sweetdream:boss/fireaxe/start/combo_dash
execute store result score @s sdbf.choice run random value 0..1
execute if score @s sdbf.choice matches 0 run return run function sweetdream:boss/fireaxe/start/chop
function sweetdream:boss/fireaxe/start/sweep
