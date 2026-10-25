execute if entity @s[tag=sd.kn.shadow] run return run function sweetdream:boss/knight/shadow/end
execute store result storage sweetdream:knight cleanup.id int 1 run scoreboard players get @s sdk.waveid
function sweetdream:boss/knight/cleanup_record with storage sweetdream:knight cleanup
kill @s
