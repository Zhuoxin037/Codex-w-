execute if score @s sdbf.phase matches 3 run return run function fallendream:boss/fireaxe/action/p2_combo_jump
execute store result score @s sdbf.frame run scoreboard players get @e[tag=sd.fb.current_rig,limit=1,distance=0..] fallendream_boss.reconstruction.combo_sweep_jump.frame
execute if score @s sdbf.frame matches ..9 if entity @e[tag=sd.fb.target,distance=0..] run function fallendream:boss/fireaxe/face
execute if score @s sdbf.frame matches 16 at @s run function fallendream:boss/fireaxe/phase/hit_sweep
execute if score @s sdbf.frame matches 28 unless entity @e[tag=sd.fb.target,distance=..12] run return run function fallendream:boss/fireaxe/abort_dash
execute if score @s sdbf.frame matches 28..30 if entity @e[tag=sd.fb.target,distance=0..] run function fallendream:boss/fireaxe/face
execute at @s run function fallendream:boss/fireaxe/motion/combo_jump
execute if score @s sdbf.frame matches 50 at @s run function fallendream:boss/fireaxe/phase/hit_jump
execute unless entity @e[tag=sd.fb.current_rig,limit=1,distance=0..,tag=fallendream_boss.reconstruction.animation.combo_sweep_jump.playing] run function fallendream:boss/fireaxe/finish
