# ============================================================
# fallendream:equipment/sword/chengxing/second —— 秤星超限的护甲同步入口
# ------------------------------------------------------------
# 【谁调】#manacore:event/second
# 【筛选】只处理"可能带着秤星"的玩家这件事没法便宜地筛（要看主手），
#   所以直接对全体玩家跑 base_sync；它自己第一行就是早退，正常玩家两次
#   items 判定 + 一次比较。
# ============================================================

execute as @a run function fallendream:equipment/sword/chengxing/base_sync
