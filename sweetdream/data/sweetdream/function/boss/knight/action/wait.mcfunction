scoreboard players set @s sdk.frame 0
execute store result score @s sdk.frame run scoreboard players get @e[tag=sd.kn.current_rig,distance=0..,limit=1] sdk.pose
scoreboard players add @s sdk.age 1
execute store result storage sweetdream:knight args.id int 1 run scoreboard players get @s sdk.id
function sweetdream:boss/knight/wait_fx with storage sweetdream:knight args
