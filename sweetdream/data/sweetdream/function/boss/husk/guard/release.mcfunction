function sweetdream:boss/husk/ward/normal
scoreboard players set @s sdh.age 0
scoreboard players set @s sdh.flash 0
execute if score @s sdh.energy matches 0 run return run function sweetdream:boss/husk/guard/cancel
scoreboard players set @s sdh.state 22
scoreboard players set @s sdh.hit0 0
execute as @e[tag=sd.hk.current_rig,distance=0..,limit=1] run function sweetdream_boss:husk/animations/guard_release/play_exclusive
