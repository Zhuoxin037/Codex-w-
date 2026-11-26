execute if score @s sdbf.phase matches 3 run return run function fallendream:boss/fireaxe/action/p2_combo_dash
execute store result score @s sdbf.frame run scoreboard players get @e[tag=sd.fb.current_rig,limit=1,distance=0..] fallendream_boss.reconstruction.combo_dash_chop.frame
execute if score @s sdbf.frame matches ..3 if entity @e[tag=sd.fb.target,distance=0..] run function fallendream:boss/fireaxe/face
execute if score @s sdbf.frame matches 9 at @s run function fallendream:boss/fireaxe/phase/hit_dash
execute if score @s sdbf.frame matches 18..37 unless entity @e[tag=sd.fb.target,distance=..10] run return run function fallendream:boss/fireaxe/abort_dash
execute if score @s sdbf.frame matches 18..40 if entity @e[tag=sd.fb.target,distance=0..] run function fallendream:boss/fireaxe/face
execute if score @s sdbf.frame matches 20..37 unless score @s sdbf.fall matches 1.. at @s unless entity @e[tag=sd.fb.target,distance=..2.6] run function fallendream:boss/fireaxe/rush_step {step:0.25}
execute if score @s sdbf.frame matches 47 at @s run function fallendream:boss/fireaxe/phase/hit_chop
execute if score @s sdbf.state matches 12 unless entity @e[tag=sd.fb.current_rig,limit=1,distance=0..,tag=fallendream_boss.reconstruction.animation.combo_dash_chop.playing] run function fallendream:boss/fireaxe/finish
