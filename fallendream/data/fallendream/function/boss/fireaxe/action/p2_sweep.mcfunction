execute store result score @s sdbf.frame run scoreboard players get @e[tag=sd.fb.current_rig,limit=1,distance=0..] fallendream_boss.reconstruction.p2_attack_sweep.frame
execute if score @s sdbf.frame matches ..8 if entity @e[tag=sd.fb.target,distance=0..] run function fallendream:boss/fireaxe/face
execute if score @s sdbf.state matches 3 if score @s sdbf.frame matches 14 at @s run function fallendream:boss/fireaxe/hit/sweep
execute if score @s sdbf.state matches 3 unless entity @e[tag=sd.fb.current_rig,limit=1,distance=0..,tag=fallendream_boss.reconstruction.animation.p2_attack_sweep.playing] run function fallendream:boss/fireaxe/finish
