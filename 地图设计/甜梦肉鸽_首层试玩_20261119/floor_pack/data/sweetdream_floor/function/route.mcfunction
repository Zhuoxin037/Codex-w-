scoreboard players operation #input sd.floor = @s sd.floor_cmd
scoreboard players set @s sd.floor_cmd 0
scoreboard players enable @s sd.floor_cmd
execute if score #input sd.floor matches 3 run return run function sweetdream_floor:lobby/back
execute if entity @s[tag=sd.floor_run] run return run function sweetdream_floor:run/route
execute if score #input sd.floor matches 1 if entity @s[tag=!sd.floor_tutorial] run return run function sweetdream_floor:lobby/menu
execute if score #input sd.floor matches 2 run return run function sweetdream_floor:tutorial/enter
execute if score #input sd.floor matches 10..14 if entity @s[tag=!sd.floor_tutorial] run return run function sweetdream_floor:run/start
