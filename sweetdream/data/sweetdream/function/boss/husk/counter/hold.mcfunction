scoreboard players set @s sdh.state 31
scoreboard players set @s sdh.age 0
function sweetdream:boss/husk/ward/guard
execute as @e[tag=sd.hk.current_rig,distance=0..,limit=1] run function sweetdream_boss:husk/animations/counter_hold/play_exclusive
