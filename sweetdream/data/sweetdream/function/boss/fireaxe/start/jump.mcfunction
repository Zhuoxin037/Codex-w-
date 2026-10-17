execute unless block ~-0.665 ~4.5 ~-0.665 #sweetdream:boss_passable run return run function sweetdream:boss/fireaxe/walk
execute unless block ~-0.665 ~6.5 ~-0.665 #sweetdream:boss_passable run return run function sweetdream:boss/fireaxe/walk
execute unless block ~-0.665 ~4.5 ~0.665 #sweetdream:boss_passable run return run function sweetdream:boss/fireaxe/walk
execute unless block ~-0.665 ~6.5 ~0.665 #sweetdream:boss_passable run return run function sweetdream:boss/fireaxe/walk
execute unless block ~0.665 ~4.5 ~-0.665 #sweetdream:boss_passable run return run function sweetdream:boss/fireaxe/walk
execute unless block ~0.665 ~6.5 ~-0.665 #sweetdream:boss_passable run return run function sweetdream:boss/fireaxe/walk
execute unless block ~0.665 ~4.5 ~0.665 #sweetdream:boss_passable run return run function sweetdream:boss/fireaxe/walk
execute unless block ~0.665 ~6.5 ~0.665 #sweetdream:boss_passable run return run function sweetdream:boss/fireaxe/walk
scoreboard players set @s sdbf.state 4
scoreboard players set @s sdbf.age 0
scoreboard players set @s sdbf.blocked 0
scoreboard players set @s sdbf.jumpcd 260
execute as @e[tag=sd.fb.current_rig,limit=1,distance=0..] run function sweetdream_boss:reconstruction/animations/attack_jump/play_exclusive
playsound minecraft:entity.ravager.ambient hostile @a[distance=..24] ~ ~ ~ 0.55 0.75
