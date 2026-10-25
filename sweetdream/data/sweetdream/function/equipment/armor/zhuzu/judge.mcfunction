# ============================================================
# sweetdream:equipment/armor/zhuzu/judge —— 1.5 秒等满了，判定"到底站没站住"
# ------------------------------------------------------------
# 【执行者】玩家
# 【成立】zx.st_n >= 30（连续静止 1.5 秒）→ 展开领域
# 【不成立】这 1.5 秒里动过 → 什么都不发生（白等一次，不消耗冷却）
# ============================================================
scoreboard players set @s zx.zz_w 0
scoreboard players set @s zx.zz_t 0
execute if score @s zx.st_n matches 30.. run function sweetdream:equipment/armor/zhuzu/open
