execute if score @s sdbf.phase matches 3 run return run function fallendream:boss/fireaxe/action/p2_chop
execute store result score @s sdbf.frame run scoreboard players get @e[tag=sd.fb.current_rig,limit=1,distance=0..] fallendream_boss.reconstruction.attack.frame
execute if score @s sdbf.frame matches ..15 if entity @e[tag=sd.fb.target,distance=0..] run function fallendream:boss/fireaxe/face
execute if score @s sdbf.state matches 2 if score @s sdbf.frame matches 22 at @s run function fallendream:boss/fireaxe/hit/chop
execute if score @s sdbf.state matches 2 unless entity @e[tag=sd.fb.current_rig,limit=1,distance=0..,tag=fallendream_boss.reconstruction.animation.attack.playing] run function fallendream:boss/fireaxe/finish
