# 只对持有寒鸦或正在播放短暂霜光的玩家执行。
execute as @a[tag=zx.cc_model_fx] unless items entity @s weapon.mainhand minecraft:crossbow[minecraft:custom_data~{zx:["cold_crow"]}] run function sweetdream:equipment/bow/cold_crow/model/cancel
execute as @a[tag=zx.cc_model_fx] run scoreboard players add @s zx.cc_fx 1
execute as @a[tag=zx.cc_model_fx,scores={zx.cc_fx=17..}] run function sweetdream:equipment/bow/cold_crow/model/cancel
execute as @a[tag=!test_pending_return] if items entity @s weapon.mainhand minecraft:crossbow[minecraft:custom_data~{zx:["cold_crow"]}] run function sweetdream:equipment/bow/cold_crow/model/mainhand
execute as @a[tag=!test_pending_return] if items entity @s weapon.offhand minecraft:crossbow[minecraft:custom_data~{zx:["cold_crow"]}] run function sweetdream:equipment/bow/cold_crow/model/offhand
