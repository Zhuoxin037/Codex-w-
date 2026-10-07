# ============================================================
# sweetdream:equipment/armor/eternity/second —— 永恒的每秒入口
# ------------------------------------------------------------
# 【谁调用它】挂在 #manacore:event/second 上(前置包每秒抛一次, 服务器身份)
# 【内容】每个玩家跑 passive(魔力上限 +280 的差值账本)。
# 【"消耗标签补回"不在这里】那条是事件驱动(标签被吃掉的那一刻): 会消耗标签的技能
#   统一调 lib/mark_consume -> lib/mark_take -> eternity/reclaim。
# ============================================================

function sweetdream:lib/in_bak

execute as @a at @s run function sweetdream:equipment/armor/eternity/passive

function sweetdream:lib/in_restore
