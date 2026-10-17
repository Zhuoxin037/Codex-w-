# ============================================================
# sweetdream:equipment/armor/armor_hp/second —— 「生命值上限 +N」每秒入口
# ------------------------------------------------------------
# 【谁调用它】挂在 #manacore:event/second
# 【它管谁】本包所有"最大生命值 +N"的装备被动（2026-10-15 批 15-3 起）：
#   沸痕(胸甲) +4  —— 后续批次往 passive 里继续加行即可。
# 【★ 为什么不并进 armor_mana ★】那件是"魔力值上限"，账本/属性都不同
#   （max_health 要同时改**面板**与**原版属性 minecraft:max_health**，见 apply）；
#   两件事混一个文件会让"某一秒到底在改哪个上限"读不出来。
# 【★ 必须对全部玩家跑 ★】账本是**差值**制的：只筛穿着的人，脱下那一秒没人执行，
#   那笔上限就永远退不回来（= 穿过一次就永久 +N）。
# 【★ 自己判穿着 ★】passive 被 broadcast 给 @a，第一步就是自己看穿没穿。
# 【为什么前后要 in_bak / in_restore】下面要走 api/stats/add 改公共输入口，
#   备份/还原是包内惯例（同 armor_mana/second）。
# ============================================================

function sweetdream:lib/in_bak

execute as @a run function sweetdream:equipment/armor/armor_hp/passive

function sweetdream:lib/in_restore
