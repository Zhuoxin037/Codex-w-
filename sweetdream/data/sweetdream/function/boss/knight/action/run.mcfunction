scoreboard players set @s sdk.frame 0
execute store result score @s sdk.frame run scoreboard players get @e[tag=sd.kn.current_rig,distance=0..,limit=1] sdk.pose
scoreboard players add @s sdk.age 1
function sweetdream:boss/knight/approach
