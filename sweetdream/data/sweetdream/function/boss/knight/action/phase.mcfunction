scoreboard players set @s sdk.frame 0
execute store result score @s sdk.frame run scoreboard players get @e[tag=sd.kn.current_rig,distance=0..,limit=1] sdk.pose
scoreboard players add @s sdk.age 1
execute if score @s sdk.frame matches 20 run particle minecraft:enchant ~ ~1.6 ~ 0.4 0.6 0.4 0 20 normal
execute if score @s sdk.frame matches 60.. run return run function sweetdream:boss/knight/phase_end
