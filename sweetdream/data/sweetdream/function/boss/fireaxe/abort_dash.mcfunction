scoreboard players set @s sdbf.state 7
scoreboard players set @s sdbf.age 0
execute as @e[tag=sd.fb.current_rig,limit=1,distance=0..] run function sweetdream_boss:reconstruction/animations/dash_stop/play_exclusive
