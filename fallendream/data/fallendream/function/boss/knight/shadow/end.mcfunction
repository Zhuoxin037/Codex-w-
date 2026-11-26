tag @s remove sd.kn.shadow
execute on passengers run kill @s
execute store result storage fallendream:knight shadow_cleanup.serial int 1 run scoreboard players get @s sdk.serial
function fallendream:boss/knight/shadow/delete_record with storage fallendream:knight shadow_cleanup
scoreboard players reset @s
kill @s
