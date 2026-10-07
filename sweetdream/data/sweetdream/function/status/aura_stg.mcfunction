# ============================================================
# sweetdream:status/aura_stg —— 「升痕」的常态特效(执行者 = 带升痕的那只)
# ------------------------------------------------------------
# 【要求】各层数要有区别 —— 1 层稀疏、2 层加电火花、3 层最盛并带上升光柱。
# 【配色】天蓝(dust color 取青色系) —— 与圣痕的金色明显区分。
# 【层数从哪读】计分项 zx.stg(1..3)。
# ============================================================

# ---- 1 层: 一小圈天蓝尘 ----
execute if score @s zx.stg matches 1 run particle minecraft:dust{color:[0.35,0.85,1.0],scale:0.9} ~ ~1.0 ~ 0.30 0.30 0.30 0.0 5 normal

# ---- 2 层: 更密 + 电火花 ----
execute if score @s zx.stg matches 2 run particle minecraft:dust{color:[0.35,0.85,1.0],scale:1.1} ~ ~1.0 ~ 0.42 0.40 0.42 0.0 10 normal
execute if score @s zx.stg matches 2 run particle minecraft:electric_spark ~ ~1.0 ~ 0.30 0.30 0.30 0.0 3 normal

# ---- 3 层: 最盛 + 上升光柱(像蓄势待发) ----
execute if score @s zx.stg matches 3.. run particle minecraft:dust{color:[0.55,0.95,1.0],scale:1.3} ~ ~1.0 ~ 0.50 0.55 0.50 0.0 16 normal
execute if score @s zx.stg matches 3.. run particle minecraft:electric_spark ~ ~1.0 ~ 0.42 0.50 0.42 0.0 7 normal
execute if score @s zx.stg matches 3.. run particle minecraft:end_rod ~ ~1.5 ~ 0.18 0.60 0.18 0.01 4 normal
