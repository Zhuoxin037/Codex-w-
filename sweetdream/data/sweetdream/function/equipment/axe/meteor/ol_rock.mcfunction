# ============================================================
# sweetdream:equipment/axe/meteor/ol_rock —— 超限·大陨石(放大版 item_display)
# ------------------------------------------------------------
# 【谁调用它】ol_big ⑥(每只目标各一颗)
# 【执行位置】被砸中那只所在处
# 【和 rock 的区别】只有两处: 缩放 1.4 → 2.8、影子更大。
#   ★ 高度必须**仍是 7 格 / 4 刻**: rock_tick 里每刻固定 `tp ~ ~-1.75 ~`,
#     改高度会让它停在半空(或穿地)而不会准点炸开。
# 【去重靠"刚出生的那一颗"】出生在目标处 -> 就近 2 格内还带 zx.mt_new 的那一颗
#   就是自己(别的石头要么悬在 y+3.5 以上、要么已经 kill)。
# ============================================================

summon minecraft:item_display ~ ~ ~ {Tags:["zx.mt_rock","zx.mt_new"],item:{id:"minecraft:stick",count:1,components:{"minecraft:item_model":"sweetdream:meteor_rock"}},brightness:{sky:15,block:15},shadow_radius:1.3f,shadow_strength:0.9f,interpolation_duration:0,transformation:{translation:[0.0f,0.0f,0.0f],scale:[2.8f,2.8f,2.8f],left_rotation:[0.0f,0.0f,0.0f,1.0f],right_rotation:[0.0f,0.0f,0.0f,1.0f]}}
execute as @e[type=item_display,tag=zx.mt_new,distance=..2] run scoreboard players set @s zx.mt_rk 4
execute as @e[type=item_display,tag=zx.mt_new,distance=..2] run tp @s ~ ~7 ~
tag @e[type=item_display,tag=zx.mt_new,distance=..2] remove zx.mt_new
