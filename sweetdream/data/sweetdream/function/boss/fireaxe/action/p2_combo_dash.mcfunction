execute store result score @s sdbf.frame run scoreboard players get @e[tag=sd.fb.current_rig,limit=1,distance=0..] sweetdream_boss.reconstruction.p2_combo_dash_chop.frame
execute if score @s sdbf.frame matches ..3 if entity @e[tag=sd.fb.target,distance=0..] run function sweetdream:boss/fireaxe/face
execute if score @s sdbf.frame matches 8 at @s run function sweetdream:boss/fireaxe/phase/hit_dash
execute if score @s sdbf.frame matches 16..33 unless entity @e[tag=sd.fb.target,distance=..10] run return run function sweetdream:boss/fireaxe/abort_dash
execute if score @s sdbf.frame matches 16..36 if entity @e[tag=sd.fb.target,distance=0..] run function sweetdream:boss/fireaxe/face
execute if score @s sdbf.frame matches 18..33 unless score @s sdbf.fall matches 1.. at @s unless entity @e[tag=sd.fb.target,distance=..2.6] run function sweetdream:boss/fireaxe/rush_step {step:0.28125}
execute if score @s sdbf.frame matches 42 at @s run function sweetdream:boss/fireaxe/phase/hit_chop
execute if score @s sdbf.state matches 12 unless entity @e[tag=sd.fb.current_rig,limit=1,distance=0..,tag=sweetdream_boss.reconstruction.animation.p2_combo_dash_chop.playing] run function sweetdream:boss/fireaxe/finish
