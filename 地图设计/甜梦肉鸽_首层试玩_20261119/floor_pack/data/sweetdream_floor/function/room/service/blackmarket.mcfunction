execute unless score #input sd.floor matches 20 run return 0
execute if items entity @s weapon.mainhand *[minecraft:custom_data~{ol:""}] run return 0
data remove storage sweetdream_floor:run stone
data modify storage sweetdream_floor:run stone.id set from entity @s SelectedItem.components."minecraft:custom_data".zx[0]
execute unless data storage sweetdream_floor:run stone.id run return run tellraw @s {"text":"主手拿着想超限的装备，再选择购买。","color":"yellow"}
function sweetdream_floor:room/service/buy_stone with storage sweetdream_floor:run stone
