function sweetdream_floor:room/unmark with storage sweetdream_floor:run current
function sweetdream_floor:combat/open_doors
scoreboard players set #phase sd.floor 1
tellraw @s {"text":"层主未能生成，请在房间中部重试。","color":"red"}
