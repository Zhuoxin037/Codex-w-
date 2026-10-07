# 缺魔不积攒冰凌，也不播放本发强化霜光。
function sweetdream:equipment/bow/cold_crow/model/cancel
execute if items entity @s weapon.mainhand minecraft:crossbow[minecraft:custom_data~{zx:["cold_crow"]}] run function sweetdream:equipment/bow/cold_crow/model/mainhand
