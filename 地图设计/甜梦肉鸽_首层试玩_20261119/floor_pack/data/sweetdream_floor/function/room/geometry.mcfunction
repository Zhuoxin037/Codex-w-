$scoreboard players set #x sd.floor $(x)
$scoreboard players set #z sd.floor $(z)
$scoreboard players set #radius sd.floor $(radius)
scoreboard players operation #x sd.floor -= #radius sd.floor
scoreboard players operation #z sd.floor -= #radius sd.floor
execute store result storage sweetdream_floor:run inspected.minx int 1 run scoreboard players get #x sd.floor
execute store result storage sweetdream_floor:run inspected.minz int 1 run scoreboard players get #z sd.floor
scoreboard players operation #radius sd.floor += #radius sd.floor
execute store result storage sweetdream_floor:run inspected.width int 1 run scoreboard players get #radius sd.floor
$scoreboard players set #x sd.floor $(x)
$scoreboard players set #z sd.floor $(z)
scoreboard players add #x sd.floor 6
scoreboard players add #z sd.floor 6
execute store result storage sweetdream_floor:run inspected.px int 1 run scoreboard players get #x sd.floor
execute store result storage sweetdream_floor:run inspected.pz int 1 run scoreboard players get #z sd.floor
