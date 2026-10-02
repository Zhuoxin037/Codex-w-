# ============================================================
# sweetdream:equipment/armor/iridescent/second —— 异彩的每秒入口
# ------------------------------------------------------------
# 【谁调用它】#manacore:event/second
# 【为什么对全部玩家跑】魔力上限 +220 是"穿上加、脱下减回去"的差值账本:
#   只筛戴头盔的人的话, 摘下那一秒没人执行 passive, +220 永远减不回去。
# 【备份公共输入口】passive 里会读面板(写 manacore:in arg), 见 lib/in_bak。
# ============================================================

function sweetdream:lib/in_bak

execute as @a run function sweetdream:equipment/armor/iridescent/passive

function sweetdream:lib/in_restore
