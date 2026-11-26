function sweetdream_floor:room/doors/update with storage sweetdream_floor:routing doors[0]
data remove storage sweetdream_floor:routing doors[0]
execute if data storage sweetdream_floor:routing doors[0] run function sweetdream_floor:room/doors/close_next
