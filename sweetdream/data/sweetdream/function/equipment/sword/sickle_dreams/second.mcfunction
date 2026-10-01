# ============================================================
# sweetdream:equipment/sword/sickle_dreams/second —— 每秒入口
# ------------------------------------------------------------
# 【只做一件事】强化攻击的 8 秒锁倒计时。没锁的人完全不参与, 开销为零。
#   (不改 manacore:in arg, 所以不需要 in_bak/in_restore 那对备份。)
# ============================================================

execute as @a[scores={zx.sd_lock=1..}] run scoreboard players remove @s zx.sd_lock 1
