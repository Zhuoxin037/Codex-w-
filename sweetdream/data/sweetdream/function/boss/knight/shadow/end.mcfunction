tag @s remove sd.kn.shadow
execute on passengers run kill @s
execute store result storage sweetdream:knight shadow_cleanup.serial int 1 run scoreboard players get @s sdk.serial
function sweetdream:boss/knight/shadow/delete_record with storage sweetdream:knight shadow_cleanup
scoreboard players reset @s
kill @s
