execute if score #budget sd.floor matches 1.. run return 0
data modify storage sweetdream_floor:routing next.cell set from storage zx:rogue floor.boss
function sweetdream_floor:room/teleport_by_index with storage sweetdream_floor:routing next
