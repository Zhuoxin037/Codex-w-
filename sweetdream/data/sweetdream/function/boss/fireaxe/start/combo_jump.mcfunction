execute unless block ~-0.665 ~4.5 ~-0.665 #sweetdream:boss_passable run return run function sweetdream:boss/fireaxe/start/chop
execute unless block ~-0.665 ~6.5 ~-0.665 #sweetdream:boss_passable run return run function sweetdream:boss/fireaxe/start/chop
execute unless block ~-0.665 ~4.5 ~0.665 #sweetdream:boss_passable run return run function sweetdream:boss/fireaxe/start/chop
execute unless block ~-0.665 ~6.5 ~0.665 #sweetdream:boss_passable run return run function sweetdream:boss/fireaxe/start/chop
execute unless block ~0.665 ~4.5 ~-0.665 #sweetdream:boss_passable run return run function sweetdream:boss/fireaxe/start/chop
execute unless block ~0.665 ~6.5 ~-0.665 #sweetdream:boss_passable run return run function sweetdream:boss/fireaxe/start/chop
execute unless block ~0.665 ~4.5 ~0.665 #sweetdream:boss_passable run return run function sweetdream:boss/fireaxe/start/chop
execute unless block ~0.665 ~6.5 ~0.665 #sweetdream:boss_passable run return run function sweetdream:boss/fireaxe/start/chop
scoreboard players set @s sdbf.state 11
scoreboard players set @s sdbf.age 0
scoreboard players set @s sdbf.blocked 0
scoreboard players set @s sdbf.jumpcd 260
scoreboard players set @s sdbf.cmask 0
scoreboard players set @s sdbf.last_combo 1
execute unless score @s sdbf.phase matches 3 as @e[tag=sd.fb.current_rig,limit=1,distance=0..] run function sweetdream_boss:reconstruction/animations/combo_sweep_jump/play_exclusive
execute if score @s sdbf.phase matches 3 as @e[tag=sd.fb.current_rig,limit=1,distance=0..] run function sweetdream_boss:reconstruction/animations/p2_combo_sweep_jump/play_exclusive
