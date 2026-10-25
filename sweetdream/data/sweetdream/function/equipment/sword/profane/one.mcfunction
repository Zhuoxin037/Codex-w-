# ============================================================
# sweetdream:equipment/sword/profane/one —— 剖线单目标结算（@s = 被命中的生物）
# ------------------------------------------------------------
# 有「噬心」→ one_shixin（清噬心 + ×8 档 + 2 格内半伤）
# 没有      → one_plain（×5 档）
# 伤害值、施法者 UUID 全在 zx:work pf 里（由 cast 预结算），这里只取用。
# ============================================================
execute if entity @s[tag=zx.status.shixin] run return run function sweetdream:equipment/sword/profane/one_shixin
execute unless entity @s[tag=zx.status.shixin] run function sweetdream:equipment/sword/profane/one_plain
