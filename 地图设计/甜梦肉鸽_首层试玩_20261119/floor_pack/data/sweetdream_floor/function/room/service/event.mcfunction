execute unless score #input sd.floor matches 20..21 run return 0
function sweetdream_floor:room/mark with storage sweetdream_floor:run inspected
execute if data storage sweetdream_floor:run current{variant:1} run return run function sweetdream_floor:room/event/resolve_well
execute if data storage sweetdream_floor:run current{variant:2} run return run function sweetdream_floor:room/event/resolve_clock
function sweetdream_floor:room/event/resolve_traveler
