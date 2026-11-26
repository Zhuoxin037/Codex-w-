execute store result score @s sdbf.frame run scoreboard players get @e[tag=sd.fb.current_rig,limit=1,distance=0..] fallendream_boss.reconstruction.p2_attack.frame
execute if score @s sdbf.frame matches ..14 if entity @e[tag=sd.fb.target,distance=0..] run function fallendream:boss/fireaxe/face
execute if score @s sdbf.state matches 2 if score @s sdbf.frame matches 20 at @s run function fallendream:boss/fireaxe/hit/chop
execute if score @s sdbf.state matches 2 unless entity @e[tag=sd.fb.current_rig,limit=1,distance=0..,tag=fallendream_boss.reconstruction.animation.p2_attack.playing] run function fallendream:boss/fireaxe/finish
