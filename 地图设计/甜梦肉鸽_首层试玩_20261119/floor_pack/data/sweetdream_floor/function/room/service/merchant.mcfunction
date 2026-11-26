execute if score #input sd.floor matches 21 run return run function sweetdream_floor:room/service/supply
execute unless score #input sd.floor matches 20 run return 0
execute unless score #lumen sd.floor matches 2.. run return run tellraw @s {"text":"梦屑不足。","color":"yellow"}
scoreboard players remove #lumen sd.floor 2
function sweetdream_floor:room/mark with storage sweetdream_floor:run inspected
scoreboard players set #tier sd.floor 4
function sweetdream_floor:reward/offer
