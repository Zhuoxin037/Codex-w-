execute if score @s sdbf.phase matches 3 run return run function fallendream:boss/fireaxe/action/p2_jump
execute store result score @s sdbf.frame run scoreboard players get @e[tag=sd.fb.current_rig,limit=1,distance=0..] fallendream_boss.reconstruction.attack_jump.frame
execute if score @s sdbf.frame matches ..9 if entity @e[tag=sd.fb.target,distance=0..] run function fallendream:boss/fireaxe/face
execute at @s run function fallendream:boss/fireaxe/motion/jump
execute if score @s sdbf.state matches 4 if score @s sdbf.frame matches 29 at @s run function fallendream:boss/fireaxe/hit/jump
execute if score @s sdbf.state matches 4 unless entity @e[tag=sd.fb.current_rig,limit=1,distance=0..,tag=fallendream_boss.reconstruction.animation.attack_jump.playing] run function fallendream:boss/fireaxe/finish
