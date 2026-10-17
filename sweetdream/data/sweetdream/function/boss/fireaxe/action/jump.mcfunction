execute store result score @s sdbf.frame run scoreboard players get @e[tag=sd.fb.current_rig,limit=1,distance=0..] sweetdream_boss.reconstruction.attack_jump.frame
execute if score @s sdbf.frame matches ..9 if entity @e[tag=sd.fb.target,distance=0..] run function sweetdream:boss/fireaxe/face
execute at @s run function sweetdream:boss/fireaxe/motion/jump
execute if score @s sdbf.state matches 4 if score @s sdbf.frame matches 29 at @s run function sweetdream:boss/fireaxe/hit/jump
execute if score @s sdbf.state matches 4 unless entity @e[tag=sd.fb.current_rig,limit=1,distance=0..,tag=sweetdream_boss.reconstruction.animation.attack_jump.playing] run function sweetdream:boss/fireaxe/finish
