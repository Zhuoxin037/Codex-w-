scoreboard players add @s sdk.age 1
execute unless entity @e[tag=sd.kn.target,distance=0..,limit=1] run return run function fallendream:boss/knight/finish
# Six ticks holding the visible pose, then six saved windup frames: hit at 12.
execute if score @s sdk.age matches ..6 run scoreboard players set @s sdk.frame 0
execute if score @s sdk.age matches 7..12 run scoreboard players operation @s sdk.frame = @s sdk.age
execute if score @s sdk.age matches 7..12 run scoreboard players remove @s sdk.frame 6
execute if score @s sdk.age matches 13.. run function fallendream:boss/knight/driver/step
execute if score @s sdk.frame matches 23.. run scoreboard players set @s sdk.frame 22
data modify storage fallendream:knight attack set value {clip:"strike"}
execute store result storage fallendream:knight attack.frame int 1 run scoreboard players get @s sdk.age
execute if score @s sdk.age matches ..6 run data modify storage fallendream:knight attack.frame set value 0
execute as @e[tag=sd.kn.current_rig,distance=0..,limit=1] run function fallendream:boss/knight/blink/apply with storage fallendream:knight attack
# Fixed landing position and facing: no approach, close_step or tracking strike.
execute if score @s sdk.frame matches 6 unless score @s sdk.hit0 matches 1 at @s rotated ~ 0 run function fallendream:boss/knight/hit/thrust_0
execute if score @s sdk.frame matches 7 unless score @s sdk.hit0 matches 1 at @s rotated ~ 0 run function fallendream:boss/knight/hit/thrust_0_next
execute if score @s sdk.frame matches 14 unless score @s sdk.hit1 matches 1 at @s rotated ~ 0 run function fallendream:boss/knight/hit/thrust_1
execute if score @s sdk.frame matches 15 unless score @s sdk.hit1 matches 1 at @s rotated ~ 0 run function fallendream:boss/knight/hit/thrust_1_next
execute if score @s sdk.frame matches 22.. run function fallendream:boss/knight/finish
