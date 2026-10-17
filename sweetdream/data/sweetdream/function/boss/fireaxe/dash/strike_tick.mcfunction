execute store result score @s sdbf.frame run scoreboard players get @e[tag=sd.fb.current_rig,limit=1,distance=0..] sweetdream_boss.reconstruction.attack_dash.frame
execute if score @s sdbf.frame matches ..37 if entity @e[tag=sd.fb.target,distance=0..] run function sweetdream:boss/fireaxe/face
execute if score @s sdbf.state matches 5 if score @s sdbf.frame matches 43 at @s run function sweetdream:boss/fireaxe/hit/dash
execute if score @s sdbf.state matches 5 unless entity @e[tag=sd.fb.current_rig,limit=1,distance=0..,tag=sweetdream_boss.reconstruction.animation.attack_dash.playing] run function sweetdream:boss/fireaxe/finish
