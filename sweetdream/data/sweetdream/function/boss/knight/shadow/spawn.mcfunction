scoreboard players set @s sdk.spawned 0
function sweetdream:boss/knight/shadow/uuid
data modify storage sweetdream:knight shadow_args set value {}
data modify storage sweetdream:knight shadow_args.body_uuid set from storage animated_java:gu out
data modify storage sweetdream:knight shadow_args.target_uuid set from storage sweetdream:knight selected.uuid
execute unless data storage sweetdream:knight shadow_args.target_uuid run return 0
scoreboard players set @s sdk.quota 1
execute if score @s sdk.phase matches 2 run scoreboard players set @s sdk.quota 2
execute at @e[tag=sd.kn.target,distance=..30,limit=1] rotated ~ 0 positioned ^-3.889087 ^ ^3.889087 align y run function sweetdream:boss/knight/shadow/try_column
execute if score @s sdk.spawned < @s sdk.quota at @e[tag=sd.kn.target,distance=..30,limit=1] rotated ~ 0 positioned ^3.889087 ^ ^3.889087 align y run function sweetdream:boss/knight/shadow/try_column
execute if score @s sdk.spawned < @s sdk.quota at @e[tag=sd.kn.target,distance=..30,limit=1] rotated ~ 0 positioned ^-3.889087 ^ ^-3.889087 align y run function sweetdream:boss/knight/shadow/try_column
execute if score @s sdk.spawned < @s sdk.quota at @e[tag=sd.kn.target,distance=..30,limit=1] rotated ~ 0 positioned ^3.889087 ^ ^-3.889087 align y run function sweetdream:boss/knight/shadow/try_column
