# Repair the old center teleport when reloading an already exhausted floor.
execute store result storage sweetdream_floor:routing anchor.cell int 1 run scoreboard players get #room_anchor sd.floor
function sweetdream_floor:room/doors/recover_anchor with storage sweetdream_floor:routing anchor
data modify storage sweetdream_floor:routing doors set value []
data modify storage sweetdream_floor:routing doors append from storage zx:rogue floor.cells[{present:1b,visited:0b}]
data remove storage sweetdream_floor:routing doors[{kind:"entry"}]
data remove storage sweetdream_floor:routing doors[{kind:"boss"}]
scoreboard players set #door_closed sd.floor 1
execute if data storage sweetdream_floor:routing doors[0] run function sweetdream_floor:room/doors/close_next
data remove storage sweetdream_floor:routing doors
data modify storage sweetdream_floor:run exploration_doors set value 1b
