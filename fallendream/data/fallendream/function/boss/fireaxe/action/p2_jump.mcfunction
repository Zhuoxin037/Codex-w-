execute store result score @s sdbf.frame run scoreboard players get @e[tag=sd.fb.current_rig,limit=1,distance=0..] fallendream_boss.reconstruction.p2_attack_jump.frame
execute if score @s sdbf.frame matches ..8 if entity @e[tag=sd.fb.target,distance=0..] run function fallendream:boss/fireaxe/face
execute at @s run function fallendream:boss/fireaxe/motion/p2_jump
execute if score @s sdbf.state matches 4 if score @s sdbf.frame matches 26 at @s run function fallendream:boss/fireaxe/hit/jump
execute if score @s sdbf.state matches 4 unless entity @e[tag=sd.fb.current_rig,limit=1,distance=0..,tag=fallendream_boss.reconstruction.animation.p2_attack_jump.playing] run function fallendream:boss/fireaxe/finish
