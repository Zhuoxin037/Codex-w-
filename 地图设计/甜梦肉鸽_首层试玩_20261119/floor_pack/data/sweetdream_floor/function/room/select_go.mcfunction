$execute unless data storage sweetdream_floor:run inspected{kind:"entry"} positioned $(x) 81 $(z) unless entity @s[distance=..8] run return run tellraw @s {"text":"走到房间中部再操作。","color":"gray"}
$execute if data storage sweetdream_floor:run rooms[{cell:$(cell)}] run return run tellraw @s {"text":"这间房已用过。","color":"gray"}
execute if data storage sweetdream_floor:run inspected{kind:"entry"} run return 0
execute if data storage sweetdream_floor:run inspected{kind:"boss"} run return run function sweetdream_floor:room/battle
execute if data storage sweetdream_floor:run inspected{kind:"elite"} run return run function sweetdream_floor:room/battle
execute if data storage sweetdream_floor:run inspected{kind:"combat"} run return run function sweetdream_floor:room/battle
$function sweetdream_floor:room/service/$(kind)
