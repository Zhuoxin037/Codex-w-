execute store result storage fallendream:husk args.id int 1 run scoreboard players get @s sdh.id
function fallendream:boss/husk/leap/resolve with storage fallendream:husk args
execute unless entity @e[tag=sd.hk.jump_start_now,distance=0..,limit=1] run return run function fallendream:boss/husk/leap/fall
execute if score @s sdh.age matches ..10 as @e[tag=sd.hk.jump_end_now,distance=0..,limit=1] at @s run function fallendream:boss/husk/leap/track
function fallendream:boss/husk/leap/trajectory
tag @e[tag=sd.hk.jump_start_now,distance=0..] remove sd.hk.jump_start_now
tag @e[tag=sd.hk.jump_end_now,distance=0..] remove sd.hk.jump_end_now
execute if score @s sdh.age matches 16.. run function fallendream:boss/husk/leap/fall
