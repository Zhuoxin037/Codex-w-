# ============================================================
# sweetdream:equipment/tool/mana_pump/second —— 体外魔力泵的每秒入口
# ------------------------------------------------------------
# 【谁调用它】挂在 #manacore:event/second 上(前置包每秒抛一次, 服务器身份)
# 【内容】每个玩家跑 passive(魔力上限 +120 的差值账本)。
# 【为什么没有别的】「体外魔力泵」文案只有一条: 最大魔力值 +120。纯被动账本。
# ============================================================

function sweetdream:lib/in_bak

execute as @a at @s run function sweetdream:equipment/tool/mana_pump/passive

function sweetdream:lib/in_restore
