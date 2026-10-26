function sweetdream:boss/husk/ward/normal
scoreboard players set @s sdh.state 40
scoreboard players set @s sdh.age 0
scoreboard players set @s sdh.flash 0
scoreboard players set @s sdh.speed 0
scoreboard players set @s sdh.leapmode 0
execute as @e[tag=sd.hk.current_rig,distance=0..,limit=1] run function sweetdream_boss:husk/animations/leap_takeoff_guard/play_exclusive
