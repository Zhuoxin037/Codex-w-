# ============================================================
# sweetdream:equipment/armor/fade/second —— 息影·每秒入口
# ------------------------------------------------------------
# 【谁调用它】挂在 #manacore:event/second
# 【管什么】"10 秒没再放技能"的倒计时与兑现。
#   魔力上限 +90 不在这里 -> 走 armor_mana/passive 的统一差值账本。
# ============================================================

function sweetdream:lib/in_bak

execute as @a at @s run function sweetdream:equipment/armor/fade/passive

function sweetdream:lib/in_restore
