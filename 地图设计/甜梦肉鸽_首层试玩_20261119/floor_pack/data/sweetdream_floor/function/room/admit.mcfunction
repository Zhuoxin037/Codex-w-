# Visited rooms, the entrance, and the boss room have no exploration cost.
$execute if data storage zx:rogue floor.cells[{cell:$(cell),visited:1b}] run return run scoreboard players set #room_anchor sd.floor $(cell)
$execute if data storage zx:rogue floor.cells[{cell:$(cell),kind:"entry"}] run return run scoreboard players set #room_anchor sd.floor $(cell)
$execute if data storage zx:rogue floor.cells[{cell:$(cell),kind:"boss"}] run return run scoreboard players set #room_anchor sd.floor $(cell)
execute unless score #budget sd.floor matches 1.. run return run function sweetdream_floor:room/reject
scoreboard players remove #budget sd.floor 1
$scoreboard players set #room_anchor sd.floor $(cell)
title @s actionbar [{"text":"剩余探索 ","color":"aqua"},{"score":{"name":"#budget","objective":"sd.floor"}},{"text":"/8","color":"gray"}]
execute if score #budget sd.floor matches 0 run function sweetdream_floor:room/status
