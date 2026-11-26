scoreboard players set #phase sd.floor 1
$function sweetdream_floor:reward/give_go with storage sweetdream_floor:run pool[$(index)]
data remove storage sweetdream_floor:run offers
data remove storage sweetdream_floor:run exact_tier
data remove storage sweetdream_floor:run battle_draw
scoreboard players set #last sd.floor -1
function sweetdream_floor:room/status
