scoreboard players set @s sdbf.dphase 1
execute as @e[tag=sd.fb.current_rig,limit=1,distance=0..] run function sweetdream_boss:reconstruction/animations/dash_loop/tween {duration:2,to_frame:0}
