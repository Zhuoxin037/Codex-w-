function sweetdream_floor:room/read
data modify storage sweetdream_floor:run encounter set from storage sweetdream_floor:run inspected
scoreboard players set #door_closed sd.floor 1
function sweetdream_floor:room/doors/update with storage sweetdream_floor:run encounter
playsound minecraft:block.wooden_door.close block @s ~ ~ ~ 0.7 0.65
