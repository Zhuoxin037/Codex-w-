scoreboard players set #phase sd.floor 2
scoreboard players set #hard sd.floor 0
execute if score #input sd.floor matches 21 run scoreboard players set #hard sd.floor 1
execute if data storage sweetdream_floor:run current{kind:"elite"} run scoreboard players set #hard sd.floor 1
scoreboard players set #echo sd.floor 0
scoreboard players set #echo_total sd.floor 0
scoreboard players set #echo_combo sd.floor 0
data modify storage sweetdream_floor:run echo_marks set value []
scoreboard players set #door_closed sd.floor 1
function sweetdream_floor:room/doors/update with storage sweetdream_floor:run current
function sweetdream_floor:combat/arena with storage sweetdream_floor:run current
playsound minecraft:block.note_block.bass hostile @s ~ ~ ~ 0.9 0.7
