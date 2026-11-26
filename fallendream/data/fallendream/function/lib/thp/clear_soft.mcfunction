# ============================================================
# fallendream:lib/thp/clear_soft —— 账本归零时只撤吸收，不动 zx.thp（set 内部用）
# ------------------------------------------------------------
# 【为什么不直接用 lib/thp/clear】set 走到这里时 @s zx.thp 已经写成 0，再调 clear
#   会多读两次计分项；而且 set 之后还要继续判断"是否 return"，用轻量版更清楚。
# ============================================================

execute if entity @s[tag=zx.thp_on] run attribute @s minecraft:max_absorption modifier remove fallendream:thp_cap
tag @s remove zx.thp_on
effect clear @s minecraft:absorption
scoreboard players set @s zx.thp_end 0
