# ============================================================
# sweetdream:equipment/armor/blaze_armor/second —— 焱·每秒入口
# ------------------------------------------------------------
# 【谁调用它】挂在 #manacore:event/second
# 【管什么】常态抗火 + 视为金甲(让附近的猪灵不把你当敌人)。
#   魔力上限 +100 不在这里 —— 走 armor_mana/passive 的统一差值账本。
#   "攻击自身的生物..."/ 是受伤触发, 见 blaze_armor/hurt(进度驱动)。
# ============================================================

execute as @a at @s run function sweetdream:equipment/armor/blaze_armor/passive
