# ============================================================
# sweetdream:equipment/armor/lethe_shore/second —— 沉溺忘川彼岸的每秒入口
# ------------------------------------------------------------
# 【谁调用它】挂在 #manacore:event/second 上(前置包每秒抛一次, 服务器身份)
# 【内容】每个玩家跑 passive(魔力上限账本 + 残念回魔/到期解除 + 阈值重置窗口)。
# 【攻击计数不在这里】那不是每秒事件, 由进度 lethe_shore_hit 驱动, 见 hit。
# ============================================================

function sweetdream:lib/in_bak

execute as @a at @s run function sweetdream:equipment/armor/lethe_shore/passive

function sweetdream:lib/in_restore
