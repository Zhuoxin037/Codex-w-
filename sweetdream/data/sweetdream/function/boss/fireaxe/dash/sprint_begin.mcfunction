scoreboard players set @s sdbf.sprint 1
execute as @e[tag=sd.fb.current_rig,limit=1,distance=0..] run function sweetdream_boss:reconstruction/animations/sprint_loop/tween {duration:3,to_frame:0}
