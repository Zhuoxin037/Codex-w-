# 仅在 shot 扣费成功并结算冰凌后调用；读取原函数保留的本发 #tier。
function sweetdream:equipment/bow/cold_crow/model/cancel
execute if score #tier zx.meta matches 4 run scoreboard players set @s zx.cc_fx 1
execute if score @s zx.cc_fx matches 1 run tag @s add zx.cc_model_fx
execute if items entity @s weapon.mainhand minecraft:crossbow[minecraft:custom_data~{zx:["cold_crow"]}] run function sweetdream:equipment/bow/cold_crow/model/mainhand
