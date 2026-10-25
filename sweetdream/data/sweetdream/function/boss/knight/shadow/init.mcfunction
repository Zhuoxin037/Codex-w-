scoreboard players add #shadow sdk.serial 1
scoreboard players operation @s sdk.serial = #shadow sdk.serial
scoreboard players set @s sdk.age -1
scoreboard players set @s sdk.hit0 0
execute store result storage sweetdream:knight shadow_args.serial int 1 run scoreboard players get @s sdk.serial
execute store result storage sweetdream:knight shadow_args.owner int 1 run scoreboard players get @s sdk.owner
function sweetdream:boss/knight/shadow/uuid
data modify storage sweetdream:knight shadow_args.ghost_uuid set from storage animated_java:gu out
execute on passengers run function sweetdream:boss/knight/shadow/cache_bone
function sweetdream:boss/knight/shadow/save_record with storage sweetdream:knight shadow_args
function sweetdream:boss/knight/shadow/frames/0 with storage sweetdream:knight shadow_args
function sweetdream:boss/knight/shadow/face with storage sweetdream:knight shadow_args
execute at @s on passengers run rotate @s ~ ~
tag @s remove sd.kn.newshadow
particle minecraft:enchant ~ ~1.7 ~ 0.5 1.1 0.5 0.1 16 normal
playsound minecraft:entity.evoker.prepare_attack hostile @a[distance=..24] ~ ~ ~ 0.4 1.5
