execute unless data storage sweetdream_floor:run options[0] run return 0
execute store result score #len sd.floor run data get storage sweetdream_floor:run options
scoreboard players remove #len sd.floor 1
execute store result storage sweetdream_floor:run draw.max int 1 run scoreboard players get #len sd.floor
function sweetdream_floor:reward/random with storage sweetdream_floor:run draw
function sweetdream_floor:reward/take_option with storage sweetdream_floor:run draw
