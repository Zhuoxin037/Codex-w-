scoreboard players set @s sdbf.state 12
scoreboard players set @s sdbf.age 0
scoreboard players set @s sdbf.blocked 0
scoreboard players set @s sdbf.cmask 0
scoreboard players set @s sdbf.last_combo 2
execute unless score @s sdbf.dashcd matches 1.. run scoreboard players set @s sdbf.dashcd 180
execute unless score @s sdbf.phase matches 3 as @e[tag=sd.fb.current_rig,limit=1,distance=0..] run function sweetdream_boss:reconstruction/animations/combo_dash_chop/tween {duration:4,to_frame:0}
execute if score @s sdbf.phase matches 3 as @e[tag=sd.fb.current_rig,limit=1,distance=0..] run function sweetdream_boss:reconstruction/animations/p2_combo_dash_chop/tween {duration:4,to_frame:0}
