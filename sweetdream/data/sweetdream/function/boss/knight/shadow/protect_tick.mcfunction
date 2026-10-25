execute if score @s sdk.protect matches 1.. run return 0
scoreboard players set @s sdk.resamp -1
execute store result score @s sdk.resamp run data get entity @s active_effects[{id:"minecraft:resistance"}].amplifier
execute if score @s sdk.resamp matches 3.. run return 0
data remove storage sweetdream:knight resistance_backup
data modify storage sweetdream:knight resistance_backup set from entity @s active_effects[{id:"minecraft:resistance"}]
effect give @s minecraft:resistance infinite 3 true
execute if data storage sweetdream:knight resistance_backup run data modify entity @s active_effects[{id:"minecraft:resistance",amplifier:3}].hidden_effect set from storage sweetdream:knight resistance_backup
data remove storage sweetdream:knight resistance_backup
scoreboard players set @s sdk.protect 1
