execute store result score @s sdbf.choice run random value 0..1
execute if score @s sdbf.choice matches 1 run return run function sweetdream:boss/fireaxe/start/combo_dash
scoreboard players set @s sdbf.dphase 2
scoreboard players set @s sdbf.frame -1
execute as @e[tag=sd.fb.current_rig,limit=1,distance=0..] run function sweetdream_boss:reconstruction/animations/attack_dash/tween {duration:4,to_frame:34}
