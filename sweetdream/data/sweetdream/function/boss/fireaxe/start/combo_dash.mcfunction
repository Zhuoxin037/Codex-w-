scoreboard players set @s sdbf.state 12
scoreboard players set @s sdbf.age 0
scoreboard players set @s sdbf.blocked 0
scoreboard players set @s sdbf.cmask 0
execute as @e[tag=sd.fb.current_rig,limit=1,distance=0..] run function sweetdream_boss:reconstruction/animations/combo_dash_chop/tween {duration:4,to_frame:0}
