execute unless score #lumen sd.floor matches 1.. run return run tellraw @s {"text":"梦屑不足。","color":"yellow"}
scoreboard players remove #lumen sd.floor 1
function sweetdream_floor:room/mark with storage sweetdream_floor:run inspected
give @s minecraft:golden_apple 2
give @s minecraft:arrow 24
give @s minecraft:cooked_beef 8
function sweetdream_floor:room/status
