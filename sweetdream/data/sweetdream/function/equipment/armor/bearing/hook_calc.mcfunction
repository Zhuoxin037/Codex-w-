# @calc: indep — 套装「阵成」期间技能伤害 +15%（独立乘区）
# ============================================================
# sweetdream:equipment/armor/bearing/hook_calc —— 「阵成」的 15% 独立乘区
# ------------------------------------------------------------
# 【谁调用它】#manacore:event/damage_calc（排在 lib/dmg_add_apply 之后）
# 【执行者】施法者（玩家）
# 【★ 为什么乘 r.damage 而不是往加算池写 ★】文案明写"独立乘区" ⇒ 必须乘在**最终**
#   伤害上；加算池是"非独立"的通道加成（口径见 lib/dmg_add_apply 头部）。
#   写法与 glimmer/hook_calc（白光 +30% 独立）逐字同源。
# 【★ 只在阵成期间 ★】zx.br_zc = 阵成的到期刻；`> #now` 表示还在生效。
# ============================================================

execute unless entity @s[type=minecraft:player] run return 0
execute unless score @s zx.br_zc > #now manacore.meta run return 0

scoreboard players set #brc zx.meta 0
execute store result score #brc zx.meta run data get storage manacore:out r.damage 1000
scoreboard players set #brk zx.meta 115
function manacore:internal/damage/mul_pct {src:"#brc",mul:"#brk",obj:"zx.meta"}
execute store result storage manacore:out r.damage double 0.001 run scoreboard players get #mul_out zx.meta
