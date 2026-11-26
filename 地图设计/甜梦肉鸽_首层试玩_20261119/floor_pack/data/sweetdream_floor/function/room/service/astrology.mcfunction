execute unless score #input sd.floor matches 20..21 run return 0
function sweetdream_floor:room/mark with storage sweetdream_floor:run inspected
execute if score #input sd.floor matches 20 run scoreboard players set #boon sd.floor 1
execute if score #input sd.floor matches 21 run scoreboard players set #boon sd.floor 2
tellraw @s {"text":"已获得本局天赋。","color":"light_purple"}
