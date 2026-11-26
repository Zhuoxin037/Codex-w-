scoreboard players add @s sdk.age 1
execute unless entity @e[tag=sd.kn.target,distance=0..,limit=1] run return run function fallendream:boss/knight/finish
function fallendream:boss/knight/face
scoreboard players operation @s sdk.frame = @s sdk.age
execute if score @s sdk.frame matches 23.. run scoreboard players set @s sdk.frame 22
data modify storage fallendream:knight attack set value {clip:"charge"}
execute store result storage fallendream:knight attack.frame int 1 run scoreboard players get @s sdk.frame
execute if score @s sdk.age matches ..22 as @e[tag=sd.kn.current_rig,distance=0..,limit=1] run function fallendream:boss/knight/blink/apply with storage fallendream:knight attack
execute if score @s sdk.age matches 40.. run function fallendream:boss/knight/start/run
