# ============================================================
# fallendream:equipment/armor/lvshuang/layer_up —— 这一片霜 +1 档（执行者 = 霜片 marker）
# ------------------------------------------------------------
# 【谁调用它】layer_add（每 0.5 秒一次，只对"玩家脚下那一片"）
# 【上限 3】原文"最高 3 层" ⇒ 到 3 就不再涨。
# 【档位干什么用】frost_tick 里 冰箱时长 = 1 秒 + 每档 1 秒（20 + 20×档 刻）。
# ============================================================

execute if score @s zx.lsh_lv matches 3.. run return 0
scoreboard players add @s zx.lsh_lv 1

particle minecraft:snowflake ~ ~0.05 ~ 0.3 0.02 0.3 0.01 4 normal
execute if score @s zx.lsh_lv matches 3 run particle minecraft:dust{color:[0.62,0.82,1.0],scale:1.3} ~ ~0.06 ~ 0.35 0.03 0.35 0.01 6 normal
