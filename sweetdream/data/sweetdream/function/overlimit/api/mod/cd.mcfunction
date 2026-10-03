# ============================================================
# sweetdream:overlimit/api/mod/cd —— arg.cooldown_seconds x (1 + 超限冷却)
# ------------------------------------------------------------
# 【为什么用 x1000】冷却常有半步(50 x1.25 = 62.5 秒), 只留整数位会变成 62 ——
#   差 0.5 秒玩家看不出来, 但和 lore 写的数就对不上了, 干脆保住小数。
# 【出参】只改 manacore:in arg.cooldown_seconds
# ============================================================

scoreboard players set #ol_v zx.meta 0
execute store result score #ol_v zx.meta run data get storage manacore:in arg.cooldown_seconds 1000
scoreboard players set #ol_p zx.meta 100
scoreboard players operation #ol_p zx.meta += #ol_c zx.meta
scoreboard players operation #ol_v zx.meta *= #ol_p zx.meta
scoreboard players operation #ol_v zx.meta /= #100 zx.meta
execute store result storage manacore:in arg.cooldown_seconds double 0.001 run scoreboard players get #ol_v zx.meta
