$execute unless data storage sweetdream_floor:run offers[$(index)] run return 0
$function sweetdream_floor:pool/filter with storage sweetdream_floor:run offers[$(index)]
execute unless data storage sweetdream_floor:run pool[0] run return 0
execute store result score #len sd.floor run data get storage sweetdream_floor:run pool
scoreboard players remove #len sd.floor 1
execute store result storage sweetdream_floor:run draw.max int 1 run scoreboard players get #len sd.floor
function sweetdream_floor:reward/random with storage sweetdream_floor:run draw
function sweetdream_floor:reward/give with storage sweetdream_floor:run draw
