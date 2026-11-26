execute unless score #input sd.floor matches 20 run return 0
execute unless score #lumen sd.floor matches 2.. run return run tellraw @s {"text":"梦屑不足。","color":"yellow"}
scoreboard players remove #lumen sd.floor 2
function sweetdream_floor:room/mark with storage sweetdream_floor:run inspected
execute store result score #gamble sd.floor run random value 1..5 sweetdream:rogue
execute if score #gamble sd.floor matches 1..2 run return run tellraw @s {"text":"梦屑落空。","color":"red"}
scoreboard players set #tier sd.floor 5
function sweetdream_floor:reward/offer
