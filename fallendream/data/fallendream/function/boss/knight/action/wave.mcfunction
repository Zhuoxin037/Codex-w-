scoreboard players add @s sdk.age 1
execute unless entity @e[tag=sd.kn.target,distance=0..,limit=1] run return run function fallendream:boss/knight/finish
function fallendream:boss/knight/driver/step
execute if score @s sdk.frame matches 29.. run scoreboard players set @s sdk.frame 28
data modify storage fallendream:knight attack set value {clip:"wave_slash"}
execute store result storage fallendream:knight attack.frame int 1 run scoreboard players get @s sdk.frame
execute as @e[tag=sd.kn.current_rig,distance=0..,limit=1] run function fallendream:boss/knight/driver/apply with storage fallendream:knight attack
execute if score @s sdk.frame matches 0..7 run function fallendream:boss/knight/face
execute if score @s sdk.frame matches 15 unless score @s sdk.hit0 matches 1 at @s rotated ~ 0 run function fallendream:boss/knight/wave/spawn
execute if score @s sdk.frame matches 16 unless score @s sdk.hit0 matches 1 at @s rotated ~ 0 run function fallendream:boss/knight/wave/spawn_next
execute if score @s sdk.frame matches 28.. run return run function fallendream:boss/knight/start/wait
