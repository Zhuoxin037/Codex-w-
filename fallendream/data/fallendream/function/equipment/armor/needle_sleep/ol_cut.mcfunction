# ============================================================
# fallendream:equipment/armor/needle_sleep/ol_cut —— 超限·针眠：冷却 -1 秒
# ------------------------------------------------------------
# 【执行者】施法者（玩家）
# 【文案】若自身对附有「噬心」的生物造成伤害后，本装备冷却时间 -1 秒。
# 【★ 只减"还没走完的"冷却 ★】zx.ns_cd 存的是"下次可附加噬心的刻", 它 ≤ #now
#   就代表已经可用 —— 这时再减 20 会把它压成负数, 没有任何收益, 只是脏账。
# 【★ 没有节流 ★】文案没写"多久内最多一次", 每一下伤害都减 1 秒。
# ============================================================

execute unless items entity @s armor.head *[custom_data~{zx:["needle_sleep"],ol:"needle_sleep"}] run return 0
execute if score @s zx.ns_cd > #now manacore.meta run scoreboard players remove @s zx.ns_cd 20
