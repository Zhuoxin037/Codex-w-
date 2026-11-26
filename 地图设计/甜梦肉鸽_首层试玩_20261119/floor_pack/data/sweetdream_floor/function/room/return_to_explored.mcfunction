execute unless score #room_anchor sd.floor matches 0..24 run scoreboard players set #room_anchor sd.floor 10
execute store result storage sweetdream_floor:routing anchor.cell int 1 run scoreboard players get #room_anchor sd.floor
function sweetdream_floor:room/teleport_by_index with storage sweetdream_floor:routing anchor
