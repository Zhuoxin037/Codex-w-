function sweetdream_floor:room/read
execute if score #input sd.floor matches 22 run return run function sweetdream_floor:room/store with storage sweetdream_floor:run inspected
function sweetdream_floor:room/select_go with storage sweetdream_floor:run inspected
