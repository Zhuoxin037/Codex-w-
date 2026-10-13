# 切走物品仍按真实服务器时钟收尾，重新拿回不会卡在施法帧。
execute if entity @s[nbt={Health:0.0f}] run return run function sweetdream:equipment/axe/sacred_relic/visual/cancel
execute unless score @s zx.srv_start matches -2147483648.. run return run function sweetdream:equipment/axe/sacred_relic/visual/cancel
scoreboard players operation #sr_age zx.srv_frame = #now manacore.meta
scoreboard players operation #sr_age zx.srv_frame -= @s zx.srv_start
execute if score #sr_age zx.srv_frame matches ..-1 run return run function sweetdream:equipment/axe/sacred_relic/visual/cancel
execute if score #sr_age zx.srv_frame matches 49.. run function sweetdream:equipment/axe/sacred_relic/visual/cancel
