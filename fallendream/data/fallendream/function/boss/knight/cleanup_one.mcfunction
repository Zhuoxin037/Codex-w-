execute if entity @s[tag=sd.kn.shadow] run return run function fallendream:boss/knight/shadow/end
execute store result storage fallendream:knight cleanup.id int 1 run scoreboard players get @s sdk.waveid
function fallendream:boss/knight/cleanup_record with storage fallendream:knight cleanup
kill @s
