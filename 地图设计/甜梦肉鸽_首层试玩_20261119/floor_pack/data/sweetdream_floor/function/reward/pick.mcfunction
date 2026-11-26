scoreboard players remove #input sd.floor 30
execute store result storage sweetdream_floor:run pick.index int 1 run scoreboard players get #input sd.floor
function sweetdream_floor:reward/pick_go with storage sweetdream_floor:run pick
