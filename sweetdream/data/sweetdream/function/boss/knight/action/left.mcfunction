scoreboard players set @s sdk.frame 0
execute store result score @s sdk.frame run scoreboard players get @e[tag=sd.kn.current_rig,distance=0..,limit=1] sdk.pose
scoreboard players add @s sdk.age 1
execute unless entity @e[tag=sd.kn.target,distance=0..,limit=1] run return run function sweetdream:boss/knight/finish
execute if score @s sdk.frame matches 0..7 run function sweetdream:boss/knight/face
execute if score @s sdk.frame matches 1..5 at @s rotated ~70 0 run function sweetdream:boss/knight/move {step:0.17}
execute if score @s sdk.frame matches 1..5 if score @s sdk.moved matches 1 at @s rotated ~70 0 run function sweetdream:boss/knight/move {step:0.17}
execute if score @s sdk.frame matches 11 unless score @s sdk.hit0 matches 1 at @s rotated ~ 0 run function sweetdream:boss/knight/hit/left_0
execute if score @s sdk.frame matches 12 unless score @s sdk.hit0 matches 1 at @s rotated ~ 0 run function sweetdream:boss/knight/hit/left_0_next
execute if score @s sdk.frame matches 24.. run function sweetdream:boss/knight/finish
