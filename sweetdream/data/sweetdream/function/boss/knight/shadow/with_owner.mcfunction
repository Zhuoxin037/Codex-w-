$execute unless entity $(body_uuid) run return run function sweetdream:boss/knight/shadow/end
$execute unless score $(body_uuid) sdk.hp matches 1.. run return run function sweetdream:boss/knight/shadow/end
$execute unless score $(body_uuid) sdk.state matches 13 run return run function sweetdream:boss/knight/shadow/end
$execute if entity @e[tag=sd.kn.body,tag=zx.stop,scores={sdk.id=$(owner)},distance=..64,limit=1] run return 0
scoreboard players add @s sdk.age 1
execute if score @s sdk.age matches 23.. run return run function sweetdream:boss/knight/shadow/end
execute if score @s sdk.age matches ..6 run function sweetdream:boss/knight/shadow/face with storage sweetdream:knight shadow_args
execute at @s on passengers run rotate @s ~ ~
execute store result storage sweetdream:knight shadow_args.frame int 1 run scoreboard players get @s sdk.age
function sweetdream:boss/knight/shadow/apply with storage sweetdream:knight shadow_args
execute if score @s sdk.age matches 7..22 at @s run function sweetdream:boss/knight/shadow/advance with storage sweetdream:knight shadow_args
