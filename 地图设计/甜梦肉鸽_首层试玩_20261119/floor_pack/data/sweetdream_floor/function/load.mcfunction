scoreboard objectives add sd.floor dummy
scoreboard objectives add sd.floor_cmd trigger
scoreboard objectives add sd.floor_death deathCount
execute unless score #phase sd.floor matches 0.. run scoreboard players set #phase sd.floor 0
execute unless score #serial sd.floor matches 0.. run scoreboard players set #serial sd.floor 0
function sweetdream_floor:pool/load
execute in minecraft:overworld unless data storage sweetdream_floor:run {lobby:1b} run function sweetdream_floor:lobby/build
