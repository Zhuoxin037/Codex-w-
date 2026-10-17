scoreboard players set @s sdbf.dphase 0
scoreboard players set @s sdbf.age 0
scoreboard players set @s sdbf.blocked 0
execute as @e[tag=sd.fb.current_rig,limit=1,distance=0..] run function sweetdream_boss:reconstruction/animations/dash_start/tween {duration:3,to_frame:0}
