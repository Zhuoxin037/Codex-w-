# ============================================================
# sweetdream:equipment/bow/cloudtrail/fire_fx —— 「领域同步伤害」的表现
# ------------------------------------------------------------
# 【谁调用它】cloudtrail/fire ④(只在领域内真的圈到了生物时才调)。
# 【执行者】射手(玩家), 但位置由 `at @e[tag=zx.ct_f]` 换成领域中心。
# ============================================================

execute at @e[tag=zx.ct_f,distance=0..,limit=1] run particle minecraft:cloud ~ ~0.3 ~ 3.0 0.2 3.0 0.05 40 normal
execute at @e[tag=zx.ct_f,distance=0..,limit=1] run particle minecraft:end_rod ~ ~0.3 ~ 2.6 0.2 2.6 0.02 16 normal
execute at @e[tag=zx.ct_f,distance=0..,limit=1] run playsound minecraft:entity.player.attack.sweep player @a ~ ~ ~ 0.6 1.4
