scoreboard players set @s sdk.frame 0
execute store result score @s sdk.frame run scoreboard players get @e[tag=sd.kn.current_rig,distance=0..,limit=1] sdk.pose
scoreboard players add @s sdk.age 1
execute unless entity @e[tag=sd.kn.target,distance=0..,limit=1] run return run function sweetdream:boss/knight/finish
function sweetdream:boss/knight/face
execute if score @s sdk.frame matches 22.. run function sweetdream:boss/knight/start/run
