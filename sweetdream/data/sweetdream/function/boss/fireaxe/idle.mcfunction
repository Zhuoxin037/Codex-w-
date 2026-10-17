execute unless score @s sdbf.state matches 0 as @e[tag=sd.fb.current_rig,limit=1,distance=0..] run function sweetdream_boss:reconstruction/animations/idle/play_exclusive
scoreboard players set @s sdbf.state 0
