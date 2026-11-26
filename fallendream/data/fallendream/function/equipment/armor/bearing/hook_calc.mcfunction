# @calc: indep — 「阵成」期间技能伤害 +15%（独立乘区）；超限枢的阵成可再叠一份
# ============================================================
# fallendream:equipment/armor/bearing/hook_calc —— 「阵成」的 15% 独立乘区
# ------------------------------------------------------------
# 【谁调用它】#manacore:event/damage_calc（排在 lib/dmg_add_apply 之后）
# 【执行者】施法者（玩家）
# 【★ 为什么乘 r.damage 而不是往加算池写 ★】文案明写"独立乘区" ⇒ 必须乘在**最终**
#   伤害上；加算池是"非独立"的通道加成（口径见 lib/dmg_add_apply 头部）。
#   写法与 glimmer/hook_calc（白光 +30% 独立）逐字同源。
# 【两份来源】
#   · zx.br_zc = 套装（枢+承）的阵成到期刻
#   · zx.pv_zc = 超限「枢」自己的阵成到期刻（2026-11-22）
#   超限枢的文案写"可以和套装和承的「阵成」叠加" ⇒ 两个都在生效时各乘一次(×1.15²)。
# 【★ 不能再"br_zc 不在就 return" ★】那样只穿超限枢时永远进不来。
# ============================================================

execute unless entity @s[type=minecraft:player] run return 0

scoreboard players set #br_on zx.meta 0
execute if score @s zx.br_zc > #now manacore.meta run scoreboard players set #br_on zx.meta 1
execute if score @s zx.pv_zc > #now manacore.meta run scoreboard players add #br_on zx.meta 1
# 超限「承」自己那份阵成(2026-11-23): 满术阵 4 秒触发, 与上面两份叠加
execute if score @s zx.brx_zc > #now manacore.meta run scoreboard players add #br_on zx.meta 1
execute if score #br_on zx.meta matches 0 run return 0

scoreboard players set #mp_src zx.meta 0
execute store result score #mp_src zx.meta run data get storage manacore:out r.damage 1000
scoreboard players operation #mp_mul zx.meta = #br_on zx.meta
scoreboard players set #br_150 zx.meta 150
scoreboard players operation #mp_mul zx.meta *= #br_150 zx.meta
scoreboard players add #mp_mul zx.meta 1000
function fallendream:lib/math/mul_permille
execute store result storage manacore:out r.damage double 0.001 run scoreboard players get #mp_out zx.meta
