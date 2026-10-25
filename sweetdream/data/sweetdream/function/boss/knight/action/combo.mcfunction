scoreboard players set @s sdk.frame 0
execute store result score @s sdk.frame run scoreboard players get @e[tag=sd.kn.current_rig,distance=0..,limit=1] sdk.pose
scoreboard players add @s sdk.age 1
execute unless entity @e[tag=sd.kn.target,distance=0..,limit=1] run return run function sweetdream:boss/knight/finish
execute if score @s sdk.frame matches 0..3 run function sweetdream:boss/knight/face
execute if score @s sdk.frame matches 9..12 run function sweetdream:boss/knight/face
execute if score @s sdk.frame matches 19..22 run function sweetdream:boss/knight/face
execute if score @s sdk.frame matches 0..5 run function sweetdream:boss/knight/close_step
execute if score @s sdk.frame matches 9..14 run function sweetdream:boss/knight/close_step
execute if score @s sdk.frame matches 19..24 run function sweetdream:boss/knight/close_step
execute if score @s sdk.frame matches 6 unless score @s sdk.hit0 matches 1 at @s rotated ~ 0 run function sweetdream:boss/knight/hit/combo_0
execute if score @s sdk.frame matches 7 unless score @s sdk.hit0 matches 1 at @s rotated ~ 0 run function sweetdream:boss/knight/hit/combo_0_next
execute if score @s sdk.frame matches 15 unless score @s sdk.hit1 matches 1 at @s rotated ~ 0 run function sweetdream:boss/knight/hit/combo_1
execute if score @s sdk.frame matches 16 unless score @s sdk.hit1 matches 1 at @s rotated ~ 0 run function sweetdream:boss/knight/hit/combo_1_next
execute if score @s sdk.frame matches 25 unless score @s sdk.hit2 matches 1 at @s rotated ~ 0 run function sweetdream:boss/knight/hit/combo_2
execute if score @s sdk.frame matches 26 unless score @s sdk.hit2 matches 1 at @s rotated ~ 0 run function sweetdream:boss/knight/hit/combo_2_next
execute if score @s sdk.frame matches 38.. run function sweetdream:boss/knight/finish
