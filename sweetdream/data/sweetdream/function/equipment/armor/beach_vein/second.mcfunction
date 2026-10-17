# ============================================================
# sweetdream:equipment/armor/beach_vein/second —— 滩纹: 每秒入口
# ------------------------------------------------------------
# 【谁调用它】挂在 #manacore:event/second
# 【为什么对全部玩家跑】护甲加成是**差值**制的账本：只筛穿着的人，脱下那一秒
#   没人执行，那 2 点护甲就永远退不回来（= 穿过一次就永久 +2）。
# 【前后 in_bak / in_restore】下面要走 api/stats/get 与 api/mana/add 改公共输入口，
#   备份/还原是包内惯例（同 armor_mana/second）。
# ============================================================

function sweetdream:lib/in_bak

execute as @a run function sweetdream:equipment/armor/beach_vein/passive

function sweetdream:lib/in_restore
