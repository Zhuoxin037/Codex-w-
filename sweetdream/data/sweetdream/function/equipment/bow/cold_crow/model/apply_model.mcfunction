# 可手动调用；正常持有时 tick 会自动迁移旧武器。
execute if items entity @s weapon.mainhand minecraft:crossbow[minecraft:custom_data~{zx:["cold_crow"]}] run function sweetdream:equipment/bow/cold_crow/model/mainhand
execute if items entity @s weapon.offhand minecraft:crossbow[minecraft:custom_data~{zx:["cold_crow"]}] run function sweetdream:equipment/bow/cold_crow/model/offhand
