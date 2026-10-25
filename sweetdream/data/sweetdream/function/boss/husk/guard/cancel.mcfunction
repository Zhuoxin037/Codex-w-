scoreboard players set @s sdh.state 24
scoreboard players set @s sdh.age 0
scoreboard players set @s sdh.rest 0
execute as @e[tag=sd.hk.current_rig,distance=0..,limit=1] run function sweetdream_boss:husk/animations/guard_cancel/play_exclusive
