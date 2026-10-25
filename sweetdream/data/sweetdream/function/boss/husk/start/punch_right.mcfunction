scoreboard players set @s sdh.state 10
scoreboard players set @s sdh.age 0
scoreboard players set @s sdh.hit0 0
scoreboard players set @s sdh.hit1 0
execute as @e[tag=sd.hk.current_rig,distance=0..,limit=1] run function sweetdream_boss:husk/animations/punch_right/play_exclusive
