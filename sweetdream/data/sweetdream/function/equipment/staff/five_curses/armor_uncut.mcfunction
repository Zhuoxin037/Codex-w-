# ============================================================
# sweetdream:equipment/staff/five_curses/armor_uncut —— 第四世破甲到期: 摘掉
# ------------------------------------------------------------
# 【执行者】带 zx.fcv_4 的那只生物(@s = 目标)
# 【调用者】tick_one(每秒: zx.fcv_t4 扣到 0 时) / clear(世咒整体清除时)
# 【文案】第四世: 护甲及护甲韧性降低 50%, **持续 5 秒**。
# 【★ 为什么要单独一个计时 ★】各层共用的 zx.fcv_t 会被"每次命中"刷回 5 秒 ——
#   玩家在第四世期间继续普攻, 破甲就跟着续命, 远超文案的 5 秒。
#   ⇒ 破甲挂**自己**的 zx.fcv_t4(秒), 由 tick_one 每秒 -1, 归零就摘。
# 【id 固定】sweetdream:fcv4_arm / fcv4_tou —— 与 armor_apply 里加的一致。
# 【幂等】modifier 不存在时 remove 是空操作, 重复调用无害。
# ============================================================

tag @s remove zx.fcv_4
scoreboard players set @s zx.fcv_t4 0
attribute @s minecraft:armor modifier remove sweetdream:fcv4_arm
attribute @s minecraft:armor_toughness modifier remove sweetdream:fcv4_tou
