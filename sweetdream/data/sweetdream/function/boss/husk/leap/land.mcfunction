scoreboard players set @s sdh.state 43
scoreboard players set @s sdh.age 0
scoreboard players set @s sdh.hit0 0
execute if score @s sdh.leapmode matches 0 as @e[tag=sd.hk.current_rig,distance=0..,limit=1] run function sweetdream_boss:husk/animations/guard_release/play_exclusive
execute if score @s sdh.leapmode matches 1 as @e[tag=sd.hk.current_rig,distance=0..,limit=1] run function sweetdream_boss:husk/animations/counter_punch/play_exclusive
execute store result storage sweetdream:husk args.id int 1 run scoreboard players get @s sdh.id
function sweetdream:boss/husk/leap/clean with storage sweetdream:husk args
