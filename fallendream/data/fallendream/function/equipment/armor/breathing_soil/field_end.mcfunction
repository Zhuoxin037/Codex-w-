# ============================================================
# fallendream:equipment/armor/breathing_soil/field_end —— 息土领域收场
# ------------------------------------------------------------
# 术阵本身由 formation 框架按 12 秒自然过期，这里只需要清计时并给一次收束表现
# （★ 不调 formation 的删除：两面都以"12 秒"为准，主动删反而会出现
#   "计时还在、术阵先没了"的错位）。
# ============================================================
# 超限·息土(2026-11-22): 领域结束先结算（回 12% / 满血减 10 秒冷却），再清倒计时。
#   ★ 必须在 reset 之前调 ★ 结算里要读 zx.so_ol / zx.so_x,y,z，虽然不读 so_ft,
#     但把它放在"清账"前面读起来也安全（以后有人往里加 so_ft 判断不会踩坑）。
execute if score @s zx.so_ol matches 1 run function fallendream:equipment/armor/breathing_soil/ol_end
scoreboard players reset @s zx.so_ft
execute at @s run particle minecraft:dust{color:[0.4,0.62,0.32],scale:1.6} ~ ~0.2 ~ 2.0 0.1 2.0 0.01 22 normal
execute at @s run playsound minecraft:block.rooted_dirt.step player @a ~ ~ ~ 0.7 0.6
