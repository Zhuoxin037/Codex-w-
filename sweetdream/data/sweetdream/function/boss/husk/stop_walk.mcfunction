scoreboard players set @s sdh.state 3
scoreboard players set @s sdh.age 0
execute as @e[tag=sd.hk.current_rig,distance=0..,limit=1] run function sweetdream_boss:husk/animations/walk_stop/play_exclusive
