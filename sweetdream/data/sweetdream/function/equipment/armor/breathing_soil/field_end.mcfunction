# ============================================================
# sweetdream:equipment/armor/breathing_soil/field_end —— 息土领域收场
# ------------------------------------------------------------
# 术阵本身由 formation 框架按 12 秒自然过期，这里只需要清计时并给一次收束表现
# （★ 不调 formation 的删除：两面都以"12 秒"为准，主动删反而会出现
#   "计时还在、术阵先没了"的错位）。
# ============================================================
scoreboard players reset @s zx.so_ft
execute at @s run particle minecraft:dust{color:[0.4,0.62,0.32],scale:1.6} ~ ~0.2 ~ 2.0 0.1 2.0 0.01 22 normal
execute at @s run playsound minecraft:block.rooted_dirt.step player @a ~ ~ ~ 0.7 0.6
