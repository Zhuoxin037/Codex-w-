execute unless entity @s[tag=sd.kn.feedback_v2] run function sweetdream:boss/knight/reconfigure
tag @s add sd.kn.current_body
execute unless score @s sdk.scd = @s sdk.scd run scoreboard players set @s sdk.scd 100
execute unless score @s sdk.state matches 13 if score @s sdk.protect matches 1.. run function sweetdream:boss/knight/shadow/release
execute store result score @s sdk.hp run data get entity @s Health 1
execute if entity @s[nbt={Health:0.0f}] as @e[tag=sd.kn.current_rig,distance=0..,limit=1] run function sweetdream:boss/knight/death/start
execute if entity @e[tag=sd.kn.current_rig,tag=sd.kn.dead,distance=0..,limit=1] run return run tag @s remove sd.kn.current_body
execute store result storage sweetdream:knight args.id int 1 run scoreboard players get @s sdk.id
function sweetdream:boss/knight/bar_update with storage sweetdream:knight args
execute if entity @s[tag=zx.stop] run tag @e[tag=sd.kn.current_rig,distance=0..,limit=1] add sd.kn.frozen
execute if entity @s[tag=zx.stop] run return run tag @s remove sd.kn.current_body
execute unless data entity @s active_effects[{id:"minecraft:invisibility"}] run effect give @s minecraft:invisibility infinite 0 true
execute if score @s sdk.rest matches 1.. run scoreboard players remove @s sdk.rest 1
execute if score @s sdk.circlecd matches 1.. run scoreboard players remove @s sdk.circlecd 1
execute if score @s sdk.wavecd matches 1.. run scoreboard players remove @s sdk.wavecd 1
execute if score @s sdk.dashcd matches 1.. run scoreboard players remove @s sdk.dashcd 1
execute if score @s sdk.combocd matches 1.. run scoreboard players remove @s sdk.combocd 1
execute if score @s sdk.scd matches 1.. run scoreboard players remove @s sdk.scd 1
execute at @s run function sweetdream:boss/knight/ground/tick
execute at @s run function sweetdream:boss/knight/target/tick
execute at @s run function sweetdream:boss/knight/dispatch
execute at @s rotated ~ 0 positioned ^ ^ ^-0.84375 run tp @e[tag=sd.kn.current_rig,distance=0..,limit=1] ~ ~ ~ ~ 0
tag @e[tag=sd.kn.target,distance=0..] remove sd.kn.target
tag @s remove sd.kn.current_body
