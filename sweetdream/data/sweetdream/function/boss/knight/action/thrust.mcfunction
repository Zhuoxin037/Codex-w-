scoreboard players add @s sdk.age 1
execute unless entity @e[tag=sd.kn.target,distance=0..,limit=1] run return run function sweetdream:boss/knight/finish
function sweetdream:boss/knight/driver/step
execute if score @s sdk.frame matches 23.. run scoreboard players set @s sdk.frame 22
data modify storage sweetdream:knight attack set value {clip:"approach_thrust"}
execute store result storage sweetdream:knight attack.frame int 1 run scoreboard players get @s sdk.frame
execute as @e[tag=sd.kn.current_rig,distance=0..,limit=1] run function sweetdream:boss/knight/driver/apply with storage sweetdream:knight attack
execute if score @s sdk.frame matches 0..2 run function sweetdream:boss/knight/face
execute if score @s sdk.frame matches 8..10 run function sweetdream:boss/knight/face
execute if score @s sdk.frame matches 0..5 run function sweetdream:boss/knight/close_step
execute if score @s sdk.frame matches 8..13 run function sweetdream:boss/knight/close_step
execute if score @s sdk.frame matches 6 unless score @s sdk.hit0 matches 1 at @s rotated ~ 0 run function sweetdream:boss/knight/hit/thrust_0
execute if score @s sdk.frame matches 7 unless score @s sdk.hit0 matches 1 at @s rotated ~ 0 run function sweetdream:boss/knight/hit/thrust_0_next
execute if score @s sdk.frame matches 14 unless score @s sdk.hit1 matches 1 at @s rotated ~ 0 run function sweetdream:boss/knight/hit/thrust_1
execute if score @s sdk.frame matches 15 unless score @s sdk.hit1 matches 1 at @s rotated ~ 0 run function sweetdream:boss/knight/hit/thrust_1_next
execute if score @s sdk.frame matches 22.. run function sweetdream:boss/knight/finish
