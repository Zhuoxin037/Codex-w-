execute unless score #input sd.floor matches 20..21 run return 0
execute unless score #lumen sd.floor matches 1.. run return run tellraw @s {"text":"梦屑不足。","color":"yellow"}
scoreboard players remove #lumen sd.floor 1
function sweetdream_floor:room/mark with storage sweetdream_floor:run inspected
execute if score #input sd.floor matches 20 run function sweetdream:upgrade/item/mana_up_a
execute if score #input sd.floor matches 21 run function sweetdream:upgrade/item/harden_a
tellraw @s {"text":"石头放主手，要强化的装备放副手，右键使用。","color":"aqua"}
